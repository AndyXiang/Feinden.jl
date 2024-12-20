using Base # methods for hash, isequal are provided.

include("Utils.jl")
# Basic Struct 

""" 
    Node
Basic components of Topology. 

# Properties
`id`: number to identify the node in a `Topology` object.

`degree`: degree of nodes (how many nodes connecting to this nodes). 
"""
struct Node
    id::Int
    degree::Int
end

"""
    Topology
Store topology as undirective graph.
"""
struct Topology
    node_list::Vector{Node}
    adjacency_list::Vector{Vector{Int}}
    combinatorial_factor::Int
end

# default construction of Topology
Topology(node_list, adjacency_list) = Topology(node_list, adjacency_list, 1)

# Global Constants
"""
    const START_TOPOLOGIES
List of `start_topologies` using `num_loop` as key.
"""
const START_TOPOLOGIES = Dict( # start_topologies for loop 0, with different max_degree
    0 => [Topology([Node(1, 1), Node(2, 1)], [[1, 2]])],
    1 => [Topology([Node(1, 3), Node(2, 1)], [[1, 1], [1, 2]], 2)]
)

# Utils

"""
    isexternal(node::Node)
For a given node, return a boolean based on whether it is a external node.

Logic: external node has degree of 1.

# Example 
```julia-repl
julia> isexternal(Node(1, 1))
true
julia> isexternal(Node(1, 3))
false
```
"""
function isexternal(node::Node)
    if node.degree == 1
        return true
    else
        return false
    end
end

"""
    isexternal(id::Int, topology::Topology)
Return a boolean based on whether it is a external node which is obtained by `getnode(id, topology)`

Logic: external node has degree of 1.

# Example 
```julia-repl
julia> isexternal(Node(1, 1))
true
julia> isexternal(Node(1, 3))
false
```
"""
function isexternal(id::Int, topology::Topology)
    node = getnode(id, topology)
    return isexternal(node)
end

"""
    countexternal(topology::Topology)
return the number of external nodes in the topology.
"""
function countexternal(topology::Topology)
    num_external = 0
    for node in topology.node_list
        if isexternal(node)
            num_external += 1
        end
    end
    return num_external
end

"""
    getnodenumber(topology::Topology)
return numbers of node in the topology.
"""
function getnodenumber(topology::Topology)
    return length(topology.node_list)
end

"""
    getnode(id::Int, topology::Topology)
return node of `topology` with given `id`.
"""
function getnode(id::Int, topology::Topology)
    return topology.node_list[id]
end

"""
    hase(node::Node[, h::UInt])
Return the hash code for `Node` object. 

The result is `hase(node.id, hash(node.degree))` with implemented method of `hase(Int, UInt)`. 
The hash code is thus the same for node with same id and degree. 
"""
function Base.hash(node::Node)
    return Base.hash(node.id, hash(node.degree))
end

function Base.hash(node::Node, h::UInt)
    return Base.hash(node.id, hash(node.degree, h))
end

"""
    hase(topology::Topology[, h::UInt])
Return the hash code for `Topology` object. 

Result is `hash(topology.adjacency_list::Vector{Vector{Int}})`.
External nodes are considered to be distinguishable, which leads to different topologies.
"""
function Base.hash(topology::Topology)
    return Base.hash(topology.adjacency_list)
end

function Base.hash(topology::Topology, h::UInt)
    return Base.hash(topology.adjacency_list, h)
end

"""
    isequal(topology1::Topology, topology2::Topology)
Return whether `topology1` and `topology2` are equvialent.

Two topologies are equvialent when they have same `adjacency_list`.
The difference of `combinatorial_factor` will be ignored, but a warning is raised.
"""
function Base.isequal(topology1::Topology, topology2::Topology)
    if topology1.adjacency_list == topology2.adjacency_list
        if topology1.combinatorial_factor != topology2.combinatorial_factor
            println("Warning: isequal() method for topologies is returning true while combinatorial_factors are unequal.")
        end
        return true
    else
        return false
    end
end


# main functions & API

"""
    create_topology(num_external::Int, num_loop::Int ;[max_degree::Int=3, start_tologies::Array{Topology}=nothing])
Create topologies with given number of external nodes and loops. 
Degrees fo internal nodes are constraint by `max_degree`.
Recursion starts with `start_tologies`, whose default value is stored in Consts.START_TOPOLOGIES.

# Logic
Starting with  `start_tologies` with n external nodes and recursively create new topology with n+1 external nodes 
For `max_degree=n`, one edge is popped out, and new edges of number `n-1` are created.

# Example
>julia create_topology(4, 1)
"""
function create_topology(num_external::Int, num_loop::Int; max_degree::Int=3, start_tologies=nothing)
    # Decide which starting topologies to use
    if isnothing(start_tologies)# Using default starting topologies when no inp
        topologies = deepcopy(START_TOPOLOGIES[num_loop]) #num_loop starts at 0, max_degree starts at 3
    elseif !(topologies isa Vector{Topology}) # throw exception when start_topologies is not a vector
        throw(ArgumentError("starting topologies must be vector (1d array) of topologies"))
    else # Using appropriate input starting topologies
        topologies = start_tologies
    end
    while true
        operating_topology = popfirst!(topologies)
        if countexternal(operating_topology) == num_external
            push!(topologies, operating_topology)
            break
        end
        # main logic to create new topology: add new node on edges or promote nodes to higer degree
        num_node = getnodenumber(operating_topology)
        combinatorial_factor = operating_topology.combinatorial_factor
        @inbounds for i = 1:length(operating_topology.adjacency_list) # iterate over each edge of operating_topology
            # push new topology to topologies
            push!(topologies, _ct_add(operating_topology, i, num_node, combinatorial_factor))
        end  # end iteration over edges
        @inbounds for node in operating_topology.node_list # promote nodes
            if (!isexternal(node)) && (node.degree < max_degree)
                # promote node that neither is external nor with degree bigger that max_degree
                push!(topologies, _ct_promote(operating_topology, node, num_node, combinatorial_factor))
            end
        end # end iteration over nodes
    end # end recursion
    # examine equvialent topology and sum the combinatorial_factor 
    return _sum(topologies)
end

function _ct_add(operating_topology::Topology, edge_index::Int, num_node::Int, combinatorial_factor::Int)
    # using deepcopy() to avoid changing the original node_list and adjacency_list 
    current_node_list = deepcopy(operating_topology.node_list)
    current_adjacency_list = deepcopy(operating_topology.adjacency_list)
    # pop out the currently iterating edge
    pop_out_edge = popat!(current_adjacency_list, edge_index)
    # add new nodes
    push!(current_node_list, Node(num_node + 1, 3))
    push!(current_node_list, Node(num_node + 2, 1))
    # create two new edge connecting to two nodes of pop-out edge (internal edges)
    push!(current_adjacency_list, [pop_out_edge[1], num_node + 1])
    push!(current_adjacency_list, [pop_out_edge[2], num_node + 1])
    # create new external edges
    push!(current_adjacency_list, [num_node + 1, num_node + 2])

    return Topology(current_node_list, current_adjacency_list, combinatorial_factor)
end

function _ct_promote(operating_topology::Topology, node::Node, num_node::Int, combinatorial_factor::Int)
    current_node_list = deepcopy(operating_topology.node_list)
    current_adjacency_list = deepcopy(operating_topology.adjacency_list)
    push!(current_node_list, Node(num_node + 1, 1))
    push!(current_node_list, Node(node.id, node.degree + 1))
    filter!(x -> x != node, current_node_list)
    push!(current_adjacency_list, [node.id, num_node + 1])

    return Topology(current_node_list, current_adjacency_list, combinatorial_factor)
end

function _ct_sum(topologies::Vector{Topology})
    output_topologies = deepcopy(topologies)
    repeated_count = Dict{Int, Int}()
    repeated_hash = Dict{Int, UInt}()
    hash_list = [hash(x) for x in topologies]
    hash_list_sorted = sort(hash_list)
    sort_p = sortperm(hash_list)
    now = hash_list_sorted[1]
    count = 0
    @inbounds for i in 1:length(hash_list)
        if hash_list_sorted[i] != now
            if count > 1
                repeated_count[i] = count
                repeated_hash[i] = now
            end
            now = hash_list_sorted[i]
            count = 1
        else 
            count += 1
        end
    end
    if count > 1
        repeated_count[length(hash_list)] = count
        repeated_hash[length(hash_list)] = now
    end
    new_topologies = Vector{Topology}()
    @inbounds for (id, num) in repeated_count
        top_id = sort_p[id]
        push!(new_topologies, 
            Topology(
                topologies[top_id].node_list,
                topologies[top_id].adjacency_list,
                topologies[top_id].combinatorial_factor / num
            )
        )
    end
    filter!(x -> (hash(x) ∉ values(repeated_hash)), output_topologies)
    append!(output_topologies, new_topologies)
    return output_topologies
end


""" 
    display_topology(topology::Topology)
Display single topology. Basic properties are printed.

# Example 
julia> display_topology(Topology())

Topology: 4 External Nodes of 6 Nodes.
    External Leg:    2 -- 3
    External Leg:    3 -- 4
    External Leg:    1 -- 5
    Propagator:      3 -- 5
    External Leg:    5 -- 6
"""
function display_topology(topology::Topology)
    print("Topology: $(countexternal(topology)) External Nodes of $(getnodenumber(topology)) Nodes.\n")
    for edge in topology.adjacency_list
        if edge[1] == edge[2]
            print("\t Self Loop:       $(edge[1]) -- $(edge[2]) \n")
        elseif isexternal(edge[1], topology) || isexternal(edge[2], topology)
            print("\t External Leg:    $(edge[1]) -- $(edge[2]) \n")
        else
            print("\t Propagator:      $(edge[1]) -- $(edge[2]) \n")
        end
    end
end
