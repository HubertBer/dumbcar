package projekt
import rl "vendor:raylib"
import "learning"

Car :: struct {
    pos : rl.Vector2,
    speed : f32,
    rotation : f32,
    dead : bool,
    on_track : bool,
    p_now : int,
}

draw_car :: proc(car : Car, track, track_in, track_out : Map($N), color : rl.Color = rl.BLUE) {
    color := color
    if !car.on_track {
        color = rl.RED
    }
    rl.DrawRectanglePro(carRect(car), rl.Vector2{CAR_LENGTH / 2, CAR_WIDTH / 2}, car.rotation, color)
    rl.DrawCircleV(car.pos, 5, rl.BLACK)

    _, hit_points, hits := raycast_sensors(car, track, track_in, track_out)
    ray_angles := RAY_ANGLES

    for i in 0..<5 {
        if hits[i] {
            rl.DrawCircleV(hit_points[i], 4, rl.RED)
            rl.DrawLineV(car.pos, hit_points[i], rl.GRAY)
        } else {
            angle := (car.rotation + ray_angles[i]) * rl.DEG2RAD
            dir := rl.Vector2Rotate(rl.Vector2{1, 0}, angle)
            ray_end := car.pos + dir * MAX_RAY_LEN
            rl.DrawLineV(car.pos, ray_end, rl.LIGHTGRAY)
        }
    }

    rl.DrawCircleV(track.points[car.p_now % len(track.points)], 10, rl.YELLOW)
}

carRect :: proc(car : Car) -> rl.Rectangle {
    return rl.Rectangle{
        car.pos.x,
        car.pos.y,
        CAR_LENGTH,
        CAR_WIDTH,
    }
}

car_on_track :: proc(car : Car, track_in, track_out : Map($N)) -> bool {
    i := N + car.p_now
    M := N
    poly := [6]rl.Vector2{
        track_in.points[(i - 1) % M],
        track_in.points[(i) % M],
        track_in.points[(i + 1) % M],
        track_out.points[(i + 1) % M],
        track_out.points[(i) % M],
        track_out.points[(i - 1) % M],
    }
    poly2 := [6]rl.Vector2{
        track_in.points[(i + 1) % M],
        track_in.points[(i + 2) % M],
        track_in.points[(i + 3) % M],
        track_out.points[(i + 3) % M],
        track_out.points[(i + 2) % M],
        track_out.points[(i + 1) % M],
    }
    poly3 := [6]rl.Vector2{
        track_in.points[(i - 3 + M) % M],
        track_in.points[(i - 2 + M) % M],
        track_in.points[(i - 1 + M) % M],
        track_out.points[(i - 1 + M) % M],
        track_out.points[(i - 2 + M) % M],
        track_out.points[(i - 3 + M) % M],
    }

    return rl.CheckCollisionPointPoly(car.pos, &poly[0], 6) || 
        rl.CheckCollisionPointPoly(car.pos, &poly2[0], 6) ||
        rl.CheckCollisionPointPoly(car.pos, &poly3[0], 6)

}

// car_on_track :: proc(car : Car, track : Map($N)) -> bool {
//     for i in 1..<(N + 1) {
//         p0 := track.points[(i - 1) % N]
//         p1 := track.points[i % N]

//         perp := rl.Vector2Rotate(rl.Vector2Normalize(p1 - p0), 90)
//         points : [4]rl.Vector2 = {
//             p0 + perp * TRACK_WIDTH / 2,
//             p0 - perp * TRACK_WIDTH / 2,
//             p1 - perp * TRACK_WIDTH / 2,
//             p1 + perp * TRACK_WIDTH / 2,
//         }

//         if rl.CheckCollisionPointPoly(car.pos, &points[0], len(points)) || 
//             rl.Vector2Length(car.pos - p0) < TRACK_WIDTH / 2 ||
//             rl.Vector2Length(car.pos - p1) < TRACK_WIDTH / 2 {
//             return true
//         }
//     }
    
//     return false
// }

one_car_logic :: proc(car: ^Car, logic: learning.Neural($K), track: Map($M), track_in: Map(M), track_out: Map(M)){
    rays, _, _ := raycast_sensors(car^, track, track_in, track_out)
    
    when LEARN_ONE_MAP {
        input : [2]f64
        car_pos := sim.cars[i].pos
        input.x = f64(car_pos.x)
        input.y = f64(car_pos.y)

    } else when COMPASS {
        input : [RAY_COUNT + 7]f64
        p_now := car.p_now + 1
        vec := track.points[p_now % len(track.points)] - car.pos
        angle := car.rotation * rl.DEG2RAD
        dir := rl.Vector2Rotate(rl.Vector2{1, 0}, angle)
        
        next_point := track.points[p_now % len(track.points)]
        car_pos := car.pos

        dif_angle := rl.Vector2Angle(dir, next_point - car_pos)
        input[RAY_COUNT + 1] = f64(dif_angle)
        // input[RAY_COUNT + 1] = f64(vec.x) / MAX_SPEED
        // input[RAY_COUNT + 2] = f64(vec.y) / MAX_SPEED
        // input[RAY_COUNT + 3] = f64(sim.cars[i].pos.x) / 2000
        // input[RAY_COUNT + 4] = f64(sim.cars[i].pos.y) / 2000
        // input[RAY_COUNT + 5] = f64(dir.x)
        // input[RAY_COUNT + 6] = f64(dir.y)
        // input[RAY_COUNT + 3] = f64(dir.x)
        // input[RAY_COUNT + 4] = f64(dir.y)
    } else {
        input : [RAY_COUNT + 1]f64
    }

    when !LEARN_ONE_MAP{
        for j in 0..<RAY_COUNT {
            input[j] = rays[j]
        }
        input[RAY_COUNT] = f64(car.speed) / f64(MAX_SPEED)
    }


    dv, dr := learning.compute(logic, input[:])
    // dv = 2 * dv - 1
    // dr = 2 * dr - 1
    
    car.speed += dv * ACC * PHYSICS_DT
    car.speed = clamp(car.speed, MIN_SPEED, MAX_SPEED)
    car.rotation += dr * ROTATION_SPEED * PHYSICS_DT
}

car_logic :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M), lastHeura: bool = false) {

    n := N if !lastHeura else N-1

    for i in 0..<n {
        one_car_logic(&sim.cars[i], logic,  sim.track, sim.track_in, sim.track_out)
    }
}