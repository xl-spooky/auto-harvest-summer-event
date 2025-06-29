local baseUrl = "https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/src/"

local mainCode = game:HttpGet(baseUrl .. "Main.lua", true)
loadstring(mainCode)()
