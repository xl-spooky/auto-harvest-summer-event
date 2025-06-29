-- AutoHarvest.lua

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace         = workspace

-- configuration
local Config = {
    AutoHarvest     = false,
    HarvestInterval = 0.1,
    Running         = true,
}

-- logging
local logs = {}
local function log(msg)
    logs[#logs+1] = msg
end

log("Script loaded")

-- plot cache
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
plotFolder.ChildAdded:Connect(addPlot)
plotFolder.ChildRemoved:Connect(removePlot)
log("Plot cache initialized ("..#plots.." plots)")

-- harvest logic
local harvestEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")
local function harvestAll()
    log("Harvest cycle start")
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
                    log("Error on "..plot.Name..": "..tostring(err))
                end
            end)
        end
    end
end

-- main loop
spawn(function()
    while Config.Running do
        if Config.AutoHarvest then
            harvestAll()
        end
        task.wait(Config.HarvestInterval)
    end
    log("Main loop ended")
end)

-- GUI
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local pg = lp:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", pg)
gui.Name = "AutoHarvestGUI"
gui.ResetOnSpawn = false

-- Toggle button
local btnToggle = Instance.new("TextButton", gui)
btnToggle.Size = UDim2.new(0,150,0,40)
btnToggle.Position = UDim2.new(0,10,0,10)
btnToggle.Text = "AutoHarvest: Off"
btnToggle.BackgroundTransparency = 0.5
btnToggle.TextColor3 = Color3.new(1,1,1)
btnToggle.BackgroundColor3 = Color3.new(0,0,0)
btnToggle.MouseButton1Click:Connect(function()
    Config.AutoHarvest = not Config.AutoHarvest
    btnToggle.Text = "AutoHarvest: "..(Config.AutoHarvest and "On" or "Off")
    log("AutoHarvest "..(Config.AutoHarvest and "enabled" or "disabled"))
end)

-- Exit button
local btnExit = Instance.new("TextButton", gui)
btnExit.Size = UDim2.new(0,80,0,30)
btnExit.Position = UDim2.new(0,10,0,60)
btnExit.Text = "Exit"
btnExit.BackgroundTransparency = 0.5
btnExit.TextColor3 = Color3.new(1,1,1)
btnExit.BackgroundColor3 = Color3.new(0,0,0)
btnExit.MouseButton1Click:Connect(function()
    Config.Running = false
    Config.AutoHarvest = false
    gui:Destroy()
    log("Script exited")
end)

-- Copy Logs button
local btnCopy = Instance.new("TextButton", gui)
btnCopy.Size = UDim2.new(0,120,0,30)
btnCopy.Position = UDim2.new(0,10,0,100)
btnCopy.Text = "Copy Logs"
btnCopy.BackgroundTransparency = 0.5
btnCopy.TextColor3 = Color3.new(1,1,1)
btnCopy.BackgroundColor3 = Color3.new(0,0,0)
btnCopy.MouseButton1Click:Connect(function()
    local content = table.concat(logs, "\n")
    if setclipboard then
        pcall(setclipboard, content)
    elseif syn and syn.set_clipboard then
        pcall(syn.set_clipboard, content)
    end
    btnCopy.Text = "Copied!"
    task.delay(2, function() btnCopy.Text = "Copy Logs" end)
end)
