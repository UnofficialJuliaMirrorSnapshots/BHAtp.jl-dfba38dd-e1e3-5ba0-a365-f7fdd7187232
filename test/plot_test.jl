using Plots
gr(size=(750,400))
title = plot(title = "Plot title", grid = false, showaxis = false, bottom_margin = -50Plots.px)
p1 = scatter(rand(5, 1), title = "Subplot 1")
p2 = scatter(rand(5, 1), title = "Subplot 2")
plot(title, p1, p2, layout = @layout([A{0.01h}; [B C]]))
