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