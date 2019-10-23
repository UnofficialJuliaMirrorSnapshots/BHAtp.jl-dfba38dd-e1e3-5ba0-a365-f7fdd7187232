function initialrelease!(node::Int64, params::Parameters)
  for i in 1:6
    params.rdel[i, 1] = copy(params.del[i,1, node])
  end
  
  if 1 < node < params.noofnodes
    params.fvec[1,1,node] = params.f[1,1,node] - (
      params.sa[1,1,node]*params.del[1,1,node-1] + params.sc[1,1,node]*params.del[1,1,node+1] +
      params.sa[1,5,node]*params.del[5,1,node-1] + params.sc[1,5,node]*params.del[5,1,node+1])
    
    params.fvec[2,1,node] = params.f[2,1,node] - (
      params.sa[2,2,node]*params.del[2,1,node-1] + params.sc[2,2,node]*params.del[2,1,node+1] +
      params.sa[2,4,node]*params.del[4,1,node-1] + params.sc[2,4,node]*params.del[4,1,node+1])
    
    params.fvec[3,1,node] = params.f[3,1,node] - (
      params.sa[3,3,node]*params.del[3,1,node-1] + params.sc[3,3,node]*params.del[3,1,node+1])
    
    params.fvec[4,1,node] = params.f[4,1,node] - (
      params.sa[4,2,node]*params.del[2,1,node-1] + params.sc[4,2,node]*params.del[2,1,node+1] +
      params.sa[4,4,node]*params.del[4,1,node-1] + params.sc[4,4,node]*params.del[4,1,node+1])
  
    params.fvec[5,1,node] = params.f[5,1,node] - (
      params.sa[5,1,node]*params.del[1,1,node-1] + params.sc[5,1,node]*params.del[1,1,node+1] +
      params.sa[5,5,node]*params.del[5,1,node-1] + params.sc[5,5,node]*params.del[5,1,node+1])
    
    params.fvec[6,1,node] = params.f[6,1,node] - (
      params.sa[6,6,node]*params.del[6,1,node-1] + params.sc[6,6,node]*params.del[6,1,node+1])
  else
    if node == 1
      params.fvec[1,1,node] = params.f[1,1,node] - (
        params.sc[1,1,node]*params.del[1,1,node+1] + params.sc[1,5,node]*params.del[5,1,node+1])
    
      params.fvec[2,1,node] = params.f[2,1,node] - (
        params.sc[2,2,node]*params.del[2,1,node+1] + params.sc[2,4,node]*params.del[4,1,node+1])
    
      params.fvec[3,1,node] = params.f[3,1,node] - params.sc[3,3,node]*params.del[3,1,node+1]
    
      params.fvec[4,1,node] = params.f[4,1,node] - (
        params.sc[4,2,node]*params.del[2,1,node+1] + params.sc[4,4,node]*params.del[4,1,node+1])
  
      params.fvec[5,1,node] = params.f[5,1,node] - (
        params.sc[5,1,node]*params.del[1,1,node+1] + params.sc[5,5,node]*params.del[5,1,node+1])
    
      params.fvec[6,1,node] = params.f[6,1,node] - params.sc[6,6,node]*params.del[6,1,node+1]
    else
      params.fvec[1,1,node] = params.f[1,1,node] - (
        params.sa[1,1,node]*params.del[1,1,node-1] + params.sa[1,5,node]*params.del[5,1,node-1])
    
      params.fvec[2,1,node] = params.f[2,1,node] - (
        params.sa[2,2,node]*params.del[2,1,node-1] + params.sa[2,4,node]*params.del[4,1,node-1])
    
      params.fvec[3,1,node] = params.f[3,1,node] - params.sa[3,3,node]*params.del[3,1,node-1]
    
      params.fvec[4,1,node] = params.f[4,1,node] - (
        params.sa[4,2,node]*params.del[2,1,node-1] + params.sa[4,4,node]*params.del[4,1,node-1])
  
      params.fvec[5,1,node] = params.f[5,1,node] - (
        params.sa[5,1,node]*params.del[1,1,node-1] + params.sa[5,5,node]*params.del[5,1,node-1])
    
      params.fvec[6,1,node] = params.f[6,1,node] - params.sa[6,6,node]*params.del[6,1,node-1]
    end
  end
  
  params.del[1, 1, node] = params.si[1, 1, node] * params.fvec[1, 1, node] +
    params.si[1, 5, node] * params.fvec[5, 1, node]
    
  params.del[2, 1, node] = params.si[2, 2, node] * params.fvec[2, 1, node] +
    params.si[2, 4, node] * params.fvec[4, 1, node]
    
  params.del[3, 1, node] = params.si[3, 3, node] * params.fvec[3, 1, node]
  
  params.del[4, 1, node] = params.si[4, 2, node] * params.fvec[2, 1, node] +
    params.si[4, 4, node] * params.fvec[4, 1, node]
    
  params.del[5, 1, node] = params.si[5, 1, node] * params.fvec[1, 1, node] +
    params.si[5, 5, node] * params.fvec[5, 1, node]
  
  params.del[6, 1, node] = params.si[6, 6, node] * params.fvec[6, 1, node]
  params
end
