function dalphainit!(dalpha::Float64, params::Parameters)
  for i in 2:length(params.nodes)
    dz = params.nodes[i].z - params.nodes[i-1].z
    params.nodes[i].inclination = params.nodes[i-1].inclination + dalpha*params.dtor*dz/1200.0
    params.nodes[i].dip = params.nodes[i-1].dip - dalpha*params.dtor*dz/1200.0
    params.elements[i-1].inclination = (params.nodes[i-1].inclination + params.nodes[i].inclination)/2.0
  end
end