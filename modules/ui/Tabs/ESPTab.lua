--!strict
--[[
    CUZAO HUB - ESP Tab
    ESP para jogadores, frutas, ilhas e NPCs
    Conectado via EventBus aos módulos de features
]]

local ESPTab = {}

function ESPTab.Build(window)
    local CUZAO = getgenv().CUZAO
    local EventBus = CUZAO and CUZAO.Modules["EventBus"]
    local ConfigManager = CUZAO and CUZAO.Modules["ConfigManager"]

    local tab = window:CreateTab({ Name = "ESP", Icon = "👁️" })

    -- ═══ Player ESP ═══
    local playerSection = tab:CreateSection("Player ESP")

    playerSection:AddToggle({
        Text = "Player ESP",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Player.Enabled", value) end
            if EventBus then EventBus:Emit("ESP.Player.Toggle", value) end
        end,
    })

    playerSection:AddToggle({
        Text = "Nome + Distância",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Player.ShowName", value) end
        end,
    })

    playerSection:AddToggle({
        Text = "Show Health",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Player.ShowHealth", value) end
        end,
    })

    playerSection:AddToggle({
        Text = "Team Color (Aliado/Azul, Inimigo/Vermelho)",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Player.TeamColor", value) end
        end,
    })

    playerSection:AddSlider({
        Text = "Distância Máxima",
        Min = 100,
        Max = 10000,
        Default = 5000,
        Suffix = " studs",
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Player.MaxDistance", value) end
        end,
    })

    -- ═══ Fruit ESP ═══
    local fruitSection = tab:CreateSection("Fruit ESP")

    fruitSection:AddToggle({
        Text = "Fruit ESP",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Fruit.Enabled", value) end
            if EventBus then EventBus:Emit("ESP.Fruit.Toggle", value) end
        end,
    })

    fruitSection:AddToggle({
        Text = "Nome da Fruta",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Fruit.ShowName", value) end
        end,
    })

    fruitSection:AddToggle({
        Text = "Distância",
        Default = true,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Fruit.ShowDistance", value) end
        end,
    })

    -- ═══ Island ESP ═══
    local islandSection = tab:CreateSection("Island/Location ESP")

    islandSection:AddToggle({
        Text = "Island ESP",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Island.Enabled", value) end
            if EventBus then EventBus:Emit("ESP.Island.Toggle", value) end
        end,
    })

    islandSection:AddToggle({
        Text = "Event Island ESP (Mirage, Kitsune, etc)",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.EventIsland.Enabled", value) end
        end,
    })

    -- ═══ Misc ESP ═══
    local miscSection = tab:CreateSection("ESP Diversos")

    miscSection:AddToggle({
        Text = "Chest ESP",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Chest.Enabled", value) end
            if EventBus then EventBus:Emit("ESP.Chest.Toggle", value) end
        end,
    })

    miscSection:AddToggle({
        Text = "Advanced Dealer ESP",
        Default = false,
        Callback = function(value)
            if ConfigManager then ConfigManager:Set("ESP.Dealer.Enabled", value) end
        end,
    })

    miscSection:AddButton({
        Text = "🗑️ Limpar Todos ESP",
        Callback = function()
            if EventBus then EventBus:Emit("ESP.ClearAll") end
        end,
    })

    return tab
end

return ESPTab
