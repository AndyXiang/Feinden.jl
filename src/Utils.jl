module Utils
export otherelement

"""
    otherelement(vector::Vector, element)
return other elements in `vector`. 
If multiple `element` exists in `vector`, only the first one is removed.
"""
function otherelement(vector::Vector, element)
    if element in vector
        return filter(x -> x != element, vector)
    end
end


end