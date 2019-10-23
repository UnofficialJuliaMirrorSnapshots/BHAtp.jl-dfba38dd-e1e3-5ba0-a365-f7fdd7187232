function elements2df(els::Vector{Element}; rtod=180.0/pi)
  DataFrame(
    length  = [els[i].length for i in 1:length(els)],
    id      = [els[i].id for i in 1:length(els)],
    od      = [els[i].od for i in 1:length(els)],
    radius  = [els[i].radius for i in 1:length(els)],
    inclination    = [els[i].inclination*rtod for i in 1:length(els)],
    heading = [els[i].heading*rtod for i in 1:length(els)],
    fc      = [els[i].fc for i in 1:length(els)], 
    mass    = [els[i].mass for i in 1:length(els)],
    ea      = [els[i].ea for i in 1:length(els)],
    er      = [els[i].er for i in 1:length(els)],
    gj      = [els[i].gj for i in 1:length(els)]
  )
end

function nodes2df(nodes::Vector{Node}; rtod=180.0/pi)
  yvals = [nodes[i].y for i in 1:length(nodes)]
  for i in 1:length(yvals)
    if abs(yvals[i]) < 1.0e-13
      yvals[i] = 0.0
    end
  end
  DataFrame(
    x  = [nodes[i].x for i in 1:length(nodes)],
    y  = yvals,
    z  = [nodes[i].z for i in 1:length(nodes)],
    tvd  = [nodes[i].tvd for i in 1:length(nodes)],
    xvert  = [nodes[i].xvert for i in 1:length(nodes)],
    dispew  = [nodes[i].dispew for i in 1:length(nodes)],
    dispns  = [nodes[i].dispns for i in 1:length(nodes)],
    inclination  = [nodes[i].inclination*rtod for i in 1:length(nodes)],
    dip  = [nodes[i].dip*rtod for i in 1:length(nodes)],
    heading  = [nodes[i].heading*rtod for i in 1:length(nodes)],
    holeradius  = [nodes[i].holeradius for i in 1:length(nodes)],
    stringradius  = [nodes[i].stringradius for i in 1:length(nodes)],
    clearance  = [nodes[i].clearance for i in 1:length(nodes)],
    fc  = [nodes[i].fc for i in 1:length(nodes)],
    weight  = [nodes[i].weight for i in 1:length(nodes)],
    mass  = [nodes[i].mass for i in 1:length(nodes)],
    massinertia  = [nodes[i].massinertia for i in 1:length(nodes)],
    axialinertia  = [nodes[i].axialinertia for i in 1:length(nodes)],
    radialinertia  = [nodes[i].radialinertia for i in 1:length(nodes)],
    deltainclination  = [nodes[i].deltainclination*rtod for i in 1:length(nodes)],
    deltaheading  = [nodes[i].deltaheading*rtod for i in 1:length(nodes)],
    externalxforce  = [nodes[i].externalxforce for i in 1:length(nodes)],
    externalyforce  = [nodes[i].externalyforce for i in 1:length(nodes)],
    fixedxcoord  = [nodes[i].fixedxcoord for i in 1:length(nodes)],
    fixedycoord  = [nodes[i].fixedycoord for i in 1:length(nodes)],
    fixedxtheta  = [nodes[i].fixedxtheta for i in 1:length(nodes)],
    fixedytheta  = [nodes[i].fixedytheta for i in 1:length(nodes)],
  )
end  

function segments2df(data::Dict{Symbol, Any})
  syms = [:segment_type, :material, :length, :id, :od, :fc, :angle, :fx, :fy]
  df = DataFrame(Any[DataType[], Symbol[], Float64[], Float64[],
    Float64[], Float64[], Float64[], Float64[], Float64[]], syms)
  for seg in data[:segments]
    if typeof(seg) in [Bit, Stabilizer]
      push!(df, [typeof(seg) seg.material 0.0 seg.id seg.od seg.fc 0.0 0.0 0.0])
    elseif typeof(seg) in [Collar, Pipe]
      push!(df, [typeof(seg) seg.material seg.length seg.id seg.od seg.fc 0.0 0.0 0.0])
    elseif typeof(seg) in [Rig]
      push!(df, [typeof(seg) seg.material 0.0 seg.id seg.od 0.0 0.0 0.0 0.0])
    elseif typeof(seg) in [Bentsub]
      push!(df, [typeof(seg) :none 0.0 0.0 0.0 0.0 seg.angle 0.0 0.0])
    elseif typeof(seg) in [ExtForce]
      push!(df, [typeof(seg) :none 0.0 0.0 0.0 0.0 0.0 seg.fx seg.fy])
    else
      println("Unknown segment_type found.")
    end
  end
  df
end

function sol2df(fname::AbstractString)
  tmp_df = DataFrames.readtable(fname)
  
	syms = [:depth, :dtb, :radius, :incl, :hdng, :x, :y, :delx, :dely, :fx, :fy, :fz]
	df = DataFrame(Any[Float64[], Float64[], Float64[], Float64[], Float64[], Float64[],
    Float64[], Float64[], Float64[], Float64[], Float64[], Float64[]], syms
	)
  
  (rows, colums) = size(tmp_df)
  maxdepth = maximum(tmp_df[:depth])
  
  for i in 1:rows
  	push!(df, [
      tmp_df[:depth][i], tmp_df[:distanceToBit][i], 
      tmp_df[:holeRadius][i], tmp_df[:inclination][i], tmp_df[:heading][i],
      round(tmp_df[:x][i], digits=4),
      round(tmp_df[:y][i], digits=4),
      round(tmp_df[:delX][i], digits=4),
      round(tmp_df[:delY][i], digits=5),
      round(tmp_df[:fX][i], digits=5),
      round(tmp_df[:fY][i], digits=5),
      round(tmp_df[:fZ][i], digits=5)
      ]
    )
  end
	df
end

function dyn2df(params::BHAtp.Parameters)
	syms = [:depth, :xampl, :xphase, :yampl, :yphase, :fxamp, :fxphase, :fyampl, :fyphase]
	df = DataFrame(Any[Float64[], Float64[], Float64[], Float64[], Float64[], Float64[],
    Float64[], Float64[], Float64[]], syms
	)
  for i in 1:params.noofnodes
    xampl = round(sqrt(params.del[1,2,i]^2 + params.del[1,3,i]^2), digits=4)
    xphase = xampl > 1.0e-20 ? atan2(params.del[1,2,i], params.del[1,3,i])/params.dtor : 0.0
    yampl = round(sqrt(params.del[2,2,i]^2 + params.del[2,3,i]^2), digits=4)
    yphase = yampl > 1.0e-20 ? atan2(-params.del[2,2,i], -params.del[2,3,i])/params.dtor : 0.0
    fxampl = round(sqrt(params.bf[1,2,i]^2 + params.bf[1,3,i]^2), digits=4)
    fxphase = fxampl > 1.0e-20 ? atan2(params.bf[1,2,i], params.bf[1,3,i])/params.dtor : 0.0
    fyampl = round(sqrt(params.bf[2,2,i]^2 + params.bf[2,3,i]^2), digits=4)
    fyphase = fyampl > 1.0e-20 ? atan2(-params.bf[2,2,i], -params.bf[2,3,i])/params.dtor : 0.0
  	push!(df, [
      params.nodes[i].z/12.0, 
      xampl,  xphase,
      yampl,  yphase,
      fxampl,  fxphase,
      fyampl,  fyphase
      ]
    )
  end
	df
end

function tp2df(tptable)
  syms = [:wob, :incl, :tp, :fbit, :dtft, :ft]
	df = DataFrame(Any[Float64[], Float64[], Float64[], Float64[], Float64[], Float64[]],
    syms)
  for i in 1:length(tptable)
    wob = round(tptable[i].wob, digits=4)/1000.0
    inclination = round(round(tptable[i].inclination, digits=4), digits=4)
    dalpha = -round(tptable[i].dalpha, digits=4)
    fbit = round(round(tptable[i].fbit, digits=4), digits=4)
    firsttouch = round(round(tptable[i].firsttouch, digits=4), digits=4)
    f_firsttouch = round(round(tptable[i].f_firsttouch, digits=4), digits=4)
  	push!(df, [wob, inclination, dalpha, fbit,  firsttouch, f_firsttouch])
  end
	df
end

function sol2df(params::BHAtp.Parameters)
	syms = [:depth, :dtb, :radius, :od, :incl, :hdng, :x, :y, :dx, :dy, :dz,
    :fx, :fy, :fz, :friction, :fn, :fs]
	df = DataFrame(Any[Float64[], Float64[], Float64[], Float64[], Float64[],
    Float64[], Float64[], Float64[], Float64[], Float64[], Float64[], Float64[],
    Float64[], Float64[], Float64[], Float64[], Float64[]], syms
	)
  nnodes = params.noofnodes
  maxdepth = maximum(params.nodes[nnodes].z)
  for i in 1:nnodes
  	push!(df, [
      (maxdepth - params.nodes[i].z)/12.0, params.nodes[i].z/12.0,
      params.nodes[i].holeradius, params.nodes[i].stringradius,
      (params.nodes[i].inclination/params.dtor),
      (params.nodes[i].heading/params.dtor),
      params.nodes[i].x, params.nodes[i].y,
      round((params.del[1,1,i] - params.nodes[i].x), digits=4),
      round((params.del[2,1,i] - params.nodes[i].y), digits=4),
      round(params.del[3,1,i], digits=4),
      round(params.f[1, 1, i], digits=5),
      round(params.f[2, 1, i], digits=5),
      round(params.f[3, 1, i], digits=5),
      round(params.friction[i], digits=5),
      round(params.fn[i], digits=5),
      round(params.fs[i], digits=5)
      ]
    )
  end
	df
end

