--!strict
--[[
    CUZAO HUB - Fruit Tab
    Gerenciamento de frutas, coleta, snipe e estoque
]]

local FruitTab = {}

local Players = game:GetService("Players")

function FruitTab.Build(window)
    local tab = window:CreateTab({ Name = "Fruit", Icon = "🍎" })

    -- ═══ Auto Fruit ═══
    local autoSection = tab:CreateSection("Auto Fruit")

    autoSection:AddToggle({
        Text = "Auto Collect Fruit",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Collect: " .. tostring(value))
        end,
    })

    autoSection:AddToggle({
        Text = "Auto Store Fruit",
        Default = false,
        Callback = function(value) end,
    })

    autoSection:AddSlider({
        Text = "Fruit Search Radius",
        Min = 500,
        Max = 5000,
        Default = 2000,
        Suffix = " studs",
        Callback = function(value) end,
    })

    autoSection:AddToggle({
        Text = "Fruit notified on Discord",
        Default = false,
        Callback = function(value) end,
    })

    autoSection:AddButton({
        Text = "Teleport to Fruit Spawn",
        Callback = function()
            print("[CUZAO] Procurando fruta...")
        end,
    })

    -- ═══ Fruit Sniper ═══
    local sniperSection = tab:CreateSection("Fruit Sniper")

    sniperSection:AddToggle({
        Text = "Auto Fruit Sniper",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Fruit Sniper: " .. tostring(value))
        end,
    })

    sniperSection:AddDropdown({
        Text = "Snipe Rarity",
        Options = {"Legendary", "Mythical", "All"},
        Default = "Legendary",
        Callback = function(value) end,
    })

    sniperSection:AddToggle({
        Text = "Auto Buy from Dealer",
        Default = false,
        Callback = function(value) end,
    })

    sniperSection:AddToggle({
        Text = "Auto Buy from Cousin",
        Default = false,
        Callback = function(value) end,
    })

    sniperSection:AddSlider({
        Text = "Dealer Check Interval",
        Min = 5,
        Max = 60,
        Default = 15,
        Suffix = "s",
        Callback = function(value) end,
    })

    -- ═══ Fruit Inventory ═══
    local invSection = tab:CreateSection("Inventário de Frutas")

    invSection:AddParagraph({
        Title = "Frutas no Inventário",
        Desc = "Carregando...",
    })

    invSection:AddButton({
        Text = "Refresh Inventory",
        Callback = function()
            print("[CUZAO] Atualizando inventário...")
        end,
    })

    invSection:AddButton({
        Text = "Drop Current Fruit",
        Callback = function()
            print("[CUZAO] Dropando fruta...")
        end,
    })

    -- ═══ Fruit Snipe List ═══
    local listSection = tab:CreateSection("Lista de Snipe")

    listSection:AddParagraph({
        Title = "Frutas Alvo",
        Desc = "Configure quais frutas deseja snipe na lista.",
    })

    -- Target fruits dropdown
    local targetFruits = {
        "Dragon", "Leopard", "Kitsune", "Spirit",
        "Dough", "Buddha", "Venom", "Control",
        "Shadow", "T-Rex", "Mammoth", "Blizzard",
        "Gas", "Love", "Sound", "Spider",
    }

    listSection:AddDropdown({
        Text = "Select Fruit",
        Options = targetFruits,
        Default = targetFruits[1],
        Callback = function(value)
            print("[CUZAO] Fruit selected: " .. value)
        end,
    })

    listSection:AddToggle({
        Text = "Auto Sniper for Selected",
        Default = false,
        Callback = function(value) end,
    })

    return tab
end

return FruitTab