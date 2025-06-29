local PlotCache = {}
local plots = {}

function PlotCache.addPlot(plot)
    if plot and not table.find(plots, plot) then
        table.insert(plots, plot)
    end
end

function PlotCache.removePlot(plot)
    for i, p in ipairs(plots) do
        if p == plot then
            table.remove(plots, i)
            break
        end
    end
end

function PlotCache.init()
    local folder = workspace:WaitForChild("Plots")
    for _, p in ipairs(folder:GetChildren()) do
        PlotCache.addPlot(p)
    end
    folder.ChildAdded:Connect(PlotCache.addPlot)
    folder.ChildRemoved:Connect(PlotCache.removePlot)
end

function PlotCache.getPlots()
    return plots
end

return PlotCache