package projekt
import rl "vendor:raylib"
import "learning"

mark_dead :: proc(sim : ^Simulation($N, $K)) {
    for &car in sim.cars {
        if !car_on_track(car, sim.track) {
            car.dead = true
            car.on_track = false
        } else {
            car.on_track = true
        }
    }
}

simulation_simple :: proc() -> Simulation(1, 6) {
    return Simulation(1, 6){
        [1]Car{
            Car{
                HEX_MAP.points[0],
                0,
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

simulation_step :: proc(sim : ^Simulation($N, $K)) {
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
    }

    mark_dead(sim)
}

fast_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M)) {
    physicsTime : f32 = 0.0
    track_in, track_out := track_in_out(sim.track) 

    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT
        car_logic(sim, logic, track_in, track_out)
        
        simulation_step(sim)
        if sim.cars[0].dead {
            break
        }
    }
}

visual_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M)) {
    rl.InitWindow(2560, 1440, "projekt")
    rl.SetTargetFPS(300)

    gameTime : f32 = 0.0
    physicsTime : f32 = 0.0
    track_in, track_out := track_in_out(sim.track)

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        
        gameTime += dt
        if dt > 0.25 {
            dt = 0.25
        }

        for physicsTime < gameTime && physicsTime < SIM_DURATION {
            physicsTime += PHYSICS_DT
            // user_input(sim)
            car_logic(sim, logic, track_in, track_out)
            simulation_step(sim)
        }

        if physicsTime >= SIM_DURATION {
            break
        } 

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        simulation_draw(sim, track_in, track_out)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}

simulation_draw :: proc(sim : ^Simulation($N, $K), track_in, track_out : Map($M)) {
    for i in 1..<7 {
        p0 := sim.track.points[i - 1]
        p1 := sim.track.points[i % 6]

        rl.DrawLineEx(p0, p1, TRACK_WIDTH, rl.BLACK)
        rl.DrawCircleV(p0, TRACK_WIDTH / 2, rl.BLACK)
    }

    for car in sim.cars {
        draw_car(car, sim.track, track_in, track_out)
    }

    for p, i in track_in.points {
        rl.DrawCircleV(p, 10, rl.BLUE)
    }
    for p, i in track_out.points {
        rl.DrawCircleV(p, 10, rl.GREEN)
    }
}