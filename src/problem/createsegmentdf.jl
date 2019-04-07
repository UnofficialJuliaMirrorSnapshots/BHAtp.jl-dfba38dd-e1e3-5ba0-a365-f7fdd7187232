function createsegmentdf(segments)
  segment_types = [Symbol, Symbol, Float64, Float64, Float64, Float64]
  segment_names = [:eltype, :material, :length, :id, :od, :frictioncoefficient]
  #segs = reshape(segments, (length(segment_types), :))

  segmentdf = DataFrame(segment_types, segment_names, 0)
  for i in 1:size(segments, 1)
    seg = segments[i]
      append!(segmentdf,
        DataFrame(eltype=seg[1], material=seg[2], length=seg[3], id=seg[4], od=seg[5],
          frictioncoefficient=seg[6])
      )
  end
  
  segmentdf
  
end