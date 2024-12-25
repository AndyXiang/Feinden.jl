"""
    Propagator
"""
struct Propagator
    particle::Particle
    #momentum::
    #helicity::
    isassigned::Bool
    vertices::Union{Tuple,Nothing}
end

Propagator(particle::Particle) = Propagator(particle, false, nothing)

###########################################################################################

"""
    Vertex
"""
struct Vertex
    degree::Int
    isassigned::Bool
    propagator_set::Union{Set{Propagator}}
    #coupling
end

Vertex(
    degree::Int, 
    propagator_set::Set{Propagator}
) = Vertex(degree, false, propagator_set)

###########################################################################################

