-- debug ping
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local dbgGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
dbgGui.Name = "AHDebug"
local dbgLbl = Instance.new("TextLabel", dbgGui)
dbgLbl.Size = UDim2.new(0, 200, 0, 50)
dbgLbl.Position = UDim2.new(0, 10, 0, 10)
dbgLbl.Text = "AutoHarvest.lua OK"
dbgLbl.BackgroundTransparency = 0.5
task.delay(2, function() dbgGui:Destroy() end)

-- config
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = workspace
local Config = { AutoHarvest = false, HarvestInterval = 0.1, Running = true }

-- plot cache
local plots = {}
local function addPlot(p)
    if p and not table.find(plots, p) then table.insert(plots, p) end
end
local function removePlot(p)
    for i, v in ipairs(plots) do
        if v == p then table.remove(plots, i) break end
    end
end
local plotFolder = workspace:WaitForChild("Plots")
for _, p in ipairs(plotFolder:GetChildren()) do addPlot(p) end
plotFolder.ChildAdded:Connect(addPlot)
plotFolder.ChildRemoved:Connect(removePlot)

-- harvester
local harvestEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")
local function harvestAll()
    for _, pl in ipairs(plots) do
        local c = pl:FindFirstChild("Crop")
        if c and c:FindFirstChild("Growth") and c:FindFirstChild("Maturity")
           and c:FindFirstChild("HarvestPrompt") and c.Growth.Value >= c.Maturity.Value then
            spawn(function()
                pcall(function() harvestEvent:FireServer(c.HarvestPrompt) end)
            end)
        end
    end
end

-- GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "AutoHarvestGUI"

local btnToggle = Instance.new("TextButton", gui)
btnToggle.Size = UDim2.new(0, 150, 0, 40)
btnToggle.Position = UDim2.new(0, 10, 0, 10)
btnToggle.Text = "AutoHarvest: Off"
btnToggle.BackgroundTransparency = 0.3
btnToggle.MouseButton1Click:Connect(function()
    Config.AutoHarvest = not Config.AutoHarvest
    btnToggle.Text = "AutoHarvest: " .. (Config.AutoHarvest and "On" or "Off")
end)

local btnExit = Instance.new("TextButton", gui)
btnExit.Size = UDim2.new(0, 80, 0, 30)
btnExit.Position = UDim2.new(0, 10, 0, 60)
btnExit.Text = "Exit"
btnExit.BackgroundTransparency = 0.3
btnExit.MouseButton1Click:Connect(function()
    Config.Running = false
    Config.AutoHarvest = false
    gui:Destroy()
end)

-- main loop
spawn(function()
    while Config.Running do
        if Config.AutoHarvest then harvestAll() end
        task.wait(Config.HarvestInterval)
    end
end)
