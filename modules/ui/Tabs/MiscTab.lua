--!strict
--[[
    CUZAO HUB - Misc Tab
    Funções miscelâneas: movimento, noclip, fly, speed, etc.
]]

local MiscTab = {}

function MiscTab.Build(window)
    local tab = window:CreateTab({ Name = "Misc", Icon = "⚙️" })

    -- ═══ Movement ═══
    local moveSection = tab:CreateSection("Movimento")

    moveSection:AddToggle({
        Text = "Noclip",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Noclip: " .. tostring(value))
        end,
    })

    moveSection:AddToggle({
        Text = "Fly",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Fly: " .. tostring(value))
        end,
    })

    moveSection:AddSlider({
        Text = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = "",
        Callback = function(value) end,
    })

    moveSection:AddSlider({
        Text = "Walk Speed",
        Min = 16,
        Max = 500,
        Default = 16,
        Suffix = "",
        Callback = function(value) end,
    })

    moveSection:AddSlider({
        Text = "Jump Power",
        Min = 50,
        Max = 500,
        Default = 50,
        Suffix = "",
        Callback = function(value) end,
    })

    moveSection:AddToggle({
        Text = "Infinite Jump",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Inf Jump: " .. tostring(value))
        end,
    })

    moveSection:AddToggle({
        Text = "Auto Jump",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Anti-Cheat ═══
    local acSection = tab:CreateSection("Anti-Cheat")

    acSection:AddToggle({
        Text = "Anti Kick",
        Default = true,
        Callback = function(value) end,
    })

    acSection:AddToggle({
        Text = "Anti AFK",
        Default = true,
        Callback = function(value) end,
    })

    acSection:AddToggle({
        Text = "Humanizer",
        Default = true,
        Callback = function(value) end,
    })

    acSection:AddSlider({
        Text = "Humanizer Delay",
        Min = 0,
        Max = 500,
        Default = 100,
        Suffix = "ms",
        Callback = function(value) end,
    })

    acSection:AddToggle({
        Text = "Anti Crash",
        Default = true,
        Callback = function(value) end,
    })

    acSection:AddToggle({
        Text = "Safe Mode",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Auto Stats ═══
    local statsSection = tab:CreateSection("Auto Stats")

    statsSection:AddToggle({
        Text = "Auto Stats",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Stats: " .. tostring(value))
        end,
    })

    statsSection:AddDropdown({
        Text = "Primary Stat",
        Options = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"},
        Default = "Melee",
        Callback = function(value) end,
    })

    statsSection:AddDropdown({
        Text = "Secondary Stat",
        Options = {"None", "Melee", "Defense", "Sword", "Gun", "Blox Fruit"},
        Default = "Defense",
        Callback = function(value) end,
    })

    statsSection:AddDropdown({
        Text = "Point Distribution",
        Options = {"All Primary", "50/50", "70/30"},
        Default = "All Primary",
        Callback = function(value) end,
    })

    -- ═══ Webhook ═══
    local whSection = tab:CreateSection("Webhook Discord")

    whSection:AddInput({
        Text = "Webhook URL",
        Placeholder = "https://discord.com/api/webhooks/...",
        Default = "",
        Callback = function(value) end,
    })

    whSection:AddToggle({
        Text = "Send Farm Logs",
        Default = false,
        Callback = function(value) end,
    })

    whSection:AddToggle({
        Text = "Send Fruit Alerts",
        Default = false,
        Callback = function(value) end,
    })

    whSection:AddButton({
        Text = "Test Webhook",
        Callback = function()
            print("[CUZAO] Testando webhook...")
        end,
    })

    -- ═══ Misc Features ═══
    local miscSection = tab:CreateSection("Outros")

    miscSection:AddToggle({
        Text = "Auto Third Sea",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Auto Trade",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Auto Race V4",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Auto Grape Fruit",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddButton({
        Text = "FPS Boost",
        Callback = function()
            -- Clear terrain, lighting effects etc.
            pcall(function()
                game:GetService("Lighting").Brightness = 0
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").FogEnd = 9e9
                for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end
            end)
        end,
    })

    miscSection:AddButton({
        Text = "Anti Lag",
        Callback = function()
            pcall(function()
                local Terrain = workspace:FindFirstChildOfClass("Terrain")
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                end
                game:GetService("Lighting").GlobalShadows = false
            end)
        end,
    })

    return tab
end

return MiscTab