package projekt

import rl "vendor:raylib"

segment_intersect :: proc(p0, p1, p2, p3 : rl.Vector2) -> (bool, rl.Vector2) {
    col_point : rl.Vector2
    intersect := rl.CheckCollisionLines(p0, p1, p2, p3, &col_point)
    return intersect, col_point
}

track_points_range_small :: proc(car : Car, track: Map($N)) -> (j0, j1 : int) {
    using track
    j := N + car.p_now
    p0 := car.pos
    for j >= 0 && j >= car.p_now && rl.Vector2Distance(points[j % N], p0) <= MAX_RAY_LEN {
        j -= 1
    }
    if rl.Vector2Distance(points[j %% N], p0) > MAX_RAY_LEN {
        j += 1
    }
    j0 = j

    j = N + car.p_now
    for j < 2 * N + car.p_now && rl.Vector2Distance(points[j % N], p0) <= MAX_RAY_LEN {
        j += 1   
    }
    j1 = j
    return
}

raycast_sensors_base :: proc(car : Car, track: Map($N), track_in: Map(N), track_out: Map(N), ray_angle: f32) -> (
    res: f64,
    hit_pos: rl.Vector2,
    hit: bool
) {
    angle := (ray_angle + car.rotation) * rl.DEG2RAD
    dir := rl.Vector2Rotate(rl.Vector2{1, 0}, angle)
    p0 := car.pos
    p1 := car.pos + dir * MAX_RAY_LEN

    min_dist : f32 = MAX_RAY_LEN
    hit_pos = p1
    hit = false

        j0, j1 := track_points_range_small(car, track)
        for j in j0-2..=j1+2 {
            ok, point := segment_intersect(p0, p1, track_in.points[(j - 1) %% N], track_in.points[j %% N])
            d := rl.Vector2Distance(point, p0)
            if ok && d < min_dist {
                min_dist = d
                hit_pos = point
                hit = true
            }
            
            ok, point = segment_intersect(p0, p1, track_out.points[(j - 1) %% N], track_out.points[j %% N])
            d = rl.Vector2Distance(point, p0)
            if ok && d < min_dist {
                min_dist = d
                hit_pos = point
                hit = true
            }
        }

    res = f64(1.0 - clamp(min_dist / MAX_RAY_LEN, 0, 1))
    return
}

raycast_sensors :: proc(car : Car, track: Map($N), track_in: Map(N), track_out: Map(N), ray_angles: [$K]f32 = RAY_ANGLES) -> (
    res : [K]f64, 
    hit_points : [K]rl.Vector2,
    hits : [K]bool,
) {
    // RAY_ANGLES := RAY_ANGLES

    for i in 0..<K {
        r, hit_pos, hit := raycast_sensors_base(car, track, track_in, track_out, ray_angles[i])

        res[i] = r
        hit_points[i] = hit_pos
        hits[i] = hit
    }
    return
}