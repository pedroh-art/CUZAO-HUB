--[[
    CUZAO HUB - Inventory Module
    Gestão de inventário, itens, frutas, armas
]]

local Inventory = {}

-- Serviços
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")

-- Cache
Inventory.Cache = {
    Fruits = {},
    Weapons = {},
    Accessories = {},
    Materials = {},
    LastUpdate = 0,
}

-- ========== FRUTAS ==========

function Inventory:GetInventoryFruits()
    local fruits = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local function scanContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local fruitModule = item:FindFirstChild("Fruit")
                if fruitModule then
                    table.insert(fruits, {
                        Name = item.Name,
                        Tool = item,
                        Container = container.Name,
                        Module = fruitModule,
                    })
                end
            end
        end
    end

    scanContainer(backpack)
    scanContainer(character)

    self.Cache.Fruits = fruits
    self.Cache.LastUpdate = tick()
    return fruits
end

function Inventory:GetStoredFruits()
    local success, result = pcall(function()
        return CommF_:InvokeServer("getInventoryFruits")
    end)

    if success and result then
        return result
    end
    return {}
end

function Inventory:HasFruit(fruitName, checkStored)
    fruitName = fruitName:lower()

    -- Verificar inventário local
    local fruits = self:GetInventoryFruits()
    for _, fruit in ipairs(fruits) do
        if fruit.Name:lower():find(fruitName) then
            return true, fruit
        end
    end

    -- Verificar armazenadas
    if checkStored then
        local stored = self:GetStoredFruits()
        for _, fruit in ipairs(stored) do
            if fruit.Name:lower():find(fruitName) then
                return true, fruit
            end
        end
    end

    return false, nil
end

function Inventory:GetFruitValue(fruitName)
    -- Valores baseados no mercado (aproximados)
    local fruitValues = {
        ["Rocket"] = 5000,
        ["Spin"] = 7500,
        ["Chop"] = 30000,
        ["Spring"] = 60000,
        ["Bomb"] = 80000,
        ["Smoke"] = 100000,
        ["Spike"] = 180000,
        ["Flame"] = 250000,
        ["Falcon"] = 300000,
        ["Ice"] = 350000,
        ["Sand"] = 420000,
        ["Dark"] = 500000,
        ["Ghost"] = 940000,
        ["Diamond"] = 1000000,
        ["Light"] = 650000,
        ["Rubber"] = 750000,
        ["Barrier"] = 800000,
        ["Magma"] = 850000,
        ["Quake"] = 1000000,
        ["Buddha"] = 1200000,
        ["Love"] = 700000,
        ["Spider"] = 1500000,
        ["Sound"] = 1700000,
        ["Phoenix"] = 1800000,
        ["Portal"] = 1900000,
        ["Rumble"] = 2100000,
        ["Pain"] = 2300000,
        ["Blizzard"] = 2400000,
        ["Gravity"] = 2500000,
        ["Mammoth"] = 2700000,
        ["T-Rex"] = 2800000,
        ["Dough"] = 2800000,
        ["Shadow"] = 2900000,
        ["Venom"] = 3000000,
        ["Control"] = 3200000,
        ["Spirit"] = 3400000,
        ["Dragon"] = 3500000,
        ["Leopard"] = 5000000,
        ["Kitsune"] = 8000000,
    }

    for name, value in pairs(fruitValues) do
        if name:lower() == fruitName:lower() then
            return value
        end
    end

    -- Busca parcial
    for name, value in pairs(fruitValues) do
        if name:lower():find(fruitName) or fruitName:find(name:lower()) then
            return value
        end
    end

    return 0
end

function Inventory:GetFruitRarity(fruitName)
    fruitName = fruitName:lower()

    local rarities = {
        Common = {"Rocket", "Spin", "Chop", "Spring", "Bomb", "Smoke", "Spike"},
        Uncommon = {"Flame", "Falcon", "Ice", "Sand", "Dark"},
        Rare = {"Ghost", "Diamond", "Light", "Rubber", "Barrier", "Magma"},
        Legendary = {"Quake", "Buddha", "Love", "Spider", "Sound", "Phoenix", "Portal", "Rumble", "Pain", "Blizzard", "Gravity", "Mammoth", "T-Rex", "Dough", "Shadow", "Venom", "Control", "Spirit"},
        Mythical = {"Dragon", "Leopard", "Kitsune"},
    }

    for rarity, fruits in pairs(rarities) do
        for _, name in ipairs(fruits) do
            if name:lower() == fruitName then
                return rarity
            end
        end
    end

    return "Unknown"
end

function Inventory:StoreFruit(fruitName)
    local success, result = pcall(function()
        return CommF_:InvokeServer("StoreFruit", fruitName)
    end)
    return success, result
end

function Inventory:EatFruit(fruitName)
    local success, result = pcall(function()
        return CommF_:InvokeServer("EatFruit", fruitName)
    end)
    return success, result
end

-- ========== ARMAS ==========

function Inventory:GetInventoryWeapons()
    local weapons = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local function scanContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and not item:FindFirstChild("Fruit") then
                table.insert(weapons, {
                    Name = item.Name,
                    Tool = item,
                    Container = container.Name,
                    Type = self:GetWeaponType(item),
                })
            end
        end
    end

    scanContainer(backpack)
    scanContainer(character)

    self.Cache.Weapons = weapons
    return weapons
end

function Inventory:GetWeaponType(tool)
    local name = tool.Name:lower()

    if name:find("sword") or name:find("katana") or name:find("blade") or name:find("cutter")
        or name:find("saber") or name:find("bisento") or name:find("cane") or name:find("mace")
        or name:find("katana") or name:find("cutlass") or name:find("trident") then
        return "Sword"
    elseif name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon")
        or name:find("musket") or name:find("flintlock") or name:find("slingshot")
        or name:find("bazooka") or name:find("bow") then
        return "Gun"
    elseif tool:FindFirstChild("Fruit") then
        return "Fruit"
    else
        return "Melee"
    end
end

function Inventory:GetWeaponMastery(weaponName)
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    if not stats then return 0 end

    local weaponType = self:GetWeaponType({Name = weaponName})
    local masteryStat = stats:FindFirstChild(weaponType)
    return masteryStat and masteryStat.Value or 0
end

function Inventory:EquipWeapon(weaponName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not backpack or not humanoid then return false end

    local tool = backpack:FindFirstChild(weaponName) or character:FindFirstChild(weaponName)
    if tool then
        humanoid:EquipTool(tool)
        return true
    end

    return false
end

function Inventory:GetBestWeapon(preferredType)
    preferredType = preferredType or "Melee"
    local weapons = self:GetInventoryWeapons()

    -- Prioridades por tipo
    local priorities = {
        Melee = {"Godhuman", "Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Sharkman Karate", "Combat", "Black Leg", "Fishman Karate", "Electro", "Dark Step"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber", "Buddy Sword", "Canvander", "Dual Katana", "Iron Mace", "Triple Katana", "Pipe", "Dual-Headed Blade", "Bisento", "Soul Cane", "Katana", "Cutlass"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Kabucha", "Soul Guitar", "Bazooka", "Cannon", "Musket", "Flintlock", "Slingshot"},
        Fruit = {}, -- Frutas não estão no inventário de armas
    }

    local weaponList = priorities[preferredType] or priorities.Melee

    for _, weaponName in ipairs(weaponList) do
        for _, weapon in ipairs(weapons) do
            if weapon.Name == weaponName then
                return weapon
            end
        end
    end

    -- Fallback: primeira arma do tipo preferido
    for _, weapon in ipairs(weapons) do
        if weapon.Type == preferredType then
            return weapon
        end
    end

    -- Qualquer arma
    return weapons[1]
end

-- ========== ACESSÓRIOS ==========

function Inventory:GetAccessories()
    local accessories = {}
    local character = LocalPlayer.Character

    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Accessory") then
                table.insert(accessories, {
                    Name = item.Name,
                    Handle = item:FindFirstChild("Handle"),
                })
            end
        end
    end

    self.Cache.Accessories = accessories
    return accessories
end

function Inventory:HasAccessory(accessoryName)
    local accessories = self:GetAccessories()
    accessoryName = accessoryName:lower()

    for _, acc in ipairs(accessories) do
        if acc.Name:lower():find(accessoryName) then
            return true
        end
    end

    return false
end

-- ========== MATERIAIS ==========

function Inventory:GetMaterials()
    local materials = {}
    local data = LocalPlayer:FindFirstChild("Data")
    local inventory = data and data:FindFirstChild("Inventory")

    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("IntValue") or item:IsA("NumberValue") then
                materials[item.Name] = item.Value
            end
        end
    end

    self.Cache.Materials = materials
    return materials
end

function Inventory:GetMaterialCount(materialName)
    local materials = self:GetMaterials()
    return materials[materialName] or 0
end

function Inventory:HasMaterials(requirements)
    -- requirements = {["MaterialName"] = count, ...}
    local materials = self:GetMaterials()

    for name, requiredCount in pairs(requirements) do
        if (materials[name] or 0) < requiredCount then
            return false, name
        end
    end

    return true, nil
end

-- ========== STATS ==========

function Inventory:GetStats()
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    if not stats then return {} end

    local result = {}
    for _, stat in ipairs(stats:GetChildren()) do
        if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
            result[stat.Name] = stat.Value
        end
    end

    return result
end

function Inventory:GetStat(statName)
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    if not stats then return nil end

    local stat = stats:FindFirstChild(statName)
    return stat and stat.Value or nil
end

function Inventory:GetLevel()
    return self:GetStat("Level") or 1
end

function Inventory:GetBeli()
    return self:GetStat("Beli") or 0
end

function Inventory:GetFragments()
    return self:GetStat("Fragments") or 0
end

function Inventory:GetCurrentFruit()
    return self:GetStat("DevilFruit") or "None"
end

function Inventory:GetMastery(statName)
    return self:GetStat(statName) or 0
end

function Inventory:AddStatPoints(statName, points)
    points = points or 1
    local success = pcall(function()
        CommF_:InvokeServer("AddPoint", statName, points)
    end)
    return success
end

function Inventory:AutoStats(priority)
    priority = priority or {"Melee", "Defense", "Sword", "Gun", "Fruit"}

    local stats = self:GetStats()
    local points = stats.Points or 0

    if points <= 0 then return false end

    for _, stat in ipairs(priority) do
        local current = stats[stat] or 0
        local maxLevel = self:GetLevel() * 3 -- Aproximado

        if current < maxLevel then
            local toAdd = math.min(points, maxLevel - current)
            self:AddStatPoints(stat, toAdd)
            points = points - toAdd
            if points <= 0 then break end
        end
    end

    return true
end

-- ========== UTILITÁRIOS ==========

function Inventory:RefreshCache()
    self:GetInventoryFruits()
    self:GetInventoryWeapons()
    self:GetAccessories()
    self:GetMaterials()
    self:GetStats()
end

function Inventory:GetCachedFruits()
    if tick() - self.Cache.LastUpdate > 5 then
        return self:GetInventoryFruits()
    end
    return self.Cache.Fruits
end

function Inventory:GetCachedWeapons()
    if tick() - self.Cache.LastUpdate > 5 then
        return self:GetInventoryWeapons()
    end
    return self.Cache.Weapons
end

function Inventory:PrintInventory()
    print("=== INVENTÁRIO ===")
    print("Frutas:")
    for _, f in ipairs(self:GetInventoryFruits()) do
        print("  - " .. f.Name .. " (" .. f.Container .. ")")
    end
    print("Armas:")
    for _, w in ipairs(self:GetInventoryWeapons()) do
        print("  - " .. w.Name .. " [" .. w.Type .. "] (" .. w.Container .. ")")
    end
    print("Materiais:")
    for name, count in pairs(self:GetMaterials()) do
        if count > 0 then print("  - " .. name .. ": " .. count) end
    end
    print("==================")
end

return Inventory