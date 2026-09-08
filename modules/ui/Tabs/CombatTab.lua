--!strict
--[[
    CUZAO HUB - Combat Tab
    AutoClicker, FastAttack, SkillSpam, Haki
    Conectado via EventBus aos módulos de features
]]

local CombatTab = {}

function CombatTab.Build(window)
    local CUZAO = getgenv().CUZAO
    local EventBus = CUZAO and CUZAO.Modules["EventBus"]
    local ConfigManager = CUZAO and CUZAO.Modules["ConfigManager"]

    local tab = window:CreateTab({ Name = "Combat", Icon = "🗡️" })

    -- ═══ Fast Attack ═══
    local fastSection = tab:CreateSection("Fast Attack")

    fastSection:AddToggle({
        Text = "Fast Attack (No Cooldown)",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.FastAttack", value) end
            if EventBus then EventBus:Emit("Combat.FastAttack.Toggle", value) end
        end,
    })

    fastSection:AddSlider({
        Text = "Attack Range",
        Min = 5,
        Max = 60,
        Default = 60,
        Suffix = " studs",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AttackRange", value) end
        end,
    })

    fastSection:AddToggle({
        Text = "Auto Click",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AutoClick", value) end
            if EventBus then EventBus:Emit("Combat.AutoClick.Toggle", value) end
        end,
    })

    fastSection:AddSlider({
        Text = "Click Interval",
        Min = 10,
        Max = 500,
        Default = 50,
        Suffix = "ms",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.ClickInterval", value) end
        end,
    })

    -- ═══ AimBot ═══
    local aimSection = tab:CreateSection("AimBot")

    aimSection:AddToggle({
        Text = "Silent Aim",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.SilentAim", value) end
            if EventBus then EventBus:Emit("Combat.AimBot.Toggle", value) end
        end,
    })

    aimSection:AddDropdown({
        Text = "Target Part",
        Options = {"Head", "HumanoidRootPart", "Closest"},
        Default = "Head",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AimPart", value) end
        end,
    })

    aimSection:AddSlider({
        Text = "FOV Size",
        Min = 30,
        Max = 500,
        Default = 150,
        Suffix = "px",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.FOVSize", value) end
        end,
    })

    -- ═══ Kill Aura ═══
    local auraSection = tab:CreateSection("Kill Aura")

    auraSection:AddToggle({
        Text = "Kill Aura",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.KillAura", value) end
            if EventBus then EventBus:Emit("Combat.KillAura.Toggle", value) end
        end,
    })

    auraSection:AddSlider({
        Text = "Aura Range",
        Min = 5,
        Max = 60,
        Default = 20,
        Suffix = " studs",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AuraRange", value) end
        end,
    })

    auraSection:AddToggle({
        Text = "Aura on Players",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AuraPlayers", value) end
        end,
    })

    auraSection:AddToggle({
        Text = "Aura on NPCs",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AuraNPCs", value) end
        end,
    })

    -- ═══ Skill Spam ═══
    local skillSection = tab:CreateSection("Skill Spam")

    skillSection:AddToggle({
        Text = "Auto Skill Spam",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.SkillSpam", value) end
            if EventBus then EventBus:Emit("Combat.SkillSpam.Toggle", value) end
        end,
    })

    skillSection:AddToggle({
        Text = "Z Skill", Default = true,
        Callback = function(v) if ConfigManager then ConfigManager:Set("Combat.SkillZ", v) end end,
    })
    skillSection:AddToggle({
        Text = "X Skill", Default = true,
        Callback = function(v) if ConfigManager then ConfigManager:Set("Combat.SkillX", v) end end,
    })
    skillSection:AddToggle({
        Text = "C Skill", Default = true,
        Callback = function(v) if ConfigManager then ConfigManager:Set("Combat.SkillC", v) end end,
    })
    skillSection:AddToggle({
        Text = "V Skill", Default = true,
        Callback = function(v) if ConfigManager then ConfigManager:Set("Combat.SkillV", v) end end,
    })
    skillSection:AddToggle({
        Text = "F Skill", Default = false,
        Callback = function(v) if ConfigManager then ConfigManager:Set("Combat.SkillF", v) end end,
    })

    skillSection:AddSlider({
        Text = "Skill Delay",
        Min = 100,
        Max = 3000,
        Default = 500,
        Suffix = "ms",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.SkillDelay", value) end
        end,
    })

    -- ═══ Haki ═══
    local hakiSection = tab:CreateSection("Haki & Ken")

    hakiSection:AddToggle({
        Text = "Auto Buso Haki",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AutoBuso", value) end
            if EventBus then EventBus:Emit("Combat.Buso.Toggle", value) end
        end,
    })

    hakiSection:AddToggle({
        Text = "Auto Ken Haki",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.AutoKen", value) end
            if EventBus then EventBus:Emit("Combat.Ken.Toggle", value) end
        end,
    })

    hakiSection:AddDropdown({
        Text = "Haki Stage",
        Options = {"State 0", "State 1", "State 2", "State 3", "State 4", "State 5"},
        Default = "State 0",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("Combat.HakiStage", value) end
        end,
    })

    return tab
end

return CombatTab
