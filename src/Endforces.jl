function endforces!(node::Int64, params::Parameters)
  if node == params.noofnodes
    l = params.nodes[node].z - params.nodes[node-1].z
    # Average rate of change in y direction
    θ = -(params.nodes[node].y - params.nodes[node-1].y) / l
    # Average rate of change in x direction
    γ = (params.nodes[node].x - params.nodes[node-1].x) / l
    
    params.f[1, 1, node] += params.fn[params.noofnodes] * γ
    params.f[2, 1, node] -= params.fn[params.noofnodes] * θ
    params.f[3, 1, node] += params.fn[params.noofnodes]
  end  
  
  if node <= 3
    params.del[4, 3, node] = sqrt(params.del[4, 2, node]^2 + params.del[4, 3, node]^2)
    params.del[4, 2, node] = 0.0
  end
end
  