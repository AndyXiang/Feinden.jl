# Basic Struct 

"""
    Topology
Topology of Feynman diagrams with distinguishable external edges.
"""
struct Topology
    node::Vector{Vector{Int}}
    comb_factor::Rational
end

# default construction of Topology
Topology(node) = Topology(node, 1 // 1)

# Global Constants
const START_TOPOLOGIES = Dict( # start topologies for loop 0, with different max_degree
    0 => [Topology([[2], [1]], 1 // 1)],
    1 => [Topology([[2], [1, 2, 2]], 1 // 2)],
    2 => [
        Topology([[2, 2, 2], [1, 1, 1]], 1 // 12),
        Topology([[1, 1, 1, 1]], 8),
        Topology([[1, 1, 2], [1, 2, 2]], 1 // 8)
    ],
)

const IRD_START_TOPOLOGIES = Dict( # start tologies for irreducible diagrams
    0 => START_TOPOLOGIES[0],
    1 => START_TOPOLOGIES[1],
    2 => [
        Topology([[2, 2, 2], [1, 1, 1]], 1 // 12),
        Topology([[1, 1, 1, 1]], 1 // 8),
    ]
)

# Utils

"""
    countexternal(topology::Topology)
return the number of external nodes in the topology.
"""
function countexternal(topology::Topology)
    num_external = 0
    for node in topology.node
        if length(node) == 1
            num_external += 1
        end
    end
    return num_external
end

"""
    countnode(topology::Topology)
return numbers of node in the topology.
"""
function countnode(topology::Topology)
    return length(topology.node)
end

"""
    getnode(id::Int, topology::Topology)
return node of `topology` with given `id`.
"""
function getnode(id::Int, topology::Topology)
    return topology.node[id]
end

# methods for Base

"""
    hash(topology::Topology[, h::UInt])
Return the hash code for `Topology` object. 

Result is `hash(topology.adj::Vector{Vector{Int}})`.
External nodes are considered to be distinguishable, which leads to different topologies.
"""
function Base.hash(topology::Topology, h::UInt=0x32a7a07f3e7cd1f9)
    return hash(topology.node, h)
end

"""
    isequal(topology1::Topology, topology2::Topology)
Return whether `topology1` and `topology2` are equvialent when external nodes are considered as distinguishable.

Two topologies are equvialent when they have same `adj`.
The difference of `comb_factor` will be ignored, but a warning is raised.
"""
function Base.isequal(topology1::Topology, topology2::Topology)
    if topology1.node == topology2.node
        if topology1.comb_factor != topology2.comb_factor
            println("Warning: isequal() method for topologies is returning true while comb_factors are unequal.")
        end
        return true
    else
        return false
    end
end

""" 
    Base.show(io::IO, mime::MIME"text/plain", topology::Topology)
Method for Base.show over topology in the plain form.

# Example 
julia> show(Topology(
                [Node(1,3), Node(2,3), Node(3,1), Node(4,1)], 
                [(1,1), (1,2), (2,3), (2,4)]
            ))
Topology with 2 External Nodes of 4 Nodes.
         Self Loop:       1 -- 1
         Propagator:      1 -- 2
         External Leg:    2 -- 3
         External Leg:    2 -- 4
"""
function Base.show(io::IO, mime::MIME"text/plain", topology::Topology)
    println(io, "Topology with $(countexternal(topology)) External Nodes of $(countnode(topology)) Nodes.")
    for current_node_id in eachindex(topology.node)
        printed_node = []
        self_loop = []
        node = topology.node[current_node_id]
        if length(node) == 1
            println(io, "\t External Leg:\t $current_node_id -- $(node[1]),")
        end
        for connect_node_id in topology.node[current_node_id]
            if connect_node_id in printed_node
                continue
            end
            if connect_node_id == current_node_id # self loop, appear as pair
                if connect_node_id in self_loop
                    filter!(x -> x != connect_node_id, self_loop)
                    continue
                else
                    println(io, "\t Self Loop:\t $connect_node_id -- $connect_node_id,")
                    push!(self_loop, connect_node_id)
                end
            end
            if length(topology.node[connect_node_id]) == 1
                println(io, "\t External Leg:\t $connect_node_id -- $current_node_id")
            else
                println(io, "\t Propagator:\t $current_node_id -- $connect_node_id")
            end
        end
        push!(printed_node, current_node_id)
    end
end


""" 
    Base.show(io::IO, topology::Topology)
Method for Base.show over topology in Julia_specific format.

# Example 
julia> create_topology(4, 0)

3-element Vector{Topology}:
 Topology with 4 External Nodes of 6 Nodes.
         External Leg:    1 -- 3
         External Leg:    3 -- 4
         External Leg:    2 -- 5
         Propagator:      3 -- 5
         External Leg:    5 -- 6

 Topology with 4 External Nodes of 6 Nodes.
         External Leg:    1 -- 3
         External Leg:    2 -- 3
         Propagator:      3 -- 5
         External Leg:    4 -- 5
         External Leg:    5 -- 6

 Topology with 4 External Nodes of 6 Nodes.
         External Leg:    2 -- 3
         External Leg:    3 -- 4
         External Leg:    1 -- 5
         Propagator:      3 -- 5
         External Leg:    5 -- 6
"""
function Base.show(io::IO, topology::Topology)
    println(io, "Topology with $(countexternal(topology)) External Nodes of $(countnode(topology)) Nodes.")
    printed_node = []
    for current_node_id in eachindex(topology.node)
        self_loop = []
        node = topology.node[current_node_id]
        if length(node) == 1
            println(io, "\t External Leg:\t $current_node_id -- $(node[1]),")
        end
        for connect_node_id in topology.node[current_node_id]
            if connect_node_id < current_node_id
                continue
            end
            if connect_node_id == current_node_id # self loop, appear as pair
                if connect_node_id in self_loop
                    filter!(x -> x != connect_node_id, self_loop)
                    continue
                else
                    println(io, "\t Self Loop:\t $connect_node_id -- $connect_node_id,")
                    push!(self_loop, connect_node_id)
                end
            end
            if length(topology.node[connect_node_id]) == 1
                println(io, "\t External Leg:\t $connect_node_id -- $current_node_id")
            else
                println(io, "\t Propagator:\t $current_node_id -- $connect_node_id")
            end
        end
        push!(printed_node, current_node_id)
    end
end


# main functions & API

"""
    create_topologies(num_loop::Int, num_external::Int; max_degree::Int)
Create topologies with given number of external nodes and loops. 
Degrees fo internal nodes are constraint by `max_degree`.
The recursion starts with default starting topologies, including tadpole topologies 
and ruducible topologies.

# Example
>julia create_topologies(1, 4)
"""
function create_topologies(num_loop::Int, num_external::Int; max_degree::Int=4)
    return _create_topology(num_external, START_TOPOLOGIES[num_loop], max_degree)
end

function create_ird_topologies(num_loop::Int, num_external::Int; max_degree::Int=4)
    return _create_topology(num_external, IRD_START_TOPOLOGIES[num_loop], max_degree)
end

function _create_topology(num_external, start_topologies::Vector{Topology}, max_degree::Int=3)
    if !(start_topologies isa Vector{Topology}) # throw exception when start_topologies is not a vector
        throw(ArgumentError("starting topologies must be vector (1d array) of topologies"))
    else # using appropriate input starting topologies
        topologies = copy(start_topologies)
    end
    while true
        # topologies is a queue of toplogy
        operating_topology = popfirst!(topologies)
        if countexternal(operating_topology) == num_external
            # if the operating_topology has sufficient number of external nodes,
            # the iteration shall stop. 
            push!(topologies, operating_topology)
            break
        end
        # main logic to create new topology: add new node on edges or promote node to higer degree
        append!(topologies, _ct_add(operating_topology))
        append!(topologies, _ct_promote(operating_topology, max_degree))
    end # end recursion
    # examine equvialent topology and sum the comb_factor 
    return _ct_sum!(topologies)
end

function _ct_add(operating_topology::Topology)
    output_topology = Vector{Topology}()
    num_node = countnode(operating_topology)
    for current_node_id in eachindex(operating_topology.node)
        current_node = operating_topology.node[current_node_id]
        for connect_node_id in current_node
            if connect_node_id < current_node_id
                continue
            end
            new_node = [
                ((i == current_node_id) || (i == connect_node_id)) ?
                copy(operating_topology.node[i]) : operating_topology.node[i]
                for i in eachindex(operating_topology.node)
            ]
            push!(new_node, [num_node + 2, current_node_id, connect_node_id])
            push!(new_node, [num_node + 1])
            # append!(
            #     new_node,
            #     [[num_node + 2, current_node_id, connect_node_id], [num_node + 1]]
            # )
            replacefirst!(new_node[current_node_id], connect_node_id => num_node + 1)
            replacefirst!(new_node[connect_node_id], current_node_id => num_node + 1)
            push!(output_topology, Topology(new_node, operating_topology.comb_factor))
        end
    end
    return output_topology
end

function _ct_promote(operating_topology::Topology, max_degree::Int)
    output_topology = Vector{Topology}()
    num_node = countnode(operating_topology)
    for current_node_id in eachindex(operating_topology.node)
        degree = length(operating_topology.node[current_node_id])
        if 1 < degree < max_degree
            new_node = deepcopy(operating_topology.node)
            push!(new_node, [current_node_id])
            push!(new_node[current_node_id], num_node + 1)
            push!(output_topology, Topology(new_node, operating_topology.comb_factor))
        end
    end
    return output_topology
end

function _ct_sum!(topologies::Vector{Topology})
    # find duplicates and change the combinatorial factor
    hash_dict = Dict{UInt,Vector{Tuple{Int, Rational}}}()
    for i in eachindex(topologies)
        h = hash(sort!.(topologies[i].node))
        if haskey(hash_dict, h)
            push!(hash_dict[h], (i, topologies[i].comb_factor))
        else
            hash_dict[h] = [(i, topologies[i].comb_factor)]
        end
    end
    new_topologies = Vector{Topology}()
    duplicate_id = []
    for id_arr in values(hash_dict)
        if length(id_arr) > 1
            #append!(duplicate_id, [x[1] for x in id_arr])
            #comb_factor = sum([x[2] for x in id_arr])
            comb_factor = 0
            for x in id_arr
                push!(duplicate_id, x[1])
                comb_factor += x[2]
            end
            push!(new_topologies,
                Topology(
                    topologies[id_arr[1][1]].node,
                    comb_factor
                )
            )
        end
    end
    deleteat!(topologies, sort!(duplicate_id))
    append!(topologies, new_topologies)
    return topologies
end

