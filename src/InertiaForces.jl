function inertiaforces!(node::Int64, params::Parameters)
  om2 = params.omega^2
  
  for i in 2:3
    for j in 1:6
      if j <= 3
        params.f[j, i, node] = params.f[j, i, node] + 
          om2 * params.nodes[node].massinertia * params.del[j, i, node]
      elseif j <= 5
        params.f[j, i, node] =  params.f[j, i, node] + 
          om2 * params.nodes[node].radialinertia * params.del[j, i, node]
      else
        params.f[j, i, node] =  params.f[j, i, node] + 
          om2 * params.nodes[node].axialinertia * params.del[j, i, node]
      end
    end
  end
end