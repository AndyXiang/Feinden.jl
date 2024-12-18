export Topology, create_topology, display_topology

# Basic Struct In This Module

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
mutable struct Topology
    node_list::Vector{Node}
    adjacency_list::Vector{Vector{Int}}
end

# Global Constants
"""
    List of `start_topologies` using `num_loop` as key.
"""
const START_TOPOLOGIES = Dict( # start_topologies for loop 0, with different max_degree
    0 => [Topology([Node(1, 1), Node(2, 1)], [[1,2]])] ,
    1 => [Topology([Node(1, 3), Node(2, 1)], [[1,1], [1,2]])]
)

# Utils

"""
    isExternal(node::Node)
For a given node, return a boolean based on whether it is a external node.

Logic: external node has degree of 1.

# Example 
julia> isExternal(Node(1, 1))

true

julia> isExternal(Node(1, 3))

false
"""
function isexternal(node::Node)
    if node.degree == 1
        return true
    else
        return false
    end
end

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
    length(topology::Topology)
return numbers of node in the topology.
"""
function getnodenumber(topology::Topology)
    return length(topology.node_list)
end

"""
    get_node(id::Int, topology::Topology)
return node of `topology` with given id.
"""
function getnode(id::Int, topology::Topology)
    return topology.node_list[id]
end


# main functions & API

"""
    create_topology(num_external::Int, num_loop::Int, [max_degree::Int=3, start_tologies::Array{Topology}=nothing])
Create topologies with given number of external nodes and loops. 
Degrees fo internal nodes are constraint by `max_degree`.
Recursion starts with `start_tologies`, whose default value is stored in Consts.START_TOPOLOGIES.

# Logic
Starting with  `start_tologies` with n external nodes and recursively create new topology with n+1 external nodes 
For `max_degree=n`, one edge is popped out, and new edges of number `n-1` are created.

# Example
>julia create_topology(4, 1)
"""
function create_topology(
    num_external::Int, 
    num_loop::Int, 
    max_degree::Int=3, 
    start_tologies=nothing
)
    # Decide which starting topologies to use
    if isnothing(start_tologies)# Using default starting topologies when no inp
        topologies = START_TOPOLOGIES[num_loop] #num_loop starts at 0, max_degree starts at 3
    elseif !(topologies isa Vector{Topology}) # throw exception when start_topologies is not a vector
        throw(ArgumentError("starting topologies must be vector (1d array) of topologies"))
    else # Using appropriate input starting topologies
        topologies = start_tologies 
    end
    output_topologies = Vector{Topology}() # init the output array of topologies
    for n in 1:(num_external-countexternal(topologies[1])) # traverse tree of topology with breadth-first
        if n != 1
            topologies = output_topologies
            output_topologies = Vector{Topology}()
        end
        for operating_topology in topologies
            # main logic to create new topology: add new node on edges or promote nodes to higer degree
            num_node = getnodenumber(operating_topology)
            for i = 1:length(operating_topology.adjacency_list) # iterate over each edge of operating_topology
                # using deepcopy() to avoid changing the original node_list and adjacency_list 
                current_node_list = deepcopy(operating_topology.node_list)
                current_adjacency_list = deepcopy(operating_topology.adjacency_list)
                # pop out the currently iterating edge
                pop_out_edge = popat!(current_adjacency_list, i)
                # add new nodes
                push!(current_node_list, Node(num_node+1, 3))
                push!(current_node_list, Node(num_node+2, 1))
                # create two new edge connecting to two nodes of pop-out edge (internal edges)
                push!(current_adjacency_list, [pop_out_edge[1], num_node+1])
                push!(current_adjacency_list, [pop_out_edge[2], num_node+1])
                # create new external edges
                push!(current_adjacency_list, [num_node+1, num_node+2])
                # push new topology to topologies
                push!(output_topologies, Topology(current_node_list,current_adjacency_list))
            end  # end iteration over edges
            for node in operating_topology.node_list # promote nodes
                if (!isexternal(node)) && node.degree < max_degree
                    current_node_list = deepcopy(operating_topology.node_list)
                    current_adjacency_list = deepcopy(operating_topology.adjacency_list)
                    push!(current_node_list, Node(num_node+1, 1)),
                    push!(current_adjacency_list, [node.id, num_node+1])
                    # add new topology
                    push!(output_topologies, Topology(current_node_list,current_adjacency_list))
                end
            end # end iteration over nodes
        end # end iteration over topologies
    end # end recursion
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

""" 
    display_topology(topology::Topology)
Display vector of topologies. Basic properties are printed.

# Example 
julia> display_topology()

Topology: 4 External Nodes of 6 Nodes.

External Leg:    2 -- 3

External Leg:    3 -- 4

External Leg:    1 -- 5

Propagator:      3 -- 5

External Leg:    5 -- 6
"""

function display_topology(topologies::Vector{Topology})
    i = 1
    for topology in topologies
        print("Topology $i : $(countexternal(topology)) External Nodes of $(getnodenumber(topology)) Nodes.\n")
        for edge in topology.adjacency_list
            if edge[1] == edge[2]
                print("\t Self Loop:        $(edge[1]) -- $(edge[2]) \n")
            elseif isexternal(edge[1], topology) || isexternal(edge[2], topology)
                print("\t External Legs:    $(edge[1]) -- $(edge[2]) \n")
            else 
                print("\t Propagator:       $(edge[1]) -- $(edge[2]) \n")
            end # end print each edge
        end # end iteration over edges
        i += 1
    end # end iteration over topologies
end

