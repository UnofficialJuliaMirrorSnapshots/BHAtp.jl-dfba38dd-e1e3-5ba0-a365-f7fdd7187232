function (bha::BHAJ)(segments, trajectory, wobrange, inclrange)

  traj = update_trajectory(bha::BHAJ, trajectory)
  
  tpdict = Dict{Symbol, Any}(
    :ratio          => bha.ratio,
    :medium         => bha.medium,
    :maxiters       => bha.maxiters,
    :dlerrormax     => bha.dlerrormax,
    :drerrormax     => bha.drerrormax,
    :segments       => update_segments(bha::BHAJ, segments),
    :tprecords      => bha.tprecords,
    :name           => bha.name,     
    :pdir           => bha.pdir,     
    :debuglevel     => bha.debuglevel,
    :wobrange       => update_wobrange(wobrange),
    :inclrange      => update_inclrange(inclrange),
    :welltrajectory => Dict{Symbol, Float64}(
      :heading  => traj.heading,
      :diameter => traj.diameter
    )
  )
  
  tp!(tpdict)
end

function update_wobrange(wobs)
  collect(wobs)
end
  
function update_inclrange(incls)
  collect(incls)
end
  
function update_trajectory(bha::BHAJ, traj)
  Trajectory(Float64(traj[1][1]), Float64(traj[1][2]))
end

function createsurveyrecord(::Type{Val{BHAtp.Bit}}, depth, incl, heading, holediameter)
  return BitSurvey(depth, incl, heading, holediameter)
end

function createsurveyrecord(::Type{Val{BHAtp.Rig}}, depth, incl, heading, holediameter)
  return BitSurvey(depth, incl, heading, holediameter)
end

function createsurveyrecord(depth, incl, heading, holediameter)
  return HoleSurvey(depth, incl, heading, holediameter)
end

function update_surveys(bha::BHAJ, incl::String, heading::Float64, holediameter::Float64)
  # Create survey records based an bha and trajectory data
  # Notice first record is top of string
  surveys = Vector{SurveyType}()
  depth = 0.0
  for i in length(bha.segments):-1:1
    seg = bha.segments[i]
    if typeof(seg) != BHAtp.Stabilizer
      if typeof(seg) in [BHAtp.Bit, BHAtp.Rig]
        push!(surveys, createsurveyrecord(Val{typeof(seg)}, depth, float(incl),
          heading, holediameter))
      else
        push!(surveys, createsurveyrecord(depth, float(incl), heading, holediameter))
      end
      depth += seg.length
    end
  end
  surveys
end
 
function create_segment(::Type{Val{:bit}},
  seg::Tuple{Symbol, Float64, Float64, Float64, Float64})
  Bit(seg...)
end

function create_segment(::Type{Val{:pipe}}, 
  seg::Tuple{Symbol, Float64, Float64, Float64, Float64})
  Pipe(seg...)
end

function create_segment(::Type{Val{:collar}}, 
  seg::Tuple{Symbol, Float64, Float64, Float64, Float64})
  Collar(seg...)
end

function create_segment(::Type{Val{:stabilizer}},
  seg::Tuple{Symbol, Float64, Float64, Float64, Float64})
  Stabilizer(seg...)
end

function update_segments(bha::BHAJ, segs)
  segments = Vector{SegmentType}()
  for i in 1:length(segs)
    
  # e.g. (:bit, :steel, 0.00, 2.75, 9.0, 0.2),
    push!(segments, create_segment(Val{segs[i][1]}, (segs[i][2], 
      segs[i][3], segs[i][4], segs[i][5], segs[i][6])))
      
  end
  segments
end

