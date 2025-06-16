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
        CARS = 300,
        CHILD_AVG = 25,
        CHILD_MUT = 150,
        LEAVE_OUT = 20, 
        STEPS = 40,
        show_mod = 10,
        mut_rate = 0.2,
        
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