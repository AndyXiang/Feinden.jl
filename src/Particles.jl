module Particles

include("Consts.jl")
import .Consts

export Particle, idAbs


"""
    Particle(id)
Type for particle, include properties of PDG id, name, and mass.
Only id needs to be specify when declaring.

# Example
```julia-repl
julia> γ = Particle(22)
γ
julia> γ.m
0
```
"""
struct Particle
    id::Int
    name::String
    m::Float64 
end

function Particle(id)
    name = Consts.NAME_FROM_PDGID[id]
    m = Consts.MASS_FROM_PDGID[id]
    return Particle(id, name, mass)
end

function idAbs(particle::Particle)
    return abs(particle.id)
end




end