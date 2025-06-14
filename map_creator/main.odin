package main

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

LINE_WIDTH :: 50
MARGIN :: 50

inbox :: proc(vec: rl.Vector2) -> bool {
    return vec.x > MARGIN \
    && vec.y > MARGIN \
    && i32(vec.x) < rl.GetScreenWidth() - MARGIN \
    && i32(vec.y) < rl.GetScreenHeight() - MARGIN
}

main :: proc() {
    rl.InitWindow(1600,800, "Map creator")
    rl.SetTargetFPS(30)
    // fmt.printf("{}", rl.GetScreenWidth())
    points : [dynamic]rl.Vector2
    showMessageBox := false

    defer rl.CloseWindow()
    
    for !rl.WindowShouldClose() {
        if rl.GuiButton((rl.Rectangle){ MARGIN, 0, 200, MARGIN }, "SAVE THIS MAP") {
            file, err := os.open(len(os.args) > 1 ? os.args[1] : "road.map", os.O_WRONLY | os.O_TRUNC | os.O_CREATE)
            if err != nil {
                fmt.eprintln(err)
                return
            }
            defer os.close(file)

            if (len(points) > 2)  {
                for p in points {
                    fmt.fprintln(file, "{", p.x,",", p.y, "},")
                }
                return
            }
        } 
        mouse_position := rl.GetMousePosition()


        if inbox(mouse_position) && rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
            sz := len(points)
            if sz == 0 || rl.Vector2Distance(mouse_position, points[sz-1]) > LINE_WIDTH {
                append(&points, mouse_position)
            }
        }
        
        size := len(points)
        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)
        rl.DrawRectangle(MARGIN, MARGIN, rl.GetScreenWidth()-2*MARGIN, rl.GetScreenHeight()-2*MARGIN, rl.WHITE)
        for i in 0..<size {

            p0 := points[i]
            p1 := points[(i+1)% size]

            rl.DrawLineEx(p0, p1, LINE_WIDTH, rl.BLACK)
            rl.DrawCircleV(p0, LINE_WIDTH/2, rl.BLACK)
        }

        if size > 0 {
            rl.DrawCircleV(points[0], LINE_WIDTH/2, rl.DARKGREEN)
        }

        rl.EndDrawing()
    }

}