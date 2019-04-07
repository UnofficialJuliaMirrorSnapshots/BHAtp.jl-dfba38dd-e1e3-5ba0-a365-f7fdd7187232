function createnodedf(nodes)
  
  #=
  mutable struct Node
    bharadius::Float64
    weight::Float64
    fc::Float64
  end
  =#
  
  node_types = [Float64, Float64, Float64]
  node_names = [:bharadius, :weight, :fc]

  nodedf = DataFrame(node_types, node_names, 0)
  for i in 1:size(nodes, 1)
      append!(nodedf, 
        DataFrame(
          bharadius=nodes[i].bharadius,
          weight=nodes[i].weight,
          fc=nodes[i].fc
        )
      )
  end
  
  nodedf
  
end