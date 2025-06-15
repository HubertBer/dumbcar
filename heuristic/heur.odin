
package heuristic

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

next_step :: proc(
    last_move: rl.Vector2,
    currwa_point: rl.Vector2,
    dest_point: rl.Vector2
    ) -> (f32, f32) {
    
    to_point := dest_point - currwa_point

    cprod :: proc(a: rl.Vector2, b: rl.Vector2) -> f32 {
        return a.x * b.y - a.y * b.x
    }

    dprod :: proc(a: rl.Vector2, b: rl.Vector2) -> f32 {
        return a.x * b.x + a.y * b.y
    }

    vlen :: proc(v: rl.Vector2) -> f32 {
        return math.sqrt(dprod(v,v))
    }

    vsin :: proc(a: rl.Vector2, b: rl.Vector2) -> f32 {
        return cprod(a,b)/(vlen(a)*vlen(b))
    }

    vcos :: proc(a: rl.Vector2, b: rl.Vector2) -> f32 {
        return dprod(a,b)/(vlen(a)*vlen(b))
    }

    cos := vcos(last_move, to_point)
    sin := vsin(last_move, to_point)
    
    
    if math.is_nan(cos) {
        cos = 1
    }
    if math.is_nan(sin) {
        sin = 0
    }
    
    acc := cos
    acc *= 20
    acc -= 19
    acc /= 2
    acc = clamp(acc, -1, 1)

    rotation := math.sign(sin) if cos < 0 else sin

    fmt.printfln("Sine: {}", sin)
    fmt.printfln("Cosine: {}", cos)
    fmt.printfln("Acc: {}", acc)

    return acc, rotation
}
