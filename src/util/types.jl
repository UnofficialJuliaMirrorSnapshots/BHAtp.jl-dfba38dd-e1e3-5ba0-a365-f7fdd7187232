# Survey types

"""
`SurveyType`: Type of a survey record, currently defined:\n
  `HoleSurvey`
"""
abstract type SurveyType end

mutable struct HoleSurvey <: SurveyType
  depth::Float64                 # [ft]
  inclination::Float64          # [degrees]
  diameter::Float64            # [in]
end

# Trajectory type

"""
`Trajectory(depth, inclination, diameter)`: Definition of well trajectory record.

where:\n
  `depth`         ::Float64                 # Distance from surface, along bore hole, in [ft]
  `inclination`  ::Float64                 # Inclination from vertical, in [radians]\n
  `diameter`    ::Float74                 # Hole diameter, in [inch]\n
"""
mutable struct TrajectoryRecord
  depth::Float64
  inclination::Float64 
  diameter::Float64
end
TrajectoryRecord() = TrajectoryRecord(0.0, 0.0)

"""
# MeshRecord object

Nodal mesh data generated from segments, etc

This structure is used to generate the PtFEM input data

### 
```julia
MeshRecord()      : Created an initialized MeshRecord

A mesh consistst of an Array{MeshRecord, 1}

The properties matrix is an Array{Floet64, 2}(no of collar/pipe segments, 4)

Each row in the properties matrix contains ea, eiy, eiz and gj.
```
### Fields
```julia
* `x::Float64`                   : x coordinate (along borehole)
* `y::Float64`                   : y coordinate
* `clearance::Float64`     : Clearance between od bha & bore hole wall
* `npType::Int`                 : Index into properties for element
* `seg::Int`                       : Element is part of segment `seg`
* `fx::Float64`                  : External force in x direction
* `fy::Float64`                  : External force in y direction
* `mx::Float64`                : External moment in x direction
* `my::Float64`                : External moment in y direction
* `eqfx::Float64`              : External equivalent force in x direction
* `eqfy::Float64`              : External equivalent force in y direction
* `eqmx::Float64`            : External equivalent moment in x direction
* `eqmy::Float64`            : External equivalent moment in y direction

The equivalent forces and moments correct the actions for distributed loads and moment (see figure 4.21 in PtFEM)
```
"""
mutable struct MeshRecord
  x::Float64
  y::Float64
  clearance::Float64                 # 
  nptype::Int
  segment::Int
  
  # Nodal loads
  
  fx::Float64
  fy::Float64
  mx::Float64
  my::Float64
  
  # Equivalent nodal forces and moments
  eqfx::Float64
  eqfy::Float64
  eqmx::Float64
  eqmy::Float64
  
end
MeshRecord() = MeshRecord(0.0, 0.0, 0.0, 1, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

"""
# BHA element object

BHA element object

### Type
```julia
Element(length, id, od, npind)
```
### Arguments
```julia
* `length`      : Length of element
* `id`             : Inside diameter
* `od`            : Outside diameter
* `npind`       : Index (row no) in property array
```
"""
mutable struct Element
  length::Float64
  id::Float64                 # Inside diameter
  od::Float64                 # Outside diameter
  npind::Int
end
Element() = Element(0.0, 0.0, 0.0, 0)

"""
# Node object

Node: Node object

### Constructor
```julia
Node(z, x, y, tvd, xvert, inclination, deltainclination, dip, 
   holeradius, stringradius, fc, clearance, weight)
  
* dip  : Angle [Radians] from horizon
* inclination : Angle [Radians] from vertical
```
### Fields
```julia
* `bharadius`         : String radius
* `weight`              : Weight (force)
* `fc`                      : Friction coefficient
```
"""
mutable struct Node
  bharadius::Float64
  weight::Float64
  fc::Float64
end
Node() = Node(0.0, 0.0, 0.0)