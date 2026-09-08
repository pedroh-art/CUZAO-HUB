--!strict
--[[
    CUZAO HUB - Misc Tab
    Funções miscelâneas: movimento, stats, performance, server tools
    Conectado via EventBus aos módulos de features
]]

local MiscTab = {}

function MiscTab.Build(window)
    local CUZAO = getgenv().CUZAO
    local EventBus = CUZAO and CUZAO.Modules["EventBus"]
    local ConfigManager = CUZAO and CUZAO.Modules["ConfigManager"]
    local Players = game:GetService("Players")

    local tab = window:CreateTab({ Name = "Misc", Icon = "⚙️" })

    -- ═══ Movement ═══
    local moveSection = tab:CreateSection("Movimento")

    moveSection:AddToggle({
        Text = "Fly",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Misc.Fly", value) end
            if EventBus then EventBus:Emit("Misc.Fly.Toggle", value) end
        end,
    })

    moveSection:AddSlider({
        Text = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = "",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Misc.FlySpeed", value) end
            if EventBus then EventBus:Emit("Misc.Fly.Speed", value) end
        end,
    })

    moveSection:AddToggle({
        Text = "Noclip",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Misc.Noclip", value) end
            if EventBus then EventBus:Emit("Misc.Noclip.Toggle", value) end
        end,
    })

    moveSection:AddToggle({
        Text = "Safe Mode (voar pra cima se low HP)",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Misc.SafeMode", value) end
            if EventBus then EventBus:Emit("Misc.SafeMode.Toggle", value) end
        end,
    })

    -- ═══ Auto Stats ═══
    local statsSection = tab:CreateSection("Auto Stats")

    statsSection:AddToggle({
        Text = "Auto Stats",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Stats.Enabled", value) end
            if EventBus then EventBus:Emit("Stats.AutoToggle", value) end
        end,
    })

    statsSection:AddDropdown({
        Text = "Stat Principal",
        Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
        Default = "Melee",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Stats.Primary", value) end
        end,
    })

    statsSection:AddDropdown({
        Text = "Stat Secundário",
        Options = {"None", "Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
        Default = "Defense",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Stats.Secondary", value) end
        end,
    })

    -- ═══ Haki ═══
    local hakiSection = tab:CreateSection("Haki")

    hakiSection:AddDropdown({
        Text = "Haki Stage",
        Options = {"State 0", "State 1", "State 2", "State 3", "State 4", "State 5"},
        Default = "State 0",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Misc.HakiStage", value) end
        end,
    })

    hakiSection:AddButton({
        Text = "Mudar Haki Stage",
        Callback = function()
            pcall(function()
                local stage = ConfigManager and ConfigManager:Get("Misc.HakiStage") or "State 0"
                local num = tonumber(stage:match("%d")) or 0
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ChangeBusoStage", num)
            end)
        end,
    })

    hakiSection:AddToggle({
        Text = "Auto Unlocked Haki",
        Default = false,
        Callback = function(value)
            if EventBus then EventBus:Emit("Misc.AutoHaki.Toggle", value) end
        end,
    })

    -- ═══ Performance ═══
    local perfSection = tab:CreateSection("Performance")

    perfSection:AddButton({
        Text = "🎮 Full Bright",
        Callback = function()
            pcall(function()
                local l = game:GetService("Lighting")
                l.Ambient = Color3.new(0.695, 0.695, 0.695)
                l.ColorShift_Bottom = Color3.new(0.695, 0.695, 0.695)
                l.ColorShift_Top = Color3.new(0.695, 0.695, 0.695)
                l.Brightness = 2
                l.FogEnd = 1e10
            end)
        end,
    })

    perfSection:AddButton({
        Text = "⚡ Low CPU",
        Callback = function()
            pcall(function()
                local t = workspace:FindFirstChildOfClass("Terrain")
                if t then
                    t.WaterWaveSize = 0
                    t.WaterWaveSpeed = 0
                    t.WaterReflectance = 0
                    t.WaterTransparency = 1
                end
                local l = game:GetService("Lighting")
                l.GlobalShadows = false
                l.FogEnd = 9e9
                l.Brightness = 0
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end
            end)
        end,
    })

    perfSection:AddButton({
        Text = "🖼️ Remove Sky Fog",
        Callback = function()
            pcall(function()
                local l = game:GetService("Lighting")
                if l:FindFirstChild("LightingLayers") then l.LightingLayers:Destroy() end
                if l:FindFirstChild("SeaTerrorCC") then l.SeaTerrorCC:Destroy() end
                if l:FindFirstChild("FantasySky") then l.FantasySky:Destroy() end
            end)
        end,
    })

    perfSection:AddButton({
        Text = "📺 Remove Camera Shake",
        Callback = function()
            pcall(function()
                local camShaker = require(game.ReplicatedStorage.Util.CameraShaker)
                camShaker:Stop()
            end)
        end,
    })

    -- ═══ Server Tools ═══
    local serverSection = tab:CreateSection("Servidor")

    serverSection:AddButton({
        Text = "🔄 Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
        end,
    })

    serverSection:AddButton({
        Text = "🔀 Server Hop",
        Callback = function()
            pcall(function()
                local HttpService = game:GetService("HttpService")
                local TPS = game:GetService("TeleportService")
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = game:HttpGet(url)
                local servers = HttpService:JSONDecode(response)
                if servers and servers.data then
                    for _, s in ipairs(servers.data) do
                        if s.id ~= game.JobId and s.playing < s.maxPlayers then
                            TPS:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
                            break
                        end
                    end
                end
            end)
        end,
    })

    serverSection:AddButton({
        Text = "📋 Copiar Job ID",
        Callback = function()
            if setclipboard then setclipboard(tostring(game.JobId)) end
        end,
    })

    serverSection:AddInput({
        Text = "Job ID",
        Placeholder = "Cole o Job ID aqui",
        Default = "",
        Callback = function(value)
            getgenv().CUZAO_JobId = value
        end,
    })

    serverSection:AddButton({
        Text = "🚀 Teleportar por Job ID",
        Callback = function()
            pcall(function()
                local jobId = getgenv().CUZAO_JobId
                if jobId and jobId ~= "" then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, Players.LocalPlayer)
                end
            end)
        end,
    })

    -- ═══ Team ═══
    local teamSection = tab:CreateSection("Time")

    teamSection:AddButton({
        Text = "🏴 Piratas",
        Callback = function()
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
            end)
        end,
    })

    teamSection:AddButton({
        Text = "⚓ Marines",
        Callback = function()
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Marines")
            end)
        end,
    })

    -- ═══ GUI Toggle ═══
    local guiSection = tab:CreateSection("Interface")

    guiSection:AddToggle({
        Text = "Desativar Chat GUI",
        Default = false,
        Callback = function(value)
            pcall(function()
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not value)
            end)
        end,
    })

    guiSection:AddToggle({
        Text = "Desativar Leaderboard",
        Default = false,
        Callback = function(value)
            pcall(function()
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not value)
            end)
        end,
    })

    return tab
end

return MiscTab
