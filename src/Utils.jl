function deleteat(a::Vector, i::Int)
    return [a[j] for j = 1:length(a) if j != i]
end

function get_another_element(tuple::Tuple{T, T}, element) where T
    if tuple[1] == element
        return tuple[2]
    elseif tuple[2] == element
        return tuple[1]
    else
        error("The element is not in the tuple.")
    end
end

function permutations(arr::Vector)
    if length(arr) <= 1
        return [arr]
    end

    result = []

    for i in 1:length(arr)
        current = arr[i]
        remaining = vcat(arr[1:i-1], arr[i+1:end])
        for perm in permutations(remaining)
            push!(result, [current; perm])
        end
    end

    return result
end

function find_first_partial_missing(array::Vector)
    for i in eachindex(array)
        has_missing = any(ismissing, array[i])
        not_all_missing = any(!ismissing, array[i])
        if has_missing && not_all_missing
            return i
        end
    end
    return nothing
end

function find_duplicates(array::Vector{Int})
    element_count = Dict{Any, Vector{Int}}()
    for i in eachindex(array)
        if haskey(element_count, array[i])
            push!(element_count[array[i]], i) 
        else
            element_count[array[i]] = [i]
        end
    end
    for key in keys(element_count)
        if !(length(element_count[key]) > 1)
            delete!(element_count, key)
        end
    end
    return element_count
end