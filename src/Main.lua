return function(Config, PlotCache, Harvester, GUI)
    PlotCache.init()

    GUI.create(
        function(isEnabled)
            Config.AutoHarvest = isEnabled
        end,
        function()
            Config.AutoHarvest = false
            Config.Running = false
        end
    )

    spawn(function()
        while Config.Running do
            if Config.AutoHarvest then
                Harvester.harvest(PlotCache)
            end
            task.wait(Config.HarvestInterval)
        end
    end)
end