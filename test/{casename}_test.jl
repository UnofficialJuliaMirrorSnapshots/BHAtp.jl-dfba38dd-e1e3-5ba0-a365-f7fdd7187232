using BHAtp

ProjDir = @__DIR__

isdir(joinpath(ProjDir, "tp0")) && rm(joinpath(ProjDir, "tp0"), recursive=true)
isdir(joinpath(ProjDir, "tp")) && rm(joinpath(ProjDir, "tp"), recursive=true)
isdir(joinpath(ProjDir, "plots")) && rm(joinpath(ProjDir, "plots"), recursive=true)

ProjName = split(ProjDir, "/")[end]
bhaj = BHAJ(ProjName, ProjDir)
bhaj.ratio = 1.7

segs = [
# Element type,  Material,    Length,     OD,         ID,      fc
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
incls = 20:10:40             # Or e.g. incls = [5 10 20 30 40 45 50]

@time bhaj(segs, traj, wobs, incls)
println()

display("Fetch tp=0, wob=40, incl@bit=20 solution:")
df,df_tp = show_solution(ProjDir, 40, 20, show=false, tp=false)
df[:,[2; 5:6; 9:12]] |> display
println()

println("Fetch wob=40, incl@bit=20 solution:")
df,df_tp = show_solution(ProjDir, 40, 20, show=false);
df[:,[2; 5:6; 9:12]] |> display
println()

show_tp(ProjDir, wobs, incls) |> display
