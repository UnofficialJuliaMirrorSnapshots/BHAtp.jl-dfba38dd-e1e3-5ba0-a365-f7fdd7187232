function finalinit!(params::Parameters)

  for i in 1:params.noofnodes
    params.nodes[i].clearance = max(0.0, params.nodes[i].holeradius - params.nodes[i].stringradius)
  end
  
  if params.remove_bit_constraints
    params.nodes[1].clearance = 999.0
  end
  
  if params.has_rig
    params.nodes[params.noofnodes].clearance = 0.0
  end
  
  params.bf[1, 1, 1] = cos(params.nodes[1].dip) * params.nodes[1].weight
  params.f[1, 1, 1] = params.bf[1, 1, 1]
  
  # Still figuring out if below adjustment is needed for bit
  params.fn[1] = -params.wob + sin(params.nodes[1].dip) * params.nodes[1].weight
  params.friction[1] = 
    params.nodes[1].fc * sqrt(params.bf[1, 1, 1]^2 + params.bf[2, 1, 1]^2)
  params.f[3, 1, 1] = params.fn[1]
  
  if params.use_geometric_correction
    params.sc[:, :, 1] += params.fn[1] * params.gm[1:6, 7:12, 1]
    params.sa[:, :, 1] += params.fn[1] * params.gm[7:12, 1:6, 1]
    params.sb1[:, :, 1] += params.fn[1] * params.gm[7:12, 7:12, 1]
    params.sb2[:, :, 1] += params.fn[1] * params.gm[1:6, 1:6, 1]
    params.si[:, :, 1] = BHAtp.stiffnessi!(1, params.sb1[:, :, 1], params.sb2[:, :, 1])
  end
  
  for i in 2:params.noofnodes
    params.bf[1, 1, i] = cos(params.nodes[i].dip) * params.nodes[i].weight
    params.f[1, 1, i] = params.bf[1, 1, i]
    params.del[1, 1, i] = params.nodes[i].x - params.nodes[i].clearance
    params.del[2, 1, i] = params.nodes[i].y + 0.001 * params.nodes[i].clearance
    
    params.fn[i] = params.fn[i-1] + sin(params.nodes[i].dip) * params.nodes[i].weight
    params.friction[i] = 
      params.nodes[i].fc * sqrt(params.bf[1, 1, i]^2 + params.bf[2, 1, i]^2)
    
    params.f[3, 1, i] = params.fn[i]
    
    local l = params.nodes[i].z - params.nodes[i-1].z
    params.del[3, 1, i] = params.del[3, 1, i-1] + params.fn[i] * l / params.elements[i-1].ea
    
    if params.use_geometric_correction
      params.sc[:, :, i] += params.fn[i] * params.gm[1:6, 7:12, i]
      params.sa[:, :, i] += params.fn[i] * params.gm[7:12, 1:6, i]
      params.sb1[:, :, i] += params.fn[i] * params.gm[7:12, 7:12, i]
      params.sb2[:, :, i] += params.fn[i] * params.gm[1:6, 1:6, i]
      params.si[:, :, i] = BHAtp.stiffnessi!(1, params.sb1[:, :, i], params.sb2[:, :, i])
    end
    
    params.del[4, 1, i] = (params.nodes[i].y - params.nodes[i-1].y) / l
    params.del[5, 1, i] = (params.nodes[i].x - params.nodes[i-1].x) / l
  end
  
  # Below vectors are initialized from the top
  params.nodes[params.noofnodes].tvd = 0.0
  params.nodes[params.noofnodes].xvert = 0.0
  params.nodes[params.noofnodes].deltainclination = 0.0
  params.nodes[params.noofnodes].deltaheading = 0.0
  params.nodes[params.noofnodes].dispew = 0.0
  params.nodes[params.noofnodes].dispns = 0.0
  for i in reverse(1:params.noofnodes-1)
    
    local dz = params.nodes[i].z - params.nodes[i+1].z
    params.nodes[i].tvd = params.nodes[i+1].tvd + dz * cos(params.nodes[i].inclination)
    params.nodes[i].xvert = params.nodes[i+1].xvert + dz * sin(params.nodes[i].inclination)
    
    # deltas expressed per 100 ft
    params.nodes[i].deltainclination =  
      1200.0 * (params.nodes[i].inclination - params.nodes[i+1].inclination)/dz
    params.nodes[i].deltaheading =  
      1200.0 * (params.nodes[i].heading - params.nodes[i+1].heading)/dz
      
    local dx = params.nodes[i].xvert - params.nodes[i+1].xvert
    params.nodes[i].dispns = params.nodes[i+1].dispns + dx * cos(params.nodes[i].heading)
    params.nodes[i].dispew = params.nodes[i+1].dispew + dx * sin(params.nodes[i].heading)
  end
  
  nothing
end
