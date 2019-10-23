function exceedanceadjustment!(node::Int64, params::Parameters)
  for i in 1:2
    for j in 1:3
      params.exc[i, j] = 0.0
    end
  end
  if node == params.noofnodes && !params.has_rig
    params.exc[1, 1] = params.del[1, 1, node] - params.nodes[node].x +
      params.nodes[node - 1].clearance
    params.exc[2, 1] = params.del[2, 1, node] - params.nodes[node].y
  else
    x1 = params.del[1, 1, node] - params.nodes[node].x
    y1 = params.del[2, 1, node] - params.nodes[node].y
    r1 = sqrt(x1^2 + y1^2)
    rex1 = max(0.0, r1 - params.nodes[node].clearance)
    if rex1 > 0.0
      params.exc[1, 1] = rex1 * x1 / r1
      params.exc[2, 1] = rex1 * y1 / r1
    end
  end
  
  params.bf[1, 1, node] = -params.exc[1, 1] / params.si[1, 1, node]
  params.bf[2, 1, node] = -params.exc[2, 1] / params.si[2, 2, node]
  params.f[1, 1, node] = params.bf[1, 1, node]
  params.f[2, 1, node] = params.bf[2, 1, node]

end

