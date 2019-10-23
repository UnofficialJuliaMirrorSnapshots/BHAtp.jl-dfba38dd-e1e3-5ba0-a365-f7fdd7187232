function curvatureforces!(node::Int64, params::Parameters)
  # Static version
  # From top to bit (node == 1): :down, from bit to top: :up
  for kk in 1:2
    if !((kk == 1 && node == 1) || (kk == 2 && node == params.noofnodes))
      k = -3 + 2 * kk
      i2 = node + kk - 1
      i1 = i2 - 1
      l = params.nodes[i2].z - params.nodes[i1].z
      tn = params.elements[i1].ea * (params.del[3, 1, i2] - params.del[3, 1, i1]) / l
      ts = params.elements[i1].gj * (params.del[6, 1, i2] - params.del[6, 1, i1]) / l
      avthx = (params.del[4, 1, i2] + params.del[4, 1, i1]) / 2.0
      avthy = (params.del[5, 1, i2] + params.del[5, 1, i1]) / 2.0
      params.f[1, 1, node] += tn * avthy * k
      params.f[2, 1, node] -= tn * avthx * k
      params.f[4, 1, node] += ts * avthy * k
      params.f[5, 1, node] -= ts * avthx * k
    end
  end
end
