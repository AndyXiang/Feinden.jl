module FeynGen

# export from Topology.jl
export Node, Topology, create_topology
export show, hash, isequal, isexternal, countexternal, countnode, getnode

# export from Model.jl 
export Model, Particle, Field, ScalarField, SpinorField, VectorField
export getid, getidabs, getanti, getname, getmass, getspin, getcharge, particlelist

include("Topology.jl")
include("Model.jl")
include("Diagram.jl")

end




