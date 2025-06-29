local ReplicatedStorage = game:GetService("ReplicatedStorage")
local harvestEvent      = ReplicatedStorage:WaitForChild("ByteNetReliable")

local Harvester = {}

function Harvester.harvest(PlotCache)
    for _, plot in ipairs(PlotCache.getPlots()) do
        local crop = plot:FindFirstChild("Crop")
        if crop
        and crop:FindFirstChild("Growth")
        and crop:FindFirstChild("Maturity")
        and crop:FindFirstChild("HarvestPrompt")
        and crop.Growth.Value >= crop.Maturity.Value then

            spawn(function()
                local ok, err = pcall(function()
                    harvestEvent:FireServer(crop.HarvestPrompt)
                end)
                if not ok then
                    warn("AutoHarvest error on", plot, err)
                end
            end)
        end
    end
end

return Harvester
