using BHAtp, DataFrames, GR

ProjDir = dirname(@__FILE__)
ProjName = split(ProjDir, "/")[end]

#bha = BHA(ProjName, ProjDir)
#bha.ratio = 1.7
#bha.medium = :lightmud

segs2 = [
# Element type,  Material,    Length,     OD,         ID,        fc
  :bit,           :steel ,       0.00,    2.75,      12.25,     0.0,
  :collar ,       :monel ,      25.00,    2.75,       7.75,     0.0,
  :stabilizer,    :steel,        0.00,    2.75,      12.125,    0.0,
  :collar,        :steel,       30.00,    2.75,       7.75,     0.0,
  :stabilizer,    :steel,        0.00,    2.75,      12.125,    0.0,
  :collar,        :steel,       30.00,    2.75,       7.75,     0.0,
  :stabilizer,    :steel,        0.00,    2.75,      12.125,    0.0,
  :collar,        :steel,       90.00,    2.75,       7.75,     0.0,
  :stabilizer,    :steel,        0.00,    2.75,      12.125,    0.0,
  :pipe,          :steel,      100.00,    2.75,       7.75,     0.0
];

segs1 = reshape(segs2, (6, :));
syms = Array{Symbol, 2}(reshape(segs1[1:2, :], (2, :)))
segs = Array{Float64, 2}(reshape(segs1[3:6, :], (4, :)))

df = DataFrame([Symbol, Symbol, Float64], [:eltype, :material, :length], 0)
append!(df, DataFrame(eltype=:bit, material=:steel, length=0.0))

using GR
x = 0:pi/10:2*pi
y1 = sin.(x)
y2 = sin.(x .- 0.25)
y3 = sin.(x .- 0.5)

plot(x,y1,"g",x,y2,"--",x,y2,"g--o",x,y3,"-",x,y3,"c*")
savefig("$(ProjDir)/gr_plot_test.pdf")

df
