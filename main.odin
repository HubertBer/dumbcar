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

main :: proc() {
    learn(
        CARS = 100,
        CHILD_AVG = 30,
        CHILD_MUT = 30,
        LEAVE_OUT = 10, 
    )

    // sim := simulation_simple()
    // visual_simulation(&sim)
}