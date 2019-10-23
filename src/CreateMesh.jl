function createmesh!(data::Dict{Symbol, Any}, params::Parameters)
  el = 0
  seg = data[:segments]
  sgmedium = data[:media][data[:medium]] / 231.     # in [in^3]
  for i in 1:length(seg)
    mat = data[:materials][seg[i].material]
    radius = seg[i].od / 2.0
    dm2 = seg[i].od^2 - seg[i].id^2
    dm4 = seg[i].od^4 - seg[i].id^4
    dp2 = seg[i].od^2 + seg[i].id^2
    if typeof(seg[i]) in [Bit, Stabilizer, Bentsub, Rig]
      if (el+1) < data[:noofelements] && radius > params.nodes[el+1].stringradius
        params.nodes[el+1].fc = seg[i].fc
        params.nodes[el+1].stringradius = radius
      end
    else
      nels = floor(Int64, 1.0+data[:ratio]*data[:segments][i].length/data[:segments][i].od)
      dl = seg[i].length
      elength = 12.0 * dl / nels

      # Cross sectional area: csa = pi * d^2 / 4
      csa = pi * dm2 / 4.0
      sgstring = mat[:sg]
      eweight = elength * csa * (sgstring - sgmedium)
      
      # See http://en.wikipedia.org/wiki/Area_moment_of_inertia
      # Area moment of inertia: Pi * r^4 / 4 or Pi * d^4 / 64

      # See http://en.wikipedia.org/wiki/Polar_moment_of_inertia
      # Polar moment of inertia: Pi * r^4 / 2 or Pi * d^4 / 32
      
      ea = csa * mat[:ez]
      er = pi * mat[:er] * dm4 / 64
      gj = pi * mat[:g] * dm4 / 32

      # g is in [m / sec^2], 32.2 [ft/sec^2] or 386.4 [in/sec^2]
      # In US-units the assumption is that sgstring & sgmedium are forces [lbf],
      # not [lbm].

      #println([nels, elength, sgstring, sgmedium, eweight, ea, eiz, eir, gj])

      emass = elength * csa * sgstring
      mmass = elength * pi * seg[i].id^2 * sgmedium / 4.0

      # See Wikipedia, list of moments of inertia:
      #       http://en.wikipedia.org/wiki/List_of_moments_of_inertia
      # Iz = elementaxialmoment = elementmass * (od^2 + id^2) / 8
      # Ix = Iy = (1 / 12) * emass * ( 3 * (od^2 + id^2) / 4 + elength^2)
      #         = emass * elength^2 / 12 + elementaxialmoment / 2

      einertialmass = emass + mmass
      eaxialmoment = emass * dp2 / 8.0
      eradialmoment = emass * elength^2 / 12.0 + eaxialmoment / 2.0
      
      for j in 1:nels
      	el += 1
	
      	# params.nodes[1] is usually the bit or a 1st support for deflection testing
      	# params.nodes[1] = 0.0, add length of element.

        params.nodes[el+1].z = params.nodes[el].z + elength
        if typeof(seg[i]) in [Pipe, Collar]
          params.elements[el].ea = ea
          params.elements[el].er = er
          params.elements[el].gj = gj
        else
          # Adjust these values for Stabilizers. :od is not the whole story.
          params.elements[el].ea = 0.58 * ea
          params.elements[el].er = 0.68 * er
          params.elements[el].gj = 0.36 * gj
        end
		
				# Use largest stringRadius if 2 elements differ.
		
        if radius > params.nodes[el].stringradius
          params.nodes[el].fc = seg[i].fc
        end
				params.nodes[el].stringradius = max(radius, params.nodes[el].stringradius)
				params.nodes[el+1].fc = seg[i].fc
				params.nodes[el+1].stringradius = radius
		
				# Pattern always the same, asign 0.5 to this node and 0.5 to next node,
				# during next loop add 0.5 of next element.
		
				params.nodes[el].weight += eweight / 2.0
				params.nodes[el+1].weight = eweight / 2.0
				params.nodes[el].mass += emass / 2.0
				params.nodes[el+1].mass = emass / 2.0
				params.nodes[el].massinertia += einertialmass / 2.0
				params.nodes[el+1].massinertia = einertialmass / 2.0
				params.nodes[el].axialinertia += eaxialmoment / 2.0
				params.nodes[el+1].axialinertia = eaxialmoment / 2.0
				params.nodes[el].radialinertia += eradialmoment / 2.0
				params.nodes[el+1].radialinertia = eradialmoment / 2.0
		
				# Set element data if it is not a "(Exc)Stab(ilizer)" or "NBS" or "Bit" or "Rig"

				if typeof(seg[i]) in [Pipe, Collar]
					params.elements[el].fc = seg[i].fc
					params.elements[el].length = elength
					params.elements[el].radius = radius
					params.elements[el].od = seg[i].od
					params.elements[el].id = seg[i].id
					params.elements[el].mass = emass
				end
      end
    end
  end
  typeof(params.nodes)
end