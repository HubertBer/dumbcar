package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "heuristic"
import "core:sort"
import "core:math"
import "core:math/rand"

heuristic_simulation :: proc(sim: ^Simulation(1)) {
    physicsTime : f32 = 0.0
    last_step: rl.Vector2
    pdv, pdr : f32
    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT

        pos := sim.cars[0].pos
        next_p := sim.track.points[(sim.cars[0].p_now+1)%MAP_SIZE]

        
        dv, dr := heuristic.next_step(last_step, pos, next_p) 
        sim.cars[0].speed += dv * ACC * PHYSICS_DT
        sim.cars[0].speed = clamp(sim.cars[0].speed, MIN_SPEED, MAX_SPEED)
        sim.cars[0].rotation += dr * ROTATION_SPEED * PHYSICS_DT       
        
        simulation_step(sim)
        last_step = sim.cars[0].pos - pos

        if sim.cars[0].dead {
            break
        }
    }
} 

heuristic_visual_simulation :: proc(sim : ^Simulation(1)) {
    rl.InitWindow(1920, 1080, "projekt")
    rl.SetTargetFPS(300)

    gameTime : f32 = 0.0
    physicsTime : f32 = 0.0
    last_step: rl.Vector2
    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        
        gameTime += dt
        if dt > 0.25 {
            dt = 0.25
        }

        for physicsTime < gameTime && physicsTime < SIM_DURATION {
            physicsTime += PHYSICS_DT
            // user_input(sim)
            pos := sim.cars[0].pos
            next_p := sim.track.points[(sim.cars[0].p_now+1)%MAP_SIZE]
        
            dv, dr := heuristic.next_step(last_step, pos, next_p)     
            sim.cars[0].speed += dv * ACC * PHYSICS_DT
            sim.cars[0].speed = clamp(sim.cars[0].speed, MIN_SPEED, MAX_SPEED)
            sim.cars[0].rotation += dr * ROTATION_SPEED * PHYSICS_DT       
            fmt.printfln("DV: {}",dv)

            simulation_step(sim)
            last_step = sim.cars[0].pos - pos             
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

main :: proc() {
    learn(
        CARS = 1000,
        CHILD_AVG = 300,
        CHILD_MUT = 400,
        LEAVE_OUT = 50, 
        steps = 50,
        show_mod = 5,
        mut_rate = 2.5,
        
    )
    // outside_test()
    // sim := simulation_simple()
    // heuristic_visual_simulation(&sim)
    // visual_simulation(&sim)
}