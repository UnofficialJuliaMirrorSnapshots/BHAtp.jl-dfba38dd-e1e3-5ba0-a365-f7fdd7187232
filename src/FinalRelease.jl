function finalrelease!(node::Int64, error, params::Parameters)
  params.del[4, 1, node] += params.si[4, 2, node] * params.f[2, 1, node]
  params.del[5, 1, node] += params.si[5, 1, node] * params.f[1, 1, node]
  params.del[1, 1, node] += params.si[1, 1, node] * params.f[1, 1, node]
  params.del[2, 1, node] += params.si[2, 2, node] * params.f[2, 1, node]
  
  if abs(params.nodes[node].fc) > eps() && 
      (abs(params.bf[1, 1, node]) > eps() || abs(params.bf[2, 1, node]) > eps())
    params.friction[node] = 
      params.nodes[node].fc * sqrt(params.bf[1, 1, node]^2 + params.bf[2, 1, node]^2)
  end
  
  for j in 1:6
    error += abs(params.del[j, 1, node] - params.rdel[j, 1])
  end
  error
end
