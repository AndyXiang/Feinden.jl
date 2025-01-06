mutable struct Vertex
    id::Int 
    degree::Int 
    connection::Vector{Vector{Union{Int, Missing}}}
end
Vertex(node::Node) = Vertex(node.id, node.degree, Vector{Vector{Union{Int, Missing}}}())

mutable struct Diagram
    verli::Vector{Vertex} # list of vertex
    comb_factor::Int
end

# Main API

function insert_field(
    topology::Topology, 
    particles_id::Pair{Vector{Int}, Vector{Int}}, 
    model::Model = CURRENT_MODEL
)
    diagram = _convert_topology(topology)
    # insert external fields 
    diagram_arr = [_insert_external!(diagram, particles_id)]
    output_diagram = Vector{Diagram}()
    while true
        inserting_diagram = popfirst!(diagram_arr)
        # find one not-inserted propagator of inserting_diagram
        inserting_vertex_id = findlast(
            x->ismissing(sum(sum(x.connection))), 
            inserting_diagram.verli
        )
        if isnothing(inserting_vertex_id)
            push!(output_diagram, inserting_diagram)
            if isempty(diagram_arr) # stop iteration when all diagrams are completely inserted
                break 
            end
            continue
        end
        # iterate over interaction vertices
        for interaction in model.interaction
            new_diagrams = _insert_internal(
                inserting_diagram, 
                inserting_vertex_id, 
                interaction
            )
            if new_diagrams == 0
                continue
            else 
                append!(diagram_arr, new_diagrams)
            end
        end
        if isempty(diagram_arr) # stop iteration when all diagrams are generated
            break 
        end
    end
    incorrect_insertion = []
    for i in eachindex(output_diagram)
        if !(_check_insertion(output_diagram[i], model.interaction)) # function returning false for incorrect insertion
            push!(incorrect_insertion, i)
        end
    end
    deleteat!(output_diagram, incorrect_insertion)
    _remove_duplicate!(output_diagram)
    return output_diagram
end

function insert_field(
    topologies::Vector{Topology}, 
    particles_id::Pair{Vector{Int}, Vector{Int}}, 
    model::Model = CURRENT_MODEL
)
    output_diagram = Vector{Diagram}()
    for topology in topologies
        append!(output_diagram, insert_field(topology, particles_id, model))
    end 
    return output_diagram
end

function _convert_topology(topology::Topology) # create start diagram from topology
    verli = [Vertex(node) for node in topology.node_list]
    for edge in topology.adj 
        for vertex in verli 
            if vertex.id in edge
                if edge[1] == edge[2] # self-loop
                    push!(vertex.connection, [vertex.id, missing])
                    push!(vertex.connection, [vertex.id, missing])
                else
                    push!(vertex.connection, [get_another_element(edge, vertex.id), missing])
                end
            end
        end
    end
    return Diagram(verli, topology.comb_factor)
end

function _insert_external!(diagram::Diagram, particles_id::Pair{Vector{Int}, Vector{Int}}) 
    i = 1
    num_incoming = length(particles_id[1])
    # find all external vertex and store the assgined particle in external_leg_dict
    for vertex in diagram.verli 
        if vertex.degree == 1
            if i <= num_incoming
                vertex.connection[1][2] = particles_id[1][i] 
                other_vertex = diagram.verli[vertex.connection[1][1]]
                connect_pos = findfirst(x->x[1] == vertex.id, other_vertex.connection)
                other_vertex.connection[connect_pos][2] = getanti(particles_id[1][i])
            else 
                vertex.connection[1][2] = getanti(particles_id[2][i-num_incoming]) 
                other_vertex = diagram.verli[vertex.connection[1][1]]
                connect_pos = findfirst(x->x[1] == vertex.id, other_vertex.connection)
                other_vertex.connection[connect_pos][2] = particles_id[2][i-num_incoming]
            end
            i += 1
        end
    end
    return diagram
end

function _insert_internal(inserting_diagram::Diagram, inserting_vertex_id::Int, interaction::Interaction)
    # following function returning 0 for incorrect interaction, otherwise 
    # returning a nonzero value.
    possible_insertion = _check_interaction(
        inserting_diagram.verli[inserting_vertex_id], 
        interaction
    ) 
    if possible_insertion == 0
        return 0 # no possible insertion -> delete this diagram
    end
    new_diagrams = Vector{Diagram}()
    possible_insertion = unique!(permutations(possible_insertion))
    selfloop_record = []
    for insertion in possible_insertion
        if hash(Set(insertion)) in selfloop_record
            continue
        end
        new_diagram = deepcopy(inserting_diagram)
        inserting_vertex = new_diagram.verli[inserting_vertex_id]
        i = 1
        for con in inserting_vertex.connection
            if i > length(insertion)
                break 
            end
            if !ismissing(con[2])
                continue
            end
            con[2] = insertion[i]
            connect_vertex = new_diagram.verli[con[1]]
            for coni in connect_vertex.connection
                if (coni[1] == inserting_vertex_id) && ismissing(coni[2])
                    coni[2] = getanti(insertion[i])
                end
            end
            if (con[1] == inserting_vertex_id) && (getanti(insertion[i]) != insertion[i]) # self-loop 
                push!(selfloop_record, hash(Set(insertion)))
            end
            i += 1
        end
        push!(new_diagrams, new_diagram)
    end
    return new_diagrams
end

function _check_interaction(vertex::Vertex, interaction::Interaction)
    interaction_comb = interaction.comb
    not_correct_interaction_symbol = false
    if length(interaction_comb) != vertex.degree
        return 0
    end
    for connection in vertex.connection
        if ismissing(connection[2])
            continue
        end 
        if connection[2] ∉ interaction_comb
            not_correct_interaction_symbol = true
            break
        else 
            index_to_remove = findfirst(x->x==connection[2], interaction_comb)
            interaction_comb = deleteat(interaction_comb, index_to_remove)
        end
    end
    if not_correct_interaction_symbol
        return 0
    end
    # for i in eachindex(interaction_comb)
    #     if -interaction_comb[i] in interaction_comb
    #         interaction_comb[i] = -interaction_comb[i]
    #     end
    # end
    return interaction_comb
end

function _check_insertion(diagram::Diagram, interactions::Vector{Interaction})
    interaction_comb_arr = [sort(interactions[i].comb) for i in eachindex(interactions)]
    for vertex in diagram.verli 
        if vertex.degree == 1
            continue
        end
        vertex_insertion = sort([vertex.connection[i][2] for i = 1:vertex.degree])
        if !(vertex_insertion in interaction_comb_arr)
            return false 
        end
    end 
    return true
end

# function _check_selfloop(diagram::Diagram)
#     selfloop = []
#     for prop in diagram.propli
#         if prop.edge[1] == prop.edge[2]
#             push!(selfloop, (prop.id, abs(prop.field_id)))
#         end 
#     end
#     return selfloop
# end

function _remove_duplicate!(diagram_arr::Vector{Diagram})
    duplicate_dict = Dict{UInt, Int}()
    delete_arr = [] 
    for i in eachindex(diagram_arr)
        h = hash(diagram_arr[i])
        if haskey(duplicate_dict, h)
            try
                diagram_arr[i].comb_factor /= 2
            catch e 
                if e isa InexactError
                    println(diagram_arr[i])
                    println(diagram_arr[duplicate_dict[h]])
                    throw(error("one error"))
                end 
            end
            push!(delete_arr, duplicate_dict[h])
        else 
            duplicate_dict[h] = i
        end
    end
    deleteat!(diagram_arr, sort!(delete_arr))
    # delete_arr = [] 
    # selfloop_record = []
    # for i in eachindex(diagram_arr)
    #     selfloop = _check_selfloop(diagram_arr[i])
    #     if !isempty(selfloop)
    #         if selfloop in selfloop_record
    #             push!(delete_arr, i)
    #         else 
    #             push!(selfloop_record, selfloop)
    #         end
    #     end
    # end
    # deleteat!(diagram_arr, sort!(delete_arr))
end

# function Base.show(io::IO, diagram::Diagram)
#     println(io, "Diagram with combinatorial factor of $(diagram.comb_factor)")
#     for prop in diagram.propli
#         if prop.type == "outgoing"
#             name = getname(getanti(prop.field_id))
#         else 
#             name = getname(prop.field_id)
#         end
#         println(io, "Propagator(field = $name, $(prop.field_id), $(prop.type)):\t$(prop.edge[1]) -- $(prop.edge[2])")
#     end
# end

function Base.show(io::IO, vertex::Vertex)
    println(io, "Vertex (degree = $(vertex.degree)): $(vertex.connection)")
end

function Base.hash(diagram::Diagram, h::UInt = 0x32a7a07f3e7cd1f9)
    hash_external = hash("external", h)
    hash_internal = hash("internal", h)
    for vertex in diagram.verli 
        if vertex.degree == 1
            hash_external = hash(
                hash_external, 
                hash(vertex.id, hash(vertex.connection, hash("external")))
            )
        else 
            for con in vertex.connection
                hash_internal ⊻= hash(con, hash("internal"))
            end 
            hash_internal = hash(hash_internal, hash(vertex.id, hash("internal")))
        end
    end
    return hash(hash_external, hash_internal)
end