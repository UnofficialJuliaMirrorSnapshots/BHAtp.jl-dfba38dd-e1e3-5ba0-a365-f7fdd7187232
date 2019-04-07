function  problem(bha, traj, wobs, incls;
  penalty=1.0e9, computefunction=PtFEM.p44, pdir=ProjDir)
  
  prob = Dict{Symbol, Any}(
    :struc_el => Frame(bha[:noofelements], bha[:noofnodes], 2, 1, 1, Line(2, 3)),
    :properties => bha[:properties],
    :etype => bha[:elements].npind,
    :xcoords => Float64.(0:bha[:noofelements]),
    :ycoords => fill(0.0,bha[:noofnodes]),
    :gnum => [(1:bha[:noofelements])'; (2:bha[:noofnodes])'],
    :support => [bha[:noofnodes], (0, 0, 1)],
    :loaded_nodes => [(1, [10000.0 0.0 0.0])],
    :penalty => penalty,
    #:eq_nodal_forces_and_moments => [],
    :traj => traj,
    :wobrange => wobs,
    :inclinationrange => incls,
    :computefunction => computefunction,
    :pdir => pdir
  )
  
  prob
end

#=
Needs to generate something like:

data = Dict(
  # Frame(nels, nn, ndim, nst, nip, finite_element(nod, nodof))
data = Dict(
  # Frame(nels, nn, ndim, nst, nip, finite_element(nod, nodof))
  :struc_el => Frame(7, 8, 2, 1, 1, Line(2, 3)),
  :properties => [
    1.0e10 1.0e6 20.0;
    1.0e10 1.0e6 50.0;
    1.0e10 1.0e6 80.0
     ],
  :etype => [1, 2, 2, 1, 3, 3, 1],
  :x_coords => [0.0,  0.0, 10.0, 20.0, 20.0, 35.0, 50.0, 50.0],
  :y_coords => [0.0, 15.0, 15.0, 15.0,  0.0, 15.0, 15.0,  0.0],
  :g_num => [
    1 2 3 5 4 6 8;
    2 3 4 4 6 7 7],
  :support => [
    (1, [0 0 0]),
    (5, [0 0 0]),
    (8, [0 0 0])
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
