local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace         = workspace

-- configuration
local Config = {
    AutoHarvest     = false,
    HarvestInterval = 0.5,
    Running         = true,
}

-- logging
local logs = {}
local function log(msg)
    table.insert(logs, msg)
end

-- plot cache
local plots = {}
local function addPlot(p)
    if p and not table.find(plots, p) then
        table.insert(plots, p)
    end
end
local function removePlot(p)
    for i, v in ipairs(plots) do
        if v == p then
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

-- harvest logic
local harvestEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")
local function harvestAll()
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
                    log("Harvested "..plot.Name)
                else
                    log("Error harvesting "..plot.Name..": "..tostring(err))
                end
            end)
        end
    end
end

-- GUI setup
local lp  = Players.LocalPlayer or Players.PlayerAdded:Wait()
local pg  = lp:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", pg)
gui.Name = "AutoHarvestGUI"

-- Toggle button
local btnToggle = Instance.new("TextButton", gui)
btnToggle.Size = UDim2.new(0,160,0,40)
btnToggle.Position = UDim2.new(0,10,0,10)
btnToggle.Text = "AutoHarvest: Off"
btnToggle.BackgroundTransparency = 0.3

-- Exit button
local btnExit = Instance.new("TextButton", gui)
btnExit.Size = UDim2.new(0,80,0,30)
btnExit.Position = UDim2.new(0,10,0,60)
btnExit.Text = "Exit"
btnExit.BackgroundTransparency = 0.3

-- Logs button
local btnLogs = Instance.new("TextButton", gui)
btnLogs.Size = UDim2.new(0,120,0,30)
btnLogs.Position = UDim2.new(0,10,0,100)
btnLogs.Text = "Show Logs"
btnLogs.BackgroundTransparency = 0.3

local logsFrame

btnToggle.MouseButton1Click:Connect(function()
    Config.AutoHarvest = not Config.AutoHarvest
    btnToggle.Text = "AutoHarvest: "..(Config.AutoHarvest and "On" or "Off")
    log("AutoHarvest "..(Config.AutoHarvest and "enabled" or "disabled"))
end)

btnExit.MouseButton1Click:Connect(function()
    Config.Running = false
    Config.AutoHarvest = false
    if logsFrame then
        logsFrame:Destroy()
        logsFrame = nil
    end
    gui:Destroy()
    log("Exited script")
end)

btnLogs.MouseButton1Click:Connect(function()
    if logsFrame then
        logsFrame:Destroy()
        logsFrame = nil
        return
    end
    logsFrame = Instance.new("ScrollingFrame", gui)
    logsFrame.Size = UDim2.new(0,400,0,300)
    logsFrame.Position = UDim2.new(0,200,0,10)
    logsFrame.CanvasSize = UDim2.new(0,0,0,#logs*20)
    for i, msg in ipairs(logs) do
        local lbl = Instance.new("TextLabel", logsFrame)
        lbl.Size = UDim2.new(1,-10,0,20)
        lbl.Position = UDim2.new(0,5,0,(i-1)*20)
        lbl.Text = msg
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
    end
end)

-- initial log
log("AutoHarvest.lua loaded")

-- main loop
spawn(function()
    while Config.Running do
        if Config.AutoHarvest then
            harvestAll()
        end
        task.wait(Config.HarvestInterval)
    end
    -- after loop ends, clean up GUI if still present
    if gui and gui.Parent then gui:Destroy() end
    log("Main loop ended")
end)
