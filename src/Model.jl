using JSON

###########################################################################################

# Struct 

"""
    Field 
"""
abstract type Field end

struct ScalarField <: Field 
    id::Int 
    name::Union{String, Nothing}
end
struct SpinorField <: Field 
    id::Int 
    name::Union{String, Nothing}
end
struct VectorField <: Field 
    id::Int 
    name::Union{String, Nothing}
end
struct GhostField <: Field 
    id::Int 
    name::Union{String, Nothing}
end

struct Interaction
    comb::Vector{Int}
    symbol::Union{String, Nothing}
end

""" 
    Model 
"""
struct Model
    field::Dict
    interaction::Vector{Interaction}
    desc::Union{String, Nothing}
end

Model(
    field::Vector{Field}, 
    interaction::Vector{Interaction}
) = Model(field, interaction, nothing)


# Construction functions 
# function ScalarField(id::Int, model::Model = CURRENT_MODEL)
#     if (haskey(model.field, ScalarField)) && ()
#         return ScalarField(id, model.dict["name"][id])
#     else 
#         throw(ArgumentError("Invaild id for a scalar field."))
#     end
# end

# function SpinorField(id::Int, model::Model = CURRENT_MODEL)
#     if (haskey(model.dict["spin"], id)) && (model.dict["spin"][id] == 1//2)
#         return SpinorField(id, model.dict["name"][id])
#     else 
#         throw(ArgumentError("Invaild id for a spinor field in current model."))
#     end
# end

# function VectorField(id::Int, model::Model = CURRENT_MODEL)
#     if (haskey(model.dict["spin"], id)) && (model.dict["spin"][id] == 1)
#         return VectorField(id, model.dict["name"][id])
#     else 
#         throw(ArgumentError("Invaild id for a vector field in current model."))
#     end
# end


# APIs
function load_model(path::String) 
    json_dict = JSON.parsefile(path) # read model file from .json and store in Dict 
    # official consist of three keys: "fields", "interactions", "dict", "desc" may exist.
    # model_dict = Dict(
    #     "mass" => Dict(), 
    #     "spin" => Dict(), 
    #     "name" => Dict()
    # )
    field_dict = Dict()
    for (k, v) in json_dict["field"]
        # k is field type, v is vectors of [id::Int, name::String]
        for field_param in v
            field_datatype = FIELD_NAME_TO_FIELD_DATATYPE[k]
            if haskey(field_dict, field_datatype)
                push!(field_dict[field_datatype], field_datatype(field_param[1], field_param[2]))
            else 
                field_dict[field_datatype] = [field_datatype(field_param[1], field_param[2])]
            end
        end
    end
    interaction_arr = Vector{Interaction}()
    for cp_param in json_dict["interaction"]
        push!(interaction_arr, Interaction(cp_param[1], cp_param[2]))
    end
    haskey(json_dict, "desc") ? 
        (return Model(field_dict, interaction_arr, json_dict["desc"])) : 
        (return Model(field_dict, interaction_arr, nothing))
end

function load_model!(path::String, model::Model) 
    new_model = load_model(path)
    model.field = new_model.field 
    model.interaction = new_model.interaction
    model.desc = new_model.desc
    return model
end 

function save_model(path::String, model::Model)
    json_dict = Dict(
        "field" => Dict(), 
        "interaction" => Vector()
    )
    if !(isnothing(model.desc))
        json_dict["desc"] = model.desc
    end 
    for (field_type, field_instance) in model.fields
        field_type_name = FIELD_DATATYPE_TO_FIELD_NAME[field_type]
        if haskey(json_dict["field"], field_type_name)
            push!(json_dict["field"][field_type_name], [field_instance.id, field_instance.name])
        else 
            json_dict["field"][field_type_name] = [[field_instance.id, field_instance.name]]
        end
    end
    for cp_instance in model.interaction
        push!(json_dict["interaction"], [cp_instance.comb, cp_instance.symbol])
    end
    open(path, "w") do f 
        write(f, JSON.json(json_dict, 4))
    end
end

"""
    getid 
Return the field's id with the given name.
"""
function getid(name::String, model::Model = CURRENT_MODEL)
    for field_arr in values(model.field)
        for field in field_arr
            if field.name == name 
                return field.id 
            end
        end
    end
    throw(ArgumentError("No field with this name in the model."))
end

"""
    getparticle
Return the instance of field with the given id.
"""
function getparticle(id::Int, model::Model = CURRENT_MODEL)
    for field_arr in values(model.field)
        for field in field_arr
            if field.id == id 
                return field 
            end 
        end 
    end
end
getparticle(name::String, 
    model::Model = CURRENT_MODEL
) = getparticle(getid(name, model), model)

getname(field::Field) = isnothing(field.name) ? println("Name not assigned") : field.name
getname(id::Int, model::Model = CURRENT_MODEL) = getname(getparticle(id, model))

function fieldlist(model::Model = CURRENT_MODEL)
    println("id\t\t", "field type\t\t", "name")
    for field_arr in values(model.field)
        for field in field_arr
            println(
                field.id, "\t\t", 
                split(string(typeof(field)), ".")[end], "\t\t", 
                isnothing(field.name) ? "not assigned" : field.name
            )
        end
    end
end

# Base.hash
Base.hash(field::Field) = hash(field.id, hash(field.name))
Base.hash(coup::Interaction) = hash(coup.comb, hash(coup.symbol))
Base.hash(model::Model) = hash(model.field, hash(model.interaction))

# Base.show

# Dictionary
const FIELD_NAME_TO_FIELD_DATATYPE = Dict(
    "scalar" => ScalarField,
    "spinor" => SpinorField,
    "vector" => VectorField,
    "ghost" => GhostField
)
const FIELD_DATATYPE_TO_FIELD_NAME = Dict(
    ScalarField => "scalar",
    SpinorField=> "spinor",
    VectorField => "vector",
    GhostField => "ghost"
)
const FIELD_NAME_TO_SPIN = Dict(
    "scalar" => 0,
    "spinor" => 1//2,
    "vector" => 1
)
