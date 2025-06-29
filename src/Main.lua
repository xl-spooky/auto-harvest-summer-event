local baseUrl = "https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/src/"
local HttpService = game:GetService("HttpService")

local moduleCache = {}
local function requireUrl(name)
    if moduleCache[name] then
        return moduleCache[name]
    end
    local url = baseUrl .. name .. ".lua"
    local code = game:HttpGet(url)
    local chunk = loadstring(code)
    local result = chunk()
    moduleCache[name] = result
    return result
end

local Config    = requireUrl("Config")
local PlotCache = requireUrl("PlotCache")
local Harvester = requireUrl("Harvester")
local GUI       = requireUrl("GUI")

PlotCache.init()

GUI.create(
    function(isEnabled)
        Config.AutoHarvest = isEnabled
    end,
    function()
        Config.AutoHarvest = false
        Config.Running = false
    end
)

spawn(function()
    while Config.Running do
        if Config.AutoHarvest then
            Harvester.harvest()
        end
        task.wait(Config.HarvestInterval)
    end
end)
