local Players = game:GetService("Players")
local UserGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local GUI = {}

function GUI.create(onToggle, onExit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoHarvestGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = UserGui

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0,150,0,40)
    toggleBtn.Position = UDim2.new(0,10,0,10)
    toggleBtn.Text = "AutoHarvest: Off"
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.Parent = screenGui

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleBtn.Text = "AutoHarvest: " .. (enabled and "On" or "Off")
        onToggle(enabled)
    end)

    local exitBtn = Instance.new("TextButton")
    exitBtn.Size = UDim2.new(0,80,0,30)
    exitBtn.Position = UDim2.new(0,10,0,60)
    exitBtn.Text = "Exit"
    exitBtn.BackgroundTransparency = 0.3
    exitBtn.Parent = screenGui

    exitBtn.MouseButton1Click:Connect(function()
        onExit()
        screenGui:Destroy()
    end)
end

return GUI
