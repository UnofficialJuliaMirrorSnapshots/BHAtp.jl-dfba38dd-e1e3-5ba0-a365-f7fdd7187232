#
# Copyright: Rob J Goedman (2015)
#
# Defines the composite Parameters type. The params variable will be created
# after checking the input Dictionary for correctness and completeness.

struct Parameters
  #
  # CONSTANTS
  #
  # Conversion factor from degrees to radians
  #
	dtor::Float64
  #
  # Gravitational acceleration
  #
	g::Float64
  #
  # PARAMETERS
  #
  # Used in construction of element mesh.
  # ratio = segment length / segment outer diameter
  #
	ratio::Float64
  #
  # INPUTS
  #
  wob::Float64
  maxiters::Int64
  remove_bit_constraints::Bool
  use_geometric_correction::Bool
  #
  # Derived from inputs
  #
  has_bit::Bool
  has_rig::Bool
	
  noofelements::Int64
  noofnodes::Int64
  noofiters::Vector{Int64}

  elements::Array{BHAtp.Element, 1}
  nodes::Array{BHAtp.Node, 1}

  f::Array{Float64, 3}
  bf::Array{Float64, 3}
  fn::Vector{Float64}
  fs::Vector{Float64}
  friction::Vector{Float64}
  del::Array{Float64, 3}
  fvec::Array{Float64, 3}

  sainit::Array{Float64, 3}
  sb1init::Array{Float64, 3}
  sb2init::Array{Float64, 3}
  scinit::Array{Float64, 3}
  siinit::Array{Float64, 3}
  sa::Array{Float64, 3}
  sb1::Array{Float64, 3}
  sb2::Array{Float64, 3}
  sc::Array{Float64, 3}
  si::Array{Float64, 3}
  gm::Array{Float64, 3}

  fdel::Matrix{Float64}
  rdel::Matrix{Float64}
  exc::Matrix{Float64}
  sasc::Matrix{Float64}
  delta::Matrix{Float64}
  
  dlerrormax::Float64
  
end

function Parameters(data::Dict{Symbol, Any})

	ratio = 
	if :ratio in keys(data)
		ratio = data[:ratio]::Float64
	else
		ratio = 0.6
	end

  noofelements = data[:noofelements]
  noofnodes = data[:noofelements] + 1
	
  elements = [BHAtp.Element() for i in 1:noofelements]
  nodes = [BHAtp.Node() for i in 1:noofnodes]
  
  f = zeros(Float64, 6, 3, noofnodes)
  bf = zeros(Float64, 2, 3, noofnodes)
  fn = zeros(Float64, noofnodes)
  fs = zeros(Float64, noofnodes)
  friction = zeros(Float64, noofnodes)
  del = zeros(Float64, 6, 3, noofnodes)
  fvec = zeros(Float64, 6, 3, noofnodes)
  
  sainit = zeros(Float64, 6, 6, noofnodes)
  sb1init = zeros(Float64, 6, 6, noofnodes)
  sb2init = zeros(Float64, 6, 6, noofnodes)
  scinit = zeros(Float64, 6, 6, noofnodes)
  siinit = zeros(Float64, 6, 6, noofnodes)
  sa = zeros(Float64, 6, 6, noofnodes)
  sb1 = zeros(Float64, 6, 6, noofnodes)
  sb2 = zeros(Float64, 6, 6, noofnodes)
  sc = zeros(Float64, 6, 6, noofnodes)
  si = zeros(Float64, 6, 6, noofnodes)
  gm = zeros(Float64, 12, 12, noofnodes)

  fdel = zeros(Float64, 6, 3)
  rdel = zeros(Float64, 6, 3)
  exc = zeros(Float64, 2, 3)
  sasc = zeros(Float64, 6, 12)
  delta = zeros(Float64, 12, 3)
  
  dtor = pi / 180.0
	
  Parameters(
  	# dtor: 1 degree = 2 * pi / 360 radians = 0.0174532925 radians
  	dtor,

  	# g: gravitational constant [m/sec^2]
  	9.80665,

  	# ratio used to subdivide segments into (finite) elements
  	ratio,
    
    # wob, already converted from tonnes
    data[:wob],
  
    # Max number of iterations
    data[:maxiters],
  
    # Set remove_bit_constraints in params (or better still, use tp!)
    :remove_bit_constraints in keys(data) ? data[:removebitcontsraints] : false,
  
    # Flag that geometriccorrection is to be applied
    :geometriccorrection in keys(data) ? data[:geometriccorrection] : false,
  
    # Set has_bit field in params, CheckInput.jl checked that if a bit is present,
    # it must be the first segment defined in the BHAJ.
    typeof(data[:segments][1]) == Bit ? true : false,
  
    # Set has_rig to indicate top element needs to be fix in central position
    typeof(data[:segments][data[:noofsegments]]) == Rig ? true : false,
  
    noofelements,
    noofnodes,
    [0],
    elements, nodes,
    f, bf, fn, fs, friction, del, fvec,
    sainit, sb1init, sb2init, scinit, siinit,
    sa, sb1, sb2, sc, si, gm,
    fdel, rdel, exc, sasc, delta,
  
    data[:dlerrormax]
  )
end

function parameters_show(io::IO, p::Parameters, compact::Bool)
  if compact
    println(io, [getfield(p, f) for f in fieldnames(p)])
  else
    println("Parameters(")
    println("  # Conversion factors:")
    println("  dtor                     = ", p.dtor)
    println("  g                        = ", p.g)
    println()
    println("  # Inputs:")
    println("  ratio                    = ", p.ratio)
    println("  wob                      = ", p.wob)
    println("  dlerrormax               = ", p.dlerrormax)
    println("  drerrormax               = ", p.drerrormax)
    println("  maxiters                 = ", p.maxiters)
    println("  noofiters                = ", p.noofiters[1])
    println()
    println("  # Mesh creation:")
    println("  noofelements             = ", p.noofelements)
    println("  noofnodes                = ", p.noofnodes)
    println()
    println("  # Execution flags:")
    println("  has_bit                  = ", p.has_bit)
    println("  remove_bit_constraints   = ", p.remove_bit_constraints)
    println("  has_rig                  = ", p.has_rig)
    println("  use_geometric_correction = ", p.use_geometric_correction)
    println(")")
  end
end

show(io::IO, p::Parameters) = parameters_show(io, p, false)
showcompact(io::IO, p::Parameters) = parameters_show(io, p, true)
