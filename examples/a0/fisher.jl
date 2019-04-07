using BHAtp

ProjDir = dirname(@__FILE__)

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
    (4, [0.0 -600.0 0.0]),
    (5, [0.0 -600.0 0.0]),
    (6, [0.0 -600.0 0.0]),
    (7, [0.0 -600.0 0.0]),
    (8, [0.0 -600.0 0.0]),
    (9, [0.0 -600.0 0.0]),
    (10, [0.0 -600.0 0.0]),
    (11, [0.0 -600.0 -600.0])
    ],
  :penalty => 1e19,
  #=
  :eq_nodal_forces_and_moments => [
    (1, [0.0 -60.0 -60.0 0.0 -60.0 60.0]),
    (2, [0.0 -120.0 -140.0 0.0 -120.0 140.0]),
    (3, [0.0 -20.0 -6.67 0.0 -20.0 6.67])
  ]
  =#
)

data |> display
println()

@time fem, dis_df, fm_df = PtFEM.p44(data)
println()

display(dis_df)
println()
display(fm_df)
println()

if VERSION.minor < 6
  using Plots
  gr(size=(400,600))

  p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
  titles = ["p44.1 rotations", "p44.1 y shear force", "p44.1 z moment"]
  moms = vcat(
    convert(Array, fm_df[:, :z1_Moment]),
    convert(Array, fm_df[:, :z2_Moment])[end]
  )
  fors = vcat(
    convert(Array, fm_df[:, :y1_Force]),
    convert(Array, fm_df[:, :y2_Force])[end]
  )
  x_coords = data[:x_coords]

  p[1] = plot(fem.displacements[3,:], ylim=(-0.002, 0.002),
    xlabel="node", ylabel="rotation [radians]", color=:red,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[1], leg=false)
  p[2] = plot(fors, lab="y Shear force", ylim=(-150.0, 250.0),
    xlabel="node", ylabel="shear force [N]", color=:blue,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[2], leg=false)
  p[3] = plot(moms, lab="z Moment", ylim=(-10.0, 150.0),
    xlabel="node", ylabel="z moment [Nm]", color=:green,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[3], leg=false)

  plot(p..., layout=(3, 1))
  savefig(ProjDir*"/fs_A1.png")

end
