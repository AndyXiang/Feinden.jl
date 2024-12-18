using FeynGen
using Test

@testset "create_topology" begin
    topologies = FeynGen.create_topology(6, 0, 4)
    #FeynGen.display_topology(topologies)
end

