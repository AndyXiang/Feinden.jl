using JSON

###########################################################################################

# Struct 

"""
    Field 
Abstract type for fields.
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
    ids::Vector{Int}
    symbol::Union{String, Nothing}
end

""" 
    Model 
"""
struct Model
    fields::Vector{Field}
    interactions::Vector{Interaction}
    dict::Dict
    desc::Union{String, Nothing}
end

# Construction functions 

function ScalarField(id::Int, model::Model = CURRENT_MODEL)
    if (haskey(model.dict["spin"], id)) && (model.dict["spin"][id] == 0)
        return ScalarField(id, model.dict["name"][id])
    else 
        throw(ArgumentError("Invaild id for a scalar field in current model."))
    end
end

function SpinorField(id::Int, model::Model = CURRENT_MODEL)
    if (haskey(model.dict["spin"], id)) && (model.dict["spin"][id] == 1//2)
        return SpinorField(id, model.dict["name"][id])
    else 
        throw(ArgumentError("Invaild id for a spinor field in current model."))
    end
end

function VectorField(id::Int, model::Model = CURRENT_MODEL)
    if (haskey(model.dict["spin"], id)) && (model.dict["spin"][id] == 1)
        return VectorField(id, model.dict["name"][id])
    else 
        throw(ArgumentError("Invaild id for a vector field in current model."))
    end
end

Model(
    fields::Vector{Field}, 
    interactions::Vector{Interaction}, 
    dict::Dict
) = Model(fields, interactions, dict, nothing)

###########################################################################################

# APIs

function load_model(path::String) 
    json_dict = JSON.parsefile(path) # read model file from .json and store in Dict 
    # official consist of three keys: "fields", "interactions", "dict", "desc" may exist.
    model_dict = Dict(
        "mass" => Dict(), 
        "spin" => Dict(), 
        "name" => Dict()
    )
    fields = Vector{Field}()
    for (k, v) in json_dict["fields"]
        # k is field type, v is vectors of [id::Int, name::String]
        for field in v
            push!(fields, NAME_TO_FIELD_TYPE[k](field[1], field[2]))
            model_dict["mass"][field[1]] = json_dict["mass"][field[2]]
            model_dict["spin"][field[1]] = NAME_TO_SPIN[k]
            model_dict["name"][field[1]] = field[2]
        end
    end
    interactions = Vector{Interaction}()
    for cp in json_dict["interactions"]
        push!(interactions, Interaction(cp[1], cp[2]))
    end
    haskey(json_dict, "desc") ? 
        (return Model(fields, interactions, model_dict, json_dict["desc"])) : 
        (return Model(fields, interactions, model_dict))
end

function load_model!(path::String, model::Model) 
    model = load_model(path) 
end 

function save_model(path::String, model::Model)
    json_dict = Dict(
        "field" => Dict(), 
        "interactions" => Vector(), 
        "mass" => Dict()
    )
    if !(isnothing(model.desc))
        json_dict["desc"] = model.desc
    end 
    for field in model.fields
        field_type = FIELD_TYPE_TO_NAME[typeof(field)]
        if haskey(json_dict["field"], field_type)
            push!(json_dict["field"][field_type], [field.id, field.name])
        else 
            json_dict["field"][field_type] = Vector()
            push!(json_dict["field"][field_type], [field.id, field.name])
        end
        json_dict["mass"][field.name] = model.dict["mass"][field.id] 
    end
    for cp in model.interactions
        push!(json_dict["interactions"], [cp.ids, cp.symbol])
    end
    open(path, "w") do f 
        write(f, JSON.json(json_dict, 4))
    end
end

function getid(name::String, model::Model = CURRENT_MODEL)
    for (k, v) in model.dict["name"]
        if v == name 
            return k 
        end
    end
end

getidabs(name::String, model::Model = CURRENT_MODEL) = abs(getid(name, model))

function getanti(field::Field, model::Model = CURRENT_MODEL) 
    if model.dict["charge"][field.id] != 0
        return getfield(-field.id)
    else 
        return field
    end
end

function getfield(id::Int, model::Model = CURRENT_MODEL)
    for field in model.fields
        if field.id == id 
            return field 
        end 
    end
end

getname(field::Field) = isnothing(field.name) ? println("Name not assigned") : field.name
getname(id::Int, model::Model = CURRENT_MODEL) = model.dict["name"][id]

getmass(id::Int, model::Model = CURRENT_MODEL) = model.dict["mass"][id]
getmass(field::Field, model::Model = CURRENT_MODEL) = getmass(field.id, model)
getmass(name::String, model::Model = CURRENT_MODEL) = getmass(getid(name, model), model)

getcharge(id::Int, model::Model = CURRENT_MODEL) = model.dict["charge"][id]
getcharge(field::Field, model::Model = CURRENT_MODEL) = getcharge(field.id, model)
getcharge(name::String, model::Model = CURRENT_MODEL) = getcharge(getid(name, model), model)

function fieldlist(model::Model = CURRENT_MODEL)
    println("id\t\t", "field type\t\t", "name")
    for field in model.fields
        println(
            field.id, "\t\t", 
            split(string(typeof(field)), ".")[end], "\t\t", 
            isnothing(field.name) ? "not assigned" : field.name
        )
    end
end



# Dictionary

const NAME_TO_FIELD_TYPE = Dict(
    "scalar" => ScalarField,
    "spinor" => SpinorField,
    "vector" => VectorField,
    "ghost" => GhostField
)
const FIELD_TYPE_TO_NAME = Dict(
    ScalarField => "scalar",
    SpinorField=> "spinor",
    VectorField => "vector",
    GhostField => "ghost"
)
const NAME_TO_SPIN = Dict(
    "scalar" => 0,
    "spinor" => 1//2,
    "vector" => 1
)
