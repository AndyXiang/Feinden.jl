using FeynGen
using TestItemRunner

# tests for Topology.jl
@testitem "Topology.hash(node)" begin
    node = Node(1,1)
    @test hash(node) == hash(node.id, hash(node.degree))
    @test typeof(hash(node, convert(UInt, 1))) == UInt
end

@testitem "Topology.isequal(node1, node2)" begin
    node1 = Node(1,1)
    node2 = Node(1,1)
    node3 = Node(2,3)
    @test (node1 == node2) == true
    @test (node1 == node3) == false
end 

@testitem "Topology.create_topology(num_loop = 0, max_degree = 3)" begin
    # results from FeynArts
    #@test length(FeynGen.create_topology(4, 0)) == 3
    #@test length(FeynGen.create_topology(5, 0)) == 15
    #@test length(FeynGen.create_topology(6, 0)) == 105
    #@test length(FeynGen.create_topology(7, 0)) == 945
    @test length(FeynGen.create_topology(8, 0)) == 10395
    #@test length(FeynGen.create_topology(9, 0)) == 135135
end

@testitem "Topology.create_topology(num_loop = 0, max_degree = 4)" begin
    # results from FeynArts
    #@test length(FeynGen.create_topology(5, 0, max_degree = 4)) == 25
    #@test length(FeynGen.create_topology(6, 0; max_degree = 4)) == 220
    #@test length(FeynGen.create_topology(7, 0; max_degree = 4)) == 2485
    @test length(FeynGen.create_topology(8, 0; max_degree = 4)) == 34300
    #@time FeynGen.create_topology(8, 0; max_degree = 4)
end 

@testitem "Topology.create_topology(num_loop = 1, max_degree = 3)" begin
    # results from FeynArts
    #@test length(FeynGen.create_topology(4, 1)) == 39
    #@test length(FeynGen.create_topology(5, 1)) == 297
    #@time FeynGen.create_topology(7, 1)
    @test length(FeynGen.create_topology(7, 1)) == 33435
end

@testitem "Topology.create_topology(num_loop = 1, max_degree = 4)" begin
    # results from FeynArts
    #@test length(FeynGen.create_topology(4, 1, max_degree = 4)) == 99
    #@test length(FeynGen.create_topology(5, 1, max_degree = 4)) == 947
    @time FeynGen.create_topology(6, 1, max_degree = 4)
    #@test length(FeynGen.create_topology(7, 1, max_degree = 4)) == 167660
end 

@testitem "Topology.hash(topology)" begin
    topologies = FeynGen.create_topology(4, 0; max_degree = 44)
    @test typeof(hash(topologies)) == UInt
    @test typeof(hash(topologies, convert(UInt, 1))) == UInt
end

@testitem "Topology.isequal(topology1, topology2)" begin
    top1 = FeynGen.Topology([Node(1, 1), Node(2, 1)], [(1,2)], 2)
    top2 = FeynGen.Topology([Node(1, 1), Node(2, 1)], [(1,2)], 1)
    top3 = FeynGen.Topology([Node(1, 3), Node(2, 1)], [(1,1), (1,2)], 2)
    @test (isequal(top1, top2)) == true
    @test (isequal(top1, top3)) == false
end

# tests for Model.jl 
@testitem "Field" begin
    using FeynGen
    ScalarField(25)
    @test typeof(ScalarField()) <: Field
    @test typeof(SpinorField(11)) == Particle
    @test typeof(VectorField(24)) == Particle
end

@testitem "Particle" begin
    γ = FeynGen.Particle("γ")
    @test FeynGen.getanti(γ) == γ 
    e = FeynGen.Particle(11)
    @test FeynGen.getidabs(FeynGen.getanti(e)) == FeynGen.getid(e)
end

@testitem "particlelist" begin
    FeynGen.particlelist()
end

@testitem "Model" begin
    sm = FeynGen.Model(Set([FeynGen.ScalarField(), FeynGen.VectorField()]))
end

