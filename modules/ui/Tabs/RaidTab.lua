--!strict
--[[
    CUZAO HUB - Raid Tab
    Configurações de Raids e Law
]]

local RaidTab = {}

function RaidTab.Build(window)
    local tab = window:CreateTab({ Name = "Raid", Icon = "🏴‍☠️" })

    -- ═══ Auto Raid ═══
    local raidSection = tab:CreateSection("Auto Raid")

    raidSection:AddToggle({
        Text = "Auto Raid",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Raid: " .. tostring(value))
        end,
    })

    raidSection:AddDropdown({
        Text = "Raid Type",
        Options = {
            "Flame", "Ice", "Quake", "Light", "Dark",
            "String", "Rumble", "Magma", "Human", "Buddha",
            "Phoenix", "Spider", "Sound", "Ghost", "Leopard",
        },
        Default = "Flame",
        Callback = function(value)
            print("[CUZAO] Raid Type: " .. value)
        end,
    })

    raidSection:AddToggle({
        Text = "Auto Select Raid",
        Default = true,
        Callback = function(value) end,
    })

    raidSection:AddToggle({
        Text = "Auto Start Raid",
        Default = true,
        Callback = function(value) end,
    })

    raidSection:AddToggle({
        Text = "Kill Aura (Raid)",
        Default = true,
        Callback = function(value) end,
    })

    raidSection:AddToggle({
        Text = "Auto Next Island",
        Default = true,
        Callback = function(value) end,
    })

    raidSection:AddToggle({
        Text = "Auto Buy Chip",
        Default = false,
        Callback = function(value) end,
    })

    raidSection:AddToggle({
        Text = "Auto Reset After Raid",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Law Raid ═══
    local lawSection = tab:CreateSection("Law Raid")

    lawSection:AddToggle({
        Text = "Auto Law Raid",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Law Raid: " .. tostring(value))
        end,
    })

    lawSection:AddToggle({
        Text = "Auto Collect Key",
        Default = true,
        Callback = function(value) end,
    })

    lawSection:AddSlider({
        Text = "Law Raid Delay",
        Min = 0,
        Max = 10,
        Default = 2,
        Suffix = "s",
        Callback = function(value) end,
    })

    -- ═══ Raid Misc ═══
    local miscSection = tab:CreateSection("Raid Misc")

    miscSection:AddToggle({
        Text = "Auto Farm Chips",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Auto Portal to Raid",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Full Moon Farm",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddButton({
        Text = "Teleport to Raid Island",
        Callback = function()
            print("[CUZAO] Teleportando para raid island...")
        end,
    })

    return tab
end

return RaidTab