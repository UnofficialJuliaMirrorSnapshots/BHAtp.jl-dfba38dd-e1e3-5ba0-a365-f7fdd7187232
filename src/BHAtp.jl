__precompile__()

module BHAtp

# package code goes here

using Reexport, DataFrames, Statistics, Distributed
using SparseArrays, LinearAlgebra 

@reexport using PtFEM

# General utilities

include("util/types.jl")

# input routines (called from BHAtp.jl)

include("input/creatematerialdict.jl")
include("input/createmediadict.jl")
include("input/input.jl")
#include("input/updatematerialtable.jl")
#include("input/updatemediatable.jl")

# problem input handling

include("problem/problem.jl")
include("problem/createmesh.jl")
include("problem/createsegmentdf.jl")
include("problem/createpropertydf.jl")
include("problem/createnodedf.jl")
include("problem/createelementdf.jl")
include("problem/createcasetable.jl")

# user visible (called from e.g. example projects)

include("solve/solve.jl")

# core ptfem based mp runs

include("threads/runcase.jl")

# These table are created here, a user might update and/or add to these dicts

bha = Dict{Symbol, Any}()
materials = creatematerialdict()
media = createmediadict()

export
  bha,
  materials,
  media,
  #updatedmaterialstable,
  #updatemedatable,
  input!,
  problem,
  solve

end # module
