using BHAtp, Test

ProjDir = dirname(@__FILE__)
ProjName = split(ProjDir, "/")[end]

bha[:segs] = [
# Element type,  Material,    Length,     ID,         OD,      fc
  (:bit,          :steel,     0.00,   2.75,   9.0,  0.0),
  (:collar,       :steel,    45.00,   2.75,   7.0,  0.0),
  (:stabilizer,   :steel,     0.00,   2.75,   9.0,  0.0),
  (:pipe,         :steel,    30.00,   2.75,   7.0,  0.0),
  (:stabilizer,   :steel,     0.00,   2.75,   9.0,  0.0),
  (:pipe,         :steel,    90.00,   2.75,   7.0,  0.0),
  (:stabilizer,   :steel,     0.00,   2.75,   9.0,  0.0),
  (:pipe,         :steel,   100.00,   2.75,   7.0,  0.0)
]

traj = [
#   Heading,      Diameter
  ( 60.0,      9.0)
]

wobs = 20:10:40
incls = 20:10:40               # Or e.g. incls = [5 10 20 30 40 45 50]

properties, nodes, elements = input!(bha)

@test bha[:materials][:monel].sg == 0.319
@test bha[:noofelements] == 265
@test size(elements) == (265, )

bha[:segments] |> display
println("\n")

bha[:properties] |> display
println("\n")

bha[:nodes] |> display
println("\n")

bha[:elements] |> display
println("\n")

pfem = problem(bha, traj, wobs, incls, pdir=ProjDir)

#=
Needs to generate something like:

data = Dict(
  # Frame(nels, nn, ndim, nst, nip, finite_element(nod, nodof))
  :struc_el => Frame(10, 11, 2, 1, 1, Line(2, 3)),
  :properties => [
    1.07207e9 4.53116e9;],
  :x_coords =>0.0:1.0:10.0,
  :y_coords => [0.0 for i in 1:11],
  :g_num => [
    1 2 3 4 5 6 7 8 9 10;
    2 3 4 5 6 7 8 9 10 11],
  :support => [
    (1, [1 0 1]),
    (5, [1 0 1]),
    (11, [0, 1, 1])
    ],
  :loaded_nodes => [
    (1, [10000.0 -600.0 -600.0]),
    (2, [0.0 -600.0 0.0]),
    (3, [0.0 -600.0 0.0]),
...
    (10, [0.0 -600.0 0.0]),
    (11, [0.0 -600.0 -600.0])
    ],
  :penalty => 1e19,
  :eq_nodal_forces_and_moments => [
    (1, [0.0 -60.0 -60.0 0.0 -60.0 60.0]),
    (2, [0.0 -120.0 -140.0 0.0 -120.0 140.0]),
    (3, [0.0 -20.0 -6.67 0.0 -20.0 6.67])
  ]
)
  =#
