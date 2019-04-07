function createmesh!(bhadata::Dict{Symbol, Any})
  
  seg = bhadata[:segs]
  bhadata[:materials] = materials
    # Future: Use updatematerialtable() to add or change an entry in the materials table
  bhadata[:media] = media
  # Future: Use updatemediatable() to add or change an entry in the media table
  bhadata[:medium] = :mud
  bhadata[:noofelements] = Int(sum([bha[:segs][i][3] for i in 1:length(bha[:segs])]))
  bhadata[:noofnodes] = bha[:noofelements] + 1

  elements = [BHAtp.Element() for i in 1:bhadata[:noofelements]]
  nodes = [BHAtp.Node() for i in 1:bhadata[:noofnodes]]
  properties = fill(0.0, length(seg), 3)

  el = 0                                            # Element index
  propertiesindex = 0                      # Row in properties matrix
  
  sgmedium = bhadata[:media][bhadata[:medium]] / 231.     # in [in^3]
  
  for i in 1:length(seg)
    mat = bhadata[:materials][seg[i][2]]
    radius = seg[i][5] / 2.0
    if seg[i][1] in [:bit, :stabilizer]
      if (el+1) < bhadata[:noofelements] && radius > nodes[el+1].bharadius
        nodes[el+1].fc = seg[i][6]
        nodes[el+1].bharadius = radius
      end
    else
      propertiesindex += 1
      nels = Int(seg[i][3])       # Divide bha in 1' elements
      elength = 12.0      # [in]

      # Cross sectional area: csa = pi * d^2 / 4
      
      csa = pi * (seg[i][5]^2 - seg[i][4]^2) / 4.0
      eweight = elength * csa * ( mat.sg - sgmedium)
      
      # See http://en.wikipedia.org/wiki/Area_moment_of_inertia
      # Area moment of inertia: Pi * r^4 / 4 or Pi * d^4 / 64

      # See http://en.wikipedia.org/wiki/Polar_moment_of_inertia
      # Polar moment of inertia: Pi * r^4 / 2 or Pi * d^4 / 32
      
      d4 = seg[i][5]^4 - seg[i][4]^4
      
      # properties = [1:nels ; ea er gj]
      properties[propertiesindex,:] = [csa * mat.ea pi * mat.er * d4 / 64 pi * mat.gj * d4 / 32]

      for j in 1:nels
      	el += 1
        
        # Set nodes data
	
		# Use largest bharadius if 2 elements differ. Could also have been influenced by stabilizers above.
		
		nodes[el].bharadius = max(radius, nodes[el].bharadius)
    
        # Preset value for next element
        
		nodes[el+1].fc = seg[i][6]
		nodes[el+1].bharadius = radius

		# Pattern always the same, asign 1/2 to this node and 1/2 to next node,
		# during next loop add 1/2 of next element.

		nodes[el].weight += eweight / 2.0
		nodes[el+1].weight = eweight / 2.0

		# Set elements data

		elements[el].length = elength
		elements[el].id = seg[i][4]
		elements[el].od = seg[i][5]
        elements[el].npind = propertiesindex
        
      end
    end
  end
  
  properties = properties[1:propertiesindex, :]
  bha[:properties] = properties
  bha[:elements] = elements
  bha[:nodes] = nodes
  
  (properties, nodes, elements)
end