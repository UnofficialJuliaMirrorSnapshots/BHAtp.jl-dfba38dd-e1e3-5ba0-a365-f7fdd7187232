function createcasetable(elementdf, wobrange, inclinationrange, computefunction, pdir)
  
  # The casetable contains a case for every requested wob and inclination
  
  casetable = Array{Tuple}(undef, length(wobrange) * length(inclinationrange))
  for (i, wob) in enumerate(wobrange)
    for (j, incl) in enumerate(inclinationrange)

      # Set up directory structure to store results
      
      wobstring = string(Int(wob))
      inclstring = string(Int(incl))
      cd(pdir) do
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
      end
      
      # And create the casetable to be used by pmap()
      
      casetable[ (i-1) * length(inclinationrange) + j ] = (elementdf, wob, incl, computefunction, pdir)
      
    end
  end
  
  casetable
end

