package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "core:sort"
import "core:math"
import "core:math/rand"

MAX_SPEED :: 500
ACC :: 1000.0

// IN DEGREES 
ROTATION_SPEED :: 500.0
PHYSICS_DT :: 1.0/60.0
CAR_WIDTH :: 10.0
CAR_LENGTH :: 30.0
TRACK_WIDTH :: 100

SHOW_SPEED :: 0.1

// SIMULATION CONSTANTS
SIM_DURATION :: 8

// RAY CONSTANTS
MAX_RAY_LEN :: 200.0
RAY_ANGLES :: [5]f32{90, 45, 0, -45, -90}

// RAYS STUFF

// raycast_input :: proc(car: Car, track: Map($N)) -> [5]f64 {
//     results: [5]f64
//     ray_angles := RAY_ANGLES

//     for i in 0..<5 {
//         angle := (car.rotation + ray_angles[i]) * rl.DEG2RAD
//         dir := rl.Vector2Rotate(rl.Vector2{1, 0}, angle)
//         ray_end := car.pos + dir * MAX_RAY_LEN

//         min_dist : f32 = MAX_RAY_LEN

//         // Check against track edges
//         for j in 0..<N {
//             p0 := track.points[j]
//             p1 := track.points[(j + 1) % N]
//             edge_dir := rl.Vector2Normalize(p1 - p0)
//             normal := rl.Vector2Rotate(edge_dir, 90)

//             // Left and right boundaries
//             left0 := p0 + normal * (TRACK_WIDTH / 2)
//             left1 := p1 + normal * (TRACK_WIDTH / 2)
//             right0 := p0 - normal * (TRACK_WIDTH / 2)
//             right1 := p1 - normal * (TRACK_WIDTH / 2)

//             // Segment-segment intersection (returns point or not)
//             hit, point := segment_intersect(car.pos, ray_end, left0, left1)
//             if hit {
//                 d := rl.Vector2Length(point - car.pos)
//                 if d < min_dist {
//                     min_dist = d
//                 }
//             }

//             hit, point = segment_intersect(car.pos, ray_end, right0, right1)
//             if hit {
//                 d := rl.Vector2Length(point - car.pos)
//                 if d < min_dist {
//                     min_dist = d
//                 }
//             }
//         }

//         // Check against corner circles
//         for point in track.points {
//             hit := ray_circle_intersect(car.pos, ray_end, point, TRACK_WIDTH / 2)
//             if hit < min_dist {
//                 min_dist = hit
//             }
//         }

//         results[i] = f64(1.0 - clamp(min_dist / MAX_RAY_LEN, 0, 1))
//     }

//     return results
// }

angle_between := proc(center: rl.Vector2, a: rl.Vector2, b: rl.Vector2, test: rl.Vector2) -> bool {
    // Convert to angles in radians
    angle_a := math.atan2(a.y - center.y, a.x - center.x)
    angle_b := math.atan2(b.y - center.y, b.x - center.x)
    angle_test := math.atan2(test.y - center.y, test.x - center.x)

    // Normalize all to [0, 2π]
    normalize := proc(x: f64) -> f64 {
        return math.mod(x + 2*math.PI, 2*math.PI)
    }
    angle_a = f32(normalize(f64(angle_a)))
    angle_b = f32(normalize(f64(angle_b)))
    angle_test = f32(normalize(f64(angle_test)))

    // Ensure angle_b > angle_a
    if angle_b < angle_a {
        angle_b += 2 * math.PI
    }

    if angle_test < angle_a {
        angle_test += 2 * math.PI
    }

    return angle_test >= angle_a && angle_test <= angle_b
}


raycast_input :: proc(car: Car, track: Map($N)) -> ([5]f64, [5]rl.Vector2, [5]bool) {
    results: [5]f64
    hit_points: [5]rl.Vector2
    hits: [5]bool
    ray_angles := RAY_ANGLES

    for i in 0..<5 {
        angle := (car.rotation + ray_angles[i]) * rl.DEG2RAD
        dir := rl.Vector2Rotate(rl.Vector2{1, 0}, angle)
        ray_end := car.pos + dir * MAX_RAY_LEN

        min_dist : f32 = MAX_RAY_LEN
        hit_pos := ray_end
        hit := false

        // Check against track edges
        for j in 0..<N {
            p0 := track.points[j]
            p1 := track.points[(j + 1) % N]
            edge_dir := rl.Vector2Normalize(p1 - p0)
            normal := rl.Vector2Rotate(edge_dir, 90)

            extend_len : f32 = 20.0
            p0_ext := p0 - edge_dir * extend_len
            p1_ext := p1 + edge_dir * extend_len

            left0 := p0 + normal * (TRACK_WIDTH / 2)
            left1 := p1 + normal * (TRACK_WIDTH / 2)
            right0 := p0 - normal * (TRACK_WIDTH / 2)
            right1 := p1 - normal * (TRACK_WIDTH / 2)

            test_edges := [2][2]rl.Vector2{
                {left0, left1},
                {right0, right1},
            }

            for pair in test_edges {
                ok, point := segment_intersect(car.pos, ray_end, pair[0], pair[1])
                if ok {
                    d := rl.Vector2Length(point - car.pos)
                    if d < min_dist {
                        min_dist = d
                        hit_pos = point
                        hit = true
                    }
                }
            }
        }

        // // Check against corner circles
        // for point in track.points {
        //     d := ray_circle_intersect(car.pos, ray_end, point, TRACK_WIDTH / 2)
        //     if d < min_dist {
        //         hit_pos = car.pos + dir * d
        //         min_dist = d
        //         hit = true
        //     }
        // }

        results[i] = f64(1.0 - clamp(min_dist / MAX_RAY_LEN, 0, 1))
        hit_points[i] = hit_pos
        hits[i] = hit
    }

    return results, hit_points, hits
}


segment_intersect :: proc(p1, p2, q1, q2: rl.Vector2) -> (bool, rl.Vector2) {
    s1 := p2 - p1
    s2 := q2 - q1

    denom := -s2.x * s1.y + s1.x * s2.y
    if denom == 0 {
        return false, rl.Vector2{}
    }

    s := (-s1.y * (p1.x - q1.x) + s1.x * (p1.y - q1.y)) / denom
    t := ( s2.x * (p1.y - q1.y) - s2.y * (p1.x - q1.x)) / denom

    if s >= 0 && s <= 1 && t >= 0 && t <= 1 {
        intersect := p1 + s1 * t
        return true, intersect
    }

    return false, rl.Vector2{}
}

ray_circle_intersect :: proc(p1, p2: rl.Vector2, center: rl.Vector2, radius: f32) -> f32 {
    d := p2 - p1
    f := p1 - center

    a := rl.Vector2DotProduct(d, d)
    b := 2 * rl.Vector2DotProduct(f, d)
    c := rl.Vector2DotProduct(f, f) - radius * radius

    disc := b*b - 4*a*c
    if disc < 0 {
        return MAX_RAY_LEN
    }

    sqrt_disc := math.sqrt(disc)
    t1 := (-b - sqrt_disc) / (2*a)
    t2 := (-b + sqrt_disc) / (2*a)

    if t1 >= 0 && t1 <= 1 {
        return rl.Vector2Length(d * t1)
    }
    if t2 >= 0 && t2 <= 1 {
        return rl.Vector2Length(d * t2)
    }

    return MAX_RAY_LEN
}

// RAYS END







Map :: struct($N : int){
    points : [N]rl.Vector2
}

DECA_MAP :: Map(10){
    [10]rl.Vector2{
        rl.Vector2{700.0, 400.0},
        rl.Vector2{642.7, 576.3},
        rl.Vector2{509.0, 690.2},
        rl.Vector2{340.0, 726.6},
        rl.Vector2{184.5, 676.3},
        rl.Vector2{100.0, 550.0},
        rl.Vector2{100.0, 400.0},
        rl.Vector2{157.3, 223.7},
        rl.Vector2{291.0, 109.8},
        rl.Vector2{460.0, 73.4},
    }
}

HEX_MAP :: Map(6){
    [6]rl.Vector2{
        rl.Vector2{473.2, 200.0},
        rl.Vector2{400.0, 73.2},
        rl.Vector2{200.0, 73.2},
        rl.Vector2{126.8, 200.0},
        rl.Vector2{200.0, 426.8},
        rl.Vector2{400.0, 426.8},
    }
} 

ZIGZAG_MAP :: Map(23){
    [23]rl.Vector2{
        rl.Vector2{800.0, 200.0},
        rl.Vector2{700.0, 400.0},
        rl.Vector2{800.0, 600.0},
        rl.Vector2{700.0, 800.0},
        rl.Vector2{800.0, 1000.0},
        rl.Vector2{700.0, 1200.0},

        rl.Vector2{900.0, 1300.0},
        rl.Vector2{1100.0, 1200.0},
        rl.Vector2{1300.0, 1300.0},
        rl.Vector2{1500.0, 1200.0},
        rl.Vector2{1700.0, 1300.0},
        rl.Vector2{1800.0, 1200.0},

        rl.Vector2{1900.0, 1000.0},
        rl.Vector2{1800.0, 800.0},
        rl.Vector2{1900.0, 600.0},
        rl.Vector2{1800.0, 400.0},
        rl.Vector2{1900.0, 200.0},
        rl.Vector2{1800.0, 200.0},

        rl.Vector2{1600.0, 100.0},
        rl.Vector2{1400.0, 200.0},
        rl.Vector2{1200.0, 100.0},
        rl.Vector2{1000.0, 200.0},
        rl.Vector2{800.0, 100.0},
    }
}

THE_MAP :: HEX_MAP
MAP_SIZE :: 6

Car :: struct {
    pos : rl.Vector2,
    speed : f32,
    rotation : f32,
    dead : bool,
    on_track : bool,
    p_now : int,
}

test :: proc(arr : ^[10]f32) {
    fmt.printfln("{}", arr)
    fmt.printfln("{}", arr^)
    arr^ = arr^ + arr^
    fmt.printfln("{}", arr^)
}

Simulation :: struct($N : u32) {
    cars : [N]Car,
    track : Map(MAP_SIZE), 
}

carRect :: proc(car : Car) -> rl.Rectangle {
    return rl.Rectangle{
        car.pos.x,
        car.pos.y,
        CAR_LENGTH,
        CAR_WIDTH,
    }
}

draw_car :: proc(car : Car, zubr_texture: rl.Texture2D) {
    scale : f32 = 0.2 // Smaller value for a smaller car
    dest := rl.Rectangle{
        car.pos.x,
        car.pos.y,
        f32(zubr_texture.width) * scale,
        f32(zubr_texture.height) * scale,
    }
    origin := rl.Vector2{f32(zubr_texture.width) * scale / 2, f32(zubr_texture.height) * scale / 2}
    rl.DrawTexturePro(zubr_texture, rl.Rectangle{0, 0, f32(zubr_texture.width), f32(zubr_texture.height)}, dest, origin, car.rotation, rl.WHITE)
}


// draw_car :: proc(car : Car) {
//     color := rl.BLUE
//     if !car.on_track {
//         color = rl.RED
//     } 
//     rl.DrawRectanglePro(carRect(car), rl.Vector2{CAR_LENGTH / 2, CAR_WIDTH / 2}, car.rotation, color)
//     rl.DrawCircleV(car.pos, 5, rl.BLACK)
// }

car_on_track :: proc(car : Car, track : Map($N)) -> bool {
    for i in 1..<(N + 1) {
        p0 := track.points[(i - 1) % N]
        p1 := track.points[i % N]

        perp := rl.Vector2Rotate(rl.Vector2Normalize(p1 - p0), 90)
        points : [4]rl.Vector2 = {
            p0 + perp * TRACK_WIDTH / 2,
            p0 - perp * TRACK_WIDTH / 2,
            p1 - perp * TRACK_WIDTH / 2,
            p1 + perp * TRACK_WIDTH / 2,
        }

        if rl.CheckCollisionPointPoly(car.pos, &points[0], len(points)) || 
            rl.Vector2Length(car.pos - p0) < TRACK_WIDTH / 2 ||
            rl.Vector2Length(car.pos - p1) < TRACK_WIDTH / 2 {
            return true
        }
    }
    
    return false
}

mark_dead :: proc(sim : ^Simulation($N)) {
    for &car in sim.cars {
        if !car_on_track(car, sim.track) {
            car.dead = true
            car.on_track = false
        } else {
            car.on_track = true
        }
    }
}

simulation_simple :: proc() -> Simulation(1) {
    return Simulation(1){
        [1]Car{
            Car{
                THE_MAP.points[0],
                0,
                -120,
                // 110,
                // 0,
                // 0,
                false,
                false,
                0
            }
        },
        THE_MAP
    }
}

// simulation_step :: proc(sim : ^Simulation) {
//     for &car in sim.cars {
//         car.prevPos = car.pos
//         // car.rotation += ROTATION_SPEED * PHYSICS_DT
//         // car.pos += car.speed * PHYSICS_DT * rl.Vector2Rotate(rl.Vector2{1, 0},  90-car.rotation)
//         car.pos += car.speed * PHYSICS_DT * rl.Vector2Rotate(rl.Vector2{1, 0}, -car.rotation)
//     }
// }

simulation_step :: proc(sim : ^Simulation($N)) {
    for &car in sim.cars {
        if car.dead {
            continue
        }

        next_p := (car.p_now + 1) % len(sim.track.points)
        dist := rl.Vector2Length(car.pos - sim.track.points[next_p])
        if dist <= TRACK_WIDTH / 2 {
            car.p_now = next_p
        }

        forward := rl.Vector2Rotate(rl.Vector2{1, 0}, car.rotation * rl.DEG2RAD)
        car.pos += forward * car.speed * PHYSICS_DT
        // car.pos += forward * MAX_SPEED * PHYSICS_DT
    }

    mark_dead(sim)
}

user_input :: proc(sim : ^Simulation($N)) {
    car := &sim.cars[0]

    if car.dead {
        return
    }

    dv : f32 = 0.0
    if rl.IsKeyDown(rl.KeyboardKey.W) {
        dv += 1
    }
    if rl.IsKeyDown(rl.KeyboardKey.S) {
        dv -= 1
    }
    
    dr : f32 = 0
    if rl.IsKeyDown(rl.KeyboardKey.A) {
        dr -= 1
    }
    if rl.IsKeyDown(rl.KeyboardKey.D) {
        dr += 1
    }

    car.speed += dv * ACC * PHYSICS_DT
    car.rotation += dr * ROTATION_SPEED * PHYSICS_DT
}

simulation_draw :: proc(sim : ^Simulation($N), zubr_texture: rl.Texture2D) {
    for i in 1..<(MAP_SIZE + 1) {
        p0 := sim.track.points[i - 1]
        p1 := sim.track.points[i % MAP_SIZE]

        rl.DrawLineEx(p0, p1, TRACK_WIDTH, rl.BLACK)
        rl.DrawCircleV(p0, TRACK_WIDTH / 2, rl.BLACK)
    }

    for car in sim.cars {
        draw_car(car, zubr_texture)
    }


    // Draw sensor rays and hits for car[0] for debug
    car := sim.cars[0]
    _, hit_points, hits := raycast_input(car, sim.track)
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

}

car_logic :: proc(sim : ^Simulation($N), logic : learning.Neural($M)) -> (dv, dr : f32){
    for i in 0..<N {
        ray_inputs, _, _ := raycast_input(sim.cars[i], sim.track)
        input := [6]f64{}
        for j in 0..<5 {
            input[j] = ray_inputs[j]
        }
        input[5] = f64(sim.cars[i].speed) / MAX_SPEED

        dv, dr = learning.compute(logic, input[:])

        dv = clamp(dv, 0, 1) * 2 - 1
        dr = clamp(dr, 0, 1) * 2 - 1
        sim.cars[i].speed += dv * ACC * PHYSICS_DT
        sim.cars[i].speed = clamp(sim.cars[i].speed, -MAX_SPEED, MAX_SPEED)
        sim.cars[i].rotation += dr * ROTATION_SPEED * PHYSICS_DT
    }
    return
}

fast_simulation :: proc(sim : ^Simulation($N), logic : learning.Neural($M)) {
    physicsTime : f32 = 0.0

    pdv, pdr : f32
    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT
        dv, dr := car_logic(sim, logic)
        if dv == pdv && dr == pdr {
            fmt.printfln("SUS")
        }
        pdv = dv
        pdr = dr

        simulation_step(sim)
        if sim.cars[0].dead {
            break
        }
    }
}

visual_simulation :: proc(sim : ^Simulation($N), logic : learning.Neural($M)) {
    rl.InitWindow(2560, 1440, "projekt")
    rl.SetTargetFPS(300)
    
    zubr_texture := rl.LoadTexture("zubr.png")
    

    gameTime : f32 = 0.0
    physicsTime : f32 = 0.0

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        
        gameTime += dt
        if dt > 0.25 {
            dt = 0.25
        }

        for physicsTime < gameTime && physicsTime < SIM_DURATION {
            physicsTime += PHYSICS_DT
            // user_input(sim)
            car_logic(sim, logic)
            simulation_step(sim)
        }

        if physicsTime >= SIM_DURATION {
            break
        } 

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        simulation_draw(sim, zubr_texture)
        rl.EndDrawing()
    }
    rl.CloseWindow()

    rl.UnloadTexture(zubr_texture)
}

score :: proc(car : learning.Neural($N), vis : bool = false) -> f64 {
    sim := simulation_simple()
    // fmt.printfln("{}", car)

    if vis {
        visual_simulation(&sim, car)
    } else {
        fast_simulation(&sim, car)
    }

    mod := len(sim.track.points)
    curr := sim.cars[0].p_now
    next := curr + 1
    a := sim.track.points[curr % mod]
    b := sim.track.points[next % mod]
    ab := b - a
    ap := sim.cars[0].pos - a
    t := clamp(rl.Vector2DotProduct(ap, ab) / rl.Vector2LengthSqr(ab), -1, 1)
    
    ans := f64(curr) + f64(t)
    ans = max(ans, 0)
    if sim.cars[0].dead {
        ans -= 3
    }
    return ans
    // return f64(sim.cars[0].p_now)
}

Car_Score :: struct($N : int){
    neural : learning.Neural(N),
    score : f64,
}

random_pair :: proc(m : int) -> (i, j : int){
    i = rand.int_max(m)
    j = rand.int_max(m)
    if(i == j){
        return random_pair(m)
    }
    return
}

/*
steps - to liczba kroków 
cars - liczba prób w każdym kroku
mut_rate - rate z jakim mutujemy najlepszych zawodników
mut_num - liczba mutacji z jednego autka
take_bests - liczba NAJLEPSZYCH (wzgledem score) zawodników, których będziemy mutować
    UWAGA: jeśli mut_num*take_bests > cars, to nie wezmiemy wszystkich mutacji. 
           Jeśli mut_num*take_bests <= cars to będziemy losować wagi tak żeby samochodzików było co najwyżej arg cars
show_best - jeśli true, w każdym kroku pokazujemy najlepszy run
*/
learn :: proc(
    $CARS: u32,
    steps: u32 = 100,
    mut_rate: f64 = 0.1,
    mut_num: int = 5, 
    take_bests: int = 5,
    show_best: bool = false,
    net_size: [$N]u32 = [4]u32{6,6,4,2}
) {
    cars : [CARS]Car_Score(N)

    car_score_len :: proc(it : sort.Interface) -> int {
        return int(CARS)
    }

    car_score_less :: proc(it : sort.Interface, i, j : int) -> bool {
        cs := ([^]Car_Score(N))(it.collection)
        return cs[i].score < cs[j].score
    }

    car_score_swap :: proc(it : sort.Interface, i, j : int) {
        cs := ([^]Car_Score(N))(it.collection)
        ci := cs[i]
        cs[i] = cs[j]
        cs[j] = ci
    }

    for i in 0..<CARS {
        cars[i].neural = learning.make_neural(net_size)
        learning.random_weights(&cars[i].neural)
    }
    

    for i in 0..<steps {
        rand.shuffle(cars[:])
        for car, i in cars {
            cars[i].score = score(car.neural)
            // fmt.printfln("score {}", cars[i].score)
        }

        sort.sort(sort.Interface{
            car_score_len,
            car_score_less,
            car_score_swap,
            &cars
        })

        for car, i in cars {
            fmt.printfln("i {}, score {}", i, car.score)
        }

        // GENETICS !!!!!!

        // new random ones
        for i in 0..<25 {
            learning.random_weights(&cars[i].neural)
        }

        // avg of best 2
        for i in 25..<50 {
            j, k := random_pair(5)
            j += 95
            k += 95
            learning.average_neural(&cars[i].neural, cars[j].neural, cars[k].neural)
        }

        // small mutation of the best
        for i in 50..<95 {
            j := rand.int_max(5) + 95
            learning.mutate_neural(&cars[i].neural, cars[j].neural, mut_rate)
        }
        score(cars[99].neural, true)
    }
    score(cars[99].neural, true)
}

main :: proc() {
    learn(CARS = 100)

    // sim := simulation_simple()
    // visual_simulation(&sim)
}