package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "core:sort"
import "core:math"

Simulation :: struct($N : int, $M : int) {
    cars : [N]Car,
    track : Map(M),
}

user_input :: proc(sim : ^Simulation($N, $M)) {
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

outside_test :: proc() {
    rl.InitWindow(2560, 1440, "projekt")
    rl.SetTargetFPS(300)


    p1 := rl.Vector2{100, 100}
    p2 := rl.Vector2{1000, 1000}
    p3 := rl.Vector2{2000, 100}

    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        
        if rl.IsKeyDown(rl.KeyboardKey.S) {
            // p3.y += rl.GetFrameTime() * 100
            p1.y += rl.GetFrameTime() * 100
        }
        in0, out0 := inner_outer(p1, p2, p3)

        // rl.DrawCircleV(p1, 50, rl.GREEN)
        rl.DrawCircleV(p1, 5, rl.BLACK)
        // rl.DrawCircleV(p2, 50, rl.GREEN)
        rl.DrawCircleV(p2, 5, rl.BLACK)
        // rl.DrawCircleV(p3, 50, rl.GREEN)
        rl.DrawCircleV(p3, 5, rl.BLACK)
        
        rl.DrawCircleV(in0, 5, rl.MAGENTA)
        rl.DrawCircleV(out0, 5, rl.MAGENTA)
        
        rl.EndDrawing()
    }
}

main :: proc() {
    learn(
        CARS = 100,
        CHILD_AVG = 30,
        CHILD_MUT = 30,
        LEAVE_OUT = 10, 
    )
    // outside_test()
}