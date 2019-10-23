function createstiffnessmatrices!(params::Parameters)
  noofnodes = length(params.nodes)
  sb0 = zeros(6, 6)
  for i in 1:noofnodes
    if 1 < i < noofnodes
      ler = params.elements[i-1].er
      lea = params.elements[i-1].ea
      lgj = params.elements[i-1].gj
      l1 = params.nodes[i].z - params.nodes[i-1].z
      l2 = params.nodes[i+1].z - params.nodes[i].z
      params.sa[:, :, i] = stiffnessa!(i, l1, ler, lea, lgj)
      params.sb1[:, :, i] = stiffnessb1!(i, l1, ler, lea, lgj)
      params.sb2[:, :, i] = stiffnessb2!(i, noofnodes, l2, ler, lea, lgj)
      params.sc[:, :, i] = stiffnessc!(i, noofnodes, l2, ler, lea, lgj)
      params.si[:, :, i] = stiffnessi!(i, params.sb1[:, :, i], params.sb2[:, :, i])
    else
      if i == 1
        ler = params.elements[i].er
        lea = params.elements[i].ea
        lgj = params.elements[i].gj
        l2 = params.nodes[i+1].z - params.nodes[i].z
        params.sb2[:, :, i] = stiffnessb2!(i, noofnodes, l2, ler, lea, lgj)
        params.sc[:, :, i] = stiffnessc!(i, noofnodes, l2, ler, lea, lgj)
        params.si[:, :, i] = stiffnessi!(i, sb0, params.sb2[:, :, i])
      else
        ler = params.elements[i-1].er
        lea = params.elements[i-1].ea
        lgj = params.elements[i-1].gj
        l1 = params.nodes[i].z - params.nodes[i-1].z
        params.sa[:, :, i] = stiffnessa!(i, l1, ler, lea, lgj)
        params.sb1[:, :, i] = stiffnessb1!(i, l1, ler, lea, lgj)
        params.si[:, :, i] = stiffnessi!(i, params.sb1[:, :, i], sb0)
      end
    end
  end
  
  params.sainit[:, :, :] = copy(params.sa)
  params.sb1init[:, :, :] = copy(params.sb1)
  params.sb2init[:, :, :] = copy(params.sb2)
  params.scinit[:, :, :] = copy(params.sc)
  
  nothing
end

function stiffnessa!(node, l, ler, lea, lgj)
  s = zeros(6, 6)
  if node == 1
    return
  else
    s[1, 1] = -12.0 * ler / l^3
    s[1, 5] =  -6.0 * ler / l^2
    s[2, 2] = -12.0 * ler / l^3
    s[2, 4] =   6.0 * ler / l^2
    s[3, 3] =        -lea / l
    s[4, 2] =  -6.0 * ler / l^2
    s[4, 4] =   2.0 * ler / l
    s[5, 1] =   6.0 * ler / l^2
    s[5, 5] =   2.0 * ler / l
    s[6, 6] =        -lgj / l  
  end
  s
end

function stiffnessb1!(node, l, ler, lea, lgj)
  s = zeros(6, 6)
  if node == 1
    return
  else
    s[1, 1] =  12.0 * ler / l^3
    s[1, 5] =  -6.0 * ler / l^2
    s[2, 2] =  12.0 * ler / l^3
    s[2, 4] =   6.0 * ler / l^2
    s[3, 3] =         lea / l
    s[4, 2] =   6.0 * ler / l^2
    s[4, 4] =   4.0 * ler / l
    s[5, 1] =  -6.0 * ler / l^2
    s[5, 5] =   4.0 * ler / l
    s[6, 6] =         lgj / l  
  end
  s
end

function stiffnessb2!(node, noofnodes, l, ler, lea, lgj)
  s = zeros(6, 6)
  if node == noofnodes
    return
  else
    s[1, 1] =  12.0 * ler / l^3
    s[1, 5] =   6.0 * ler / l^2
    s[2, 2] =  12.0 * ler / l^3
    s[2, 4] =  -6.0 * ler / l^2
    s[3, 3] =         lea / l
    s[4, 2] =  -6.0 * ler / l^2
    s[4, 4] =   4.0 * ler / l
    s[5, 1] =   6.0 * ler / l^2
    s[5, 5] =   4.0 * ler / l
    s[6, 6] =         lgj / l  
  end
  s
end

function stiffnessc!(node, noofnodes, l, ler, lea, lgj)
  s = zeros(6, 6)
  if node == noofnodes
    return
  else
    s[1, 1] = -12.0 * ler / l^3
    s[1, 5] =   6.0 * ler / l^2
    s[2, 2] = -12.0 * ler / l^3
    s[2, 4] =  -6.0 * ler / l^2
    s[3, 3] =        -lea / l
    s[4, 2] =   6.0 * ler / l^2
    s[4, 4] =   2.0 * ler / l
    s[5, 1] =  -6.0 * ler / l^2
    s[5, 5] =   2.0 * ler / l
    s[6, 6] =        -lgj / l  
  end
  s
end

function stiffnessi!(node, sb1, sb2)
  s = zeros(6, 6)
  b = sb1 + sb2
  h = b[1, 1] * b[5, 5] - b[1, 5]^2
  ff = b[5, 5] / h
  g = -b[1, 5] / h
  h = b[1, 1] / h
  s[1, 1] = ff
  s[1, 5] = g
  s[2, 2] = ff
  s[2, 4] = -g
  s[3, 3] = node == 1 ? 0.0 : 1.0 / b[3, 3]
  s[4, 2] = -g
  s[4, 4] = h
  s[5, 1] = g
  s[5, 5] = h
  s[6, 6] = node == 1 ? 0.0 : 1.0 / b[6, 6]  
  s
end

