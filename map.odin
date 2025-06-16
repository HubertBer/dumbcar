package projekt
import rl "vendor:raylib"

Map :: struct($N : int){
    points : [N]rl.Vector2
}

HEX_MAP_SIZE :: 6
HEX_MAP :: Map(HEX_MAP_SIZE){
    [HEX_MAP_SIZE]rl.Vector2{
        rl.Vector2{473.2, 200.0},
        rl.Vector2{400.0, 73.2},
        rl.Vector2{200.0, 73.2},
        rl.Vector2{126.8, 200.0},
        rl.Vector2{200.0, 426.8},
        rl.Vector2{400.0, 426.8},
    },
}

DECA_MAP_SIZE :: 10
DECA_MAP :: Map(DECA_MAP_SIZE){
    [DECA_MAP_SIZE]rl.Vector2{
        rl.Vector2{700.0, 400.0},
        rl.Vector2{642.7, 576.3},
        rl.Vector2{509.0, 690.2},
        rl.Vector2{340.0, 726.6},
        rl.Vector2{184.5, 676.3},
        rl.Vector2{100.0, 550.0},
        rl.Vector2{100.0, 400.0},
        rl.Vector2{157.3, 223.7},
        rl.Vector2{291.0, 109.8},
        rl.Vector2{460.0, 73.4},
    }
}

ZIGZAG_MAP_SIZE :: 23
ZIGZAG_MAP :: Map(ZIGZAG_MAP_SIZE){
    [ZIGZAG_MAP_SIZE]rl.Vector2{
        rl.Vector2{800.0, 200.0},
        rl.Vector2{700.0, 400.0},
        rl.Vector2{800.0, 600.0},
        rl.Vector2{700.0, 800.0},
        rl.Vector2{800.0, 1000.0},
        rl.Vector2{700.0, 1200.0},

        rl.Vector2{900.0, 1300.0},
        rl.Vector2{1100.0, 1200.0},
        rl.Vector2{1300.0, 1300.0},
        rl.Vector2{1500.0, 1200.0},
        rl.Vector2{1700.0, 1300.0},
        rl.Vector2{1800.0, 1200.0},

        rl.Vector2{1900.0, 1000.0},
        rl.Vector2{1800.0, 800.0},
        rl.Vector2{1900.0, 600.0},
        rl.Vector2{1800.0, 400.0},
        rl.Vector2{1900.0, 200.0},
        rl.Vector2{1800.0, 200.0},

        rl.Vector2{1600.0, 100.0},
        rl.Vector2{1400.0, 200.0},
        rl.Vector2{1200.0, 100.0},
        rl.Vector2{1000.0, 200.0},
        rl.Vector2{800.0, 100.0},
    }
}

MAP1_SIZE :: 23
MAP1 :: Map(MAP1_SIZE) {
    {
        { 207 , 213 },
        { 144 , 455 },
        { 297 , 630 },
        { 551 , 544 },
        { 700 , 680 },
        { 870 , 550 },
        { 1103 , 668 },
        { 1274 , 582 },
        { 1287 , 389 },
        { 1243 , 160 },
        { 1080 , 221 },
        { 1093 , 336 },
        { 1176 , 432 },
        { 1122 , 534 },
        { 946 , 440 },
        { 962 , 297 },
        { 946 , 129 },
        { 707 , 169 },
        { 810 , 327 },
        { 840 , 453 },
        { 729 , 520 },
        { 624 , 355 },
        { 460 , 110 },
    }
}

INFINITY_MAP_SIZE :: 14
INFINITY_MAP :: Map(INFINITY_MAP_SIZE){
    {
        { 265 , 351 },
        { 329 , 507 },
        { 494 , 608 },
        { 702 , 481 },
        { 903 , 269 },
        { 1105 , 100 },
        { 1311 , 122 },
        { 1426 , 274 },
        { 1427 , 508 },
        { 1272 , 601 },
        { 943 , 423 },
        { 776 , 216 },
        { 567 , 96 },
        { 285 , 147 },
    }
}

SKRYG_MAP_SIZE :: 16
SKRYG_MAP :: Map(SKRYG_MAP_SIZE) {
    {
        { 157 , 323 },
        { 156 , 376 },
        { 231 , 387 },
        { 247 , 312 },
        { 307 , 310 },
        { 326 , 358 },
        { 337 , 461 },
        { 158 , 464 },
        { 162 , 546 },
        { 433 , 541 },
        { 391 , 293 },
        { 463 , 293 },
        { 500 , 523 },
        { 585 , 534 },
        { 549 , 219 },
        { 160 , 233 },
    }
}

NURBURGRING_SIZE :: 20
NURBURGRING :: Map(NURBURGRING_SIZE){
    {
        { 1476 , 462 },
        { 902 , 704 },
        { 831 , 614 },
        { 963 , 435 },
        { 676 , 416 },
        { 640 , 514 },
        { 746 , 567 },
        { 539 , 891 },
        { 603 , 1016 },
        { 206 , 1052 },
        { 180 , 984 },
        { 423 , 835 },
        { 596 , 589 },
        { 441 , 404 },
        { 514 , 285 },
        { 941 , 149 },
        { 1303 , 343 },
        { 1389 , 267 },
        { 1627 , 236 },
        { 1684 , 358 },
    }
}

BOOTCAMP_SIZE :: 47
BOOTCAMP :: Map(BOOTCAMP_SIZE){{
    { 412 , 1055 },
    { 1413 , 1046 },
    { 1544 , 967 },
    { 1664 , 1029 },
    { 1784 , 1040 },
    { 1835 , 984 },
    { 1849 , 879 },
    { 1798 , 764 },
    { 1723 , 742 },
    { 1651 , 755 },
    { 1666 , 833 },
    { 1723 , 876 },
    { 1738 , 934 },
    { 1678 , 949 },
    { 1607 , 923 },
    { 1558 , 868 },
    { 1518 , 779 },
    { 1526 , 708 },
    { 1571 , 672 },
    { 1639 , 644 },
    { 1710 , 645 },
    { 1769 , 617 },
    { 1776 , 541 },
    { 1765 , 457 },
    { 1646 , 419 },
    { 1593 , 533 },
    { 1378 , 765 },
    { 1451 , 901 },
    { 1175 , 968 },
    { 1119 , 892 },
    { 1601 , 314 },
    { 1790 , 280 },
    { 1754 , 110 },
    { 1506 , 116 },
    { 1068 , 798 },
    { 945 , 728 },
    { 1229 , 161 },
    { 1151 , 85 },
    { 1007 , 92 },
    { 996 , 338 },
    { 666 , 445 },
    { 487 , 400 },
    { 308 , 165 },
    { 141 , 149 },
    { 87 , 217 },
    { 115 , 486 },
    { 175 , 904 },
}} 

intersect_lines :: proc(l00, l01, l10, l11: rl.Vector2) -> rl.Vector2 {
    r := l01 - l00
    s := l11 - l10

    delta := l10 - l00

    rs := r.x * s.y - r.y * s.x

    if abs(rs) < rl.EPSILON {
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
    // rl.DrawCircleV(p0out, 10, rl.GREEN)
    // rl.DrawCircleV(p10out, 10, rl.BLUE)
    // rl.DrawCircleV(p11out, 10, rl.RED)
    // rl.DrawCircleV(p2out, 10, rl.BLACK)
    
    p0in := p0 - perp01 * TRACK_WIDTH / 2
    p10in := p1 - perp01 * TRACK_WIDTH / 2
    p11in := p1 - perp12 * TRACK_WIDTH / 2
    p2in := p2 - perp12 * TRACK_WIDTH / 2
    // rl.DrawCircleV(p0in, 10, rl.GREEN)
    // rl.DrawCircleV(p10in, 10, rl.BLUE)
    // rl.DrawCircleV(p11in, 10, rl.RED)
    // rl.DrawCircleV(p2in, 10, rl.BLACK)
    
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

