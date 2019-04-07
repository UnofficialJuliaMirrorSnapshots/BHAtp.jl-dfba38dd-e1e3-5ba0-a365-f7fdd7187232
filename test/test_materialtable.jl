using BHAtp
using Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  @test materials[:steel].sg == 0.283
  
end # cd
