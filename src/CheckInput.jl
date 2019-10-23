"""
`checkinput!(data)`: Check and/or initialize all fields in data dictionary.

where:  `data`::Dict{Symbol, Any}

"""
function checkinput!(data::Dict{Symbol, Any})
  #
  # Check and/or set all input datafields that do not depend on the unitsystem
  # for the checks on the provided values.
  #
  if !(:isotropic in keys(data))
    #
    # Might be updated when :newmaterials are added containing an :er
    # in addition to an :ez value. In that case the material is
    # anisotropic and :er is the 'radial' Young modulus for pipes
    # (used for both :ezx and :ezy in the stiffness matrix).
    #
    # The :isotropic setting will only be updated if an anisotropic material
    # is actually used in the definitions for the segments.
    #
    # Note that either a single :ez value needs to be specified or 2 values (:er and :ez).
    #
    push!(data, :isotropic => true)
  end
	
  if :ratio in keys(data)
    checkratio!(data)
  else
    push!(data, :ratio => 0.6)
  end
	
  if :maxiters in keys(data)
    checkmaxiters!(data)
  else
    push!(data, :maxiters => 1000)
  end
	
  if !(:dlerrormax in keys(data))
    push!(data, :dlerrormax => 1e-6)
  end
	
  if !(:drerrormax in keys(data))
    push!(data, :drerrormax => 1e-6)
  end
	
  if !(:maxiters in keys(data))
    push!(data, :maxiters => 1000)
  end
	
  if !(:media in keys(data))
    createmediatable!(data)
  end
	
  if !(:materials in keys(data))
    creatematerialstable!(data)
  end
	
  if :newmedia in keys(data)
    updatemediatable!(data)
  end
	
  if :newmaterials in keys(data)
    updatematerialstable!(data)
  end
	
  if !(:segments in keys(data))
    println("No segments defined! Exiting.")
    data[:terminated => true]
    return
  else
    checksegmenttable!(data)
  end
  
  if :medium in keys(data)
    checkmedium!(data)
  else
    println(":medium not defined. Set to :mud.")
    push!(data, :medium => :mud)
  end

  if !(:surveys in keys(data))
    if !(:welltrajectory in keys(data))
      println("Neither surveys or trajectory data defined!")
      data[:terminated => true]
      return
    end
  else
    checksurveytable!(data)
  end
	
  if !(:wob in keys(data))
    println("No wob defined! Set to 0.0")
    push!(data, :wob => 0.0)
  else
    data[:wob] *= 1000.0
  end
	
  if :use_geometric_correction in keys(data)
    checkgeometriccorrectionsettings!(data)
  else
    push!(data, :use_geometric_correction => false)
  end
	
  if :usetortuosity in keys(data)
    checktortuositysettings!(data)
  end
	
end


"""
# The checkratio! function
`checkratio!(data)`: Check and/or set the ratio field in data.

  where:  
  `data`::Dict{Symbol, Any}  
          
"""
function checkratio!(data::Dict{Symbol, Any})
  if data[:ratio] < 0.01 || data[:ratio] > 10.0
    data[:ratio] = 0.6
    println("Setting of :ratio updated to $(data[:ratio])")
  end
end

function checkmaxiters!(data::Dict{Symbol, Any})
  if data[:maxiters] < 1 || data[:maxiters] > Int(1e6)
    data[:maxiters] = 5000
    println("Setting of :maxiters updated to $(data[:maxiters])")
  end
end

function updatemediatable!(data::Dict{Symbol, Any})
  if :newmedia in keys(data)
    if typeof(data[:newmedia]) == Dict{Symbol, Float64}
      merge!(data[:media], data[:newmedia])
      delete!(data, :newmedia)
    end
  end
end


function updatematerialstable!(data::Dict{Symbol, Any})
  if :newmaterials in keys(data)
    if typeof(data[:newmaterials]) == Dict{Symbol,Dict{Symbol,Float64}}
      for key in keys(data[:newmaterials])
        if key in keys(data[:materials])
          merge!(data[:materials][key], data[:newmaterials][key])
        else
          if !(:sg in keys(data[:newmaterials][key]))
            println("No :sg specified for new material $(key)")
            data[:terminated => true]
            return
          end            
          if !(:g in keys(data[:newmaterials][key]))
            println("No :g specified for new material $(key)")
            data[:terminated => true]
            return            
          end
          if !(:ez in keys(data[:newmaterials][key]))
            println("No :ez specified for new material $(key)")
            data[:terminated => true]
            return            
          end
          if !(:er in keys(data[:newmaterials][key]))
            println("No :er specified for new material $(key). Assumed isotropic material.")
            data[:newmaterials][key][:er] = data[:newmaterials][key][:ez]
          end
          push!(data[:materials], key => data[:newmaterials][key])
        end
      end
      delete!(data, :newmaterials)
    end
  end
end

function checksegmenttable!(data::Dict{Symbol, Any})
  println("Checking $(length(data[:segments])) segments")
  if !(:holedepth in keys(data))
    push!(data, :holedepth => 0.0)
  end
  push!(data, :noofelements => 0)
  push!(data, :noofsegments => length(data[:segments]))
  if typeof(data[:segments][1]) != BHAtp.Bit
    println("First segment needs to be a Bit segment.")
    data[:terminated => true]
    return
  end
  for i in 1:length(data[:segments])
    if typeof(data[:segments][i]) == BHAtp.Rig
      if i != data[:noofsegments]
        println("Only last segment can be a Rig segment.")
        data[:terminated => true]
        return
      end
    end
    checkforanisotropiccomponent!(data[:segments][i], data)
    if !(data[:segments][i].material in keys(data[:materials]))
      println("Material not defined. Set to :steel")
      data[:segments][i].material = :steel
    end
    if data[:segments][i].id < 0.0
      println("Element id not set properly (< 0.0) for segment $i")
      data[:terminated => true]
      return
    end
    if data[:segments][i].od < 0.0
      println("Element od not set properly (< 0.0) for segment $i")
      data[:terminated => true]
      return
    end
    if data[:segments][i].id >= data[:segments][i].od
      println("Element id >= od for segment $i")
      data[:terminated => true]
      return
    end
    if data[:segments][i].fc < 0.0
      println("Element fc not set properly (< 0.0) for segment $i")
      data[:terminated => true]
      return
    end
    if typeof(data[:segments][i])  in [Pipe, Collar]
      if data[:segments][i].length < 0.0
        println("Length of segment $i < 0.0")
        data[:terminated => true]
        return
      end
      checksegmentrecord!(data[:segments][i], data)
      data[:noofelements] += 
        floor(Int64, 1.0+data[:ratio]*data[:segments][i].length/data[:segments][i].od)
    end
  end
  data[:noofnodes] = data[:noofelements] + 1
end

function checksurveytable!(data::Dict{Symbol, Any})
  println("Checking $(length(data[:surveys])) survey records")
  if !(:surveylength in keys(data))
    if size(data[:surveys], 1) > 0
      push!(data, :surveylength => data[:surveys][size(data[:surveys], 1)].depth)
    else
      push!(data, :surveylength => 0.0)
    end
  end
  for i in 1:length(data[:surveys])
    if !(0.0 <= data[:surveys][i].inclination <= 360.0)
      println("Survey inclination not set properly for survey record $i")
      data[:terminated => true]
      return
    end
    if !(0.0 <= data[:surveys][i].heading <= 360.0)
      println("Survey heading not set properly for survey record $i")
      data[:terminated => true]
      return
    end
    if data[:surveys][i].diameter < 0.0
      println("Survey radius not set properly (< 0.0) for survey record $i")
      data[:terminated => true]
      return
    end
    if typeof(data[:surveys][i]) == HoleSurvey
      if data[:surveys][i].depth < 0.0
        println("Depth of survey record $i < 0.0")
        data[:terminated => true]
        return
      end
      checksurveyrecord!(data[:surveys][i], data)
    end
  end
end

"""
`checktrajectoryinput!(data)`: Check trajectory data in data dictionary.

where:  `data`::Dict{Symbol, Any}

"""
function checktrajectoryinput!(data::Dict{Symbol, Any})
  if :welltrajectory in keys(data)
    welltraj = data[:welltrajectory]
    if !(:inclination in keys(welltraj))
      println("No inclination specified in well trajectory.")
      push!(data, :terminated => true)
      return
    end
    if !(:heading in keys(welltraj))
      println("No heading specified in well trajectory.")
      push!(data, :terminated => true)
      return
    end
    if !(:diameter in keys(welltraj))
      println("No hole diameter specified in well trajectory.")
      push!(data, :terminated => true)
      return
    end
  else
    println("No well trajectory data in input dictionary.")
    push!(data, :terminated => true)
    return
  end
end

function checkforcestable!(data::Dict{Symbol, Any})
  println("Checking $(length(data[:forces])) external force records")
  if !(:surveylength in keys(data))
    if size(data[:surveys], 1) > 0
      push!(data, :surveylength => data[:surveys][size(data[:surveys], 1)].depth)
    else
      push!(data, :surveylength => 0.0)
    end
  end
  for i in 1:length(data[:surveys])
    if !(0.0 <= data[:surveys][i].inclination <= 360.0)
      println("Survey inclination not set properly for survey record $i")
      data[:terminated => true]
      return
    end
    if !(0.0 <= data[:surveys][i].heading <= 360.0)
      println("Survey heading not set properly for survey record $i")
      data[:terminated => true]
      return
    end
    if data[:surveys][i].radius < 0.0
      println("Survey radius not set properly (< 0.0) for survey record $i")
      data[:terminated => true]
      return
    end
    if typeof(data[:surveys][i]) == HoleSurvey
      if data[:surveys][i].depth < 0.0
        println("Depth of survey record $i < 0.0")
        data[:terminated => true]
        return
      end
      #checksurveyrecord!(data[:surveys][i], data)
    end
  end
end

function checksegmentrecord!(rec::Collar, data::Dict{Symbol, Any})
  data[:holedepth] += rec.length
end

function checksegmentrecord!(rec::Pipe, data::Dict{Symbol, Any})
  data[:holedepth] += rec.length
end

function checksurveyrecord!(rec::HoleSurvey, data::Dict{Symbol, Any})
  #data[:surveylength] += rec.depth
end

function checkmedium!(data::Dict{Symbol, Any})
  if !(data[:medium] in keys(data[:media]))
    println("Unknown :medium specified. Set to :mud.")
    data[:medium] = :mud
  end
end

function checkforanisotropiccomponent!(seg::SegmentType, data::Dict{Symbol, Any})
  if :er in keys(data[:materials][seg.material])
    data[:isotropic] = false
  end
end

function checkgeometriccorrectionsettings!(data::Dict{Symbol, Any})
  if data[:use_geometric_correction] 
    println("Geometric correction is being used.")
  end
end

function checktortuositysettings!(data::Dict{Symbol, Any})
  if (:tortuosity in keys(data)) && (:tortuositylength in keys(data))
    println("Tortuosity is injected.")
  else
    data[:usetortuosity] = false
    println("Artificial tortuosity was requested but not properly defined.")
  end
end
