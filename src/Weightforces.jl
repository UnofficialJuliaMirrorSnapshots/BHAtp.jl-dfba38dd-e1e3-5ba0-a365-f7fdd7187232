function weightforces!(node::Int64, params::Parameters)
  params.f[3, 1, node] = -params.nodes[node].weight * sin(params.nodes[node].dip)
  params.f[1, 1, node] = -params.nodes[node].weight * cos(params.nodes[node].dip)
end