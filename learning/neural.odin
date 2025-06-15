package learning

import "core:math/rand"
import "core:math"

// import function for evaluation

relu :: proc(x: f64) -> f64 {
    return math.max(0, x)
}

sigmoid :: proc(x : f64) -> f64 {
    return 1 / (1 + math.exp(-x))
}

tanh :: proc(x: f64) -> f64 {
    return math.tanh(x)
}

activation :: tanh

// [from, to)
Ival :: struct {
    from: u32,
    to: u32
}

Node :: struct {
    edges: []f64,
    nodes: []Node,
    eval : f64,
    b: f64
}

Layer :: struct {
    nodes: []Node
}


Neural :: struct($N : int){
    net_size: [N]u32,
    layers: []Layer,
    
    weights: []f64,
    nodes: []Node
}

make_neural :: proc(net_size: [$N]u32) -> Neural(N) {
    nodes_num: u32 = net_size[0]
    edges: u32 = 0
    for i := 1; i < len(net_size); i+=1 {
        edges += net_size[i-1]*net_size[i]
        nodes_num += net_size[i]
    } 
    
    w_size := edges
    ptr : Neural(N)
    ptr.weights = make([]f64, w_size)
    ptr.net_size = net_size
    nodes := make([]Node, nodes_num)
    ptr.nodes = nodes
    ptr.layers = make([]Layer, len(net_size))
    
    indices: u32 = net_size[0]
    edges_id: u32 = 0
    ptr.layers[0].nodes = nodes[:net_size[0]]

    for i := 1; i < len(net_size); i+=1 {
        prev_start := indices - net_size[i-1]
        curr_start := indices
        ptr.layers[i].nodes = nodes[curr_start : curr_start + net_size[i]]
        for j: u32 = 0; j < net_size[i]; j+=1 {
            curr := curr_start + j
            nodes[curr].edges = ptr.weights[edges_id : edges_id + net_size[i-1]]
            nodes[curr].nodes = ptr.nodes[prev_start : prev_start + net_size[i-1]]
            edges_id += net_size[i-1]
        }
        indices += net_size[i]
    }

    
    return ptr
}


delete_neural :: proc(ptr: Neural($N)) {
    delete(ptr.weights)
    delete(ptr.nodes)
    delete(ptr.layers)
}

random_weights :: proc(ptr: ^Neural($N)) {
    for i := 0; i < len(ptr.weights); i+=1 {
        ptr.weights[i] = rand.float64_uniform(-1,1)
    }

    for i := 0; i < len(ptr.nodes); i+=1 {
        ptr.nodes[i].b = rand.float64_uniform(-1, 1)
    }
}

compute_node :: proc(node: ^Node) {
    num : f64 = 0
    for i: int = 0; i < len(node.edges); i+=1 {
        num += node.edges[i] * node.nodes[i].eval
    }

    num += node.b
    node.eval = activation(num)
}

compute_layer :: proc(ptr: ^Layer) {
    for &node in ptr.nodes {
        compute_node(&node)
    }
}


compute :: proc(ptr: Neural($N), input: []f64) -> (f32, f32){
    using ptr

    for &node, i in ptr.layers[0].nodes {
        node.eval = input[i]
    }
    
    for &layer in ptr.layers[1:] {
        compute_layer(&layer)
    }

    out_nodes := ptr.layers[len(ptr.layers)-1].nodes
    return f32(out_nodes[0].eval), f32(out_nodes[1].eval)
}

average_neural :: proc(out : ^Neural($N),  in0, in1 : Neural(N)) {
    for i in 0..<len(out.weights) {
        out.weights[i] = (in0.weights[i] + in1.weights[i]) / 2.0
    }

    for i in 0..<len(out.nodes) {
        out.nodes[i].b = (in0.nodes[i].b + in1.nodes[i].b) / 2.0
    }
}

mutate_neural :: proc(out : ^Neural($N),  in0 : Neural(N), mut_rate := 1.0) {
    for i in 0..<len(out.weights) {
        out.weights[i] = in0.weights[i]
        out.weights[i] += rand.float64_uniform(-mut_rate, mut_rate)
    }

    for i in 0..<len(out.nodes) {
        out.nodes[i].b = in0.nodes[i].b
        out.nodes[i].b += rand.float64_uniform(-mut_rate, mut_rate)
    }
}