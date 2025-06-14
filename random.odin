package projekt

import "core:math/rand"

random_pair :: proc(m : int) -> (i, j : int){
    i = rand.int_max(m)
    j = rand.int_max(m)
    if(i == j){
        return random_pair(m)
    }
    return
}