local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace         = workspace

local Config = {
    AutoHarvest     = false,  -- starts off
    HarvestInterval = 0.1,    -- seconds between cycles
    Running         = true,   -- set false to stop all loops
}

local plots = {}
local function addPlot(plot)
    if plot and not table.find(plots, plot) then
        table.insert(plots, plot)
    end
end
local function removePlot(plot)
    for i, p in ipairs(plots) do
        if p == plot then
            table.remove(plots, i)
            break
        end
    end
end

local plotFolder = workspace:WaitForChild("Plots")
for _, p in ipairs(plotFolder:GetChildren()) do
    addPlot(p)
end
plotFolder.ChildAdded:Connect(addPlot)
plotFolder.ChildRemoved:Connect(removePlot)

local harvestEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")
local function harvest()
    for _, plot in ipairs(plots) do
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
                    warn("AutoHarvest error:", err)
                end
            end)
        end
    end
end

local lp  = Players.LocalPlayer or Players.PlayerAdded:Wait()
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "AutoHarvest_GUI"

local btnToggle = Instance.new("TextButton", gui)
btnToggle.Size = UDim2.new(0,150,0,40)
btnToggle.Position = UDim2.new(0,10,0,10)
btnToggle.Text = "AutoHarvest: Off"
btnToggle.BackgroundTransparency = 0.3

btnToggle.MouseButton1Click:Connect(function()
    Config.AutoHarvest = not Config.AutoHarvest
    btnToggle.Text = "AutoHarvest: " .. (Config.AutoHarvest and "On" or "Off")
end)

local btnExit = Instance.new("TextButton", gui)
btnExit.Size = UDim2.new(0,80,0,30)
btnExit.Position = UDim2.new(0,10,0,60)
btnExit.Text = "Exit"
btnExit.BackgroundTransparency = 0.3

btnExit.MouseButton1Click:Connect(function()
    Config.Running = false
    Config.AutoHarvest = false
    gui:Destroy()
end)

spawn(function()
    while Config.Running do
        if Config.AutoHarvest then
            harvest()
        end
        task.wait(Config.HarvestInterval)
    end
end)
