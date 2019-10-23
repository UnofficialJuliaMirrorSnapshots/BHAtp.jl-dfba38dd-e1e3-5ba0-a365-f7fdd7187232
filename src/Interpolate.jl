function interpolate!(data::Dict{Symbol, Any}, params::Parameters)
  survey_df = surveys2df(data)
  interpolate!(survey_df, params)
end

function interpolate!(survey_df::DataFrame, params::Parameters)
  dtor = params.dtor
  knots = (12.0*survey_df[!, :depth],)
  intp_inclination = interpolate(knots, reverse(dtor*survey_df[!, :inclination]),
    Gridded(Linear()))
  intp_dip = interpolate(knots, reverse(dtor*(90.0 .- survey_df[!, :inclination])),
    Gridded(Linear()))
  intp_heading = interpolate(knots, reverse(dtor*survey_df[!, :heading]),
    Gridded(Linear()))
  intp_holeradius = interpolate(knots, reverse(survey_df[!, :diameter]/2.0), 
    Gridded(Linear()))
  for i in 1:length(params.elements)
    params.elements[i].inclination =
      (intp_inclination(params.nodes[i].z...) + intp_inclination(params.nodes[i+1].z...))/2.0
      params.elements[i].heading =
        (intp_heading(params.nodes[i].z...)+intp_heading(params.nodes[i+1].z...))/2.0
  end
  for i in 1:length(params.nodes)
    params.nodes[i].inclination = intp_inclination(params.nodes[i].z...)
    params.nodes[i].heading = intp_heading(params.nodes[i].z...) 
    params.nodes[i].dip = intp_dip(params.nodes[i].z...)
    params.nodes[i].holeradius = intp_holeradius(params.nodes[i].z...)
  end
end

function surveys2df(data::Dict{Symbol, Any})
  syms = [:survey_type, :depth, :inclination, :heading, :diameter]
  df = DataFrame(Any[DataType[], Float64[], Float64[], Float64[], Float64[]], syms)
  for surv in data[:surveys]
    push!(df, [typeof(surv)  surv.depth surv.inclination surv.heading surv.diameter])
  end
  df
end

