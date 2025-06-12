package learning 

import "core:fmt"

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
    steps: u32 = 100,
    cars: u32 = 100,
    mut_rate: f64 = 0.2,
    mut_num: int = 5, 
    take_bests: int = 5,
    show_best: bool = false,
    net_size: [$N]u32 = [4]u32{6,6,4,2}
) {
    fmt.println(N)
}