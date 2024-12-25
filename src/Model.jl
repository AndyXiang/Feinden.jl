using Symbolics

###########################################################################################

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

ScalarField(id::Int) = (CURRENT_MODEL.dict["spin"][id] == 0) ? ScalarField(id, nothing) : 
    throw(ArgumentError("Invaild id for a scalar field in current model."))
ScalarField(name::String) = (CURRENT_MODEL.dict["spin"][CURRENT_MODEL.dict["id"][name]] == 0) ?
    ScalarField(CURRENT_MODEL.dict["id"][name], name) : 
    throw(ArgumentError("Invaild name for a scalar field in current model."))

SpinorField(id::Int) = (CURRENT_MODEL.dict["spin"][id] == 1//2) ? SpinorField(id, nothing) : 
    throw(ArgumentError("Invaild id for a scalar field in current model."))
SpinorField(name::String) = (CURRENT_MODEL.dict["spin"][CURRENT_MODEL.dict["id"][name]] == 1//2) ?
    SpinorField(CURRENT_MODEL.dict["id"][name], name) : 
    throw(ArgumentError("Invaild name for a spinor field in current model."))

VectorField(id::Int) = (CURRENT_MODEL.dict["spin"][id] == 1) ? VectorField(id, nothing) : 
    throw(ArgumentError("Invaild id for a vector field in current model."))
VectorField(name::String) = (CURRENT_MODEL.dict["spin"][CURRENT_MODEL.dict["id"][name]] == 1) ?
    VectorField(CURRENT_MODEL.dict["id"][name], name) : 
    throw(ArgumentError("Invaild name for a vector field in current model."))


getid(field::Field) = field.id
getidabs(field::Field) = abs(field.id)

getanti(field::Field) = (field.charge != 0) ? typeof(field)(-field.id) : field

getname(field::Field) = isnothing(field.name) ? println("Name not assigned") : field.name
function getname(id::Int)
    name = CURRENT_MODEL.dict["name"][id]
    isnothing(name) ? println("Name not assigned") : name
end

getmass(id::Int) = CURRENT_MODEL.dict["mass"][id]
getmass(field::Field) = getmass(field.id)
getmass(name::Union{String, Nothing}) = isnothing(name) ? println("Name not assigned.") : 
    getmass(CURRENT_MODEL.dict["id"][name])

getspin(id::Int) = CURRENT_MODEL.dict["spin"][id]
getspin(field::Field) = getspin(field.id)
getspin(name::Union{String, Nothing}) = isnothing(name) ? println("Name not assigned.") : 
    getspin(CURRENT_MODEL.dict["id"][name])

getcharge(id::Int) = CURRENT_MODEL.dict["charge"][id]
getcharge(field::Field) = getcharge(field.id)
getcharge(name::Union{String, Nothing}) = isnothing(name) ? println("Name not assigned.") :
    getcharge(CURRENT_MODEL.dict["id"][name])

function fieldlist()
    println("id\t\t", "field type\t\t", "name")
    for field in CURRENT_MODEL.fields[]
        println(
            field.id, "\t\t", 
            typeof(field), "\t\t", 
            isnothing(name) ? "not assigned" : name
        )
    end
end

###########################################################################################

struct Interaction
    fields::Vector{Field}
    cpconst::Union{Float64, Num}
end



###########################################################################################

""" 
    Model 
"""
struct Model
    fields::Vector{Field}
    couplings::Vector{Interaction}
    dict::Dict
    desc::Union{String, Nothing}
end

function load_model(path::String)
    if splitext(path) != ".model"
        println("Warning: Reading from file not ending with .model")
    end 
    vec_fields = Vector{Field}()
    vec_couplings = Vector{Interaction}()
    dict = Dict()
    words = readlines(path)
    index = indexin(["fields:", "couplings:", "dict:", "desc"], words)
    i = 1
    #while true
        #if words[index[1]+i] 
    #end
end


# Dictionary

const NAME_FROM_PDGID = Dict(
    # quarks
    1 => "d",
    -1 => "dbar",
    2 => "u",
    -2 => "ubar",
    3 => "s",
    -3 => "sbar",
    4 => "c",
    -4 => "cbar",
    5 => "b",
    -5 => "bbar",
    6 => "t",
    -6 => "tbar",
    # leptons
    11 => "e-",
    -11 => "e+",
    12 => "ν_e",
    -12 => "νbar_e",
    13 => "μ-",
    -13 => "μ+",
    14 => "ν_μ",
    -14 => "νbar_μ",
    15 => "τ-",
    -15 => "τ+",
    16 => "ν_τ",
    -16 => "νbar_τ",
    # gauge bosons
    21 => "g",
    22 => "γ",
    23 => "Z",
    24 => "W+",
    -24 => "W-",
    25 => "H"
    # light I=1 mesons
)
const PDGID_FROM_NAME = Dict(
    # quarks
    "d" => 1,
    "dbar" => -1,
    "u" => 2,
    "ubar" => 2,
    "s" => 3,
    "sbar" => -3,
    "c" => 4,
    "cbar" => -4,
    "b" => 5,
    "bbar" => 5,
    "t" => 6,
    "tbar" => -6,
    # leptons
    "e-" => 11,
    "e+" => -11,
    "ν_e" => 12,
    "νbar_e" => -12,
    "μ-" => 13,
    "μ+" => -13,
    "ν_μ" => 14,
    "νbar_μ" => -14,
    "τ-" => 15,
    "τ+" => -15,
    "ν_τ" => 16,
    "νbar_τ" => -16,
    # gauge bosons
    "g" => 21,
    "γ" => 22,
    "Z" => 23,
    "W+" => 24,
    "W-" => -24,
    "H" => 25
    # light I=1 mesons
)
const MASS_FROM_PDGID = Dict(
    # quarks
    1 => 4.67e-3,
    -1 => 4.67e-3,
    2 => 2.16e-3,
    -2 => 2.16e-3,
    3 => 93.4e-3,
    -3 => 93.4e-3,
    4 => 1.27,
    -4 => 1.27,
    5 => 4.18,
    -5 => 4.18,
    6 => 172.69,
    -6 => 172.69,
    # leptons
    11 => 0.51099895e-3,
    -11 => 0.51099895e-3,
    12 => 0,
    -12 => 0,
    13 => 105.6583755e-3,
    -13 => 105.6583755e-3,
    14 => 0,
    -14 => 0,
    15 => 1776.86e-3,
    -15 => 1776.86e-3,
    16 => 0,
    -16 => 0,
    # gauge bosons
    21 => 0,
    22 => 0,
    23 => 91.1876,
    24 => 80.377,
    -24 => 80.377,
    25 => 125.25
    # light I=1 mesons
)
const SPIN_FROM_PDGID = Dict(
    # quarks
    1 => 1 // 2,
    -1 => 1 // 2,
    2 => 1 // 2,
    -2 => 1 // 2,
    3 => 1 // 2,
    -3 => 1 // 2,
    4 => 1 // 2,
    -4 => 1 // 2,
    5 => 1 // 2,
    -5 => 1 // 2,
    6 => 1 // 2,
    -6 => 1 // 2,
    # leptons
    11 => 1 // 2,
    -11 => 1 // 2,
    12 => 1 // 2,
    -12 => 1 // 2,
    13 => 1 // 2,
    -13 => 1 // 2,
    14 => 1 // 2,
    -14 => 1 // 2,
    15 => 1 // 2,
    -15 => 1 // 2,
    16 => 1 // 2,
    -16 => 1 // 2,
    # gauge bosons
    21 => 1,
    22 => 1,
    23 => 1,
    24 => 1,
    -24 => 1,
    25 => 0
    # light I=1 mesons
)
const CHARGE_FROM_PDGID = Dict(
    # quarks
    1 => -1 // 3,
    -1 => 1 // 3,
    2 => 2 // 3,
    -2 => -2 // 3,
    3 => -1 // 3,
    -3 => 1 // 3,
    4 => 2 // 3,
    -4 => -2 // 3,
    5 => -1 // 3,
    -5 => 1 // 3,
    6 => 2 // 3,
    -6 => -2 // 3,
    # leptons
    11 => -1,
    -11 => 1,
    12 => 0,
    -12 => 0,
    13 => -1,
    -13 => 1,
    14 => 0,
    -14 => 0,
    15 => -1,
    -15 => 1,
    16 => 0,
    -16 => 0,
    # gauge bosons
    21 => 0,
    22 => 0,
    23 => 0,
    24 => 1,
    -24 => -1,
    25 => 0
    # light I=1 mesons
)