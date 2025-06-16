package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "heuristic"
import "core:sort"
import "core:math"
import "core:math/rand"


main :: proc() {
    learn(
        CARS = 1000,
        CHILD_AVG = 300,
        CHILD_MUT = 400,
        LEAVE_OUT = 50, 
        steps = 100,
        show_mod = 10,
        mut_rate = 0.1,
        
    )
    // outside_test()
    // sim := simulation_simple()
    // heuristic_visual_simulation(&sim)
    // visual_simulation(&sim)
}