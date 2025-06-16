package projekt
import rl "vendor:raylib"
import "core:fmt"
import "learning"
import "heuristic"
import "core:sort"
import "core:math"
import "core:math/rand"


main :: proc() {
    train_scores, test_scores := learn(
        CARS = 1000,
        CHILD_AVG = 300,
        CHILD_MUT = 400,
        LEAVE_OUT = 50, 
        STEPS = 20,
        show_mod = 10,
        mut_rate = 0.1,
        
    )

    fmt.println("--- TRAIN_SCORES --- ")
    for score, i in train_scores {
        fmt.printfln("[{}, {}]", i, score)
    }
    fmt.println("----------------------")
    fmt.println("--- TEST_SCORES --- ")
    for score, i in test_scores {
        fmt.printfln("[{}, {}]", i, score)
    }
    // // outside_test()
    // sim := simulation_on_map(SKRYG_MAP)
    // heuristic_visual_simulation(&sim)
    // visual_simulation(&sim)
}