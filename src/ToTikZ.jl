function generate_tikz(diagram::Diagram, file_root::String)
    vertex_record = []
    generated_line = []
    for vertex in diagram.verli 
        skip_tadpole = false
        if vertex.degree == 1
            name1 = "e$(vertex.id) [particle=\\($(getname(vertex.connection[1][2]))\\)]"
        else 
            name1 = "i$(vertex.id)"
        end
        loop_tmp = [con[1] for con in vertex.connection]
        duplicate = find_duplicates(loop_tmp)
        for i in eachindex(vertex.connection)
            con = vertex.connection[i]
            if (con[1] in vertex_record) || 
                (haskey(duplicate, con[1]) && duplicate[con[1]][1] != i)
                continue
            end
            another_vertex = diagram.verli[con[1]]
            if another_vertex.degree == 1
                name2 = "e$(another_vertex.id) [particle=\\($(getname(con[2]))\\)]"
            else 
                name2 = "i$(another_vertex.id)"
            end
            if haskey(duplicate, con[1])
                if con[1] == vertex.id # handle tadpole diagrams
                    if skip_tadpole
                        skip_tadpole = false
                        continue
                    end
                    skip_tadpole = true
                    push!(
                        generated_line, 
                        "\t$name1"* 
                        "-- [edge label=\\($(getname(con[2]))\\),"* 
                        "fermion, out=135, in=45, loop, min distance=2cm]"* 
                        "$name1,\n"
                    )
                else 
                    another_con = vertex.connection[duplicate[con[1]][2]]
                    if ((getanti(con[2]) < 0) && (another_con[2] < 0)) || 
                        ((getanti(another_con[2]) < 0) && (con[2] < 0))
                        push!(
                            generated_line, 
                            "\t$name1 -- [fermion, half left] $name2,\n"*
                            "\t$name2 -- [fermion, half left] $name1,\n"
                        )
                    elseif (getanti(con[2]) >= 0) && (getanti(another_con[2]) < 0)
                        push!(
                            generated_line, 
                            "\t$name1 -- [boson, half left] $name2,\n"*
                            "\t$name1 -- [fermion, half right] $name2,\n"
                        )
                    elseif (getanti(con[2]) >= 0) && (another_con[2] < 0)
                        push!(
                            generated_line, 
                            "\t$name1 -- [boson, half left] $name2,\n"*
                            "\t$name2 -- [fermion, half left] $name1,\n"
                        )
                    elseif (getanti(another_con[2]) >= 0) && (getanti(con[2]) < 0)
                        push!(
                            generated_line, 
                            "\t$name1 -- [boson, half left] $name2,\n"*
                            "\t$name1 -- [fermion, half right] $name2,\n"
                        )
                    elseif (getanti(another_con[2]) >= 0) && (con[2] < 0)
                        push!(
                            generated_line, 
                            "\t$name1 -- [boson, half left] $name2,\n"*
                            "\t$name2 -- [fermion, half left] $name1,\n"
                        )
                    else 
                        push!(
                            generated_line, 
                            "\t$name1 -- [boson, half left] $name2,\n"*
                            "\t$name1 -- [boson, half right] $name2,\n"
                        )
                    end
                end
                continue
            end
            if getanti(con[2]) < 0
                push!(generated_line, "\t$name1 -- [fermion] $name2,\n")
            elseif con[2] < 0
                push!(generated_line, "\t$name2 -- [fermion] $name1,\n")
            else 
                push!(generated_line, "\t$name1 -- [boson] $name2,\n")
            end 
        end
        push!(vertex_record, vertex.id)
    end
    push!(generated_line, "};\n\\end{document}")
    tex = "\\documentclass{standalone}\n"*
        "\\usepackage{tikz,standalone}\n"*
        "\\usepackage[compat=1.1.0]{tikz-feynman}\n"*
        "\\begin{document}\n"*
        "\\feynmandiagram [horizontal=i1 to i2]{\n"
    for line in generated_line
        tex = tex * line 
    end 
    open(file_root, "w") do file 
        write(file, tex)
    end
end

function generate_tikz(diagrams::Vector{Diagram}, dir_root::String)
    count_diagram = 1
    for diagram in diagrams
        generate_tikz(diagram, dir_root*"feynmandiagram$count_diagram.tex")
        count_diagram += 1
    end
end

function generate_tikz(topolgy::Tology, dir_root::String)
    
end

const FIELD_DATATYPE_TO_EDGE_NAME = Dict(
    SpinorField => "fermion",
    VectorField => "boson"
)