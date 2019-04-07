function createpropertydf(properties)
  
  
  prop_types = [Float64, Float64, Float64]
  prop_names = [:ea, :er, :gj]

  propertydf = DataFrame(prop_types, prop_names, 0)
  for i in 1:size(properties, 1)
      append!(propertydf, 
        DataFrame(
          ea=properties[i, 1],
          er=properties[i, 2],
          gj=properties[i, 3]
        )
      )
  end
  
  propertydf
  
end