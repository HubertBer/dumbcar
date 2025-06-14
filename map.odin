package projekt
import rl "vendor:raylib"

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
    },
}

intersect_lines :: proc(l00, l01, l10, l11: rl.Vector2) -> rl.Vector2 {
    r := l01 - l00
    s := l11 - l10

    delta := l10 - l00

    rs := r.x * s.y - r.y * s.x

    if rs < rl.EPSILON {
        return l01
    }

    t := (delta.x * s.y - delta.y * s.x) / rs

    return l00 + r * t
}

inner_outer :: proc(p0, p1, p2 : rl.Vector2) -> (inner, outer : rl.Vector2){
    d01 := p1 - p0
    d12 := p2 - p1

    perp01 := rl.Vector2Rotate(rl.Vector2Normalize(d01), 90 * rl.DEG2RAD)
    perp12 := rl.Vector2Rotate(rl.Vector2Normalize(d12), 90 * rl.DEG2RAD)
    
    p0out := p0 + perp01 * TRACK_WIDTH / 2
    p10out := p1 + perp01 * TRACK_WIDTH / 2
    p11out := p1 + perp12 * TRACK_WIDTH / 2
    p2out := p2 + perp12 * TRACK_WIDTH / 2

    p0in := p0 - perp01 * TRACK_WIDTH / 2
    p10in := p1 - perp01 * TRACK_WIDTH / 2
    p11in := p1 - perp12 * TRACK_WIDTH / 2
    p2in := p2 - perp12 * TRACK_WIDTH / 2
    
    return intersect_lines(p0out, p10out, p11out, p2out), intersect_lines(p0in, p10in, p11in, p2in) 
}

track_in_out :: proc(track : Map($N)) -> (track_in, track_out : Map(N)) {
    using track
    for i in 1..=N {
        track_in.points[i % N], track_out.points[i % N] = inner_outer(points[i - 1], points[i % N], points[(i + 1) % N])
    }
    return
}

map_boundaries :: proc(track : Map($N)) -> (inner : Map(N), outer : Map(N)) {
    for i in 1..=N {
        p0 := track.points[(i - 1) % N]
        p1 := track.points[i % N]
        p2 := track.points[(i + 1) % N]

        inn, out := inner_outer(p0, p1, p2)
        inner.points[i % N] = inn
        outer.points[i % N] = out
    }
    return
}

