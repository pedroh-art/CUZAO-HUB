--[[
    CUZAO HUB - Weapons Data
    Dados de espadas, armas de fogo e estilos de luta
]]

local Weapons = {}

-- ═══════════════════════════════════════════
-- SWORDS
-- ═══════════════════════════════════════════
Weapons.Swords = {
    -- Legendary
    ["Shark Anchor"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 280,
        Source = "Tiki Outpost",
        Color = Color3.fromRGB(0, 200, 255),
    },
    ["Cursed Dual Katana"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 270,
        Source = "Cursed Ship",
        Color = Color3.fromRGB(100, 0, 150),
    },
    ["Dark Blade"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 260,
        Source = "Gamepass / Admin",
        Color = Color3.fromRGB(0, 0, 0),
    },
    ["Mink Cobra"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 250,
        Source = "Kitsune Island",
        Color = Color3.fromRGB(0, 150, 100),
    },
    ["True Triple Katana"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 245,
        Source = "Boss Drop",
        Color = Color3.fromRGB(255, 0, 0),
    },
    ["Yama"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 240,
        Source = "Tablo Quest",
        Color = Color3.fromRGB(200, 50, 50),
    },
    ["Tushita"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 240,
        Source = "Tablo Quest",
        Color = Color3.fromRGB(255, 255, 100),
    },
    ["Buddy Sword"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 230,
        Source = "Cake Prince",
        Color = Color3.fromRGB(255, 150, 200),
    },
    ["Canvander"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 225,
        Source = "Dragon Dojo",
        Color = Color3.fromRGB(200, 100, 0),
    },
    ["Spikey Trident"] = {
        Rarity = "Legendary",
        Type = "Sword",
        Damage = 220,
        Source = "Leviathan",
        Color = Color3.fromRGB(0, 100, 200),
    },

    -- Rare
    ["Soul Guitar"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 210,
        Source = "Cursed Ship",
        Color = Color3.fromRGB(200, 200, 200),
    },
    ["Gravity Blade"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 200,
        Source = "Boss Drop",
        Color = Color3.fromRGB(100, 0, 200),
    },
    ["Pirate Captain's Blade"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 190,
        Source = "Hydra Island",
        Color = Color3.fromRGB(150, 0, 0),
    },
    ["Midnight Blade"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 180,
        Source = "Raid Drop",
        Color = Color3.fromRGB(50, 0, 80),
    },
    ["Bisento"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 175,
        Source = "New World",
        Color = Color3.fromRGB(200, 200, 255),
    },
    ["Shisui"] = {
        Rarity = "Rare",
        Type = "Sword",
        Damage = 170,
        Source = "Boss Drop",
        Color = Color3.fromRGB(255, 50, 0),
    },

    -- Uncommon
    ["Saber"] = {
        Rarity = "Uncommon",
        Type = "Sword",
        Damage = 120,
        Source = "Jungle Quest",
        Color = Color3.fromRGB(200, 200, 200),
    },
    ["Longsword"] = {
        Rarity = "Uncommon",
        Type = "Sword",
        Damage = 100,
        Source = "Sword Dealer",
        Color = Color3.fromRGB(180, 180, 180),
    },
    ["Katana"] = {
        Rarity = "Uncommon",
        Type = "Sword",
        Damage = 90,
        Source = "Sword Dealer",
        Color = Color3.fromRGB(170, 170, 170),
    },
    ["Cutlass"] = {
        Rarity = "Common",
        Type = "Sword",
        Damage = 50,
        Source = "Sword Dealer",
        Color = Color3.fromRGB(160, 160, 160),
    },
    ["Dual Katana"] = {
        Rarity = "Common",
        Type = "Sword",
        Damage = 45,
        Source = "Sword Dealer",
        Color = Color3.fromRGB(150, 150, 150),
    },
    ["Iron Mace"] = {
        Rarity = "Common",
        Type = "Sword",
        Damage = 40,
        Source = "Sword Dealer",
        Color = Color3.fromRGB(140, 140, 140),
    },
}

-- ═══════════════════════════════════════════
-- GUNS
-- ═══════════════════════════════════════════
Weapons.Guns = {
    ["Soul Guitar"] = {
        Rarity = "Legendary",
        Type = "Gun",
        Damage = 200,
        Source = "Cursed Ship",
        Color = Color3.fromRGB(200, 200, 200),
    },
    ["Kabucha"] = {
        Rarity = "Rare",
        Type = "Gun",
        Damage = 180,
        Source = "Sea Event",
        Color = Color3.fromRGB(200, 150, 50),
    },
    ["Acidum Rifle"] = {
        Rarity = "Rare",
        Type = "Gun",
        Damage = 160,
        Source = "Boss Drop",
        Color = Color3.fromRGB(0, 200, 100),
    },
    ["Bazooka"] = {
        Rarity = "Uncommon",
        Type = "Gun",
        Damage = 130,
        Source = "Gun Dealer",
        Color = Color3.fromRGB(100, 100, 100),
    },
    ["Musket"] = {
        Rarity = "Uncommon",
        Type = "Gun",
        Damage = 100,
        Source = "Gun Dealer",
        Color = Color3.fromRGB(150, 100, 50),
    },
    ["Flintlock"] = {
        Rarity = "Common",
        Type = "Gun",
        Damage = 60,
        Source = "Gun Dealer",
        Color = Color3.fromRGB(120, 120, 120),
    },
    ["Slingshot"] = {
        Rarity = "Common",
        Type = "Gun",
        Damage = 30,
        Source = "Gun Dealer",
        Color = Color3.fromRGB(139, 90, 43),
    },
}

-- ═══════════════════════════════════════════
-- FIGHTING STYLES
-- ═══════════════════════════════════════════
Weapons.FightingStyles = {
    ["Godhuman"] = {
        Rarity = "Legendary",
        Type = "FightingStyle",
        Damage = 250,
        Source = "Dragon Dojo",
        Color = Color3.fromRGB(255, 215, 0),
    },
    ["Sanguine Art"] = {
        Rarity = "Legendary",
        Type = "FightingStyle",
        Damage = 240,
        Source = "Leviathan",
        Color = Color3.fromRGB(200, 0, 0),
    },
    ["Sharkman Karate"] = {
        Rarity = "Rare",
        Type = "FightingStyle",
        Damage = 180,
        Source = "Fishman",
        Color = Color3.fromRGB(0, 150, 200),
    },
    ["Electric Claw"] = {
        Rarity = "Rare",
        Type = "FightingStyle",
        Damage = 170,
        Source = "Raid",
        Color = Color3.fromRGB(0, 150, 255),
    },
    ["Dragon Talon"] = {
        Rarity = "Rare",
        Type = "FightingStyle",
        Damage = 160,
        Source = "Dragon Talon Sage",
        Color = Color3.fromRGB(255, 100, 0),
    },
    ["Death Step"] = {
        Rarity = "Rare",
        Type = "FightingStyle",
        Damage = 150,
        Source = "Frozen Village",
        Color = Color3.fromRGB(0, 0, 0),
    },
    ["Superhuman"] = {
        Rarity = "Rare",
        Type = "FightingStyle",
        Damage = 140,
        Source = "Forgotten Island",
        Color = Color3.fromRGB(255, 255, 255),
    },
    ["Dark Step"] = {
        Rarity = "Uncommon",
        Type = "FightingStyle",
        Damage = 110,
        Source = "Underwater City",
        Color = Color3.fromRGB(50, 0, 80),
    },
    ["Water Kung Fu"] = {
        Rarity = "Uncommon",
        Type = "FightingStyle",
        Damage = 100,
        Source = "Underwater City",
        Color = Color3.fromRGB(0, 100, 200),
    },
    ["Ken Hop"] = {
        Rarity = "Common",
        Type = "FightingStyle",
        Damage = 50,
        Source = "Auto",
        Color = Color3.fromRGB(180, 180, 180),
    },
}

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
function Weapons:GetAllSwords()
    return self.Swords
end

function Weapons:GetAllGuns()
    return self.Guns
end

function Weapons:GetAllFightingStyles()
    return self.FightingStyles
end

function Weapons:GetWeaponByName(name)
    return self.Swords[name] or self.Guns[name] or self.FightingStyles[name]
end

function Weapons:GetWeaponsByRarity(rarity)
    local result = {}
    for category, data in pairs({Swords = self.Swords, Guns = self.Guns, FightingStyles = self.FightingStyles}) do
        for name, info in pairs(data) do
            if info.Rarity == rarity then
                result[name] = info
            end
        end
    end
    return result
end

function Weapons:SortByDamage(weaponTable)
    local sorted = {}
    for name, data in pairs(weaponTable) do
        table.insert(sorted, { Name = name, Damage = data.Damage, Rarity = data.Rarity })
    end
    table.sort(sorted, function(a, b) return a.Damage > b.Damage end)
    return sorted
end

return Weapons