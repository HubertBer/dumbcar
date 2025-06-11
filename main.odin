package projekt
import rl "vendor:raylib"
import "core:fmt"

MAX_SPEED :: 500
MAX_ACC :: 1000

// IN DEGREES 
ROTATION_SPEED :: 180
PHYSICS_DT :: 1.0/60.0
CAR_WIDTH :: 5.0
CAR_LENGTH :: 15.0

model : [10]f32

Car :: struct {
    pos : rl.Vector2,
    prevPos : rl.Vector2,
    vel : rl.Vector2,
    rotation : f32,
    prevRotation : f32,
}

carRect :: proc(car : Car) -> rl.Rectangle {
    
    return rl.Rectangle{
        car.pos.x - CAR_LENGTH / 2,
        car.pos.y - CAR_WIDTH / 2,
        CAR_LENGTH,
        CAR_WIDTH,
    }
}

main :: proc() {
    rl.InitWindow(1000, 1000, "projekt")
    rl.SetTargetFPS(300)

    playerCar := Car{
        rl.Vector2{500, 500},
        rl.Vector2{500, 500},
        rl.Vector2(0),
        63,
        63
    }

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
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        
        rl.DrawCircleV(playerCar.pos, 40, rl.RED)
        rl.DrawRectanglePro(carRect(playerCar), playerCar.pos, playerCar.rotation, rl.RED)

        rl.EndDrawing()
    }
}