function geometrixmatrix(l::Float64)
  gm = zeros(12, 12)
  pt1 = 0.1
  opt2 = 1.2
  two = 2.0
  d15 = 15.0
  d30 = 30.0
  
  gm[1, 1]   = opt2 / l
  gm[1, 5]   = pt1
  gm[1, 7]   = -opt2 / l
  gm[1, 11]  = pt1
  
  gm[2, 2]   = opt2 / l
  gm[2, 4]   = -pt1
  gm[2, 8]   = -opt2 / l
  gm[2, 10]  = -pt1
  
  gm[4, 2]   = -pt1
  gm[4, 4]   = two * l / d15
  gm[4, 8]   = pt1
  gm[4, 10]  = -l / d30
  
  gm[5, 1]   = pt1
  gm[5, 5]   = two * l / d15
  gm[5, 7]   = -pt1
  gm[5, 11]  = -l / d30
  
  gm[7, 1]   = -opt2 / l
  gm[7, 5]   = -pt1
  gm[7, 7]   = opt2 / l
  gm[7, 11]  = -pt1
  
  gm[8, 2]   = -opt2 / l
  gm[8, 4]   = pt1
  gm[8, 8]   = opt2 / l
  gm[8, 10]  = pt1
  
  gm[10, 2]  = -pt1
  gm[10, 4]  = -l / d30
  gm[10, 8]  = pt1
  gm[10, 10] = two * l / d15
  
  gm[11, 1]  = pt1
  gm[11, 5]  = -l / d30
  gm[11, 7]  = -pt1
  gm[11, 11] = two * l / d15
  
  gm
end