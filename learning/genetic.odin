package learning 

import "core:fmt"
import "core:sort"

score :: proc(car : Neural($N)) -> f64 {
    return 0
}

Car_Score :: struct($N : int){
    neural : Neural(N),
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
    $CARS: u32,
    steps: u32 = 100,
    mut_rate: f64 = 0.2,
    mut_num: int = 5, 
    take_bests: int = 5,
    show_best: bool = false,
    net_size: [$N]u32 = [4]u32{6,6,4,2}
) {
    cars : [CARS]Car_Score(N)

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
        cars[i].neural = make_neural(net_size)
    }

    for i in 0..<steps {
        for car, i in cars {
            cars[i].score = score(car.neural)
        }

        sort.sort(sort.Interface{
            car_score_len,
            car_score_less,
            car_score_swap,
            &cars
        })
    }

}