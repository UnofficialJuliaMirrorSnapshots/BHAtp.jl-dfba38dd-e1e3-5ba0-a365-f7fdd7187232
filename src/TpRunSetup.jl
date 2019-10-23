function tprun(t::Tuple)
  data = t[1]
  ProjDir = data[:pdir]
  wob = t[2]
  incl = t[3]
  holediameter = t[4]
  heading = t[5]
  dalpha = 0.0

  tptable = Vector{TpRecord}()  
  printvec = [1; 100; 1000; 5000:5000:data[:maxiters]]
  
  local fstream
  cd(joinpath(ProjDir, "tp", "$(string(Int(wob)))", "$(string(Int(incl)))")) do
    fstream = open("tp.log", "w")
  end
  ptup = (printvec, fstream)
  
  write(fstream, "$(ProjDir)\n")
  write(fstream, "WOB: $(wob), Incl: $(incl)\n")
  write(fstream, "Dalpha: $(data[:welltrajectory][:dalpha])\n")
  
  data[:welltrajectory][:dalpha] = 0.0
  data[:wob] = wob * 1000.
  data[:welltrajectory][:inclination] = incl
  survey_df = trajectory2df(data)
	params = Parameters(data)
  createmesh!(data, params)
  interpolate!(survey_df, params)
  
  #println(elements2df(params.elements))

  local tpstring
  count = 1
  while true && count < 10
    dalphainit!(data[:welltrajectory][:dalpha], params)
    xyinit!(data, params)
    createstiffnessmatrices!(params)
    finalinit!(params)
    fem!(params, ptup)
    df = sol2df(params)
    if data[:welltrajectory][:dalpha] == 0.0
      cd(joinpath(ProjDir, "tp0", "$(string(Int(wob)))", "$(string(Int(incl)))")) do
        CSV.write("solution.csv", df)
      end
    end
    ft, f_ft = findfirsttouch(df)
    tprec = TpRecord(data[:welltrajectory][:dalpha], data[:wob], 
      data[:welltrajectory][:inclination], df[1, :fx], ft, f_ft, df)
    push!(tptable, tprec)
    if abs(df[1, :fx]) < 1.0
      break
    else
      data[:welltrajectory][:dalpha] = nexttprun(tptable) 
      count += 1
    end
    write(fstream, "\nWOB: $(data[:wob]), Incl: $(data[:welltrajectory][:inclination])\n")
    write(fstream, "Force on bit: $(df[1, :fx])\n")
    write(fstream, "New dalpha: $(data[:welltrajectory][:dalpha])\n")
  end
  cd(joinpath(ProjDir, "tp", "$(string(Int(wob)))", "$(string(Int(incl)))")) do
    #tpdf = tp2df(tptable)
    CSV.write("solution.csv", sol2df(params))
    CSV.write("tp.csv", tp2df(tptable))
  end
  close(fstream)
  println("Completed $wob and $incl.")
end

function nexttprun(tptab)
  cnt = length(tptab)
  if tptab[cnt].dalpha == 0.0
    dalpha = tptab[1].fbit > 10.0 ? 0.5 : -0.5
  else
    dfbit = tptab[cnt].fbit - tptab[cnt-1].fbit
    dalpha = (tptab[cnt].fbit*tptab[cnt-1].dalpha-tptab[cnt-1].fbit*tptab[cnt].dalpha)/dfbit
  end
  dalpha
end

function findfirsttouch(df::DataFrame)
  nrows = size(df, 1)
  ft = df[!, :dtb][nrows]
  f_ft = df[!, :fx][nrows]
  for i in 2:nrows
    if abs(df[!, :fx][i]) > 0.0
      ft = df[!, :dtb][i]
      f_ft = df[!, :fx][i]
      break
    end
  end
  (ft, f_ft)
end

function trajectory2df(data::Dict{Symbol, Any})
  df = BHAtp.segments2df(data)
  DataFrame(
    survey_type = [BHAtp.HoleSurvey, BHAtp.BitSurvey],
    depth=[0.0, sum(df[:, :length])], 
    inclination = data[:welltrajectory][:inclination]*ones(2),
    heading = data[:welltrajectory][:heading]*ones(2),
    diameter = data[:welltrajectory][:diameter]*ones(2)
  )
end

