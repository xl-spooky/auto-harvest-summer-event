local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace         = workspace

-- Logs
local logs = {}
local function log(msg)
    logs[#logs+1] = msg
end

log("AutoHarvest initializing")

-- Configuration
local Config = {
    AutoHarvest     = false,
    HarvestInterval = 0.1,
    Running         = true,
}

-- Plot caching
local plots = {}
local function addPlot(p)
    if p and not table.find(plots, p) then
        table.insert(plots, p)
        log("Plot added: "..p.Name)
    end
end
local function removePlot(p)
    for i, v in ipairs(plots) do
        if v == p then
            table.remove(plots, i)
            log("Plot removed: "..p.Name)
            break
        end
    end
end

local plotFolder = workspace:WaitForChild("Plots")
for _, p in ipairs(plotFolder:GetChildren()) do addPlot(p) end
log("Initial plots count: "..#plots)
plotFolder.ChildAdded:Connect(addPlot)
plotFolder.ChildRemoved:Connect(removePlot)

-- Harvest logic
local harvestEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")
local function harvestAll()
    log("Harvest cycle start, plots: "..#plots)
    for _, plot in ipairs(plots) do
        local c = plot:FindFirstChild("Crop")
        if c
        and c:FindFirstChild("Growth")
        and c:FindFirstChild("Maturity")
        and c:FindFirstChild("HarvestPrompt")
        and c.Growth.Value >= c.Maturity.Value then
            spawn(function()
                local ok, err = pcall(function()
                    harvestEvent:FireServer(c.HarvestPrompt)
                end)
                if ok then
                    log("Harvested: "..plot.Name)
                else
                    log("Error harvesting "..plot.Name..": "..tostring(err))
                end
            end)
        end
    end
end

-- GUI
local lp  = Players.LocalPlayer or Players.PlayerAdded:Wait()
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "AutoHarvestGUI"

-- Toggle button
local btnToggle = Instance.new("TextButton", gui)
btnToggle.Size = UDim2.new(0, 160, 0, 40)
btnToggle.Position = UDim2.new(0, 10, 0, 10)
btnToggle.Text = "AutoHarvest: Off"
btnToggle.BackgroundTransparency = 0.3
btnToggle.MouseButton1Click:Connect(function()
    Config.AutoHarvest = not Config.AutoHarvest
    btnToggle.Text = "AutoHarvest: " .. (Config.AutoHarvest and "On" or "Off")
    log("AutoHarvest "..(Config.AutoHarvest and "enabled" or "disabled"))
end)

-- Exit button
local btnExit = Instance.new("TextButton", gui)
btnExit.Size = UDim2.new(0, 80, 0, 30)
btnExit.Position = UDim2.new(0, 10, 0, 60)
btnExit.Text = "Exit"
btnExit.BackgroundTransparency = 0.3
btnExit.MouseButton1Click:Connect(function()
    Config.Running = false
    Config.AutoHarvest = false
    gui:Destroy()
    log("Exit pressed, script stopped")
end)

-- Show Logs button
local btnLogs = Instance.new("TextButton", gui)
btnLogs.Size = UDim2.new(0, 120, 0, 30)
btnLogs.Position = UDim2.new(0, 10, 0, 100)
btnLogs.Text = "Show Logs"
btnLogs.BackgroundTransparency = 0.3

local logsFrame
btnLogs.MouseButton1Click:Connect(function()
    if logsFrame then
        logsFrame:Destroy()
        logsFrame = nil
        return
    end
    logsFrame = Instance.new("ScrollingFrame", gui)
    logsFrame.Size = UDim2.new(0, 400, 0, 300)
    logsFrame.Position = UDim2.new(0, 200, 0, 10)
    logsFrame.CanvasSize = UDim2.new(0, 0, 0, #logs * 20)
    for i, msg in ipairs(logs) do
        local lbl = Instance.new("TextLabel", logsFrame)
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, (i-1)*20)
        lbl.Text = msg
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
    end
end)

-- Main loop
spawn(function()
    while Config.Running do
        if Config.AutoHarvest then
            harvestAll()
        end
        task.wait(Config.HarvestInterval)
    end
end)
