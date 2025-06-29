-- scans cached plots & fires the harvest remote concurrently
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local harvestEvent      = ReplicatedStorage:WaitForChild("ByteNetReliable")
local PlotCache         = require(script:WaitForChild("PlotCache"))

local Harvester = {}

function Harvester.harvest()
    for _, plot in ipairs(PlotCache.getPlots()) do
        local crop = plot:FindFirstChild("Crop")
        if crop
        and crop:FindFirstChild("Growth")
        and crop:FindFirstChild("Maturity")
        and crop:FindFirstChild("HarvestPrompt")
        and crop.Growth.Value >= crop.Maturity.Value then

            spawn(function()
                local success, err = pcall(function()
                    harvestEvent:FireServer(crop.HarvestPrompt)
                end)
                if not success then
                    warn("AutoHarvest error on", plot, err)
                end
            end)
        end
    end
end

return Harvester
