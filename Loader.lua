local baseUrl = "https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/src/"

do
    local Players = game:GetService("Players")
    local gui = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "LoaderDebug"
    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(0, 200, 0, 50)
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.Text = "Loader.lua OK"
    lbl.BackgroundTransparency = 0.5
    task.delay(3, function() gui:Destroy() end)
end

local mainCode = game:HttpGet(baseUrl .. "Main.lua", true)
loadstring(mainCode)()
