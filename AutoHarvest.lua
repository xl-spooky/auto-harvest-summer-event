spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local workspace = workspace

    -- immediate debug label
    local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local pg = lp:WaitForChild("PlayerGui")
    local dbgGui = Instance.new("ScreenGui", pg)
    dbgGui.Name = "AHDebug"
    local dbgLbl = Instance.new("TextLabel", dbgGui)
    dbgLbl.Size = UDim2.new(0,200,0,50)
    dbgLbl.Position = UDim2.new(0,10,0,10)
    dbgLbl.Text = "AutoHarvest startup"
    dbgLbl.BackgroundTransparency = 0.5

    -- config
    local Config = {AutoHarvest=false,HarvestInterval=0.1,Running=true}
    local logs = {}
    local function log(m) logs[#logs+1]=m end
    log("config ok")

    -- cache
    local plots = {}
    local function add(p) if p and not table.find(plots,p) then table.insert(plots,p) end end
    local function rem(p) for i,v in ipairs(plots) do if v==p then table.remove(plots,i);break end end end
    local folder = workspace:WaitForChild("Plots")
    for _,p in ipairs(folder:GetChildren()) do add(p) end
    folder.ChildAdded:Connect(add)
    folder.ChildRemoved:Connect(rem)
    log("cache ok")

    -- harvest fn
    local evt = ReplicatedStorage:WaitForChild("ByteNetReliable")
    local function harvestAll()
        for _,pl in ipairs(plots) do
            local c = pl:FindFirstChild("Crop")
            if c and c:FindFirstChild("Growth") and c:FindFirstChild("Maturity") and c:FindFirstChild("HarvestPrompt") and c.Growth.Value>=c.Maturity.Value then
                pcall(function() evt:FireServer(c.HarvestPrompt) end)
            end
        end
    end

    -- remove debug label
    task.delay(2, function() dbgGui:Destroy() end)

    -- build GUI
    local gui = Instance.new("ScreenGui", pg)
    gui.Name = "AutoHarvestGUI"
    local tb = Instance.new("TextButton", gui)
    tb.Size = UDim2.new(0,150,0,40)
    tb.Position = UDim2.new(0,10,0,10)
    tb.Text = "AutoHarvest: Off"
    tb.BackgroundTransparency = 0.5
    tb.TextColor3 = Color3.new(1,1,1)
    task.wait(0.1)
    tb.MouseButton1Click:Connect(function()
        Config.AutoHarvest = not Config.AutoHarvest
        tb.Text = "AutoHarvest: "..(Config.AutoHarvest and "On" or "Off")
        log("toggled "..tostring(Config.AutoHarvest))
    end)

    local eb = Instance.new("TextButton", gui)
    eb.Size = UDim2.new(0,80,0,30)
    eb.Position = UDim2.new(0,10,0,60)
    eb.Text = "Exit"
    eb.BackgroundTransparency = 0.5
    eb.TextColor3 = Color3.new(1,1,1)
    eb.MouseButton1Click:Connect(function()
        Config.Running = false
        gui:Destroy()
    end)

    local cb = Instance.new("TextButton", gui)
    cb.Size = UDim2.new(0,120,0,30)
    cb.Position = UDim2.new(0,10,0,100)
    cb.Text = "Copy Logs"
    cb.BackgroundTransparency = 0.5
    cb.TextColor3 = Color3.new(1,1,1)
    cb.MouseButton1Click:Connect(function()
        local s = table.concat(logs,"\n")
        if setclipboard then pcall(setclipboard,s) elseif syn and syn.set_clipboard then pcall(syn.set_clipboard,s) end
        cb.Text="Copied"
        task.delay(2,function() cb.Text="Copy Logs" end)
    end)

    -- main loop
    spawn(function()
        while Config.Running do
            if Config.AutoHarvest then harvestAll() end
            task.wait(Config.HarvestInterval)
        end
    end)
end)
