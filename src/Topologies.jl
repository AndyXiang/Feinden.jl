module Topologies

export Topology, create_topology, show

using Base

"""
    Topology
Store topology as undirective graph.
"""
mutable struct Topology
    #max_node_degree::Int 
    num_node::Int
    num_external::Int
    external_list::Array{Int}
    adjacency_list::Vector{Vector{Int}}
end

"""
    List of `start_topologies` using `num_loop` as indices.
"""
const START_TOPOLOGIES = [
    [Topology(2, 2, [1,2],[[1,2]])],
    [Topology(2, 2, [2],[[1,1],[1,2]])]
]

"""
    create_topology(num_external::Int, num_loop::Int, [max_degree::Int=3, start_tologies::Array{Topology}=nothing])
Create topologies with given number of external nodes and loops. 
Degrees fo internal nodes are constraint by `max_degree`.
Recursion starts with `start_tologies`, whose default value is stored in Consts.START_TOPOLOGIES.

# Logic
Starting with  `start_tologies` and recursively create new topology by iterating on each edges. 
For `max_degree=n`, one edge is popped out, and new edges of number `n-1` are created.

# Example
>julia create_topology(4, 1)

"""
function create_topology(num_external::Int, 
    num_loop::Int, 
    max_degree::Int=3, 
    start_tologies=nothing)
    # Decide which starting topologies to use
    if isnothing(start_tologies)# Using default starting topologies when no inp
        topologies = START_TOPOLOGIES[num_loop+1] #num_loop starts at 0
    elseif !(topologies isa Vector) # throw exception when start_topologies is not a vector
        throw(ArgumentError("starting topologies must be vector (1d array) of topologies"))
    else # Using appropriate input starting topologies
        topologies = start_tologies 
    end

    output_topologies = [] # init the output array of topologies
    key = 0
    while true # traverse tree of topology with breadth-first
        #break recursion when all topologies are traversed;
        if isempty(topologies) 
            break   
        end
        operating_topology = popfirst!(topologies) # pop out first topology
        if operating_topology.num_external == num_external
        # add the operating_topology with sufficient external legs in the output
            push!(output_topologies, operating_topology)
            continue
        elseif operating_topology.num_external > num_external
            continue # pop this topology out and do nothing since it has extra external legs
        end
        # main logic to create new topology
        num_node = operating_topology.num_node
        for i = 1:length(operating_topology.adjacency_list) # iterate over each edge of operating_topology
            # using deepcopy() to avoid changing the original adjacency_list
            current_adjacency_list = deepcopy(operating_topology.adjacency_list)
            current_external_list = deepcopy(operating_topology.external_list)
            # pop out the currently iterating edge
            pop_out_edge = popat!(current_adjacency_list, i)
            # create two new edge connecting to two nodes of pop-out edge (internal edges)
            push!(current_adjacency_list, [pop_out_edge[1], num_node+1])
            push!(current_adjacency_list, [pop_out_edge[2], num_node+1])
            # create new external edges 
            for j = 1:max_degree-2
                push!(current_adjacency_list, [num_node+1, num_node+j+1])
                push!(current_external_list, num_node+j+1)
            end
            # push new topology to topologies
            push!(topologies, 
                Topology(num_node+max_degree-1, 
                    operating_topology.num_external+max_degree-2, 
                    current_external_list,
                    current_adjacency_list)
            )
        end 
    end
    return output_topologies
end

""" 
    display_topology(topology::Topology)
Display single topology. Basic properties are printed.
"""
function display_topology(topology::Topology)
    print("Topology: $(topology.num_external) External Nodes of $(topology.num_node) Nodes.\n")
    for i = 1:topology.num_node
        for edge in topology.adjacency_list
            if i in edge
                other_node = filter(x -> x!=i, edge)[1]
                if edge[1] == i && edge[2] == i
                    print("\t Self Loop:    $i <--> $i \n")
                elseif i in topology.external_list
                    print("\t External Leg: $i --> $(other_node) \n")
                elseif !(other_node in topology.ex)
                    print("\t Propagator:   $(edge[1]) --> $(edge[2]) \n")
                end
            end
        end
    end
end

end

