function createmediatable!(data::Dict{Symbol, Any})
  push!(data, :media=>Dict{Symbol, Float64}())
  push!(data[:media], :mud=>11.35)
  push!(data[:media], :water=>8.339)
  push!(data[:media], :air=>0.0)
  push!(data[:media], :heavymud=>12.0)
  push!(data[:media], :lightmud=>10.0)
end
