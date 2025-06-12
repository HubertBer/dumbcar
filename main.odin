package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "core:sort"
import "core:math"

MAX_SPEED :: 500
ACC :: 1000.0

// IN DEGREES 
ROTATION_SPEED :: 180.0
PHYSICS_DT :: 1.0/60.0
CAR_WIDTH :: 10.0
CAR_LENGTH :: 30.0
TRACK_WIDTH :: 50

// SIMULATION CONSTANTS
SIM_DURATION :: 60


Map :: struct($N : int){
    points : [N]rl.Vector2
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

carrr :: Car{
    0,
    0,
    0,
    0,
    0,
    false,
    false,
    0,
}

Car :: struct {
    pos : rl.Vector2,
    prevPos : rl.Vector2,
    speed : f32,
    rotation : f32,
    prevRotation : f32,
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
    track : Map(6), 
}

carRect :: proc(car : Car) -> rl.Rectangle {
    return rl.Rectangle{
        car.pos.x,
        car.pos.y,
        CAR_LENGTH,
        CAR_WIDTH,
    }
}

draw_car :: proc(car : Car) {
    color := rl.BLUE
    if !car.on_track {
        color = rl.RED
    } 
    rl.DrawRectanglePro(carRect(car), rl.Vector2{CAR_LENGTH / 2, CAR_WIDTH / 2}, car.rotation, color)
    rl.DrawCircleV(car.pos, 5, rl.BLACK)
}

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
                HEX_MAP.points[0],
                HEX_MAP.points[0],
                0,
                -30,
                -30,
                // 0,
                // 0,
                false,
                false,
                0
            }
        },
        HEX_MAP
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
        car.prevPos = car.pos
        car.prevRotation = car.rotation

        forward := rl.Vector2Rotate(rl.Vector2{1, 0}, car.rotation * rl.DEG2RAD)
        car.pos += forward * car.speed * PHYSICS_DT
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

simulation_draw :: proc(sim : ^Simulation($N)) {
    for i in 1..<7 {
        p0 := sim.track.points[i - 1]
        p1 := sim.track.points[i % 6]

        rl.DrawLineEx(p0, p1, TRACK_WIDTH, rl.BLACK)
        rl.DrawCircleV(p0, TRACK_WIDTH / 2, rl.BLACK)
    }

    for car in sim.cars {
        draw_car(car)
    }
}

car_logic :: proc(sim : ^Simulation($N), logic : learning.Neural($M)) {
    for i in 0..<N {
        input := [6]f64{0, 0, 0, 0, 0, f64(sim.cars[i].speed)}
        dv, dr := learning.compute(logic, input[:])
        dv = clamp(dv, 0, 1) * 2 - 1
        dr = clamp(dr, 0, 1) * 2 - 1
        sim.cars[i].speed += dv * ACC * PHYSICS_DT
        sim.cars[i].rotation += dr * ROTATION_SPEED * PHYSICS_DT
    }
}

visual_simulation :: proc(sim : ^Simulation($N), logic : learning.Neural($M)) {
    rl.InitWindow(2560, 1440, "projekt")
    rl.SetTargetFPS(300)

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
        simulation_draw(sim)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}

score :: proc(car : learning.Neural($N)) -> f64 {
    sim := simulation_simple()
    fmt.printfln("{}", car)
    visual_simulation(&sim, car)
    return f64(sim.cars[0].p_now)
}

Car_Score :: struct($N : int){
    neural : learning.Neural(N),
    score : f64,
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
    mut_rate: f64 = 0.2,
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
        for car, i in cars {
            cars[i].score = score(car.neural)
        }

        sort.sort(sort.Interface{
            car_score_len,
            car_score_less,
            car_score_swap,
            &cars
        })


    }

}

main :: proc() {
    learn(CARS = 100)

    // sim := simulation_simple()
    // visual_simulation(&sim)
}