package projekt
import rl "vendor:raylib"
import "learning"
import "heuristic"

Simulation :: struct($N : int, $M : int) {
    cars : [N]Car,
    track : Map(M),
    track_in : Map(M),
    track_out : Map(M)
}

mark_dead :: proc(sim : ^Simulation($N, $K)) {
    for &car in sim.cars {
        if !car_on_track(car, sim.track_in, sim.track_out) {
            car.dead = true
            car.on_track = false
        } else {
            car.on_track = true
        }
    }
}

simulation_simple :: proc() -> Simulation(1, MAP_SIZE) {
    p0 := MAP_USED.points[0]
    p1 := MAP_USED.points[1]
    rot := rl.Vector2Angle(rl.Vector2{1, 0}, p1 - p0) * rl.RAD2DEG
    track_in, track_out := track_in_out(MAP_USED)
    
    return Simulation(1, MAP_SIZE){
        [1]Car{
            Car{
                MAP_USED.points[0],
                MIN_SPEED,
                rot,
                false,
                false,
                0
            }
        },
        MAP_USED,
        track_in,
        track_out
    }
}

simulation_on_map :: proc(track : Map($N)) -> Simulation(1, N) {
    p0 := MAP_USED.points[0]
    p1 := MAP_USED.points[1]
    rot := rl.Vector2Angle(rl.Vector2{1, 0}, p1 - p0) * rl.RAD2DEG

    track_in, track_out := track_in_out(track)

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
        track,
        track_in,
        track_out
    }
}

simulation_race_on_map :: proc(track : Map($N)) -> Simulation(2, N) {
    p0 := MAP_USED.points[0]
    p1 := MAP_USED.points[1]
    rot := rl.Vector2Angle(rl.Vector2{1, 0}, p1 - p0) * rl.RAD2DEG

    track_in, track_out := track_in_out(track)

    return Simulation(2, N){
        [2]Car{
            Car{
                track.points[0],
                MIN_SPEED,
                rot,
                false,
                false,
                0
            },
            Car{
                track.points[0],
                MIN_SPEED,
                rot,
                false,
                false,
                0
            }
        },

        track,
        track_in,
        track_out
    }
}


simulation_step :: proc(sim : ^Simulation($N, $K)) {
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

    mark_dead(sim)
}

fast_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M)) {
    physicsTime : f32 = 0.0

    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT
        car_logic(sim, logic)
        
        simulation_step(sim)
        if sim.cars[0].dead {
            break
        }
    }
}

visual_simulation :: proc(sim : ^Simulation($N, $K), logic : learning.Neural($M), infinite := false) {
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
            car_logic(sim, logic)
            simulation_step(sim)
        }

        if physicsTime >= SIM_DURATION && !infinite{
            break
        } 

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        simulation_draw(sim)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}

track_draw :: proc(sim: ^Simulation($N, $K)) {
    for i in 1..=K {
        out0 := sim.track_out.points[(i - 1) % K]
        out1 := sim.track_out.points[i % K]
        in0 := sim.track_in.points[(i - 1) % K]
        in1 := sim.track_in.points[i % K]

        rl.DrawTriangle(out0, out1, in1, rl.BLACK)
        rl.DrawTriangle(in1, in0, out0, rl.BLACK)
        rl.DrawTriangle(out1, out0, in1, rl.BLACK)
        rl.DrawTriangle(in0, in1, out0, rl.BLACK)
    }
}

simulation_draw :: proc(sim : ^Simulation($N, $K)) {
    track_draw(sim)
        
    // for i in 1..<7 {
    //     p0 := sim.track.points[i - 1]
    //     p1 := sim.track.points[i % 6]

    //     rl.DrawLineEx(p0, p1, TRACK_WIDTH, rl.BLACK)
    //     rl.DrawCircleV(p0, TRACK_WIDTH / 2, rl.BLACK)
    // }

    for car, i in sim.cars {
        color := i % 2 == 1 ? rl.BLUE : rl.GREEN
        draw_car(car, sim.track, sim.track_in, sim.track_out, color)
    }

    // for p, i in track_in.points {
    //     rl.DrawCircleV(p, 10, rl.BLUE)
    // }
    // for p, i in track_out.points {
    //     rl.DrawCircleV(p, 10, rl.GREEN)
    // }
}

heuristic_simulation :: proc(sim: ^Simulation(1, $M)) {
    physicsTime : f32 = 0.0
    last_step: rl.Vector2
    pdv, pdr : f32
    for physicsTime < SIM_DURATION  {
        physicsTime += PHYSICS_DT

        pos := sim.cars[0].pos
        next_p := sim.track.points[(sim.cars[0].p_now+1)%M]

        
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

heuristic_visual_simulation :: proc(sim : ^Simulation(1, $M)) {
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
            next_p := sim.track.points[(sim.cars[0].p_now+1)%M]

            ray, _, _ := raycast_sensors_base(sim.cars[0], sim.track, sim.track_in, sim.track_out, 0)
        
            dv, dr := heuristic.next_step(last_step, pos, next_p, ray)     
            sim.cars[0].speed += dv * ACC * PHYSICS_DT
            sim.cars[0].speed = clamp(sim.cars[0].speed, MIN_SPEED, MAX_SPEED)
            sim.cars[0].rotation += dr * ROTATION_SPEED * PHYSICS_DT       

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

visual_comparing_simulation :: proc(sim : ^Simulation(2, $M), logic : learning.Neural($K), infinite := false) {
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

        for physicsTime < gameTime && (physicsTime < SIM_DURATION || infinite) {
            physicsTime += PHYSICS_DT
            // user_input(sim)
            
            // car_logic(sim, logic, true)
            one_car_logic(&sim.cars[0],logic, sim.track, sim.track_in, sim.track_out)

            pos := sim.cars[1].pos
            next_p := sim.track.points[(sim.cars[1].p_now+1)%M]

            ray, _, _ := raycast_sensors_base(sim.cars[1], sim.track, sim.track_in, sim.track_out, 0)
        
            dv, dr := heuristic.next_step(last_step, pos, next_p, ray)     
            sim.cars[1].speed += dv * ACC * PHYSICS_DT
            sim.cars[1].speed = clamp(sim.cars[1].speed, MIN_SPEED, MAX_SPEED)
            sim.cars[1].rotation += dr * ROTATION_SPEED * PHYSICS_DT       

            simulation_step(sim)
            last_step = sim.cars[1].pos - pos  

        }

        if physicsTime >= SIM_DURATION && !infinite{
            break
        } 

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        simulation_draw(sim)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}