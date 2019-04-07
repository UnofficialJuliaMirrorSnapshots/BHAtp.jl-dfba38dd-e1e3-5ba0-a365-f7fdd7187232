using BHAtp
using Test

ProjDir = joinpath(dirname(@__FILE__), "..", "examples", "fisherpaper")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);
    
  include(joinpath(ProjDir, "a1/fisher_01.jl"))
  
  @test round(results[1][2][11, 2], digits =6) == -0.003333

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
