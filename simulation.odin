package projekt
import rl "vendor:raylib"
import "learning"

Simulation :: struct($N : int, $M : int) {
    cars : [N]Car,
    track : Map(M),
}

mark_dead :: proc(sim : ^Simulation($N, $K), track_in, track_out : Map(K)) {
    for &car in sim.cars {
        if !car_on_track(car, track_in, track_out) {
            car.dead = true
            car.on_track = false
        } else {
            car.on_track = true
        }
    }
}

simulation_on_map :: proc(track : Map($N)) -> Simulation(1, N) {
    p0 := track.points[0]
    p1 := track.points[1]
    rot := rl.Vector2Angle(rl.Vector2{1, 0}, p1 - p0) * rl.RAD2DEG

    return Simulation(1, N){
        [1]Car{
            Car{
                track.points[0],
                MIN_SPEED,
                rot,
                false,
                false,
                0
            }
        },
        track
    }
}

simulation_step :: proc(sim : ^Simulation($N, $K), track_in, track_out : Map(K)) {
    for &car in sim.cars {
        if car.dead {
            continue
        }

        next_p := (car.p_now + 1) % len(sim.track.points)
        dist := rl.Vector2Length(car.pos - sim.track.points[next_p])
        if dist <= TRACK_WIDTH {
            car.p_now = next_p
        }

        forward := rl.Vector2Rotate(rl.Vector2{1, 0}, car.rotation * rl.DEG2RAD)
        car.pos += forward * car.speed * PHYSICS_DT
    }

    mark_dead(sim, track_in, track_out)
}

fast_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M), track_in, track_out : Map(K)) {
    physicsTime : f32 = 0.0

    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT
        car_logic(sim, logic, track_in, track_out)
        
        simulation_step(sim, track_in, track_out)
        if sim.cars[0].dead {
            break
        }
    }
}

visual_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M), track_in, track_out : Map(K), infinite := false) {
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

        for physicsTime < gameTime && (physicsTime < SIM_DURATION || infinite) {
            physicsTime += PHYSICS_DT
            // user_input(sim)
            car_logic(sim, logic, track_in, track_out)
            simulation_step(sim, track_in, track_out)
        }

        if physicsTime >= SIM_DURATION && !infinite{
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
    for i in 1..=M {
        out0 := track_out.points[i - 1 % M]
        out1 := track_out.points[i % M]
        in0 := track_in.points[i - 1 % M]
        in1 := track_in.points[i % M]

        
        rl.DrawTriangle(out0, out1, in1, rl.BLACK)
        rl.DrawTriangle(in1, in0, out0, rl.BLACK)
        rl.DrawTriangle(out1, out0, in1, rl.BLACK)
        rl.DrawTriangle(in0, in1, out0, rl.BLACK)
        
        // rl.DrawCircleV(out0, 10, rl.YELLOW)
        // rl.DrawCircleV(out1, 10, rl.YELLOW)
        // rl.DrawCircleV(in0, 10, rl.YELLOW)
        // rl.DrawCircleV(in1, 10, rl.YELLOW)
    }
        
    // for i in 1..<7 {
    //     p0 := sim.track.points[i - 1]
    //     p1 := sim.track.points[i % 6]

    //     rl.DrawLineEx(p0, p1, TRACK_WIDTH, rl.BLACK)
    //     rl.DrawCircleV(p0, TRACK_WIDTH / 2, rl.BLACK)
    // }

    for car in sim.cars {
        draw_car(car, sim.track, track_in, track_out)
    }

    // for p, i in track_in.points {
    //     rl.DrawCircleV(p, 10, rl.BLUE)
    // }
    // for p, i in track_out.points {
    //     rl.DrawCircleV(p, 10, rl.GREEN)
    // }
}