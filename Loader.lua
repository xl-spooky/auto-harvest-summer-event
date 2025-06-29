local baseUrl = "https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/src/"

local function fetch(name)
    return game:HttpGet(baseUrl .. name .. ".lua", true)
end

local Config    = loadstring(fetch("Config"))()
local PlotCache = loadstring(fetch("PlotCache"))()
local Harvester = loadstring(fetch("Harvester"))()
local GUI       = loadstring(fetch("GUI"))()
local mainChunk = loadstring(fetch("Main"))

mainChunk(Config, PlotCache, Harvester, GUI)
