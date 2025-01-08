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
    top1 = FeynGen.Topology([Node(1, 1), Node(2, 1)], [(1,2)])
    top2 = FeynGen.Topology([Node(1, 1), Node(2, 1)], [(1,2)])
    top3 = FeynGen.Topology([Node(1, 3), Node(2, 1)], [(1,1), (1,2)])
    @test (isequal(top1, top2)) == true
    @test (isequal(top1, top3)) == false
end

# tests for Model.jl 

@testitem "fieldlist" begin
    FeynGen.fieldlist()
end

@testitem "Model" begin
    using FeynGen
    save_model("test.json", CURRENT_MODEL)
end

@testitem "CURRENT_MODEL" begin
    FeynGen.fieldlist()
end

@testitem "hash(Field)" begin
    using FeynGen
    println(hash(getparticle(0)))
end

@testitem "hash(Model)" begin
    using FeynGen
    println(hash(CURRENT_MODEL))
end

@testitem "_convert_topology" begin
    using FeynGen
    topology = Topology(
        [Node(1, 1), Node(2, 1), Node(3, 3), Node(4, 3), Node(5, 1), Node(6, 1)], 
        [(1,3), (2, 3), (3,4), (4,5), (4,6)]
    )
    diagram = FeynGen._convert_topology(topology)
    print(diagram.verli)
end

@testitem "_insert_external" begin
    using FeynGen
    topology = Topology(
        [Node(1, 1), Node(2, 1), Node(3, 3), Node(4, 3), Node(5, 1), Node(6, 1)], 
        [(1,3), (2, 3), (3,4), (4,5), (4,6)]
    )
    diagram = FeynGen._convert_topology(topology)
    FeynGen._insert_external!(diagram, [1,-1]=>[1,-1])
    println(diagram.verli)
end

@testitem "deleteat" begin
    using FeynGen
    a = [1,2,3]
    FeynGen.deleteat(a, 1)
    @test a == [1,2,3]
end

@testitem "insert_field()" begin
    using FeynGen
    @time @test length(insert_field(create_topology(7, 0), [1,-1,1,-1]=>[2,-2,0])) == 84
    @time print(length(insert_field(create_topology(8, 0), [1,-1,1,-1]=>[2,-2,2,-2])))
end

@testitem "insert_field()" begin
    using FeynGen
    generate_tikz(insert_field(create_topology(4, 1), [1, -1]=>[2, -2]), "test_diagram/")
end

@testitem "hash(diagram)" begin
    using FeynGen
    dias = insert_field(create_topology(2, 1), [1]=>[1])
    for dia in dias
        println(dia)
    end
end

@testitem "permutations" begin
    using FeynGen
    arr = [1,1,0]
    println(unique(FeynGen.permutations(arr)))
end

@testitem "generate_tikz" begin
    using FeynGen
    dias = insert_field(create_topology(4, 1), [1,-1]=>[2,-2])
    generate_tikz(dias, "test_diagram/")
end