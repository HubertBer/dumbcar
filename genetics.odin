package projekt
import "learning"
import "core:fmt"
import "core:sort"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

score :: proc(car : learning.Neural($N), vis : bool = false, sim : ^Simulation($M, $K), track_in, track_out : Map(K)) -> f64 {
    if vis {
        visual_simulation(sim, car, track_in, track_out)
    } else {
        fast_simulation(sim, car, track_in, track_out)
    }

    mod := len(sim.track.points)
    curr := sim.cars[0].p_now
    next := curr + 1
    a := sim.track.points[curr % mod]
    b := sim.track.points[next % mod]
    ab := b - a
    ap := sim.cars[0].pos - a
    t := clamp(rl.Vector2DotProduct(ap, ab) / rl.Vector2LengthSqr(ab), -1, 1)
    
    ans := f64(curr) + f64(t)
    ans = max(ans, 0)
        if sim.cars[0].dead {
        //     ans /= 2
            ans -= 1
        }
    return ans
}

Car_Score :: struct($N : int){
    neural : learning.Neural(N),
    score : f64,
}

/*
steps - to liczba kroków 
cars - liczba prób w każdym kroku
mut_rate - rate z jakim mutujemy najlepszych zawodników
mut_num - liczba mutacji z jednego autka
take_bests - liczba NAJLEPSZYCH (wzgledem score) zawodników, których będziemy mutować
    UWAGA: jeśli mut_num*take_bests > cars, to nie wezmiemy wszystkich mutacji. 
           Jeśli mut_num*take_bests <= cars to będziemy losować wagi tak żeby samochodzików było co najwyżej arg cars
show_best - jeśli true, w każdym kroku pokazujemy najlepszy run
*/
learn :: proc(
    $CARS: int,
    $CHILD_AVG: int,
    $CHILD_MUT: int,
    $LEAVE_OUT: int,
    steps: u32 = 100,
    show_mod : int = 1,
    mut_rate: f64 = 0.2,
    net_size: [$N]u32 = NEURAL_SHAPE
) {
    CHILD_REROLL :: CARS - CHILD_AVG - CHILD_MUT - LEAVE_OUT
    REROLL_L :: 0
    REROLL_R :: CHILD_REROLL
    AVG_L :: REROLL_R
    AVG_R :: AVG_L + CHILD_AVG
    MUT_L :: AVG_R
    MUT_R :: MUT_L + CHILD_MUT
    LEAVE_L :: MUT_R
    LEAVE_R :: LEAVE_L + LEAVE_OUT
    assert(LEAVE_R == CARS)
    
    cars : [CARS]Car_Score(N)
    sim := simulation_on_map(TRAINING_MAP)
    sim_base := simulation_on_map(TRAINING_MAP)
    track_in, track_out := track_in_out(sim.track)

    car_score_len :: proc(it : sort.Interface) -> int {
        return int(CARS)
    }

    car_score_less :: proc(it : sort.Interface, i, j : int) -> bool {
        cs := ([^]Car_Score(N))(it.collection)
        return cs[i].score < cs[j].score
    }

    car_score_swap :: proc(it : sort.Interface, i, j : int) {
        cs := ([^]Car_Score(N))(it.collection)
        ci := cs[i]
        cs[i] = cs[j]
        cs[j] = ci
    }

    for i in 0..<CARS {
        cars[i].neural = learning.make_neural(net_size)
        learning.random_weights(&cars[i].neural)
    }
    

    for i in 0..<steps {
        rand.shuffle(cars[:])
        for car, i in cars {
            sim.cars = sim_base.cars
            cars[i].score = score(car.neural, sim = &sim, track_in = track_in, track_out = track_out)
        }

        sort.sort(sort.Interface{
            car_score_len,
            car_score_less,
            car_score_swap,
            &cars
        })

        // !!! GENETICS !!!

        for i in REROLL_L..<REROLL_R {
            learning.random_weights(&cars[i].neural)
        }
        
        for i in AVG_L..<AVG_R {
            j, k := random_pair(int(LEAVE_OUT))
            j += LEAVE_L
            k += LEAVE_L
            
            learning.average_neural(&cars[i].neural, cars[j].neural, cars[k].neural)
        }
        
        for i in MUT_L..<MUT_R {
            j := LEAVE_L + rand.int_max(LEAVE_OUT)
            learning.mutate_neural(&cars[i].neural, cars[j].neural)
        }
        if int(i) % show_mod == 0 {
            sim.cars = sim_base.cars
            score(cars[CARS - 1].neural, true, &sim, track_in, track_out)
        }

        if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
            break
        }
    }
    sim.cars = sim_base.cars

    sim2 := simulation_on_map(TEST_MAP)
    track_in2, track_out2 := track_in_out(sim2.track)
    // score(cars[CARS - 1].neural, true, &sim2, track_in2, track_out2)
    visual_simulation(&sim2, cars[CARS - 1].neural, track_in2, track_out2, true)
}