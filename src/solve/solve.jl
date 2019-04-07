 function solve(pfem)
   
   #=
   casetable = createcasetable(elementdf,
      data[:wobrange], data[:inclinationrange],
      data[:computefunction], data[:pdir])
      
   pmap(runcase, casetable)
   =#
   fem, dis_df, fm_df = PtFEM.p44(pfem)
   (fem, dis_df, fm_df)
 end
 