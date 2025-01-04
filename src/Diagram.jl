mutable struct Vertex
    id::Int 
    degree::Int 
    prop_id::Union{Vector{Int}, Missing}
    prop_field::Vector{Union{Int, Missing}}
end
Vertex(node::Node) = Vertex(node.id, node.degree, missing, [missing])

mutable struct Propagator
    id::Int 
    edge::Tuple{Int, Int}
    field::Union{Int, Missing}
end

struct Diagram
    verli::Vector{Vertex} # list of vertex
    propli::Vector{Propagator}
    comb_factor::Int
end

# Main API

function insert_field(
    particles::Vector{Field}, 
    topology::Topology, 
    model::Model = CURRENT_MODEL
)
    diagram = _convert_topology(topology)
    # insert external fields 
    diagram_arr = [_insert_external!(diagram, particles)]
    while true
        inserting_diagram = pop!(diagram_arr)
        new_diagrams = Vector{Diagram}()
        # find one not-inserted propagator of inserting_diagram
        for prop in inserting_diagram.propli
            if ismissing(prop.field)
                inserting_prop = prop 
                vertex = diagram.verli[prop.edge[1]]
                break 
            end
        end
        # find possible interaction vertex
        for ita in model.coupling
            if length(ita.comb) != Vertex.degree
                continue
            end
            for i = 1:num

            end
        end
        if isempty(diagram_arr) # stop iteration when all diagrams are generated
            break 
        end
    end

    
end

function _convert_topology(topology::Topology) # create start diagram from topology
    verli = [Vertex(node) for node in topology.node_list]
    propli = Vector{Propagator}()
    id = 1
    for edge in topology.adj 
        push!(propli, Propagator(id, edge, missing))
        for ver in verli 
            if ver.id == edge[1] 
                if ismissing(ver.prop_id)
                    ver.prop_id = [id]
                    ver.prop_field = [missing]
                else 
                    push!(ver.prop_id, id)
                    push!(ver.prop_field, missing)
                end
            end 
            if ver.id == edge[2] 
                if ismissing(ver.prop_id)
                    ver.prop_id = [id]
                    ver.prop_field = [missing]
                else 
                    push!(ver.prop_id, id)
                    push!(ver.prop_field, missing)
                end
            end
        end
        id += 1
    end
    return Diagram(verli, propli, topology.comb_factor)
end

function _insert_external!(diagram::Diagram, particles::Vector) 
    i = 1
    external_leg_dict = Dict()
    # find all external vertex and store the assgined particle in external_leg_dict
    for vertex in diagram.verli 
        if vertex.degree == 1
            external_leg_dict[vertex.prop_id[1]] = particles[i].id
            i += 1
        end
    end
    # iterate over all vertex and assign the field id to propli of vertices
    for i in 1:length(diagram.verli)
        for j in 1:length(diagram.verli[i].prop_id)
            prop_id = diagram.verli[i].prop_id[j]
            if haskey(external_leg_dict, prop_id)
                diagram.verli[i].prop_field[j] = external_leg_dict[prop_id]
            end
        end
    end
    # iterate over all propagators and assign the field id to them
    for i in 1:length(diagram.propli)
        prop = diagram.propli[i]
        if haskey(external_leg_dict, prop.id)
            prop.field = external_leg_dict[prop.id]
        end
    end
end

function _insert_edge(diagram::Diagram, prop_id::Int, prop_field::Int)
    
end

function _examine_vertex(diagrams::Diagram)
    
end