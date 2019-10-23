"""

## Theoretical performance of a BHA

Function to compute the theoretical performance of a Bottom Hole Assembly (BHA)
in terms of building or dropping rate.

### Function
```julia
theoretical_performance!(data::Dict{Symbol, Any})

or

tp!(data::Dict{Symbol, Any})

```
### Arguments
```julia
* `data`      : Dictionary with input (and updated) data. 
```
### Results
```julia
* `params`    : Object with all computational results.
```
"""
function tp!(data::Dict{Symbol, Any})
  if !(:wobrange in keys(data))
    println("Please specify a WOB range, e.g. :wobrange = 5:10:25.")
    data[:terminated] = true
    return
  end
  if !(:inclrange in keys(data))
    println("Please specify an inclination range, e.g. inclrange = 20:5:50.")
    data[:terminated] = true
    return
  end
  
  if :wob in keys(data)
    if typeof(data[:wobrange]) == StepRange{Int64, Int64}
      data[:wob] = float(data[:wobrange].start)
    else
      data[:wob] = float(data[:wobrange][1])
    end
  else
    if typeof(data[:wobrange]) == StepRange{Int64, Int64}
      push!(data, :wob =>  float(data[:wobrange].start))
    else
      push!(data, :wob =>  float(data[:wobrange][1]))
    end
  end
    
  if :inclination in keys(data[:welltrajectory])
    if typeof(data[:inclrange]) == StepRange{Int64, Int64}
      data[:welltrajectory][:inclination] = float(data[:inclrange].start)
    else
      data[:welltrajectory][:inclination] = float(data[:inclrange][1])
    end
  else
    if typeof(data[:inclrange]) == StepRange{Int64, Int64}
      push!(data[:welltrajectory], :inclination => float(data[:inclrange].start))
    else
      push!(data[:welltrajectory], :inclination => float(data[:inclrange][1]))
    end
  end
  push!(data[:welltrajectory], :dalpha => 0.0)
  
  checktrajectoryinput!(data)
  if :terminated in keys(data)
    return
  end
	println("Trajectory input data checks completed!")
  
  checkinput!(data)
  if :terminated in keys(data)
    return
  end
	println("BHA input data checks completed!\n")
  
  wobrange = data[:wobrange]
  inclrange = data[:inclrange]
  heading = data[:welltrajectory][:heading]
  holediameter = data[:welltrajectory][:diameter]
  
  if length(wobrange) > 0 && length(inclrange) > 0 && !isdefined(data, :welltrajectory)
    indxtab = Array{Tuple}(undef, length(wobrange)*length(inclrange))
    for (i, wob) in enumerate(wobrange)
      for (j, incl) in enumerate(inclrange)
        #wobstring = string(Int(wob/klbf))
        #inclstring = string(Int(incl/°))
        wobstring = string(Int(wob))
        inclstring = string(Int(incl))
        cd(data[:pdir]) do
          if isdir("tp0/$wobstring/$inclstring")
            rm("tp0/$wobstring/$inclstring", recursive=true)
          end
          (!isdir("tp0")) && mkdir("tp0")
          (!isdir("tp0/$wobstring")) && mkdir("tp0/$wobstring")
          (!isdir("tp0/$wobstring/$inclstring")) && mkdir("tp0/$wobstring/$inclstring")
          if isdir("tp/$wobstring/$inclstring")
            rm("tp/$wobstring/$inclstring", recursive=true)
          end
          (!isdir("tp")) && mkdir("tp")
          (!isdir("tp/$wobstring")) && mkdir("tp/$wobstring")
          (!isdir("tp/$wobstring/$inclstring")) && mkdir("tp/$wobstring/$inclstring")
          indxtab[(i - 1) * length(inclrange) + j] = 
            (data, wob, incl, holediameter, heading)
        end
      end
    end
    pmap(tprun, indxtab)
    println()
  end
end
