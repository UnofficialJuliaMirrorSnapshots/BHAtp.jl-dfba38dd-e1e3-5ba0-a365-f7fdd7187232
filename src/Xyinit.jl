function xyinit!(data::Dict{Symbol, Any}, params::Parameters)
  sd1 = sin(params.nodes[1].dip)
  cd1 = cos(params.nodes[1].dip)
  for i in 2:length(params.nodes)
    dz = params.nodes[i].z - params.nodes[i-1].z
    # Use average heading of element, subtract heading at bit.
    cdh = cos(params.elements[i-1].heading - params.nodes[1].heading)
    sdh = sin(params.elements[i-1].heading - params.nodes[1].heading)
    # Use average dip of element.
    dd = (params.nodes[i].dip + params.nodes[i-1].dip)/2.0
    cdd = cos(dd)
    sdd = sin(dd)
    
    params.nodes[i].x = params.nodes[i-1].x - dz * (sd1 * cdd * cdh - cd1 * sdd)
    params.nodes[i].y = params.nodes[i-1].y + dz * cdd * sdh
  end
end