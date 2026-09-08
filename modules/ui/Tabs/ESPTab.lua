--!strict
--[[
    CUZAO HUB - ESP Tab
    ESP para jogadores, frutas, cofres e NPCs
]]

local ESPTab = {}

function ESPTab.Build(window)
    local tab = window:CreateTab({ Name = "ESP", Icon = "👁️" })

    -- ═══ Player ESP ═══
    local playerSection = tab:CreateSection("Player ESP")

    playerSection:AddToggle({
        Text = "Player ESP",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Player ESP: " .. tostring(value))
        end,
    })

    playerSection:AddToggle({
        Text = "Box ESP",
        Default = true,
        Callback = function(value) end,
    })

    playerSection:AddToggle({
        Text = "Name ESP",
        Default = true,
        Callback = function(value) end,
    })

    playerSection:AddToggle({
        Text = "Health ESP",
        Default = true,
        Callback = function(value) end,
    })

    playerSection:AddToggle({
        Text = "Distance ESP",
        Default = false,
        Callback = function(value) end,
    })

    playerSection:AddToggle({
        Text = "Team Color",
        Default = false,
        Callback = function(value) end,
    })

    playerSection:AddSlider({
        Text = "ESP Max Distance",
        Min = 100,
        Max = 10000,
        Default = 5000,
        Suffix = " studs",
        Callback = function(value) end,
    })

    playerSection:AddColorPicker({
        Text = "Box Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color) end,
    })

    -- ═══ Fruit ESP ═══
    local fruitSection = tab:CreateSection("Fruit ESP")

    fruitSection:AddToggle({
        Text = "Fruit ESP",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Fruit ESP: " .. tostring(value))
        end,
    })

    fruitSection:AddToggle({
        Text = "Fruit Name",
        Default = true,
        Callback = function(value) end,
    })

    fruitSection:AddToggle({
        Text = "Fruit Distance",
        Default = true,
        Callback = function(value) end,
    })

    fruitSection:AddColorPicker({
        Text = "Fruit Color",
        Default = Color3.fromRGB(255, 165, 0),
        Callback = function(color) end,
    })

    -- ═══ Chest ESP ═══
    local chestSection = tab:CreateSection("Chest ESP")

    chestSection:AddToggle({
        Text = "Chest ESP",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Chest ESP: " .. tostring(value))
        end,
    })

    chestSection:AddToggle({
        Text = "Diamond Chest",
        Default = true,
        Callback = function(value) end,
    })

    chestSection:AddToggle({
        Text = "Gold Chest",
        Default = true,
        Callback = function(value) end,
    })

    chestSection:AddToggle({
        Text = "Silver Chest",
        Default = false,
        Callback = function(value) end,
    })

    chestSection:AddColorPicker({
        Text = "Chest Color",
        Default = Color3.fromRGB(255, 215, 0),
        Callback = function(color) end,
    })

    -- ═══ NPC ESP ═══
    local npcSection = tab:CreateSection("NPC ESP")

    npcSection:AddToggle({
        Text = "NPC ESP",
        Default = false,
        Callback = function(value)
            print("[CUZAO] NPC ESP: " .. tostring(value))
        end,
    })

    npcSection:AddToggle({
        Text = "Quest Giver Highlight",
        Default = false,
        Callback = function(value) end,
    })

    npcSection:AddToggle({
        Text = "Dealer Highlight",
        Default = false,
        Callback = function(value) end,
    })

    npcSection:AddColorPicker({
        Text = "NPC Color",
        Default = Color3.fromRGB(0, 255, 0),
        Callback = function(color) end,
    })

    -- ═══ Misc ESP ═══
    local miscSection = tab:CreateSection("ESP Misc")

    miscSection:AddToggle({
        Text = "Island Names",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Sea Monster ESP",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddToggle({
        Text = "Ability Cooldown ESP",
        Default = false,
        Callback = function(value) end,
    })

    miscSection:AddButton({
        Text = "Refresh All ESP",
        Callback = function()
            print("[CUZAO] Refreshing ESP...")
        end,
    })

    miscSection:AddButton({
        Text = "Clear All ESP",
        Callback = function()
            print("[CUZAO] Clearing ESP...")
        end,
    })

    return tab
end

return ESPTab