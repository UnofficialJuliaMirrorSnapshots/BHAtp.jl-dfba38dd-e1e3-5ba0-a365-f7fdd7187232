function fem!(params::BHAtp.Parameters, ptup)

  params.noofiters[:] = [0]
  while params.noofiters[1] < params.maxiters
    params.noofiters[1] += 1
    error = 0.0
    
    for j in 1:(2 * params.noofnodes)
      node = j
      if j > params.noofnodes
        node = 2 * params.noofnodes + 1 - j
      end
      for i in 1:6
        params.fdel[i, 1] = params.f[i, 1, node]
        params.f[i, 1, node] = 0.0
      end
      weightforces!(node, params)
      endforces!(node, params)
      curvatureforces!(node, params)
      initialrelease!(node, params)
      exceedanceadjustment!(node, params)
      error = finalrelease!(node, error, params)
    end
    if params.noofiters[1] in ptup[1]
      write(ptup[2], "Errors ($(params.noofiters[1])): $(error)\n")
    end
    if error < params.dlerrormax
      write(ptup[2], "Errors ($(params.noofiters[1])): $(error)\n")
      break
    end
  end
end
