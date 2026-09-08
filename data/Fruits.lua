--[[
    CUZAO HUB - Fruits Data
    Dados completos de todas frutas: preço, raridade, spawn, mastery
]]

local Fruits = {}

-- ═══════════════════════════════════════════
-- FRUIT DATABASE
-- ═══════════════════════════════════════════
Fruits.Database = {
    -- ─── Legendary ───
    ["Dragon"] = {
        Rarity = "Legendary",
        Price = 3500000,
        Fragment = 0,
        Damage = 230,
        Mastery = {0, 0},
        Element = "Fire",
        Type = "Natural",
        Color = Color3.fromRGB(255, 100, 0),
        Spawns = { "Hot and Cold", "Kitsune Island" },
        Quest = "Do a quest",
        ZAbility = "Fire Pillar",
        XAbility = "Fire Pillar Blast",
        CAbility = "Fire Pillar Explosion",
        VAbility = "Dragon Transformation",
        FAbility = "Dragon Flight",
    },
    ["Leopard"] = {
        Rarity = "Legendary",
        Price = 5000000,
        Fragment = 0,
        Damage = 260,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(255, 200, 0),
        Spawns = { "Prehistoric Island" },
        ZAbility = "Leopard Claws",
        XAbility = "Leopard Rush",
        CAbility = "Leopard Spike",
        VAbility = "Leopard Transformation",
        FAbility = "Leopard Leap",
    },
    ["Kitsune"] = {
        Rarity = "Legendary",
        Price = 4000000,
        Fragment = 0,
        Damage = 250,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(100, 150, 255),
        Spawns = { "Kitsune Island" },
        ZAbility = "Kitsune Rush",
        XAbility = "Kitsune Blaze",
        CAbility = "Kitsune Snare",
        VAbility = "Kitsune Transformation",
        FAbility = "Kitsune Sprint",
    },
    ["Dough"] = {
        Rarity = "Legendary",
        Price = 2800000,
        Fragment = 0,
        Damage = 200,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 220, 180),
        Spawns = { "Hot and Cold" },
        ZAbility = "Dough Fist",
        XAbility = "Dough Roller",
        CAbility = "Dough Slam",
        VAbility = "Dough Vortex",
        FAbility = "Dough Flight",
    },
    ["Buddha"] = {
        Rarity = "Legendary",
        Price = 1200000,
        Fragment = 0,
        Damage = 180,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 215, 0),
        Spawns = { "Hot and Cold", "Graveyard" },
        ZAbility = "Buddha Punch",
        XAbility = "Buddha Slam",
        CAbility = "Buddha Smash",
        VAbility = "Buddha Transformation",
        FAbility = "Buddha Leap",
    },
    ["Venom"] = {
        Rarity = "Legendary",
        Price = 3000000,
        Fragment = 0,
        Damage = 220,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(0, 200, 0),
        Spawns = { "Hot and Cold" },
        ZAbility = "Venom Shot",
        XAbility = "Venom Cloud",
        CAbility = "Venom Rain",
        VAbility = "Venom Transformation",
        FAbility = "Venom Flight",
    },
    ["Control"] = {
        Rarity = "Legendary",
        Price = 2500000,
        Fragment = 0,
        Damage = 210,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(150, 0, 200),
        Spawns = { "Hot and Cold" },
        ZAbility = "Control Punch",
        XAbility = "Control Room",
        CAbility = "Control Swap",
        VAbility = "Control: Dest",
        FAbility = "Control Flight",
    },
    ["Shadow"] = {
        Rarity = "Legendary",
        Price = 1800000,
        Fragment = 0,
        Damage = 190,
        Mastery = {0, 0},
        Element = "Dark",
        Type = "Natural",
        Color = Color3.fromRGB(80, 0, 120),
        Spawns = { "Hot and Cold" },
        ZAbility = "Shadow Tendrils",
        XAbility = "Shadow Assault",
        CAbility = "Shadow Empower",
        VAbility = "Shadow Possession",
        FAbility = "Shadow Vanish",
    },
    ["T-Rex"] = {
        Rarity = "Legendary",
        Price = 3200000,
        Fragment = 0,
        Damage = 225,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(139, 69, 19),
        Spawns = { "Prehistoric Island" },
        ZAbility = "T-Rex Bite",
        XAbility = "T-Rex Tail",
        CAbility = "T-Rex Rush",
        VAbility = "T-Rex Transformation",
        FAbility = "T-Rex Leap",
    },
    ["Mammoth"] = {
        Rarity = "Legendary",
        Price = 3100000,
        Fragment = 0,
        Damage = 215,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(120, 120, 140),
        Spawns = { "Prehistoric Island" },
        ZAbility = "Mammoth Stomp",
        XAbility = "Mammoth Tusk",
        CAbility = "Mammoth Charge",
        VAbility = "Mammoth Transformation",
        FAbility = "Mammoth Rush",
    },
    ["Blizzard"] = {
        Rarity = "Legendary",
        Price = 1600000,
        Fragment = 0,
        Damage = 170,
        Mastery = {0, 0},
        Element = "Ice",
        Type = "Natural",
        Color = Color3.fromRGB(200, 230, 255),
        Spawns = { "Frozen Village", "Snow Mountain" },
        ZAbility = "Blizzard Shards",
        XAbility = "Blizzard Breath",
        CAbility = "Blizzard Ice",
        VAbility = "Blizzard Storm",
        FAbility = "Blizzard Glide",
    },

    -- ─── Mythical ───
    ["Spirit"] = {
        Rarity = "Mythical",
        Price = 3400000,
        Fragment = 0,
        Damage = 240,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(200, 100, 255),
        Spawns = { "Mirage Island" },
        ZAbility = "Spirit Punch",
        XAbility = "Spirit Orb",
        CAbility = "Spirit Beam",
        VAbility = "Spirit Possession",
        FAbility = "Spirit Flight",
    },
    ["Love"] = {
        Rarity = "Mythical",
        Price = 1500000,
        Fragment = 0,
        Damage = 160,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 105, 180),
        Spawns = { "Tiki Outpost" },
        ZAbility = "Love Shot",
        XAbility = "Love Heart",
        CAbility = "Love Shower",
        VAbility = "Love Transformation",
        FAbility = "Love Flight",
    },

    -- ─── Rare ───
    ["Sound"] = {
        Rarity = "Rare",
        Price = 800000,
        Fragment = 0,
        Damage = 140,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 100, 100),
        Spawns = { "Tiki Outpost" },
        ZAbility = "Sound Blast",
        XAbility = "Sound Wave",
        CAbility = "Sound Burst",
        VAbility = "Sound Symphony",
        FAbility = "Sound Dash",
    },
    ["Spider"] = {
        Rarity = "Rare",
        Price = 750000,
        Fragment = 0,
        Damage = 135,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(80, 80, 80),
        Spawns = { "Cursed Ship" },
        ZAbility = "Spider Web",
        XAbility = "Spider Shots",
        CAbility = "Spider Swing",
        VAbility = "Spider Transformation",
        FAbility = "Spider String",
    },
    ["Phoenix"] = {
        Rarity = "Rare",
        Price = 1000000,
        Fragment = 0,
        Damage = 150,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(0, 150, 255),
        Spawns = { "Hot and Cold" },
        ZAbility = "Phoenix Shot",
        XAbility = "Phoenix Assault",
        CAbility = "Phoenix Regeneration",
        VAbility = "Phoenix Transformation",
        FAbility = "Phoenix Flight",
    },
    ["Ghost"] = {
        Rarity = "Rare",
        Price = 620000,
        Fragment = 0,
        Damage = 125,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(200, 200, 255),
        Spawns = { "Cursed Ship" },
        ZAbility = "Ghostly Chop",
        XAbility = "Ghostly Scream",
        CAbility = "Possession",
        VAbility = "Ghostly form",
        FAbility = "Ghost Float",
    },
    ["Gas"] = {
        Rarity = "Rare",
        Price = 550000,
        Fragment = 0,
        Damage = 120,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(100, 200, 100),
        Spawns = { "Hot and Cold" },
        ZAbility = "Gas Release",
        XAbility = "Gas Explosion",
        CAbility = "Gas Cloud",
        VAbility = "Gas Transformation",
        FAbility = "Gas Flight",
    },

    -- ─── Uncommon ───
    ["Rubber"] = {
        Rarity = "Uncommon",
        Price = 75000,
        Fragment = 0,
        Damage = 60,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 100, 100),
        Spawns = { "Jungle", "Marine Fortress" },
    },
    ["Light"] = {
        Rarity = "Uncommon",
        Price = 650000,
        Fragment = 0,
        Damage = 120,
        Mastery = {0, 0},
        Element = "Light",
        Type = "Natural",
        Color = Color3.fromRGB(255, 255, 200),
        Spawns = { "Hot and Cold" },
    },
    ["Dark"] = {
        Rarity = "Uncommon",
        Price = 500000,
        Fragment = 0,
        Damage = 115,
        Mastery = {0, 0},
        Element = "Dark",
        Type = "Natural",
        Color = Color3.fromRGB(30, 0, 60),
        Spawns = { "Hot and Cold" },
    },
    ["Flame"] = {
        Rarity = "Uncommon",
        Price = 250000,
        Fragment = 0,
        Damage = 90,
        Mastery = {0, 0},
        Element = "Fire",
        Type = "Natural",
        Color = Color3.fromRGB(255, 100, 0),
        Spawns = { "Magma Village", "Hot and Cold" },
    },
    ["Ice"] = {
        Rarity = "Uncommon",
        Price = 350000,
        Fragment = 0,
        Damage = 100,
        Mastery = {0, 0},
        Element = "Ice",
        Type = "Natural",
        Color = Color3.fromRGB(150, 200, 255),
        Spawns = { "Frozen Village", "Hot and Cold" },
    },
    ["Magma"] = {
        Rarity = "Uncommon",
        Price = 300000,
        Fragment = 0,
        Damage = 95,
        Mastery = {0, 0},
        Element = "Fire",
        Type = "Natural",
        Color = Color3.fromRGB(255, 80, 0),
        Spawns = { "Magma Village", "Hot and Cold" },
    },
    ["Quake"] = {
        Rarity = "Uncommon",
        Price = 750000,
        Fragment = 0,
        Damage = 130,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(200, 200, 200),
        Spawns = { "Hot and Cold" },
    },
    ["Rumble"] = {
        Rarity = "Uncommon",
        Price = 650000,
        Fragment = 0,
        Damage = 120,
        Mastery = {0, 0},
        Element = "Electric",
        Type = "Natural",
        Color = Color3.fromRGB(0, 150, 255),
        Spawns = { "Hot and Cold" },
    },
    ["String"] = {
        Rarity = "Uncommon",
        Price = 600000,
        Fragment = 0,
        Damage = 115,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(255, 255, 255),
        Spawns = { "Hot and Cold" },
    },

    -- ─── Common ───
    ["Bomb"] = {
        Rarity = "Common",
        Price = 80000,
        Fragment = 0,
        Damage = 45,
        Mastery = {0, 0},
        Element = "Bomb",
        Type = "Natural",
        Color = Color3.fromRGB(100, 100, 100),
        Spawns = { "Starter Island", "Jungle", "Marine Fortress" },
    },
    ["Spike"] = {
        Rarity = "Common",
        Price = 75000,
        Fragment = 0,
        Damage = 40,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(150, 150, 150),
        Spawns = { "Starter Island", "Jungle", "Marine Fortress" },
    },
    ["Smoke"] = {
        Rarity = "Common",
        Price = 100000,
        Fragment = 0,
        Damage = 50,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(180, 180, 180),
        Spawns = { "Starter Island", "Jungle", "Marine Fortress" },
    },
    ["Spring"] = {
        Rarity = "Common",
        Price = 60000,
        Fragment = 0,
        Damage = 35,
        Mastery = {0, 0},
        Element = "Natural",
        Type = "Natural",
        Color = Color3.fromRGB(0, 200, 0),
        Spawns = { "Starter Island", "Jungle" },
    },
    ["Falcon"] = {
        Rarity = "Common",
        Price = 300000,
        Fragment = 0,
        Damage = 65,
        Mastery = {0, 0},
        Element = "Beast",
        Type = "Zoan",
        Color = Color3.fromRGB(139, 90, 43),
        Spawns = { "Starter Island", "Marine Fortress" },
    },
}

-- ═══════════════════════════════════════════
-- RARITY ORDER
-- ═══════════════════════════════════════════
Fruits.RarityOrder = {
    "Mythical",
    "Legendary",
    "Rare",
    "Uncommon",
    "Common",
}

Fruits.RarityColors = {
    Mythical = Color3.fromRGB(200, 100, 255),
    Legendary = Color3.fromRGB(255, 165, 0),
    Rare = Color3.fromRGB(0, 150, 255),
    Uncommon = Color3.fromRGB(0, 200, 0),
    Common = Color3.fromRGB(180, 180, 180),
}

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
function Fruits:GetByName(name)
    return self.Database[name]
end

function Fruits:GetByRarity(rarity)
    local result = {}
    for name, data in pairs(self.Database) do
        if data.Rarity == rarity then
            result[name] = data
        end
    end
    return result
end

function Fruits:GetLegendaryAndAbove()
    local result = {}
    for name, data in pairs(self.Database) do
        if data.Rarity == "Legendary" or data.Rarity == "Mythical" then
            result[name] = data
        end
    end
    return result
end

function Fruits:GetSortedByPrice()
    local sorted = {}
    for name, data in pairs(self.Database) do
        table.insert(sorted, { Name = name, Price = data.Price, Rarity = data.Rarity })
    end
    table.sort(sorted, function(a, b) return a.Price > b.Price end)
    return sorted
end

function Fruits:GetFruitNames()
    local names = {}
    for name in pairs(self.Database) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function Fruits:GetPlayerFruits(player)
    -- Placeholder: in-game detection
    local fruits = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local fruitData = self.Database[item.Name]
                if fruitData then
                    table.insert(fruits, {
                        Name = item.Name,
                        Data = fruitData,
                        Tool = item,
                    })
                end
            end
        end
    end
    return fruits
end

return Fruits