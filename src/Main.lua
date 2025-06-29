local Config      = require(script:WaitForChild("Config"))
local PlotCache   = require(script:WaitForChild("PlotCache"))
local Harvester   = require(script:WaitForChild("Harvester"))
local GUI         = require(script:WaitForChild("GUI"))

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
            Harvester.harvest()
        end
        task.wait(Config.HarvestInterval)
    end
end)
