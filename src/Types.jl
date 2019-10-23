# Segment and survey types

"""
`SegmentType`: Type of a segment in a Bottom Hole Assembly (BHA), currently defined:\n
  `Collar`, `Pipe`, `Stabilizer`, `Bit`
"""
abstract type SegmentType end

"""
`Collar(material, length, id, od, fc)`: Definition of a Collar segment.

where:\n
  `material`::Symbol, e.g. :Steel or :Composite\n
  `length`  ::Float64, length of segment, in [m] or [ft]\n
  `id`      ::Float74, internal diameter, in [m] or [inch]\n
  `od`      ::Float74, external diameter, in [m] or [inch]\n
  `fc`      ::Float74, friction coefficient, in [-]
"""
mutable struct Collar <: SegmentType
  material::Symbol
  length::Float64
  id::Float64
  od::Float64
  fc::Float64
end

"""
`Pipe(material, length, id, od, fc)`: Definition of a Pipe segment.

where:\n
  `material`::Symbol, e.g. :Steel or :Composite\n
  `length`  ::Float64, length of segment, in [m] or [ft]\n
  `id`      ::Float74, internal diameter, in [m] or [inch]\n
  `od`      ::Float74, external diameter, in [m] or [inch]\n
  `fc`      ::Float74, friction coefficient, in [-]
"""
mutable struct Pipe <: SegmentType
  material::Symbol
  length::Float64
  id::Float64
  od::Float64
  fc::Float64
end

"""
`Stabilizer(material, id, od, fc)`: Definition of a Stabilizer segment.

where:\n
  `material`::Symbol, e.g. :Steel or :Composite\n
  `length`  ::Float64, length of segment, in [m] or [ft]\n
  `id`      ::Float74, internal diameter, in [m] or [inch]\n
  `od`      ::Float74, external diameter, in [m] or [inch]\n
  `fc`      ::Float74, friction coefficient, in [-]
"""
mutable struct Stabilizer <: SegmentType
  material::Symbol
  length::Float64
  id::Float64
  od::Float64
  fc::Float64
end

"""
`Rig(id, od)`: Definition of a Rig segment. This element must
be the topmost element of the BHA and will fix the position of
the BHA in the center.

where:\n
  `material`::Symbol, e.g. :Steel or :Composite\n
  `length`  ::Float64, length of segment, in [m] or [ft]\n
  `id`      ::Float74, internal diameter, in [m] or [inch]\n
  `od`      ::Float74, external diameter, in [m] or [inch]\n
  `fc`      ::Float74, friction coefficient, in [-]
"""
mutable struct Rig <: SegmentType
  material::Symbol
  length::Float64
  id::Float64
  od::Float64
  fc::Float64
end

"""
`Bit(material, id, od, fc)`: Definition of a Bit segment.

where:\n
  `material`::Symbol, e.g. :Steel or :Composite\n
  `length`  ::Float64, length of segment, in [m] or [ft]\n
  `id`      ::Float74, internal diameter, in [m] or [inch]\n
  `od`      ::Float74, external diameter, in [m] or [inch]\n
  `fc`      ::Float74, friction coefficient, in [-]
"""
mutable struct Bit <: SegmentType
  material::Symbol
  length::Float64
  id::Float64
  od::Float64
  fc::Float64
end
"""
`Bentsub(material, id, od, fc, angle)`: Definition of the Bentsub.

where:\n
  `angle`   ::Bentsub angle [degrees]
"""
mutable struct Bentsub <: SegmentType
  material::Symbol
  angle::Float64
end

"""
# ExtForce

ExtForce: Segment with no length that handles an external force applied to the assemby.

The forces fx and fy are assumed to be in the local coordinate system.

### Tpe
```julia
ExtForce(depth, inclination, heading, Fx, Fy)
```
### Arguments
```julia
* `fx`          : Force in x direction
* `fy`          : Force in y direction
```
"""
mutable struct ExtForce <: SegmentType
  fx::Float64
  fy::Float64
end

# Segment and survey types

"""
`SurveyType`: Type of a survey record, currently defined:\n
  `RigSurvey`, `HoleSurvey`, `BitSurvey`
"""
abstract type SurveyType end
mutable struct RigSurvey <: SurveyType
  depth::Float64
  inclination::Float64          # [Degrees]
  heading::Float64              # [Degrees]
  diameter::Float64
end

mutable struct HoleSurvey <: SurveyType
  depth::Float64
  inclination::Float64          # [Degrees]
  heading::Float64              # [Degrees]
  diameter::Float64
end

mutable struct BitSurvey <: SurveyType
  depth::Float64
  inclination::Float64          # [Degrees]
  heading::Float64              # [Degrees]
  diameter::Float64
end

mutable struct TpRecord
  dalpha::Float64
  wob::Float64
  inclination::Float64
  fbit::Float64
  firsttouch::Float64
  f_firsttouch::Float64
  solution::DataFrame
end

function tprecord_show(io::IO, tprecord::TpRecord, compact::Bool)
  println(io, Float64[getfield(tprecord, f) for f in fieldnames(tprecord)[1:6]])
end

show(io::IO, tprecord::TpRecord) = tprecord_show(io, tprecord, false)
showcompact(io::IO, tprecord::TpRecord) = tprecord_show(io, tprecord, true)

# Trajectory type

"""
`Trajectory(inclination, heading, diameter)`: Definition of the well trajectory.

where:\n
  `inclination` ::Float64, inclination from vertical, in [radians]\n
  `heading`     ::Float64, direction from North, in [radians]\n
  `diameter`    ::Float74, internal diameter, in [inch]\n
"""
mutable struct Trajectory
  heading::Float64          # Used, but irrelevant
  diameter::Float64
end
Trajectory() = Trajectory(0.0, 0.0)

# BHA type

"""
`BHA(material, length, id, od, fc)`: Definition of a BHA type.

where:\n
  `ratio`       ::Float64, used to generate the FE mesh, in []\n
  `medium`      ::Symbol, currently only :mud is supported\n
  `maxiters`    ::Int, maximum number of FE up/down iterations\n
  `dlerrormax`  ::Float74, maximum dl difference between 2 iterations\n
  `drerrormax`  ::Float74, maximum dr difference between 2 iterations\n
  `segments`    ::Vector of Segments (see SegmentType)\n
  `surveys`     ::Vector of Survey records (see SurveyType)\n
"""
mutable struct BHAJ{T}
  ratio::Float64
  medium::Symbol
  maxiters::Int
  dlerrormax::Float64
  drerrormax::Float64
  segments::Array{SegmentType, 1}
  surveys::Array{SurveyType, 1}
  trajectory::Trajectory
  tprecords::Array{TpRecord, 1}
  name::T
  pdir::String
  debuglevel::Int
end

# External constructors
BHAJ(name::T, pdir::String, debuglevel::Int=0) where T = BHAJ(
  0.6, 
  :mud, 
  Int(1e5), 
  1e-7, 
  1e-7, 
  Array{SegmentType, 1}(), 
  Array{SurveyType, 1}(), 
  Trajectory(), 
  Array{TpRecord, 1}(),
  name,
  pdir,
  debuglevel
)

"""
# Finite Element object

Element: Finite element object

### Tpe
```julia
Fe(length, id, od, radius, fc, inclination, heading, mass, ea, eix, eiy, gl)
```
### Arguments
```julia
* `length`      : Length of element
* `id`          : Inside diameter
* `od`          : Outside diameter
* `radius`      : Radius
* `fc`          : Friction coefficient
* `inclination` : Inclination [Radians]
* `heading`     : Heading [Radians]
* `mass`        : Element mass
                  Young moduli
* `ea`          : E*A in z direction
* `er`          : E*I in r direction
* `gj`          : Shear modulus
* `nu`          : Poisson constant
```
"""
mutable struct Element
  length::Float64
  id::Float64                 # Inside diameter
  od::Float64                 # Outside diameter
  radius::Float64
  fc::Float64                 # Friction coefficient
  inclination::Float64
  heading::Float64
  mass::Float64
  ea::Float64
  er::Float64
  gj::Float64
  nu::Float64
end
Element() = Element(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

"""
# Node object

Node: Node object

### Constructor
```julia
Node(z, x, y, tvd, xvert, dispew, dispns, inclination, deltainclination, dip, 
  heading, deltaheading, holeradius, stringradius, fc, clearance,
  weight, mass, massinertia, axialinertia, radialinertia)
  
* dip  : Angle [Radians] from horizon
* inclination : Angle [Radians] from vertical
```
### Fields
```julia
* `x`                 : x coordinate
* `y`                 : y coordinate
* `z`                 : z coordinate
* `tvd`               : Measured depth
* `xvert`             : True vertical depth
* `dispew`            : Angle from east to west [Radians]
* `dispns`            : Angle from north to south [Radians]
* `inclination`       : Inclination [Radians]
* `deltainclination`  : Add'l inclinationination angle (bentsub) [Radians]
* `dip`               : Dip at node [Radians]
* `heading`           : Heading [Radians]
* `deltaheading`         : Add'l heading angle (bentsub) [Radians]
* `holeradius`        : Hole radius
* `stringradius`      : String radius
* `fc`                : Friction coefficient
* `clearance`         : Clearance element in hole
* `weight`            : Weight (force)
* `mass`              : Mass
* `massinertia`       : Second moment of inertia
* `axialinertia`      : Moment of inertia
* `radialinertia`     : Radial inertia
* `externalxforce`    : External force in x direction applied at node
* `externalyforce`    : External force in y direction applied at node
* `fixedxcoord`       : Fixed location in x direction at node
* `fixedycoord`       : Fixed location in y direction at node
* `fixedxtheta`       : Fixed angle from z towards x direction at node
* `fixedytheta`       : Fixed angle from z towards y direction at node
```
"""
mutable struct Node
  x::Float64
  y::Float64
  z::Float64
  tvd::Float64
  xvert::Float64
  dispew::Float64
  dispns::Float64
  inclination::Float64
  deltainclination::Float64
  dip::Float64
  heading::Float64
  deltaheading::Float64
  holeradius::Float64
  stringradius::Float64
  fc::Float64
  clearance::Float64
  weight::Float64
  mass::Float64
  massinertia::Float64
  axialinertia::Float64
  radialinertia::Float64
  externalxforce::Float64
  externalyforce::Float64
  fixedxcoord::Float64
  fixedycoord::Float64
  fixedxtheta::Float64
  fixedytheta::Float64
end
Node() = Node(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)