using FeynGen, Test, BenchmarkTools

@testset "Topology.jl" begin
    @test length(create_topologies(0, 5, max_degree=3)) == 15
    @test length(create_topologies(0, 6, max_degree=3)) == 105
    @test length(create_topologies(0, 7, max_degree=3)) == 945
    @test length(create_topologies(0, 8, max_degree=3)) == 10395

    @test length(create_topologies(0, 5, max_degree=4)) == 25
    @test length(create_topologies(0, 6, max_degree=4)) == 220
    @test length(create_topologies(0, 7, max_degree=4)) == 2485
    @test length(create_topologies(0, 8, max_degree=4)) == 34300

    @test length(create_topologies(1, 5, max_degree=3)) == 297
    @test length(create_topologies(1, 6, max_degree=3)) == 2865
    @test length(create_topologies(1, 7, max_degree=3)) == 33435

    @test length(create_topologies(1, 5, max_degree=4)) == 947
    @test length(create_topologies(1, 6, max_degree=4)) == 11460

    for topology in create_topologies(1, 5)
        @test countnode(topology) == length(topology.node)
        @test getnode(1, topology) == topology.node[1]
        @test countexternal(topology) == 5
        @test hash(topology, UInt(1)) == hash(topology.node, UInt(1))
    end
end 

#@profview @time create_topologies(1, 6, max_degree=4)
#@benchmark create_topologies(1, 6, max_degree=4)