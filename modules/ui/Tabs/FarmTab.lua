--!strict
--[[
    CUZAO HUB - Farm Tab
    Configurações de AutoFarm: Level, Bone, Katakuri, Factory
    Conectado via EventBus aos módulos de features
]]

local FarmTab = {}

function FarmTab.Build(window)
    local CUZAO = getgenv().CUZAO
    local EventBus = CUZAO and CUZAO.Modules["EventBus"]
    local ConfigManager = CUZAO and CUZAO.Modules["ConfigManager"]

    local tab = window:CreateTab({ Name = "Farm", Icon = "⚔️" })

    -- ═══ Auto Farm Level ═══
    local levelSection = tab:CreateSection("Auto Farm Level")

    levelSection:AddToggle({
        Text = "Auto Farm Level",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.Enabled", value) end
            if EventBus then EventBus:Emit("AutoFarm.Level.Toggle", value) end
        end,
    })

    levelSection:AddDropdown({
        Text = "Método de Farm",
        Options = {"Below", "Behind", "Tween", "Bypass"},
        Default = "Below",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.Method", value) end
        end,
    })

    levelSection:AddSlider({
        Text = "Velocidade do Tween",
        Min = 50,
        Max = 350,
        Default = 200,
        Suffix = " studs/s",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.TweenSpeed", value) end
        end,
    })

    levelSection:AddSlider({
        Text = "Distância de Ataque",
        Min = 5,
        Max = 60,
        Default = 15,
        Suffix = " studs",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.AttackDistance", value) end
        end,
    })

    levelSection:AddToggle({
        Text = "Auto Quest",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.AutoQuest", value) end
        end,
    })

    levelSection:AddToggle({
        Text = "Auto Equip Weapon",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.AutoEquip", value) end
        end,
    })

    levelSection:AddToggle({
        Text = "Fast Attack",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.FastAttack", value) end
            if EventBus then EventBus:Emit("Combat.FastAttack.Toggle", value) end
        end,
    })

    levelSection:AddToggle({
        Text = "Auto Haki",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.AutoHaki", value) end
        end,
    })

    levelSection:AddToggle({
        Text = "Auto Ken Haki",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.AutoKen", value) end
        end,
    })

    -- ═══ Farm Bone ═══
    local boneSection = tab:CreateSection("Farm Bone (Sea 3)")

    boneSection:AddToggle({
        Text = "Auto Farm Bone",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("BoneFarm.Enabled", value) end
            if EventBus then EventBus:Emit("AutoFarm.Bone.Toggle", value) end
        end,
    })

    boneSection:AddToggle({
        Text = "Auto Pray Gravestone",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("BoneFarm.AutoPray", value) end
        end,
    })

    boneSection:AddToggle({
        Text = "Auto Lucky",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("BoneFarm.AutoLucky", value) end
        end,
    })

    -- ═══ Farm Katakuri/Cake ═══
    local kataSection = tab:CreateSection("Farm Cake Prince")

    kataSection:AddParagraph({
        Title = "Cake Prince Status",
        Desc = "Matou: 0/500",
    })

    kataSection:AddToggle({
        Text = "Auto Farm Cake Prince",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("KatakuriFarm.Enabled", value) end
            if EventBus then EventBus:Emit("AutoFarm.Katakuri.Toggle", value) end
        end,
    })

    kataSection:AddToggle({
        Text = "Auto Kill Cake Prince",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("KatakuriFarm.KillPrince", value) end
        end,
    })

    -- ═══ Elite Hunter ═══
    local eliteSection = tab:CreateSection("Elite Hunter")

    eliteSection:AddToggle({
        Text = "Auto Farm Elite",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("EliteFarm.Enabled", value) end
            if EventBus then EventBus:Emit("AutoFarm.Elite.Toggle", value) end
        end,
    })

    eliteSection:AddToggle({
        Text = "Auto Hop (Elite Cooldown)",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("EliteFarm.AutoHop", value) end
        end,
    })

    -- ═══ Sea Events ═══
    local seaSection = tab:CreateSection("Eventos do Mar")

    seaSection:AddToggle({
        Text = "Auto Farm Tyrant of the Skies",
        Default = false,
        Callback = function(value)
            if EventBus then EventBus:Emit("AutoFarm.Tyrant.Toggle", value) end
        end,
    })

    seaSection:AddToggle({
        Text = "Auto Farm Rip Indra",
        Default = false,
        Callback = function(value)
            if EventBus then EventBus:Emit("AutoFarm.RipIndra.Toggle", value) end
        end,
    })

    seaSection:AddToggle({
        Text = "Auto Summon Boss",
        Default = false,
        Callback = function(value)
            if EventBus then EventBus:Emit("AutoFarm.SummonBoss.Toggle", value) end
        end,
    })

    -- ═══ Mastery Farm ═══
    local masterySection = tab:CreateSection("Mastery Farm")

    masterySection:AddToggle({
        Text = "Auto Mastery Sword",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Mastery.Sword", value) end
        end,
    })

    masterySection:AddToggle({
        Text = "Auto Mastery Gun",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Mastery.Gun", value) end
        end,
    })

    masterySection:AddToggle({
        Text = "Auto Mastery Fruit",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Mastery.Fruit", value) end
        end,
    })

    -- ═══ General Farm Settings ═══
    local generalSection = tab:CreateSection("Configurações Gerais")

    generalSection:AddToggle({
        Text = "Bypass Teleport",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.BypassTP", value) end
        end,
    })

    generalSection:AddToggle({
        Text = "Auto Stop on Missing Quest",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.StopOnNoQuest", value) end
        end,
    })

    generalSection:AddDropdown({
        Text = "Team",
        Options = {"Pirates", "Marines", "Auto"},
        Default = "Auto",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("AutoFarm.Team", value) end
        end,
    })

    return tab
end

return FarmTab
