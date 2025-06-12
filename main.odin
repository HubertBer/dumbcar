package projekt
import rl "vendor:raylib"
import "core:fmt"

MAX_SPEED :: 500
ACC :: 1000.0

// IN DEGREES 
ROTATION_SPEED :: 180.0
PHYSICS_DT :: 1.0/60.0
CAR_WIDTH :: 10.0
CAR_LENGTH :: 30.0
TRACK_WIDTH :: 50

model : [10]f32

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

Simulation :: struct {
    cars : [1]Car,
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
    if car.on_track {
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

mark_dead :: proc(sim : ^Simulation) {
    for &car in sim.cars {
        if !car_on_track(car, sim.track) {
            car.dead = true
            car.on_track = false
        } else {
            car.on_track = true
        }
    }
}

simulation_simple :: proc() -> Simulation {
    return Simulation{
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

simulation_step :: proc(sim : ^Simulation) {
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

user_input :: proc(sim : ^Simulation) {
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

simulation_draw :: proc(sim : ^Simulation) {
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

visual_simulation :: proc(sim : ^Simulation) {
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

        for physicsTime < gameTime {
            physicsTime += PHYSICS_DT
            user_input(sim)
            simulation_step(sim)
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        simulation_draw(sim)
        rl.EndDrawing()
    }
}

main :: proc() {
    sim := simulation_simple()

    visual_simulation(&sim)
}