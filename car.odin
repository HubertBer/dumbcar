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

draw_car :: proc(car : Car, track, track_in, track_out : Map($N)) {
    color := rl.BLUE
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
    i := MAP_SIZE + car.p_now
    M := MAP_SIZE
    poly := [6]rl.Vector2{
        track_in.points[(i - 1) % M],
        track_in.points[(i) % M],
        track_in.points[(i + 1) % M],
        track_out.points[(i + 1) % M],
        track_out.points[(i) % M],
        track_out.points[(i - 1) % M],
    }

    return rl.CheckCollisionPointPoly(car.pos, &poly[0], 6)
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

car_logic :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M), track_in, track_out : Map(K)) {
    for i in 0..<N {
        rays, _, _ := raycast_sensors(sim.cars[i], sim.track, track_in, track_out)
        input := [RAY_COUNT + 1]f64{0, 0, 0, 0, 0, f64(sim.cars[i].speed)}
        for j in 0..<RAY_COUNT {
            input[j] = rays[j]
        }
        input[RAY_COUNT] = f64(sim.cars[i].speed) / f64(MAX_SPEED)
        
        dv, dr := learning.compute(logic, input[:])
        sim.cars[i].speed += dv * ACC * PHYSICS_DT
        sim.cars[i].speed = clamp(sim.cars[i].speed, -MAX_SPEED, MAX_SPEED)
        sim.cars[i].rotation += dr * ROTATION_SPEED * PHYSICS_DT
    }
}