local baseUrl = "https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/src/"

local Players = game:GetService("Players")
local gui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
local lbl = Instance.new("TextLabel", gui)
lbl.Size = UDim2.new(0,200,0,50)
lbl.Position = UDim2.new(0,10,0,10)
lbl.Text = "Loader OK"
lbl.BackgroundTransparency = 1

local mainCode = game:HttpGet(baseUrl .. "Main.lua", true)
loadstring(mainCode)()
