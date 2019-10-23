function creatematerialstable!(data::Dict{Symbol, Any})
  push!(data, :materials=>Dict{Symbol, Dict{Symbol, Float64}}())
  #
  # Insert default values for :steel
  #
  merge!(data[:materials], Dict(:steel=>Dict{Symbol, Float64}()))
  push!(data[:materials][:steel], :sg=>0.283)
  push!(data[:materials][:steel], :ez => 29.0e6)
  push!(data[:materials][:steel], :er => 29.0e6)
  push!(data[:materials][:steel], :g=>11.5e6)

  merge!(data[:materials], Dict(:monel=>Dict{Symbol, Float64}()))
  push!(data[:materials][:monel], :sg=>0.319)
  push!(data[:materials][:monel], :ez => 26.0e6)
  push!(data[:materials][:monel], :er => 26.0e6)
  push!(data[:materials][:monel], :g=>9.9e6)

  merge!(data[:materials], Dict(:titanium=>Dict{Symbol, Float64}()))
  push!(data[:materials][:titanium], :sg=>0.164)
  push!(data[:materials][:titanium], :ez => 15.5e6)
  push!(data[:materials][:titanium], :er => 15.5e6)
  push!(data[:materials][:titanium], :g=>5.9e6)

  merge!(data[:materials], Dict(:aluminium=>Dict{Symbol, Float64}()))
  push!(data[:materials][:aluminium], :sg=>0.1)
  push!(data[:materials][:aluminium], :ez => 10.3e6)
  push!(data[:materials][:aluminium], :er => 10.3e6)
  push!(data[:materials][:aluminium], :g=>3.9e6)
end
