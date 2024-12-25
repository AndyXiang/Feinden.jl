using Base # methods for hash, isequal are provided.

include("Utils.jl")
# Basic Struct 

""" 
    Node
Basic components of `Topology`. Distinguished by its index in the topology and degree.

# Example
```julia-repl 
julia> Node(1, 3)
Node(1, 3)
```
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
    adj::Vector{Tuple{Int,Int}}
    comb_factor::Int
end

# default construction of Topology
Topology(node_list, adj) = Topology(node_list, adj, 1)

# Global Constants
const START_TOPOLOGIES = Dict( # start_topologies for loop 0, with different max_degree
    0 => [Topology([Node(1, 1), Node(2, 1)], [(1, 2)])],
    1 => [Topology([Node(1, 3), Node(2, 1)], [(1, 1), (1, 2)], 2)]
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
Return a boolean based on whether it is a external node which is obtained by `getnode(id, topology)`.

# Example 
```julia-repl
julia> top = Topology(
               [Node(1,3), Node(2,3), Node(3,1), Node(4,1)], 
               [(1,1), (1,2), (2,3), (2,4)]
             )
Topology: 2 External Nodes of 4 Nodes.
         Self Loop:       1 -- 1
         Propagator:      1 -- 2
         External Leg:    2 -- 3
         External Leg:    2 -- 4
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
    countnode(topology::Topology)
return numbers of node in the topology.
"""
function countnode(topology::Topology)
    return length(topology.node_list)
end

"""
    getnode(id::Int, topology::Topology)
return node of `topology` with given `id`.
"""
function getnode(id::Int, topology::Topology)
    return topology.node_list[id]
end

# methods for Base

"""
    hase(node::Node[, h::UInt])
Return the hash code for `Node` object. 

The result is `hase(node.id, hash(node.degree))` with implemented method of `hase(Int, UInt)`. 
The hash code is thus the same for node with same id and degree. 
"""
function Base.hash(node::Node)
    return hash(node.id, hash(node.degree))
end

function Base.hash(node::Node, h::UInt)
    return hash(node.id, hash(node.degree, h))
end

"""
    hase(topology::Topology[, h::UInt])
Return the hash code for `Topology` object. 

Result is `hash(topology.adj::Vector{Vector{Int}})`.
External nodes are considered to be distinguishable, which leads to different topologies.
"""
function Base.hash(topology::Topology)
    return hash(topology.adj)
end

function Base.hash(topology::Topology, h::UInt)
    return hash(topology.adj, h)
end

"""
    isequal(topology1::Topology, topology2::Topology)
Return whether `topology1` and `topology2` are equvialent when external nodes are considered as distinguishable.

Two topologies are equvialent when they have same `adj`.
The difference of `comb_factor` will be ignored, but a warning is raised.
"""
function Base.isequal(topology1::Topology, topology2::Topology)
    if topology1.adj == topology2.adj
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
    for edge in topology.adj
        if edge[1] == edge[2]
            println(io, "\t Self Loop:       $(edge[1]) -- $(edge[2])")
        elseif isexternal(edge[1], topology) || isexternal(edge[2], topology)
            println(io, "\t External Leg:    $(edge[1]) -- $(edge[2])")
        else
            println(io, "\t Propagator:      $(edge[1]) -- $(edge[2])")
        end
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
    for edge in topology.adj
        if edge[1] == edge[2]
            println(io, "\t Self Loop:       $(edge[1]) -- $(edge[2])")
        elseif isexternal(edge[1], topology) || isexternal(edge[2], topology)
            println(io, "\t External Leg:    $(edge[1]) -- $(edge[2])")
        else
            println(io, "\t Propagator:      $(edge[1]) -- $(edge[2])")
        end
    end
end

#"""
    #ishomeo(topology1::Topology, topology2::Topology)
#Return whether `topology1` and `topology2` are equvialent when external nodes are considered as indistinguishable.
#"""
#function ishomeo(topology1::Topology, topology2::Topology)
    #adj1, adj2 = copy(topology1.adj), copy(topology2.adj)
#end


# main functions & API

"""
    create_topology(num_external::Int, num_loop::Int ;[max_degree::Int=3, start_tologies::Vector{Topology}=nothing])
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
    # decide which starting topologies to use
    if isnothing(start_tologies)# using default starting topologies when no inp
        topologies = deepcopy(START_TOPOLOGIES[num_loop]) #num_loop starts at 0, max_degree starts at 3
    elseif !(topologies isa Vector{Topology}) # throw exception when start_topologies is not a vector
        throw(ArgumentError("starting topologies must be vector (1d array) of topologies"))
    else # using appropriate input starting topologies
        topologies = start_tologies
    end
    while true
        # topologies is a queue of toplogy
        operating_topology = popfirst!(topologies)
        if countexternal(operating_topology) == num_external
            # if the operating_topology has sufficient number of external nodes,
            # the iteration shall stop. 
            push!(topologies, operating_topology) # push back the operating_topology
            break
        end
        # main logic to create new topology: add new node on edges or promote node to higer degree
        @inbounds for i = 1:length(operating_topology.adj) # iterate over each edge of operating_topology
            # push new topology to topologies
            push!(topologies, _ct_add(i, operating_topology))
        end  # end iteration over edges
        @inbounds for node in operating_topology.node_list # promote nodes
            if (!isexternal(node)) && (node.degree < max_degree)
                # promote node that neither is external nor with degree bigger that max_degree
                push!(topologies, _ct_promote(node, operating_topology))
            end
        end # end iteration over nodes
    end # end recursion
    # examine equvialent topology and sum the comb_factor 
    return _ct_sum(topologies)
end

function _ct_add(edge_index::Int, operating_topology::Topology)
    # using deepcopy() to avoid changing the original node_list and adj 
    current_node_list = copy(operating_topology.node_list)
    current_adj = copy(operating_topology.adj)
    num_node = countnode(operating_topology)
    # pop out the currently iterating edge
    pop_out_edge = popat!(current_adj, edge_index)
    # add new nodes
    push!(current_node_list, Node(num_node + 1, 3))
    push!(current_node_list, Node(num_node + 2, 1))
    # create two new edge connecting to two nodes of pop-out edge (internal edges)
    push!(current_adj, (pop_out_edge[1], num_node + 1))
    push!(current_adj, (pop_out_edge[2], num_node + 1))
    # create new external edges
    push!(current_adj, (num_node + 1, num_node + 2))

    return Topology(current_node_list, current_adj, operating_topology.comb_factor)
end

function _ct_promote(node::Node, operating_topology::Topology)
    num_node = countnode(operating_topology)
    current_node_list = copy(operating_topology.node_list)
    current_adj = copy(operating_topology.adj)
    push!(current_node_list, Node(num_node + 1, 1))
    push!(current_node_list, Node(node.id, node.degree + 1))
    filter!(x -> x != node, current_node_list)
    push!(current_adj, (node.id, num_node + 1))

    return Topology(current_node_list, current_adj, operating_topology.comb_factor)
end

function _ct_sum(topologies::Vector{Topology})
    output_topologies = copy(topologies)
    repeated_count = Dict{Int,Int}()
    repeated_hash = Vector{UInt}()
    hash_list = [hash(x) for x in topologies]
    hash_list_sorted = sort(hash_list)
    sort_p = sortperm(hash_list)
    now = hash_list_sorted[1]
    count = 0
    @inbounds for i in 1:length(hash_list)
        if hash_list_sorted[i] != now
            if count > 1
                repeated_count[i] = count
                push!(repeated_hash, now)
            end
            now = hash_list_sorted[i]
            count = 1
        else
            count += 1
        end
    end
    if count > 1
        repeated_count[length(hash_list)] = count
        push!(repeated_hash, now)
    end
    new_topologies = Vector{Topology}()
    @inbounds for (id, num) in repeated_count
        top_id = sort_p[id]
        push!(new_topologies,
            Topology(
                topologies[top_id].node_list,
                topologies[top_id].adj,
                topologies[top_id].comb_factor / num
            )
        )
    end
    hash_set = Set(repeated_hash)
    filter!(x -> (hash(x) ∉ hash_set), output_topologies)
    append!(output_topologies, new_topologies)
    return output_topologies
end

