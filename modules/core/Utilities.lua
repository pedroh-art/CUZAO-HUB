--[[
    CUZAO HUB - Utilities Module
    Funções utilitárias gerais para o script
]]

local Utilities = {}

-- Serviços
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ========== MATEMÁTICA & VETORES ==========

function Utilities:Distance(pos1, pos2)
    if typeof(pos1) == "Instance" and pos1:IsA("BasePart") then
        pos1 = pos1.Position
    end
    if typeof(pos2) == "Instance" and pos2:IsA("BasePart") then
        pos2 = pos2.Position
    end
    return (pos1 - pos2).Magnitude
end

function Utilities:Distance2D(pos1, pos2)
    if typeof(pos1) == "Instance" and pos1:IsA("BasePart") then
        pos1 = Vector2.new(pos1.Position.X, pos1.Position.Z)
    elseif typeof(pos1) == "Vector3" then
        pos1 = Vector2.new(pos1.X, pos1.Z)
    end
    if typeof(pos2) == "Instance" and pos2:IsA("BasePart") then
        pos2 = Vector2.new(pos2.Position.X, pos2.Position.Z)
    elseif typeof(pos2) == "Vector3" then
        pos2 = Vector2.new(pos2.X, pos2.Z)
    end
    return (pos1 - pos2).Magnitude
end

function Utilities:Lerp(start, goal, alpha)
    return start + (goal - start) * alpha
end

function Utilities:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utilities:Round(num, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utilities:RandomFloat(min, max)
    return min + math.random() * (max - min)
end

function Utilities:RandomVector3(range)
    return Vector3.new(
        self:RandomFloat(-range, range),
        self:RandomFloat(-range, range),
        self:RandomFloat(-range, range)
    )
end

-- ========== CFrame & POSIÇÃO ==========

function Utilities:GetRootPart(character)
    character = character or LocalPlayer.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function Utilities:GetHumanoid(character)
    character = character or LocalPlayer.Character
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

function Utilities:GetCharacterPosition(character)
    local root = self:GetRootPart(character)
    return root and root.Position or Vector3.new(0, 0, 0)
end

function Utilities:TeleportTo(cframe, character)
    character = character or LocalPlayer.Character
    local root = self:GetRootPart(character)
    if root then
        root.CFrame = cframe
        return true
    end
    return false
end

function Utilities:TweenTo(targetCFrame, duration, easingStyle, easingDirection, character)
    character = character or LocalPlayer.Character
    local root = self:GetRootPart(character)
    local humanoid = self:GetHumanoid(character)

    if not root or not humanoid then return false end

    duration = duration or 1
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out

    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})

    tween:Play()
    return tween
end

function Utilities:TweenToPosition(position, duration, easingStyle, easingDirection, character)
    return self:TweenTo(CFrame.new(position), duration, easingStyle, easingDirection, character)
end

-- Tween suave com verificação de colisão (noclip style)
function Utilities:SafeTweenTo(targetCFrame, speed, character)
    character = character or LocalPlayer.Character
    local root = self:GetRootPart(character)
    local humanoid = self:GetHumanoid(character)

    if not root or not humanoid then return nil end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed

    return self:TweenTo(targetCFrame, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, character)
end

-- ========== COMBATE & TARGETING ==========

function Utilities:GetNearestPlayer(maxDistance, excludeTeam)
    local nearest = nil
    local shortestDistance = maxDistance or math.huge
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if excludeTeam and player.Team == myTeam then continue end

            local root = self:GetRootPart(player.Character)
            if root then
                local dist = self:Distance(LocalPlayer.Character, root)
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = player
                end
            end
        end
    end

    return nearest, shortestDistance
end

function Utilities:GetNearestMob(maxDistance, mobFolder)
    mobFolder = mobFolder or Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
    if not mobFolder then return nil, math.huge end

    local nearest = nil
    local shortestDistance = maxDistance or math.huge
    local myRoot = self:GetRootPart()

    if not myRoot then return nil, math.huge end

    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local humanoid = mob.Humanoid
            if humanoid.Health > 0 then
                local dist = (myRoot.Position - mob.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = mob
                end
            end
        end
    end

    return nearest, shortestDistance
end

function Utilities:GetMobsInRadius(radius, mobFolder)
    mobFolder = mobFolder or Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
    if not mobFolder then return {} end

    local mobs = {}
    local myRoot = self:GetRootPart()

    if not myRoot then return mobs end

    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local humanoid = mob.Humanoid
            if humanoid.Health > 0 then
                local dist = (myRoot.Position - mob.HumanoidRootPart.Position).Magnitude
                if dist <= radius then
                    table.insert(mobs, {mob = mob, distance = dist})
                end
            end
        end
    end

    table.sort(mobs, function(a, b) return a.distance < b.distance end)
    return mobs
end

function Utilities:FaceTarget(targetPosition, character)
    character = character or LocalPlayer.Character
    local root = self:GetRootPart(character)
    if root then
        local lookAt = CFrame.new(root.Position, Vector3.new(targetPosition.X, root.Position.Y, targetPosition.Z))
        root.CFrame = lookAt
    end
end

-- ========== INVENTÁRIO & ITENS ==========

function Utilities:GetTool(name)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if backpack then
        local tool = backpack:FindFirstChild(name)
        if tool then return tool end
    end

    if character then
        local tool = character:FindFirstChild(name)
        if tool then return tool end
    end

    return nil
end

function Utilities:EquipTool(name)
    local tool = self:GetTool(name)
    local humanoid = self:GetHumanoid()

    if tool and humanoid then
        humanoid:EquipTool(tool)
        return true
    end
    return false
end

function Utilities:UnequipTools()
    local humanoid = self:GetHumanoid()
    if humanoid then
        humanoid:UnequipTools()
    end
end

function Utilities:GetInventoryFruits()
    local fruits = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local function checkContainer(container)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Fruit") then
                    table.insert(fruits, item.Name)
                end
            end
        end
    end

    checkContainer(backpack)
    checkContainer(character)

    return fruits
end

function Utilities:HasFruit(fruitName)
    local fruits = self:GetInventoryFruits()
    for _, name in ipairs(fruits) do
        if name:lower():find(fruitName:lower()) then
            return true
        end
    end
    return false
end

-- ========== VERIFICAÇÕES DE ESTADO ==========

function Utilities:IsAlive(character)
    character = character or LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function Utilities:IsInCombat(character)
    character = character or LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health < humanoid.MaxHealth
end

function Utilities:GetPlayerLevel()
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    local level = stats and stats:FindFirstChild("Level")
    return level and level.Value or 1
end

function Utilities:GetBeli()
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    local beli = stats and stats:FindFirstChild("Beli")
    return beli and beli.Value or 0
end

function Utilities:GetFragments()
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    local fragments = stats and stats:FindFirstChild("Fragments")
    return fragments and fragments.Value or 0
end

function Utilities:GetCurrentFruit()
    local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
    local fruit = stats and stats:FindFirstChild("DevilFruit")
    return fruit and fruit.Value or "None"
end

-- ========== MOVIMENTO ==========

function Utilities:SetWalkSpeed(speed)
    local humanoid = self:GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

function Utilities:SetJumpPower(power)
    local humanoid = self:GetHumanoid()
    if humanoid then
        humanoid.JumpPower = power
    end
end

function Utilities:EnableNoclip(character)
    character = character or LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

function Utilities:DisableNoclip(character)
    character = character or LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ========== TEMPO & TIMERS ==========

function Utilities:Wait(seconds)
    local start = tick()
    while tick() - start < seconds do
        RunService.Heartbeat:Wait()
    end
end

function Utilities:WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local start = tick()
    local child = parent:FindFirstChild(childName)

    while not child and tick() - start < timeout do
        RunService.Heartbeat:Wait()
        child = parent:FindFirstChild(childName)
    end

    return child
end

-- ========== STRING & FORMATATAÇÃO ==========

function Utilities:FormatNumber(num)
    if num >= 1e9 then
        return string.format("%.1fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

function Utilities:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

function Utilities:Capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

function Utilities:Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- ========== TABELA & ARRAY ==========

function Utilities:TableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function Utilities:TableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utilities:TableFind(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then return i end
    end
    return nil
end

function Utilities:TableRemove(tbl, value)
    local index = self:TableFind(tbl, value)
    if index then
        table.remove(tbl, index)
        return true
    end
    return false
end

function Utilities:DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utilities:MergeTables(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            self:MergeTables(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

-- ========== RAYCAST & COLISÃO ==========

function Utilities:Raycast(origin, direction, params)
    params = params or RaycastParams.new()
    params.FilterType = params.FilterType or Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = params.FilterDescendantsInstances or {LocalPlayer.Character}

    return Workspace:Raycast(origin, direction, params)
end

function Utilities:IsPositionVisible(position, ignoreList)
    local camera = Workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (position - origin).Unit * (position - origin).Magnitude

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {LocalPlayer.Character}

    local result = Workspace:Raycast(origin, direction, params)
    return result == nil or result.Position == position
end

-- ========== HTTP & JSON ==========

function Utilities:HttpGet(url, headers)
    local success, result = pcall(function()
        return game:HttpGet(url, headers)
    end)
    return success, result
end

function Utilities:HttpPost(url, data, headers)
    local success, result = pcall(function()
        return game:HttpPost(url, data, headers)
    end)
    return success, result
end

function Utilities:JSONEncode(data)
    return HttpService:JSONEncode(data)
end

function Utilities:JSONDecode(str)
    local success, result = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    return success, result
end

-- ========== DEBUG & LOG ==========

Utilities.LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

Utilities.CurrentLogLevel = Utilities.LogLevel.INFO

function Utilities:Log(level, message, ...)
    if level < self.CurrentLogLevel then return end

    local prefix = ""
    if level == self.LogLevel.DEBUG then prefix = "[DEBUG] "
    elseif level == self.LogLevel.INFO then prefix = "[INFO] "
    elseif level == self.LogLevel.WARN then prefix = "[WARN] "
    elseif level == self.LogLevel.ERROR then prefix = "[ERROR] "
    end

    local formatted = string.format(message, ...)
    print(prefix .. formatted)
end

function Utilities:Debug(message, ...) self:Log(self.LogLevel.DEBUG, message, ...) end
function Utilities:Info(message, ...) self:Log(self.LogLevel.INFO, message, ...) end
function Utilities:Warn(message, ...) self:Log(self.LogLevel.WARN, message, ...) end
function Utilities:Error(message, ...) self:Log(self.LogLevel.ERROR, message, ...) end

-- ========== INPUT ==========

function Utilities:IsKeyDown(keyCode)
    return UserInputService:IsKeyDown(keyCode)
end

function Utilities:BindAction(name, callback, touchEnabled, ...)
    UserInputService:BindAction(name, callback, touchEnabled, ...)
end

function Utilities:UnbindAction(name)
    UserInputService:UnbindAction(name)
end

return Utilities