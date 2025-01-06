module FeynGen

using Base


# export from Topology.jl
export Node, Topology, create_topology, create_topology_ird
export show, hash, isequal, isexternal, countexternal, countnode, getnode

# export from Model.jl 
export Model, Interaction, Field, ScalarField, SpinorField, VectorField
export getid, getname, getparticle, fieldlist, load_model, load_model!, save_model
export CURRENT_MODEL

# export from Diagram.jl 
export Diagram, Vertex
export insert_field, show

include("Utils.jl")
include("Topology.jl")
include("Model.jl")
include("Diagram.jl")


CURRENT_MODEL = load_model(joinpath(@__DIR__, "models/QED.json"))


end




