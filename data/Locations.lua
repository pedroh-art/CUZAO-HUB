--[[
    CUZAO HUB - Locations Data
    Coordenadas de todas ilhas, NPCs e pontos de interesse
    Blox Fruits (1st Sea, 2nd Sea, 3rd Sea)
]]

local Locations = {}

-- ═══════════════════════════════════════════
-- FIRST SEA ISLANDS
-- ═══════════════════════════════════════════
Locations.Sea1 = {
    ["Starter Island"] = {
        Position = Vector3.new(1061, 16, 1445),
        Level = {1, 19},
        NPCs = {
            ["Quest Giver"] = Vector3.new(1061, 16, 1445),
            ["Sword Dealer"] = Vector3.new(1050, 16, 1440),
        },
        Mobs = {
            { Name = "Bandit", Level = 5, Position = Vector3.new(1097, 16, 1495) },
            { Name = "Monkey", Level = 12, Position = Vector3.new(-1602, 36, 149) },
            { Name = "Gorilla", Level = 20, Position = Vector3.new(-1624, 36, 145) },
        },
    },
    ["Marine Fortress"] = {
        Position = Vector3.new(-4505, 20, 4260),
        Level = {20, 59},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-4505, 20, 4260),
            ["Blox Fruit Dealer"] = Vector3.new(-434, 73, 334),
        },
        Mobs = {
            { Name = "Trainee", Level = 22, Position = Vector3.new(-4500, 20, 4260) },
            { Name = "Blue Chef", Level = 35, Position = Vector3.new(-4480, 20, 4280) },
            { Name = "Shark", Level = 45, Position = Vector3.new(-4500, 15, 4300) },
        },
    },
    ["Jungle"] = {
        Position = Vector3.new(-1612, 36, 149),
        Level = {15, 59},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-1612, 36, 149),
            ["Sword Dealer"] = Vector3.new(-1620, 36, 150),
        },
        Mobs = {
            { Name = "Monkey", Level = 12, Position = Vector3.new(-1602, 36, 149) },
            { Name = "Gorilla", Level = 20, Position = Vector3.new(-1624, 36, 145) },
        },
    },
    ["Pirate Village"] = {
        Position = Vector3.new(-1131, 4, 3828),
        Level = {30, 59},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-1131, 4, 3828),
            ["Blox Fruit Dealer"] = Vector3.new(-434, 73, 334),
        },
        Mobs = {
            { Name = "Pirate", Level = 30, Position = Vector3.new(-1120, 4, 3830) },
            { Name = "Gambler", Level = 40, Position = Vector3.new(-1100, 4, 3850) },
        },
    },
    ["Desert"] = {
        Position = Vector3.new(944, 6, 4373),
        Level = {60, 89},
        NPCs = {
            ["Quest Giver"] = Vector3.new(944, 6, 4373),
            ["Alchemist"] = Vector3.new(950, 6, 4380),
        },
        Mobs = {
            { Name = "Desert Bandit", Level = 60, Position = Vector3.new(940, 6, 4370) },
            { Name = "Desert Officer", Level = 75, Position = Vector3.new(935, 6, 4375) },
        },
    },
    ["Frozen Village"] = {
        Position = Vector3.new(1384, 87, -1298),
        Level = {90, 129},
        NPCs = {
            ["Quest Giver"] = Vector3.new(1384, 87, -1298),
            ["Sword Dealer"] = Vector3.new(1390, 87, -1300),
        },
        Mobs = {
            { Name = "Snow Bandit", Level = 90, Position = Vector3.new(1380, 87, -1295) },
            { Name = "Snowman", Level = 100, Position = Vector3.new(1375, 87, -1300) },
        },
    },
    ["Marine Fortress (2)"] = {
        Position = Vector3.new(-4505, 20, 4260),
        Level = {100, 149},
        Mobs = {
            { Name = "Elite Pirate", Level = 120, Position = Vector3.new(-4500, 20, 4260) },
        },
    },
    ["Skylands"] = {
        Position = Vector3.new(-4968, 717, -2623),
        Level = {110, 149},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-4968, 717, -2623),
        },
        Mobs = {
            { Name = "Sky Bandit", Level = 110, Position = Vector3.new(-4970, 717, -2620) },
        },
    },
    ["Prison"] = {
        Position = Vector3.new(4875, 5, 734),
        Level = {150, 189},
        NPCs = {
            ["Quest Giver"] = Vector3.new(4875, 5, 734),
        },
        Mobs = {
            { Name = "Prisoner", Level = 150, Position = Vector3.new(4880, 5, 730) },
            { Name = "Chief Warden", Level = 170, Position = Vector3.new(4870, 5, 740) },
        },
    },
    ["Colosseum"] = {
        Position = Vector3.new(-1576, 7, -2983),
        Level = {170, 219},
        Mobs = {
            { Name = "Gladiator", Level = 170, Position = Vector3.new(-1580, 7, -2980) },
        },
    },
    ["Magma Village"] = {
        Position = Vector3.new(-5247, 12, 8534),
        Level = {210, 259},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-5247, 12, 8534),
        },
        Mobs = {
            { Name = "Magma Tribe", Level = 210, Position = Vector3.new(-5245, 12, 8530) },
            { Name = "Military Soldier", Level = 230, Position = Vector3.new(-5250, 12, 8540) },
        },
    },
    ["Underwater City"] = {
        Position = Vector3.new(61163, 11, 1819),
        Level = {300, 374},
        Mobs = {
            { Name = "Fishman", Level = 300, Position = Vector3.new(61160, 11, 1815) },
            { Name = "Deep Sea", Level = 325, Position = Vector3.new(61165, 11, 1820) },
        },
    },
    ["Fountain City"] = {
        Position = Vector3.new(5256, 39, 4050),
        Level = {375, 449},
        Mobs = {
            { Name = "Shanda", Level = 375, Position = Vector3.new(5260, 39, 4055) },
            { Name = "Royal Squad", Level = 400, Position = Vector3.new(5250, 39, 4045) },
        },
    },
    ["Forgotten Island"] = {
        Position = Vector3.new(-3032, 240, -10172),
        Level = {450, 524},
        Mobs = {
            { Name = "Has-Been Hero", Level = 450, Position = Vector3.new(-3030, 240, -10170) },
        },
    },
    ["Usopp's Island"] = {
        Position = Vector3.new(-4562, 20, 4370),
        Level = {450, 524},
        Mobs = {
            { Name = "Cookie Crafter", Level = 450, Position = Vector3.new(-4560, 20, 4365) },
        },
    },
    ["Hot and Cold"] = {
        Position = Vector3.new(61163, 11, 1819),
        Level = {525, 600},
        Mobs = {
            { Name = "Don Swan", Level = 525, Position = Vector3.new(61160, 11, 1815) },
        },
    },
}

-- ═══════════════════════════════════════════
-- SECOND SEA ISLANDS
-- ═══════════════════════════════════════════
Locations.Sea2 = {
    ["Kingdom of Rose"] = {
        Position = Vector3.new(-379, 36, 5594),
        Level = {700, 849},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-379, 36, 5594),
            ["Blox Fruit Dealer"] = Vector3.new(-385, 73, -2100),
        },
        Mobs = {
            { Name = "Raider", Level = 700, Position = Vector3.new(-380, 36, 5590) },
            { Name = "Mercenary", Level = 725, Position = Vector3.new(-375, 36, 5600) },
        },
    },
    ["Green Zone"] = {
        Position = Vector3.new(-2373, 25, -3221),
        Level = {850, 999},
        Mobs = {
            { Name = "Marine Lieutenant", Level = 850, Position = Vector3.new(-2370, 25, -3218) },
            { Name = "Marine Captain", Level = 900, Position = Vector3.new(-2375, 25, -3225) },
        },
    },
    ["Graveyard"] = {
        Position = Vector3.new(-5370, 19, -792),
        Level = {1000, 1149},
        Mobs = {
            { Name = "Reborn Skeleton", Level = 1000, Position = Vector3.new(-5370, 19, -790) },
        },
    },
    ["Snow Mountain"] = {
        Position = Vector3.new(647, 400, -13000),
        Level = {1150, 1299},
        Mobs = {
            { Name = "Yeti", Level = 1150, Position = Vector3.new(645, 400, -13000) },
        },
    },
    ["Hot and Cold (2)"] = {
        Position = Vector3.new(6540, 50, -13100),
        Level = {1200, 1349},
        Mobs = {
            { Name = "Magma Admiral", Level = 1250, Position = Vector3.new(6540, 50, -13100) },
        },
    },
    ["Cursed Ship"] = {
        Position = Vector3.new(923, 125, 32800),
        Level = {1450, 1549},
        Mobs = {
            { Name = "Ghost", Level = 1450, Position = Vector3.new(920, 125, 32800) },
            { Name = "Ship Officer", Level = 1500, Position = Vector3.new(925, 125, 32810) },
        },
    },
    ["Last Sea"] = {
        Position = Vector3.new(-13400, 900, 2750),
        Level = {1550, 1700},
        Mobs = {
            { Name = "Forest Pirate", Level = 1550, Position = Vector3.new(-13400, 900, 2750) },
        },
    },
}

-- ═══════════════════════════════════════════
-- THIRD SEA ISLANDS
-- ═══════════════════════════════════════════
Locations.Sea3 = {
    ["Port Town"] = {
        Position = Vector3.new(-290, 44, 5590),
        Level = {1700, 1849},
        NPCs = {
            ["Quest Giver"] = Vector3.new(-290, 44, 5590),
        },
        Mobs = {
            { Name = "Raider", Level = 1700, Position = Vector3.new(-290, 44, 5590) },
        },
    },
    ["Hydra Island"] = {
        Position = Vector3.new(5746, 610, -253),
        Level = {1850, 1999},
        Mobs = {
            { Name = "Dragon Crew", Level = 1850, Position = Vector3.new(5746, 610, -253) },
            { Name = "Hydra Enforcer", Level = 1900, Position = Vector3.new(5750, 610, -250) },
        },
    },
    ["Great Tree"] = {
        Position = Vector3.new(2681, 1682, -7190),
        Level = {1950, 2100},
        Mobs = {
            { Name = "Has-Been Hero", Level = 1950, Position = Vector3.new(2681, 1682, -7190) },
        },
    },
    ["Tiki Outpost"] = {
        Position = Vector3.new(-16400, 350, -500),
        Level = {2100, 2250},
        Mobs = {
            { Name = "Island Empress", Level = 2100, Position = Vector3.new(-16400, 350, -500) },
        },
    },
    ["Kitsune Island"] = {
        Position = Vector3.new(-1598, 245, -1254),
        Level = {2250, 2400},
        Mobs = {
            { Name = "Kitsune", Level = 2250, Position = Vector3.new(-1598, 245, -1254) },
        },
    },
    ["Prehistoric Island"] = {
        Position = Vector3.new(-11645, 334, -9725),
        Level = {2400, 2550},
        Mobs = {
            { Name = "Dinosaur", Level = 2400, Position = Vector3.new(-11645, 334, -9725) },
        },
    },
    ["Mirage Island"] = {
        Position = Vector3.new(-6653, 259, -2231),
        Level = {2550, 2700},
        Mobs = {
            { Name = "Mirage Guardian", Level = 2550, Position = Vector3.new(-6653, 259, -2231) },
        },
    },
}

-- ═══════════════════════════════════════════
-- KEY NPCs (all seas)
-- ═══════════════════════════════════════════
Locations.NPCs = {
    ["Blox Fruit Dealer"] = Vector3.new(-434, 73, 334),
    ["Blox Fruit Dealer Cousin"] = Vector3.new(-434, 73, 334),
    ["Awakening Expert"] = Vector3.new(-12463, 333, -9970),
    ["Blacksmith"] = Vector3.new(-12463, 333, -9970),
    ["Sword Dealer"] = Vector3.new(-12463, 333, -9970),
    ["Gun Dealer"] = Vector3.new(-12463, 333, -9970),
    ["Haki Trainer"] = Vector3.new(1075, 16, 1445),
    ["Fighting Style Teacher"] = Vector3.new(1075, 16, 1445),
    ["Title Hunter"] = Vector3.new(-1075, 30, 1675),
    ["Bartilo"] = Vector3.new(-385, 73, -2100),
    ["Mysterious Dealer"] = Vector3.new(-12463, 333, -9970),
    ["Law Raid"] = Vector3.new(5410, 20, 4060),
    ["Factory Core"] = Vector3.new(5410, 20, 4060),
}

-- ═══════════════════════════════════════════
-- FRUIT SPAWNS
-- ═══════════════════════════════════════════
Locations.FruitSpawns = {
    { Position = Vector3.new(-223, 15, 352), Name = "Spawn 1" },
    { Position = Vector3.new(-1243, 10, -2244), Name = "Spawn 2" },
    { Position = Vector3.new(-518, 10, -2726), Name = "Spawn 3" },
    { Position = Vector3.new(-1373, 10, -1110), Name = "Spawn 4" },
    { Position = Vector3.new(42, 10, -808), Name = "Spawn 5" },
    { Position = Vector3.new(1298, 10, -389), Name = "Spawn 6" },
    { Position = Vector3.new(-3278, 10, -2682), Name = "Spawn 7" },
    { Position = Vector3.new(3866, 10, 698), Name = "Spawn 8" },
    { Position = Vector3.new(-2893, 10, -846), Name = "Spawn 9" },
    { Position = Vector3.new(1169, 10, -585), Name = "Spawn 10" },
    { Position = Vector3.new(1761, 10, 208), Name = "Spawn 11" },
    { Position = Vector3.new(3532, 10, 3671), Name = "Spawn 12" },
    { Position = Vector3.new(-614, 10, 1810), Name = "Spawn 13" },
    { Position = Vector3.new(-2190, 10, -1629), Name = "Spawn 14" },
    { Position = Vector3.new(187, 10, 4692), Name = "Spawn 15" },
}

-- ═══════════════════════════════════════════
-- SEA DETECTION
-- ═══════════════════════════════════════════

-- Place IDs of each sea
local SeaPlaceIds = {
    [2753915549] = 1,  -- Blox Fruits 1st Sea
    [4442272183] = 2,  -- Blox Fruits 2nd Sea
    [7449423635] = 3,  -- Blox Fruits 3rd Sea
}

-- Detected sea (cached after first call)
Locations._DetectedSea = nil

--[[
    Detecta automaticamente em qual Sea o jogador está
    Baseado no PlaceId do jogo atual
    Retorna: 1, 2 ou 3
]]
function Locations:GetCurrentSea()
    if self._DetectedSea then
        return self._DetectedSea
    end

    local placeId = game.PlaceId
    local sea = SeaPlaceIds[placeId]

    if not sea then
        -- Fallback: tentar detectar por posición/nome
        sea = self:DetectSeaByPosition()
    end

    self._DetectedSea = sea or 1
    return self._DetectedSea
end

--[[
    Detecção alternativa por posição do jogador
    Usado quando o PlaceId não é reconhecido
]]
function Locations:DetectSeaByPosition()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player or not player.Character then return 1 end

    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 1 end

    local pos = rootPart.Position

    -- Sea 3: áreas com Y > 1000 ou X < -10000
    if pos.X < -10000 or pos.Y > 2000 then
        return 3
    end

    -- Sea 2: áreas com X entre -1000 e 1000, Z > 5000
    if pos.Z > 5000 and math.abs(pos.X) < 2000 then
        return 2
    end

    -- Default: Sea 1
    return 1
end

--[[
    Retorna o nome do Sea como string
]]
function Locations:GetCurrentSeaName()
    local sea = self:GetCurrentSea()
    local names = {
        [1] = "First Sea",
        [2] = "Second Sea",
        [3] = "Third Sea",
    }
    return names[sea] or "Unknown"
end

--[[
    Retorna as ilhas do Sea atual
]]
function Locations:GetCurrentSeaIslands()
    local sea = self:GetCurrentSea()
    return self:GetIslands(sea)
end

--[[
    Retorna a lista de nomes das ilhas do Sea atual
]]
function Locations:GetCurrentIslandNames()
    local islands = self:GetCurrentSeaIslands()
    local names = {}
    for name in pairs(islands) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--[[
    Força uma detecção de sea (útil para testes)
]]
function Locations:SetSea(sea)
    if sea >= 1 and sea <= 3 then
        self._DetectedSea = sea
        return true
    end
    return false
end

--[[
    Limpa o cache de detecção (força nova detecção)
]]
function Locations:ClearSeaCache()
    self._DetectedSea = nil
end

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
function Locations:GetIslands(season)
    if season == 1 then return self.Sea1
    elseif season == 2 then return self.Sea2
    elseif season == 3 then return self.Sea3
    else
        local all = {}
        for k, v in pairs(self.Sea1) do all[k] = v end
        for k, v in pairs(self.Sea2) do all[k] = v end
        for k, v in pairs(self.Sea3) do all[k] = v end
        return all
    end
end

function Locations:GetNearestIsland(position, season)
    local islands = self:GetIslands(season)
    local nearest = nil
    local minDist = math.huge

    for name, data in pairs(islands) do
        local dist = (data.Position - position).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = { Name = name, Distance = dist, Data = data }
        end
    end

    return nearest
end

function Locations:GetMobsForLevel(level)
    local mobs = {}
    for _, season in ipairs({self.Sea1, self.Sea2, self.Sea3}) do
        for _, island in pairs(season) do
            if island.Mobs then
                for _, mob in ipairs(island.Mobs) do
                    if mob.Level and level >= mob.Level - 20 and level <= mob.Level + 20 then
                        table.insert(mobs, mob)
                    end
                end
            end
        end
    end
    return mobs
end

function Locations:GetBestFarmIsland(level)
    for _, season in ipairs({self.Sea1, self.Sea2, self.Sea3}) do
        for name, island in pairs(season) do
            if island.Level and level >= island.Level[1] and level <= island.Level[2] then
                return name, island
            end
        end
    end
    return nil, nil
end

return Locations