function create_final_tp_df(pdir, wobs, incls; ofu=true)
  df = DataFrame()
  for wob in wobs
    for incl in incls
      filepath = joinpath(pdir, "tp", string(Int(wob)),
        string(Int(incl)), "tp.csv")
      tp_df = DataFrame(CSV.read(filepath))
      if size(df, 1) == 0
        df = DataFrame(tp_df[end, :])
      else
        append!(df, DataFrame(tp_df[end, :]))
      end
    end
  end
  df
end

function show_tp(pdir, wobs, incls; ofu=false)
  println()
  df = DataFrame()
  tp_df = DataFrame()
  for wob in wobs
    for incl in incls
      wobstring = string(Int(wob))
      inclstring = string(Int(incl))
      filepath = joinpath(pdir, "tp", wobstring, inclstring, "tp.csv")
      if ofu
        #tp_df = convert_tp_to_ofu_df(filepath)
      else
        tp_df = DataFrame(CSV.read(filepath))
      end
      if size(df, 1) == 0
        df = tp_df
      else
        append!(df, tp_df)
      end
    end
  end
  df
end

function show_solution(pdir, wobs, incls; tp=true, show=true)
  df = DataFrame()
  tp_df = DataFrame()
  for wob in wobs
    for incl in incls
      wobstring = string(Int(wob))
      inclstring = string(Int(incl))
      assembly = tp ? "tp" : "tp0"
      solpath = joinpath(pdir, assembly, wobstring, inclstring, "solution.csv")
      tppath = joinpath(pdir, assembly, wobstring, inclstring, assembly*".csv")
      tp && (tp_df = CSV.read(tppath))
      df = CSV.read(solpath)
      if show
        println("\n=====================================================")
        println("      $(assembly) (wob=$wobstring, incl=$inclstring)")
        println("=====================================================")
        println()
        size(tp_df, 1) > 0 && tp_df |> display
        size(tp_df, 1) > 0 && println()
        df |> display
        println()
      end 
    end
  end
  (df, tp_df)
end

function show_solution(pdir, wob::Int, incl::Int; tp=true, show=true)
  df = DataFrame()
  tp_df = DataFrame()
  wobstring = string(wob)
  inclstring = string(incl)
  assembly = tp ? "tp" : "tp0"
  solpath = joinpath(pdir, assembly, wobstring, inclstring, "solution.csv")
  tppath = joinpath(pdir, assembly, wobstring, inclstring, assembly*".csv")
  #tp && (tp_df = convert_tp_to_ofu_df(tppath))
  #(df = convert_to_ofu_df(solpath, wobstring, inclstring))
  tp && (tp_df = CSV.read(tppath))
  df = CSV.read(solpath)
  if show
    println("\n=====================================================")
    println("      $(assembly) (wob=$wobstring, incl=$inclstring)")
    println("=====================================================")
    println()
    size(tp_df, 1) > 0 && tp_df |> display
    size(tp_df, 1) > 0 && println()
    df |> display
    println()
  end 
  (df, tp_df)
end
