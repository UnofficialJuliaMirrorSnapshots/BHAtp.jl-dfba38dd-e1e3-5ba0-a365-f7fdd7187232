function createelementdf(elements)
  
  #=
    mutable struct Element
      length::Float64
      id::Float64                 # Inside diameter
      od::Float64                 # Outside diameter
      npind::Int
    end
  =#

  element_types = [Float64, Float64, Float64, Int]
  element_names = [:length, :id, :od, :npind]

  elementdf = DataFrame(element_types, element_names, 0)
  for i in 1:size(elements, 1)
      append!(elementdf, 
        DataFrame(
          length=elements[i].length,
          id=elements[i].id,
          od=elements[i].od,
          npind=elements[i].npind
        )
      )
  end
  
  elementdf
  
end