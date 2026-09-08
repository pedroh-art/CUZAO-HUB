--[[
    CUZAO HUB - All-in-One Bundle
    Uso: loadstring(game:HttpGet("https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/cuzao_all.lua"))()
]]
local CUZAO = {}
CUZAO.Version = "1.0.0"
CUZAO.StartTime = tick()
CUZAO.Loaded = false
CUZAO.Modules = {}
CUZAO.Errors = {}
getgenv().CUZAO = CUZAO
getgenv().CUZAO_VERSION = CUZAO.Version

-- [Core/Services]
pcall(function()
--[[
    CUZAO HUB - Core Services Module
    Centraliza todos os serviços do Roblox para acesso fácil
]]

local Services = {}

-- Serviços Principais
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.RunService = game:GetService("RunService")
Services.TweenService = game:GetService("TweenService")
Services.HttpService = game:GetService("HttpService")
Services.UserInputService = game:GetService("UserInputService")
Services.Lighting = game:GetService("Lighting")
Services.SoundService = game:GetService("SoundService")
Services.VirtualUser = game:GetService("VirtualUser")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.CoreGui = game:GetService("CoreGui")
Services.StarterGui = game:GetService("StarterGui")
Services.StarterPlayer = game:GetService("StarterPlayer")
Services.TeleportService = game:GetService("TeleportService")
Services.MarketplaceService = game:GetService("MarketplaceService")
Services.PathfindingService = game:GetService("PathfindingService")
Services.PhysicsService = game:GetService("PhysicsService")
Services.LocalizationService = game:GetService("LocalizationService")
Services.TextChatService = game:GetService("TextChatService")

-- Referências Comuns
Services.LocalPlayer = Services.Players.LocalPlayer
Services.Camera = Services.Workspace.CurrentCamera
Services.Mouse = Services.LocalPlayer:GetMouse()

-- Remotes Comuns do Blox Fruits
Services.Remotes = {}
Services.Remotes.CommF_ = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
Services.Remotes.CommE = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")

-- Net Modules (para comunicação cliente-servidor)
Services.Net = {}
local NetFolder = Services.ReplicatedStorage:WaitForChild("Net")
if NetFolder then
    Services.Net.Fruit = NetFolder:FindFirstChild("Fruit")
    Services.Net.Weapon = NetFolder:FindFirstChild("Weapon")
    Services.Net.Combat = NetFolder:FindFirstChild("Combat")
end

-- Módulos do Jogo
Services.Modules = {}
local ModulesFolder = Services.ReplicatedStorage:WaitForChild("Modules")
if ModulesFolder then
    Services.Modules.Fruit = ModulesFolder:FindFirstChild("Fruit")
    Services.Modules.Weapon = ModulesFolder:FindFirstChild("Weapon")
    Services.Modules.Combat = ModulesFolder:FindFirstChild("Combat")
    Services.Modules.Quest = ModulesFolder:FindFirstChild("Quest")
end

-- Dados do Jogador
Services.PlayerData = {}
Services.PlayerData.Stats = Services.LocalPlayer:WaitForChild("Data"):WaitForChild("Stats")
Services.PlayerData.Level = Services.PlayerData.Stats:WaitForChild("Level")
Services.PlayerData.Beli = Services.PlayerData.Stats:WaitForChild("Beli")
Services.PlayerData.Fragments = Services.PlayerData.Stats:WaitForChild("Fragments")
Services.PlayerData.DevilFruit = Services.PlayerData.Stats:WaitForChild("DevilFruit")
Services.PlayerData.Melee = Services.PlayerData.Stats:WaitForChild("Melee")
Services.PlayerData.Defense = Services.PlayerData.Stats:WaitForChild("Defense")
Services.PlayerData.Sword = Services.PlayerData.Stats:WaitForChild("Sword")
Services.PlayerData.Gun = Services.PlayerData.Stats:WaitForChild("Gun")
Services.PlayerData.Fruit = Services.PlayerData.Stats:WaitForChild("Fruit")

-- Configurações do Personagem
Services.Character = Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait()
Services.Humanoid = Services.Character:WaitForChild("Humanoid")
Services.HumanoidRootPart = Services.Character:WaitForChild("HumanoidRootPart")

-- Atualizar referências quando personagem respawna
Services.LocalPlayer.CharacterAdded:Connect(function(char)
    Services.Character = char
    Services.Humanoid = char:WaitForChild("Humanoid")
    Services.HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Utilitário para pegar remote com segurança
function Services:GetRemote(name, parent)
    parent = parent or Services.ReplicatedStorage.Remotes
    local remote = parent:FindFirstChild(name)
    if not remote then
        warn("[Services] Remote não encontrado: " .. name)
    end
    return remote
end

-- Utilitário para invocar CommF_ com segurança
function Services:CommF_(...)
    local args = {...}
    local success, result = pcall(function()
        return Services.Remotes.CommF_:InvokeServer(unpack(args))
    end)
    if not success then
        warn("[Services] CommF_ falhou: " .. tostring(result))
    end
    return success, result
end

-- Utilitário para disparar CommE com segurança
function Services:CommE(...)
    local args = {...}
    local success, result = pcall(function()
        return Services.Remotes.CommE:FireServer(unpack(args))
    end)
    if not success then
        warn("[Services] CommE falhou: " .. tostring(result))
    end
    return success, result
end

return Servicesend)

-- [Core/Utilities]
pcall(function()
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

return Utilitiesend)

-- [Core/EventBus]
pcall(function()
--[[
    CUZAO HUB - Event Bus Module
    Sistema de eventos para comunicação desacoplada entre módulos
]]

local EventBus = {}
EventBus._events = {}
EventBus._onceEvents = {}
EventBus._wildcardListeners = {}

-- Conectar a um evento
function EventBus:On(eventName, callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    self._events[eventName] = self._events[eventName] or {}
    table.insert(self._events[eventName], callback)

    -- Retornar função para desconectar
    return function()
        self:Off(eventName, callback)
    end
end

-- Conectar a um evento apenas uma vez
function EventBus:Once(eventName, callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    self._onceEvents[eventName] = self._onceEvents[eventName] or {}
    table.insert(self._onceEvents[eventName], callback)

    return function()
        self:OffOnce(eventName, callback)
    end
end

-- Conectar a todos os eventos (wildcard)
function EventBus:OnAny(callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    table.insert(self._wildcardListeners, callback)

    return function()
        self:OffAny(callback)
    end
end

-- Desconectar de um evento
function EventBus:Off(eventName, callback)
    if not self._events[eventName] then return false end

    for i, cb in ipairs(self._events[eventName]) do
        if cb == callback then
            table.remove(self._events[eventName], i)
            return true
        end
    end
    return false
end

-- Desconectar de um evento once
function EventBus:OffOnce(eventName, callback)
    if not self._onceEvents[eventName] then return false end

    for i, cb in ipairs(self._onceEvents[eventName]) do
        if cb == callback then
            table.remove(self._onceEvents[eventName], i)
            return true
        end
    end
    return false
end

-- Desconectar de wildcard
function EventBus:OffAny(callback)
    for i, cb in ipairs(self._wildcardListeners) do
        if cb == callback then
            table.remove(self._wildcardListeners, i)
            return true
        end
    end
    return false
end

-- Emitir evento
function EventBus:Emit(eventName, ...)
    local args = {...}

    -- Listeners normais
    if self._events[eventName] then
        for _, callback in ipairs(self._events[eventName]) do
            task.spawn(function()
                local success, err = pcall(callback, unpack(args))
                if not success then
                    warn("[EventBus] Erro no listener '" .. eventName .. "': " .. tostring(err))
                end
            end)
        end
    end

    -- Listeners once (executam e removem)
    if self._onceEvents[eventName] then
        for _, callback in ipairs(self._onceEvents[eventName]) do
            task.spawn(function()
                local success, err = pcall(callback, unpack(args))
                if not success then
                    warn("[EventBus] Erro no listener once '" .. eventName .. "': " .. tostring(err))
                end
            end)
        end
        self._onceEvents[eventName] = nil
    end

    -- Wildcard listeners
    for _, callback in ipairs(self._wildcardListeners) do
        task.spawn(function()
            local success, err = pcall(callback, eventName, unpack(args))
            if not success then
                warn("[EventBus] Erro no wildcard listener: " .. tostring(err))
            end
        end)
    end
end

-- Emitir evento de forma síncrona (bloqueante)
function EventBus:EmitSync(eventName, ...)
    local args = {...}
    local results = {}

    if self._events[eventName] then
        for _, callback in ipairs(self._events[eventName]) do
            local success, result = pcall(callback, unpack(args))
            if success then
                table.insert(results, result)
            else
                warn("[EventBus] Erro no listener sync '" .. eventName .. "': " .. tostring(result))
            end
        end
    end

    if self._onceEvents[eventName] then
        for _, callback in ipairs(self._onceEvents[eventName]) do
            local success, result = pcall(callback, unpack(args))
            if success then
                table.insert(results, result)
            else
                warn("[EventBus] Erro no listener once sync '" .. eventName .. "': " .. tostring(result))
            end
        end
        self._onceEvents[eventName] = nil
    end

    return results
end

-- Aguardar evento (promise-like)
function EventBus:WaitFor(eventName, timeout)
    timeout = timeout or 5
    local thread = coroutine.running()
    local connection

    connection = self:Once(eventName, function(...)
        if connection then connection() end
        task.spawn(thread, ...)
    end)

    task.delay(timeout, function()
        if connection then
            connection()
            task.spawn(thread, nil, "timeout")
        end
    end)

    return coroutine.yield()
end

-- Limpar todos os listeners de um evento
function EventBus:Clear(eventName)
    self._events[eventName] = nil
    self._onceEvents[eventName] = nil
end

-- Limpar todos os eventos
function EventBus:ClearAll()
    self._events = {}
    self._onceEvents = {}
    self._wildcardListeners = {}
end

-- Obter contagem de listeners
function EventBus:GetListenerCount(eventName)
    local count = 0
    if self._events[eventName] then
        count = count + #self._events[eventName]
    end
    if self._onceEvents[eventName] then
        count = count + #self._onceEvents[eventName]
    end
    return count
end

-- Listar todos os eventos registrados
function EventBus:GetRegisteredEvents()
    local events = {}
    for name, _ in pairs(self._events) do
        table.insert(events, name)
    end
    for name, _ in pairs(self._onceEvents) do
        if not self._events[name] then
            table.insert(events, name .. " (once)")
        end
    end
    return events
end

-- Debug: imprimir todos os listeners
function EventBus:DebugPrint()
    print("=== EventBus Debug ===")
    for name, listeners in pairs(self._events) do
        print("  " .. name .. ": " .. #listeners .. " listeners")
    end
    for name, listeners in pairs(self._onceEvents) do
        print("  " .. name .. " (once): " .. #listeners .. " listeners")
    end
    print("  Wildcard: " .. #self._wildcardListeners .. " listeners")
    print("=====================")
end

return EventBusend)

-- [Core/ConfigManager]
pcall(function()
--[[
    CUZAO HUB - Config Manager Module
    Gerenciamento de configurações (Save/Load JSON, Presets, Merge)
]]

local ConfigManager = {}
ConfigManager.FileName = "CUZAO_HUB_Config.json"
ConfigManager.FolderName = "CUZAO_HUB"
ConfigManager.CurrentConfig = {}
ConfigManager.DefaultConfig = {}

-- Serviços
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========== CONFIGURAÇÃO PADRÃO ==========

ConfigManager.DefaultConfig = {
    Version = "1.0.0",
    UI = {
        Theme = "Dark",           -- Dark, Light, RGB, CUZAO
        Keybind = "RightControl", -- Tecla para abrir/fechar UI
        Transparency = 0.15,      -- Transparência da UI (0-1)
        Scale = 1.0,              -- Escala da UI
        Language = "PT-BR",       -- PT-BR, EN, ES
        Notifications = true,     -- Mostrar notificações toast
        SoundEnabled = true,      -- Sons da UI
        AnimationSpeed = 1.0,     -- Velocidade das animações
    },
    AutoFarm = {
        Enabled = false,
        SelectedFarm = "Level",   -- Level, Bone, Katakuri, Factory
        Weapon = "Melee",         -- Melee, Sword, Gun, Fruit
        FarmMethod = "Below",     -- Below, Behind, Above, Tween
        Distance = 15,
        TweenSpeed = 350,
        AutoHaki = true,
        AutoKen = false,
        BringMobs = true,
        AttackDelay = 0.1,
        UseSkills = true,
        SkillZ = true,
        SkillX = true,
        SkillC = true,
        SkillV = false,
        SkillF = false,
        AutoStats = false,
        StatPriority = "Melee",   -- Melee, Defense, Sword, Gun, Fruit
    },
    Raid = {
        Enabled = false,
        SelectedRaid = "Flame",   -- Flame, Ice, Quake, Light, Dark, String, Rumbling, Magma, Phoenix, Dough
        AutoStart = true,
        AutoNextIsland = true,
        AutoBuyChip = false,
        ChipAmount = 1,
        KillAura = true,
        TweenSpeed = 400,
    },
    Fruit = {
        Enabled = false,
        SniperEnabled = false,
        WebhookURL = "",
        WebhookPing = "@everyone",
        StoreFruits = true,
        MasteryFarm = false,
        SelectedFruit = "All",
        AutoAwaken = false,
        FragmentThreshold = 5000,
        NotifyOnFind = true,
        SoundOnFind = true,
    },
    Teleport = {
        Enabled = false,
        TweenSpeed = 350,
        SafeMode = true,          -- Verificar se área é segura antes de TP
        Islands = {},
        NPCs = {},
        Players = {},
        CustomWaypoints = {},
    },
    ESP = {
        Enabled = false,
        Player = {
            Enabled = false,
            Box = true,
            Name = true,
            Health = true,
            Distance = true,
            Team = true,
            Weapon = true,
            Fruit = true,
            MaxDistance = 5000,
            Color = Color3.fromRGB(255, 0, 0),
            TeamColor = Color3.fromRGB(0, 255, 0),
        },
        Fruit = {
            Enabled = false,
            ShowName = true,
            ShowPrice = true,
            ShowRarity = true,
            MaxDistance = 10000,
            Color = Color3.fromRGB(255, 255, 0),
        },
        Chest = {
            Enabled = false,
            ShowName = true,
            MaxDistance = 5000,
            Color = Color3.fromRGB(139, 69, 19),
        },
        Mob = {
            Enabled = false,
            ShowName = true,
            ShowHealth = true,
            ShowLevel = true,
            MaxDistance = 3000,
            Color = Color3.fromRGB(255, 100, 100),
        },
        Flower = {
            Enabled = false,
            MaxDistance = 5000,
            Color = Color3.fromRGB(255, 0, 255),
        },
    },
    Combat = {
        Enabled = false,
        AutoClicker = {
            Enabled = false,
            ClickDelay = 0.05,
            RightClick = false,
        },
        AimBot = {
            Enabled = false,
            Mode = "Silent",      -- Silent, Legit, FOV
            FOV = 100,
            Smoothness = 0.5,
            TargetPart = "Head",  -- Head, HumanoidRootPart, Torso
            TeamCheck = true,
            WallCheck = true,
            Prediction = 0.1,
        },
        KillAura = {
            Enabled = false,
            Range = 30,
            TargetPlayers = false,
            TargetMobs = true,
            AttackDelay = 0.1,
        },
        SkillSpam = {
            Enabled = false,
            Skills = {Z = true, X = true, C = true, V = false, F = false},
            Delay = 0.5,
        },
        AutoHaki = true,
        AutoKen = false,
        KenDuration = 5,
    },
    Misc = {
        Enabled = false,
        ServerHop = {
            Enabled = false,
            Mode = "LowPlayers",  -- LowPlayers, HighPlayers, Specific
            MinPlayers = 1,
            MaxPlayers = 12,
            SpecificServer = "",
            Delay = 10,
        },
        Rejoin = {
            Enabled = false,
            OnKick = true,
            OnCrash = true,
            OnLowFPS = false,
            FPSThreshold = 15,
        },
        AntiAFK = true,
        AutoStats = {
            Enabled = false,
            Priority = {"Melee", "Defense", "Sword", "Gun", "Fruit"},
        },
        FPSCap = 60,
        NoClip = false,
        Fly = {
            Enabled = false,
            Speed = 50,
            Keybind = "F",
        },
    },
    SeaEvents = {
        Enabled = false,
        ShipRaid = false,
        SeaBeast = false,
        KitsuneEvent = false,
        SharkAnchor = false,
        AutoCollect = true,
    },
    KeySystem = {
        Enabled = false,
        Key = "",
        Premium = false,
        Discord = "https://discord.gg/cuzahub",
    },
    Advanced = {
        DebugMode = false,
        LogLevel = "INFO",        -- DEBUG, INFO, WARN, ERROR
        BypassAntiCheat = true,
        HumanizerEnabled = true,
        RandomDelays = true,
        MinDelay = 0.05,
        MaxDelay = 0.2,
        SafeMode = false,
    }
}

-- ========== FUNÇÕES AUXILIARES ==========

local function getConfigPath()
    -- Tentar pasta do jogo primeiro, depois pasta do executor
    local success, path = pcall(function()
        return LocalPlayer:GetAttribute("ExecutorFolder") or ""
    end)

    if success and path ~= "" then
        return path .. "/" .. ConfigManager.FolderName .. "/" .. ConfigManager.FileName
    end

    -- Fallback: usar workspace do executor se disponível
    local executorFolder = identifyexecutor and "workspace" or ""
    if executorFolder ~= "" then
        return executorFolder .. "/" .. ConfigManager.FolderName .. "/" .. ConfigManager.FileName
    end

    -- Último recurso: path relativo
    return ConfigManager.FileName
end

local function ensureFolder()
    local path = getConfigPath()
    local folder = path:match("(.+)/[^/]+$")
    if folder and makefolder then
        pcall(makefolder, folder)
    end
end

-- ========== MERGE PROFUNDO ==========

local function deepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            deepMerge(target[key], value)
        else
            if target[key] == nil then
                target[key] = value
            end
        end
    end
end

local function deepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- ========== API PÚBLICA ==========

function ConfigManager:Load()
    local path = getConfigPath()
    local config = deepCopy(self.DefaultConfig)

    -- Tentar ler arquivo existente
    local success, content = pcall(function()
        if readfile and isfile and isfile(path) then
            return readfile(path)
        end
        return nil
    end)

    if success and content then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)

        if decodeSuccess and decoded then
            -- Merge com defaults (preserva novos campos do default)
            deepMerge(config, decoded)
            self.CurrentConfig = config
            return true, config
        else
            warn("[ConfigManager] Erro ao decodificar JSON, usando defaults")
        end
    end

    self.CurrentConfig = config
    return false, config
end

function ConfigManager:Save(config)
    config = config or self.CurrentConfig
    config.Version = self.DefaultConfig.Version
    config.LastSaved = os.date("%Y-%m-%d %H:%M:%S")

    local path = getConfigPath()
    ensureFolder()

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)

    if not success then
        warn("[ConfigManager] Erro ao codificar JSON: " .. tostring(encoded))
        return false
    end

    local writeSuccess, err = pcall(function()
        if writefile then
            writefile(path, encoded)
        end
    end)

    if writeSuccess then
        self.CurrentConfig = config
        return true
    else
        warn("[ConfigManager] Erro ao salvar arquivo: " .. tostring(err))
        return false
    end
end

function ConfigManager:Get(path)
    -- Suporte a path com pontos (ex: "UI.Theme")
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.CurrentConfig
    for _, key in ipairs(keys) do
        if type(current) == "table" then
            current = current[key]
        else
            return nil
        end
    end

    return current
end

function ConfigManager:Set(path, value)
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.CurrentConfig
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end

    current[keys[#keys]] = value
    return self:Save()
end

function ConfigManager:Reset(path)
    if path then
        -- Reset apenas uma seção
        local keys = {}
        for key in path:gmatch("[^%.]+") do
            table.insert(keys, key)
        end

        local current = self.CurrentConfig
        local default = self.DefaultConfig

        for i = 1, #keys - 1 do
            local key = keys[i]
            current = current[key]
            default = default[key]
            if not current or not default then return false end
        end

        current[keys[#keys]] = deepCopy(default[keys[#keys]])
    else
        -- Reset completo
        self.CurrentConfig = deepCopy(self.DefaultConfig)
    end

    return self:Save()
end

function ConfigManager:GetAll()
    return deepCopy(self.CurrentConfig)
end

function ConfigManager:GetDefault(path)
    if not path then return deepCopy(self.DefaultConfig) end

    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.DefaultConfig
    for _, key in ipairs(keys) do
        if type(current) == "table" then
            current = current[key]
        else
            return nil
        end
    end

    return deepCopy(current)
end

-- ========== PRESETS ==========

ConfigManager.Presets = {
    ["Legit Farm"] = {
        AutoFarm = {
            Enabled = true,
            FarmMethod = "Behind",
            Distance = 20,
            TweenSpeed = 300,
            AutoHaki = true,
            AutoKen = true,
            BringMobs = false,
            AttackDelay = 0.3,
        },
        Combat = {
            AimBot = { Enabled = false },
            KillAura = { Enabled = false },
        },
        Misc = { AntiAFK = true },
    },
    ["Raid Speedrun"] = {
        Raid = {
            Enabled = true,
            AutoStart = true,
            AutoNextIsland = true,
            KillAura = true,
            TweenSpeed = 500,
        },
        Combat = {
            KillAura = { Enabled = true, Range = 50 },
            SkillSpam = { Enabled = true, Skills = {Z = true, X = true, C = true, V = true, F = true}, Delay = 0.3 },
        },
        Movement = { Fly = { Enabled = true, Speed = 80 } },
    },
    ["Fruit Sniper"] = {
        Fruit = {
            Enabled = true,
            SniperEnabled = true,
            NotifyOnFind = true,
            SoundOnFind = true,
            StoreFruits = true,
        },
        Misc = { ServerHop = { Enabled = true, Mode = "LowPlayers", Delay = 5 } },
    },
    ["PvP God"] = {
        Combat = {
            AimBot = { Enabled = true, Mode = "Silent", FOV = 150, Smoothness = 0.3 },
            KillAura = { Enabled = true, Range = 40, TargetPlayers = true },
            AutoHaki = true,
            AutoKen = true,
            KenDuration = 8,
        },
        ESP = { Player = { Enabled = true, MaxDistance = 3000 } },
    },
    ["AFK Farm (Safe)"] = {
        AutoFarm = {
            Enabled = true,
            FarmMethod = "Below",
            Distance = 25,
            TweenSpeed = 200,
            AutoHaki = true,
            AutoKen = true,
            BringMobs = false,
            AttackDelay = 0.5,
        },
        Misc = {
            AntiAFK = true,
            Rejoin = { Enabled = true, OnCrash = true, OnKick = true },
            ServerHop = { Enabled = true, Mode = "LowPlayers", Delay = 30 },
        },
        Advanced = { SafeMode = true, HumanizerEnabled = true },
    }
}

function ConfigManager:ApplyPreset(presetName)
    local preset = self.Presets[presetName]
    if not preset then
        warn("[ConfigManager] Preset não encontrado: " .. presetName)
        return false
    end

    deepMerge(self.CurrentConfig, preset)
    return self:Save()
end

function ConfigManager:GetPresets()
    local names = {}
    for name, _ in pairs(self.Presets) do
        table.insert(names, name)
    end
    return names
end

-- ========== EXPORT/IMPORT ==========

function ConfigManager:ExportToString()
    return HttpService:JSONEncode(self.CurrentConfig)
end

function ConfigManager:ImportFromString(jsonStr)
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(jsonStr)
    end)

    if success and decoded then
        deepMerge(self.CurrentConfig, decoded)
        return self:Save()
    end

    return false, "JSON inválido"
end

function ConfigManager:ExportToClipboard()
    local str = self:ExportToString()
    if setclipboard then
        setclipboard(str)
        return true
    end
    return false, "Clipboard não disponível"
end

function ConfigManager:ImportFromClipboard()
    if getclipboard then
        local str = getclipboard()
        return self:ImportFromString(str)
    end
    return false, "Clipboard não disponível"
end

-- ========== AUTO-SAVE ==========

ConfigManager._autoSaveConnection = nil
ConfigManager._autoSaveInterval = 30 -- segundos

function ConfigManager:StartAutoSave(interval)
    interval = interval or self._autoSaveInterval

    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
    end

    self._autoSaveConnection = RunService.Heartbeat:Connect(function()
        self._autoSaveTimer = (self._autoSaveTimer or 0) + 1/60
        if self._autoSaveTimer >= interval then
            self._autoSaveTimer = 0
            self:Save()
        end
    end)
end

function ConfigManager:StopAutoSave()
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
        self._autoSaveConnection = nil
    end
end

-- ========== INICIALIZAÇÃO ==========

function ConfigManager:Initialize()
    local loaded, config = self:Load()
    if loaded then
        print("[ConfigManager] Configuração carregada com sucesso")
    else
        print("[ConfigManager] Usando configuração padrão")
        self:Save() -- Criar arquivo inicial
    end

    -- Auto-save periódico
    self:StartAutoSave()

    return self.CurrentConfig
end

return ConfigManagerend)

-- [Core/Http]
pcall(function()
--[[
    CUZAO HUB - HTTP Module
    Sistema HTTP robusto para webhooks, APIs e atualizações
]]

local Http = {}
Http.RequestQueue = {}
Http.Processing = false

-- Serviços
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configurações
Http.DefaultTimeout = 10
Http.MaxRetries = 3
Http.RetryDelay = 1
Http.UserAgent = "CUZAO-HUB/1.0.0 (Roblox; Blox Fruits)"

-- ========== FUNÇÕES AUXILIARES ==========

local function buildHeaders(customHeaders)
    local headers = {
        ["User-Agent"] = Http.UserAgent,
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
    }

    if customHeaders then
        for k, v in pairs(customHeaders) do
            headers[k] = v
        end
    end

    return headers
end

local function requestWithRetry(options)
    local retries = 0
    local lastError = nil

    while retries <= Http.MaxRetries do
        local success, result = pcall(function()
            return request(options)
        end)

        if success and result.Success then
            return true, result
        end

        lastError = result and result.StatusMessage or "Unknown error"
        retries = retries + 1

        if retries <= Http.MaxRetries then
            task.wait(Http.RetryDelay * retries) -- Backoff exponencial
        end
    end

    return false, lastError
end

-- ========== MÉTODOS HTTP ==========

function Http:Get(url, headers, timeout)
    local options = {
        Url = url,
        Method = "GET",
        Headers = buildHeaders(headers),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Post(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "POST",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Put(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "PUT",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Delete(url, headers, timeout)
    local options = {
        Url = url,
        Method = "DELETE",
        Headers = buildHeaders(headers),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Patch(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "PATCH",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

-- ========== WEBHOOKS DISCORD ==========

Http.WebhookCache = {}

function Http:SendWebhook(url, data)
    -- Rate limiting simples por webhook
    local now = tick()
    local cache = self.WebhookCache[url] or {lastSent = 0, count = 0}

    if now - cache.lastSent < 1 then -- Mínimo 1 segundo entre webhooks
        cache.count = cache.count + 1
        if cache.count > 5 then
            warn("[Http] Rate limit atingido para webhook")
            return false, "Rate limited"
        end
    else
        cache.count = 1
    end

    cache.lastSent = now
    self.WebhookCache[url] = cache

    -- Formatar para Discord
    local payload = {
        embeds = data.embeds or {},
        content = data.content or "",
        username = data.username or "CUZAO HUB",
        avatar_url = data.avatar_url or "https://i.imgur.com/CUZAO.png",
    }

    -- Adicionar timestamp se não tiver
    if payload.embeds then
        for _, embed in ipairs(payload.embeds) do
            if not embed.timestamp then
                embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            end
            if not embed.color then
                embed.color = 0xFF0000 -- Vermelho CUZAO
            end
            if not embed.footer then
                embed.footer = {
                    text = "CUZAO HUB | Blox Fruits",
                    icon_url = "https://i.imgur.com/CUZAO.png"
                }
            end
        end
    end

    return self:Post(url, payload)
end

function Http:CreateEmbed(title, description, color, fields, thumbnail, image)
    local embed = {
        title = title,
        description = description,
        color = color or 0xFF0000,
        fields = fields or {},
        thumbnail = thumbnail and {url = thumbnail} or nil,
        image = image and {url = image} or nil,
    }
    return embed
end

function Http:CreateField(name, value, inline)
    return {name = name, value = value, inline = inline or false}
end

-- Webhook específico para Fruit Sniper
function Http:SendFruitWebhook(webhookUrl, fruitData, playerData)
    local embed = self:CreateEmbed(
        "🍎 Fruta Encontrada!",
        string.format("**%s** spawnou no servidor!", fruitData.Name),
        fruitData.RarityColor or 0xFFD700,
        {
            self:CreateField("📍 Localização", fruitData.Location or "Desconhecido", true),
            self:CreateField("💰 Preço", self:FormatNumber(fruitData.Price or 0) .. " Beli", true),
            self:CreateField("⭐ Raridade", fruitData.Rarity or "Desconhecido", true),
            self:CreateField("👤 Jogador", playerData.Name or "Desconhecido", true),
            self:CreateField("🆔 User ID", tostring(playerData.UserId or "N/A"), true),
            self:CreateField("🌐 Servidor", "JobId: " .. (game.JobId or "N/A"), false),
        },
        fruitData.Thumbnail,
        fruitData.Image
    )

    return self:SendWebhook(webhookUrl, {
        content = playerData.Ping or "@everyone",
        embeds = {embed}
    })
end

-- Webhook para logs de farm
function Http:SendFarmLog(webhookUrl, farmData)
    local embed = self:CreateEmbed(
        "📊 Log de Farm",
        farmData.Message or "Atividade de farm registrada",
        0x00FF00,
        {
            self:CreateField("🎯 Tipo", farmData.Type or "Auto Farm", true),
            self:CreateField("📈 XP Ganho", self:FormatNumber(farmData.XP or 0), true),
            self:CreateField("💰 Beli Ganho", self:FormatNumber(farmData.Beli or 0), true),
            self:CreateField("⏱️ Tempo", self:FormatTime(farmData.Duration or 0), true),
            self:CreateField("👤 Jogador", farmData.Player or "Desconhecido", true),
            self:CreateField("🌐 Servidor", "JobId: " .. (game.JobId or "N/A"), false),
        }
    )

    return self:SendWebhook(webhookUrl, {embeds = {embed}})
end

-- ========== GITHUB API ==========

function Http:GetLatestRelease(repo)
    local url = "https://api.github.com/repos/" .. repo .. "/releases/latest"
    local success, result = self:Get(url, {["Accept"] = "application/vnd.github.v3+json"})

    if success then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(result.Body)
        end)
        if decodeSuccess then
            return true, data
        end
    end

    return false, result
end

function Http:GetFileContent(repo, path, branch)
    branch = branch or "main"
    local url = "https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/" .. path
    return self:Get(url, {}, 15)
end

function Http:CheckForUpdates(currentVersion, repo)
    local success, release = self:GetLatestRelease(repo)
    if not success then return false, release end

    local latestVersion = release.tag_name:gsub("^v", "")
    currentVersion = currentVersion:gsub("^v", "")

    local function versionToNumber(ver)
        local parts = {}
        for part in ver:gmatch("%d+") do
            table.insert(parts, tonumber(part))
        end
        return parts[1] * 10000 + (parts[2] or 0) * 100 + (parts[3] or 0)
    end

    local hasUpdate = versionToNumber(latestVersion) > versionToNumber(currentVersion)
    return true, {
        hasUpdate = hasUpdate,
        currentVersion = currentVersion,
        latestVersion = latestVersion,
        releaseNotes = release.body,
        downloadUrl = release.html_url,
        publishedAt = release.published_at,
    }
end

-- ========== UTILITÁRIOS ==========

function Http:FormatNumber(num)
    if num >= 1e9 then return string.format("%.1fB", num / 1e9) end
    if num >= 1e6 then return string.format("%.1fM", num / 1e6) end
    if num >= 1e3 then return string.format("%.1fK", num / 1e3) end
    return tostring(num)
end

function Http:FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

-- ========== QUEUE SYSTEM (para evitar rate limits) ==========

function Http:QueueRequest(options, callback)
    table.insert(self.RequestQueue, {options = options, callback = callback})
    self:ProcessQueue()
end

function Http:ProcessQueue()
    if self.Processing or #self.RequestQueue == 0 then return end

    self.Processing = true

    task.spawn(function()
        while #self.RequestQueue > 0 do
            local req = table.remove(self.RequestQueue, 1)
            local success, result = requestWithRetry(req.options)
            if req.callback then
                task.spawn(req.callback, success, result)
            end
            task.wait(0.1) -- Pequeno delay entre requests
        end
        self.Processing = false
    end)
end

return Httpend)

-- [Core/Tween]
pcall(function()
--[[
    CUZAO HUB - Tween Module
    Sistema de movimento suave e tweening avançado
]]

local TweenModule = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Cache de tweens ativos
TweenModule.ActiveTweens = {}
TweenModule.TweenCache = {}

-- Configurações padrão
TweenModule.Defaults = {
    Speed = 350,                    -- Studs por segundo
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    Timeout = 30,                   -- Timeout máximo em segundos
    CheckCollision = true,          -- Verificar colisão durante tween
    CollisionCheckInterval = 0.1,   -- Intervalo de verificação
    HumanizerEnabled = true,        -- Adicionar variação humana
    HumanizerVariance = 0.15,       -- 15% de variação na velocidade
}

-- ========== FUNÇÕES AUXILIARES ==========

local function getRootPart(character)
    character = character or LocalPlayer.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getHumanoid(character)
    character = character or LocalPlayer.Character
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

local function calculateDuration(startPos, endPos, speed)
    local distance = (startPos - endPos).Magnitude
    return distance / speed
end

local function addHumanizer(value, variance)
    if not variance or variance <= 0 then return value end
    local factor = 1 + (math.random() * 2 - 1) * variance
    return value * factor
end

-- ========== TWEEN BÁSICO ==========

function TweenModule:CreateTween(object, properties, tweenInfo)
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

function TweenModule:TweenModel(model, targetCFrame, options)
    options = options or {}
    local speed = options.Speed or self.Defaults.Speed
    local easingStyle = options.EasingStyle or self.Defaults.EasingStyle
    local easingDirection = options.EasingDirection or self.Defaults.EasingDirection

    local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
    if not primaryPart then
        warn("[Tween] Modelo sem PrimaryPart ou HumanoidRootPart")
        return nil
    end

    local startPos = primaryPart.Position
    local duration = calculateDuration(startPos, targetCFrame.Position, speed)

    if options.HumanizerEnabled ~= false and self.Defaults.HumanizerEnabled then
        duration = addHumanizer(duration, self.Defaults.HumanizerVariance)
    end

    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        easingDirection
    )

    local tween = TweenService:Create(primaryPart, tweenInfo, {CFrame = targetCFrame})
    return tween, duration
end

-- ========== TWEEN PARA PERSONAGEM ==========

function TweenModule:TweenTo(targetCFrame, options, character)
    character = character or LocalPlayer.Character
    local root = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not root or not humanoid then
        warn("[Tween] Personagem inválido")
        return nil, false
    end

    options = options or {}
    local speed = options.Speed or self.Defaults.Speed
    local easingStyle = options.EasingStyle or self.Defaults.EasingStyle
    local easingDirection = options.EasingDirection or self.Defaults.EasingDirection
    local timeout = options.Timeout or self.Defaults.Timeout
    local onComplete = options.OnComplete
    local onStep = options.OnStep

    local startPos = root.Position
    local duration = calculateDuration(startPos, targetCFrame.Position, speed)

    if options.HumanizerEnabled ~= false and self.Defaults.HumanizerEnabled then
        duration = addHumanizer(duration, self.Defaults.HumanizerVariance)
    end

    -- Limitar duração máxima
    duration = math.min(duration, timeout)

    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        easingDirection
    )

    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})

    -- Registrar tween ativo
    local tweenId = HttpService:GenerateGUID(false)
    self.ActiveTweens[tweenId] = {
        Tween = tween,
        RootPart = root,
        StartTime = tick(),
        Duration = duration,
        TargetCFrame = targetCFrame,
        OnComplete = onComplete,
        OnStep = onStep,
        Character = character,
        Options = options,
    }

    -- Callback de conclusão
    tween.Completed:Connect(function(playbackState)
        self.ActiveTweens[tweenId] = nil

        if onComplete then
            task.spawn(onComplete, playbackState == Enum.PlaybackState.Completed)
        end
    end)

    -- Step callback (para verificação de colisão, etc.)
    if onStep or (options.CheckCollision and self.Defaults.CheckCollision) then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not self.ActiveTweens[tweenId] then
                connection:Disconnect()
                return
            end

            local tweenData = self.ActiveTweens[tweenId]
            local elapsed = tick() - tweenData.StartTime
            local progress = math.clamp(elapsed / tweenData.Duration, 0, 1)

            -- Verificação de colisão
            if options.CheckCollision and self.Defaults.CheckCollision then
                local currentPos = tweenData.RootPart.Position
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {character}
                rayParams.IgnoreWater = true

                local rayResult = Workspace:Raycast(
                    currentPos + Vector3.new(0, 3, 0),
                    Vector3.new(0, -10, 0),
                    rayParams
                )

                if not rayResult then
                    -- No chão - pausar tween
                    tween:Pause()
                    task.wait(0.5)
                    if self.ActiveTweens[tweenId] then
                        tween:Play()
                    end
                end
            end

            if onStep then
                task.spawn(onStep, progress, elapsed)
            end
        end)
    end

    tween:Play()
    return tween, tweenId
end

function TweenModule:TweenToPosition(position, options, character)
    return self:TweenTo(CFrame.new(position), options, character)
end

function TweenModule:TweenToPart(targetPart, options, character)
    if not targetPart then return nil, false end
    return self:TweenTo(targetPart.CFrame, options, character)
end

-- ========== CONTROLE DE TWEENS ==========

function TweenModule:CancelTween(tweenId)
    local tweenData = self.ActiveTweens[tweenId]
    if tweenData then
        tweenData.Tween:Cancel()
        self.ActiveTweens[tweenId] = nil
        return true
    end
    return false
end

function TweenModule:PauseTween(tweenId)
    local tweenData = self.ActiveTweens[tweenId]
    if tweenData then
        tweenData.Tween:Pause()
        return true
    end
    return false
end

function TweenModule:ResumeTween(tweenId)
    local tweenData = self.ActiveTweens[tweenId]
    if tweenData then
        tweenData.Tween:Play()
        return true
    end
    return false
end

function TweenModule:CancelAllTweens()
    for tweenId, tweenData in pairs(self.ActiveTweens) do
        tweenData.Tween:Cancel()
    end
    self.ActiveTweens = {}
end

function TweenModule:GetActiveTweenCount()
    local count = 0
    for _ in pairs(self.ActiveTweens) do count = count + 1 end
    return count
end

function TweenModule:GetTweenProgress(tweenId)
    local tweenData = self.ActiveTweens[tweenId]
    if not tweenData then return 0 end

    local elapsed = tick() - tweenData.StartTime
    return math.clamp(elapsed / tweenData.Duration, 0, 1)
end

-- ========== MOVIMENTO AVANÇADO ==========

-- Pathfinding Tween (contorna obstáculos)
function TweenModule:PathfindTo(targetPosition, options, character)
    character = character or LocalPlayer.Character
    local root = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not root or not humanoid then return nil end

    local PathfindingService = game:GetService("PathfindingService")
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
        WaypointSpacing = 4,
    })

    local success, errorMsg = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        warn("[Tween] Pathfinding falhou: " .. tostring(errorMsg))
        return self:TweenToPosition(targetPosition, options, character) -- Fallback direto
    end

    local waypoints = path:GetWaypoints()
    if #waypoints < 2 then
        return self:TweenToPosition(targetPosition, options, character)
    end

    local currentWaypoint = 1
    local totalTweens = {}

    local function moveToNextWaypoint()
        currentWaypoint = currentWaypoint + 1
        if currentWaypoint > #waypoints then
            if options.OnComplete then
                task.spawn(options.OnComplete, true)
            end
            return
        end

        local wp = waypoints[currentWaypoint]
        local targetCFrame = CFrame.new(wp.Position + Vector3.new(0, 3, 0))

        local tween, tweenId = self:TweenTo(targetCFrame, {
            Speed = options.Speed,
            OnComplete = function(success)
                if success then
                    moveToNextWaypoint()
                else
                    if options.OnComplete then
                        task.spawn(options.OnComplete, false)
                    end
                end
            end,
            CheckCollision = options.CheckCollision,
        }, character)

        table.insert(totalTweens, tween)
    end

    -- Iniciar com primeiro waypoint
    moveToNextWaypoint()

    return totalTweens
end

-- Tween em círculo ao redor de alvo (para farm)
function TweenModule:CircleAround(targetPosition, radius, height, speed, direction, character)
    character = character or LocalPlayer.Character
    local root = getRootPart(character)

    if not root then return nil end

    direction = direction or 1 -- 1 = horário, -1 = anti-horário
    local angle = 0
    local connection
    local cancelled = false

    local function updatePosition()
        if cancelled or not root or not root.Parent then
            if connection then connection:Disconnect() end
            return
        end

        angle = angle + (speed / radius) * direction * (1/60) -- Assumindo 60 FPS
        local x = targetPosition.X + math.cos(angle) * radius
        local z = targetPosition.Z + math.sin(angle) * radius
        local y = targetPosition.Y + (height or 5)

        root.CFrame = CFrame.new(x, y, z, targetPosition.X, targetPosition.Y, targetPosition.Z)
    end

    connection = RunService.Heartbeat:Connect(updatePosition)

    return {
        Cancel = function()
            cancelled = true
            if connection then connection:Disconnect() end
        end,
        SetRadius = function(newRadius) radius = newRadius end,
        SetSpeed = function(newSpeed) speed = newSpeed end,
        SetDirection = function(newDirection) direction = newDirection end,
    end
end

-- Tween "Below" (ficar abaixo do alvo)
function TweenModule:TweenBelow(targetPart, distance, height, options, character)
    if not targetPart then return nil end

    local targetPos = targetPart.Position
    local belowPos = Vector3.new(targetPos.X, targetPos.Y - (height or 10), targetPos.Z)

    -- Offset horizontal aleatório para humanizar
    if options and options.RandomOffset then
        belowPos = belowPos + Vector3.new(
            math.random(-options.RandomOffset, options.RandomOffset),
            0,
            math.random(-options.RandomOffset, options.RandomOffset)
        )
    end

    return self:TweenToPosition(belowPos, options, character)
end

-- Tween "Behind" (ficar atrás do alvo)
function TweenModule:TweenBehind(targetPart, distance, options, character)
    if not targetPart then return nil end

    local targetCFrame = targetPart.CFrame
    local behindPos = (targetCFrame * CFrame.new(0, 0, distance or 5)).Position

    return self:TweenToPosition(behindPos, options, character)
end

-- Tween "Above" (ficar acima do alvo)
function TweenModule:TweenAbove(targetPart, height, options, character)
    if not targetPart then return nil end

    local targetPos = targetPart.Position
    local abovePos = Vector3.new(targetPos.X, targetPos.Y + (height or 15), targetPos.Z)

    return self:TweenToPosition(abovePos, options, character)
end

-- ========== NOCLIP TWEEN ==========

TweenModule.NoclipConnection = nil
TweenModule.NoclipEnabled = false

function TweenModule:EnableNoclip(character)
    character = character or LocalPlayer.Character
    if not character then return end

    self.NoclipEnabled = true

    if self.NoclipConnection then
        self.NoclipConnection:Disconnect()
    end

    self.NoclipConnection = RunService.Stepped:Connect(function()
        if not self.NoclipEnabled then return end
        if not character or not character.Parent then return end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function TweenModule:DisableNoclip(character)
    character = character or LocalPlayer.Character
    self.NoclipEnabled = false

    if self.NoclipConnection then
        self.NoclipConnection:Disconnect()
        self.NoclipConnection = nil
    end

    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- Tween com noclip automático
function TweenModule:TweenWithNoclip(targetCFrame, options, character)
    character = character or LocalPlayer.Character
    self:EnableNoclip(character)

    local tween, tweenId = self:TweenTo(targetCFrame, options, character)

    -- Desabilitar noclip ao terminar
    local originalComplete = options.OnComplete
    if tween then
        tween.Completed:Connect(function()
            self:DisableNoclip(character)
            if originalComplete then
                originalComplete()
            end
        end)
    end

    return tween, tweenId
end

-- ========== FLY TWEEN ==========

TweenModule.FlyData = {
    Enabled = false,
    Speed = 50,
    BodyVelocity = nil,
    BodyGyro = nil,
    Connection = nil,
}

function TweenModule:EnableFly(speed, character)
    character = character or LocalPlayer.Character
    local root = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not root or not humanoid then return false end

    if self.FlyData.Enabled then
        self:DisableFly(character)
    end

    self.FlyData.Enabled = true
    self.FlyData.Speed = speed or 50

    -- BodyVelocity para movimento
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    self.FlyData.BodyVelocity = bv

    -- BodyGyro para estabilização
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.CFrame = root.CFrame
    bg.Parent = root
    self.FlyData.BodyGyro = bg

    humanoid.PlatformStand = true

    -- Controle de voo
    local UserInputService = game:GetService("UserInputService")
    local Camera = Workspace.CurrentCamera

    self.FlyData.Connection = RunService.Heartbeat:Connect(function()
        if not self.FlyData.Enabled or not root or not root.Parent then
            self:DisableFly(character)
            return
        end

        local moveVector = Vector3.new(0, 0, 0)
        local cameraCFrame = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * self.FlyData.Speed
        end

        self.FlyData.BodyVelocity.Velocity = moveVector
        self.FlyData.BodyGyro.CFrame = cameraCFrame
    end)

    return true
end

function TweenModule:DisableFly(character)
    character = character or LocalPlayer.Character
    local root = getRootPart(character)
    local humanoid = getHumanoid(character)

    self.FlyData.Enabled = false

    if self.FlyData.BodyVelocity then
        self.FlyData.BodyVelocity:Destroy()
        self.FlyData.BodyVelocity = nil
    end

    if self.FlyData.BodyGyro then
        self.FlyData.BodyGyro:Destroy()
        self.FlyData.BodyGyro = nil
    end

    if self.FlyData.Connection then
        self.FlyData.Connection:Disconnect()
        self.FlyData.Connection = nil
    end

    if humanoid then
        humanoid.PlatformStand = false
    end
end

function TweenModule:SetFlySpeed(speed)
    self.FlyData.Speed = speed
end

-- ========== LIMPEZA ==========

function TweenModule:Cleanup()
    self:CancelAllTweens()
    self:DisableNoclip()
    self:DisableFly()
    self.TweenCache = {}
end

-- Adicionar HttpService para GUID
local HttpService = game:GetService("HttpService")

return TweenModuleend)

-- [Core/Combat]
pcall(function()
--[[
    CUZAO HUB - Combat Module
    Funções de combate: attack, aim, skills, haki, ken
]]

local Combat = {}

-- Serviços
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

-- Estado
Combat.AutoClickerEnabled = false
Combat.AutoClickerConnection = nil
Combat.AimBotEnabled = false
Combat.AimBotConnection = nil
Combat.KillAuraEnabled = false
Combat.KillAuraConnection = nil
Combat.SkillSpamEnabled = false
Combat.SkillSpamConnection = nil
Combat.AutoHakiEnabled = false
Combat.AutoKenEnabled = false
Combat.KenConnection = nil

-- Configurações
Combat.Config = {
    AutoClicker = { Delay = 0.05, RightClick = false },
    AimBot = { FOV = 100, Smoothness = 0.5, TargetPart = "Head", TeamCheck = true, WallCheck = true, Prediction = 0.1 },
    KillAura = { Range = 30, TargetPlayers = false, TargetMobs = true, AttackDelay = 0.1 },
    SkillSpam = { Skills = {Z = true, X = true, C = true, V = false, F = false}, Delay = 0.5 },
    AutoHaki = true,
    AutoKen = false,
    KenDuration = 5,
}

-- ========== AUTO CLICKER ==========

function Combat:StartAutoClicker(config)
    config = config or self.Config.AutoClicker
    self:StopAutoClicker()

    self.AutoClickerEnabled = true
    self.AutoClickerConnection = RunService.Heartbeat:Connect(function()
        if not self.AutoClickerEnabled then return end

        local character = LocalPlayer.Character
        if not character then return end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            -- Tentar equipar arma do backpack
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                tool = backpack:FindFirstChildOfClass("Tool")
                if tool then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then humanoid:EquipTool(tool) end
                end
            end
        end

        if tool then
            if config.RightClick then
                tool:Activate()
            else
                -- Simular click esquerdo
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end

        task.wait(config.Delay)
    end)
end

function Combat:StopAutoClicker()
    self.AutoClickerEnabled = false
    if self.AutoClickerConnection then
        self.AutoClickerConnection:Disconnect()
        self.AutoClickerConnection = nil
    end
end

function Combat:SetAutoClickerDelay(delay)
    self.Config.AutoClicker.Delay = delay
end

-- ========== AIM BOT ==========

Combat.AimBotTarget = nil

function Combat:GetAimBotTarget(config)
    config = config or self.Config.AimBot
    local camera = Workspace.CurrentCamera
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not camera or not rootPart then return nil end

    local nearest = nil
    local shortestDistance = config.FOV
    local mousePos = UserInputService:GetMouseLocation()

    -- Verificar jogadores
    if config.TargetPlayers ~= false then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if config.TeamCheck and player.Team == LocalPlayer.Team then continue end

                local targetPart = player.Character:FindFirstChild(config.TargetPart)
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDistance then
                            -- Wall check
                            if config.WallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {character, player.Character}
                                local rayResult = Workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 500, rayParams)
                                if rayResult and rayResult.Instance:IsDescendantOf(player.Character) then
                                    -- Parede na frente, pular
                                else
                                    shortestDistance = dist
                                    nearest = {Player = player, Part = targetPart, ScreenPos = screenPos}
                                end
                            else
                                shortestDistance = dist
                                nearest = {Player = player, Part = targetPart, ScreenPos = screenPos}
                            end
                        end
                    end
                end
            end
        end
    end

    -- Verificar mobs
    if config.TargetMobs ~= false then
        local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in ipairs(mobsFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    local targetPart = mob:FindFirstChild(config.TargetPart) or mob:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortestDistance then
                                if config.WallCheck then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    rayParams.FilterDescendantsInstances = {character, mob}
                                    local rayResult = Workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 500, rayParams)
                                    if rayResult and rayResult.Instance:IsDescendantOf(mob) then
                                    else
                                        shortestDistance = dist
                                        nearest = {Mob = mob, Part = targetPart, ScreenPos = screenPos}
                                    end
                                else
                                    shortestDistance = dist
                                    nearest = {Mob = mob, Part = targetPart, ScreenPos = screenPos}
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nearest
end

function Combat:StartAimBot(config)
    config = config or self.Config.AimBot
    self:StopAimBot()

    self.AimBotEnabled = true
    self.AimBotConnection = RunService.RenderStepped:Connect(function()
        if not self.AimBotEnabled then return end

        local target = self:GetAimBotTarget(config)
        if target and target.Part then
            self.AimBotTarget = target

            local camera = Workspace.CurrentCamera
            local targetPos = target.Part.Position

            -- Prediction
            if config.Prediction and config.Prediction > 0 then
                local velocity = target.Part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                targetPos = targetPos + velocity * config.Prediction
            end

            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)

            if config.Mode == "Silent" then
                -- Silent aim: apenas modificar onde a bala vai (precisa de hook no remote)
                -- Por enquanto, apenas rotação da câmera
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, config.Smoothness)
            elseif config.Mode == "Legit" then
                -- Legit aim: mover mouse suavemente
                local currentCFrame = camera.CFrame
                camera.CFrame = currentCFrame:Lerp(targetCFrame, config.Smoothness)
            elseif config.Mode == "FOV" then
                -- Apenas mostrar FOV, não aimar automaticamente
            end
        else
            self.AimBotTarget = nil
        end
    end)
end

function Combat:StopAimBot()
    self.AimBotEnabled = false
    self.AimBotTarget = nil
    if self.AimBotConnection then
        self.AimBotConnection:Disconnect()
        self.AimBotConnection = nil
    end
end

-- ========== KILL AURA ==========

function Combat:StartKillAura(config)
    config = config or self.Config.KillAura
    self:StopKillAura()

    self.KillAuraEnabled = true
    self.KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not self.KillAuraEnabled then return end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local targets = {}

        -- Mobs
        if config.TargetMobs then
            local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
            if mobsFolder then
                for _, mob in ipairs(mobsFolder:GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mobRoot then
                            local dist = (rootPart.Position - mobRoot.Position).Magnitude
                            if dist <= config.Range then
                                table.insert(targets, {Model = mob, RootPart = mobRoot, Distance = dist, Type = "Mob"})
                            end
                        end
                    end
                end
            end
        end

        -- Players
        if config.TargetPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if player.Team == LocalPlayer.Team then continue end
                    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if playerRoot and humanoid and humanoid.Health > 0 then
                        local dist = (rootPart.Position - playerRoot.Position).Magnitude
                        if dist <= config.Range then
                            table.insert(targets, {Model = player.Character, RootPart = playerRoot, Distance = dist, Type = "Player"})
                        end
                    end
                end
            end
        end

        -- Ordenar por distância
        table.sort(targets, function(a, b) return a.Distance < b.Distance end)

        -- Atacar alvos
        for _, target in ipairs(targets) do
            self:AttackTarget(target.Model)
            task.wait(config.AttackDelay)
        end
    end)
end

function Combat:StopKillAura()
    self.KillAuraEnabled = false
    if self.KillAuraConnection then
        self.KillAuraConnection:Disconnect()
        self.KillAuraConnection = nil
    end
end

-- ========== ATTACK TARGET ==========

function Combat:AttackTarget(targetModel)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetModel:FindFirstChild("Humanoid")

    if not humanoid or not rootPart or not targetRoot or not targetHumanoid then return end
    if targetHumanoid.Health <= 0 then return end

    -- Olhar para o alvo
    rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z))

    -- Equipar arma se necessário
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            tool = backpack:FindFirstChildOfClass("Tool")
            if tool and humanoid then humanoid:EquipTool(tool) end
        end
    end

    -- Atacar
    if tool then
        tool:Activate()
    else
        -- Click vazio
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- ========== SKILLS ==========

Combat.SkillKeys = {
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
    F = Enum.KeyCode.F,
}

function Combat:UseSkill(skillKey)
    local keyCode = self.SkillKeys[skillKey]
    if not keyCode then return false end

    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    return true
end

function Combat:StartSkillSpam(config)
    config = config or self.Config.SkillSpam
    self:StopSkillSpam()

    self.SkillSpamEnabled = true
    self.SkillSpamConnection = RunService.Heartbeat:Connect(function()
        if not self.SkillSpamEnabled then return end

        for skill, enabled in pairs(config.Skills) do
            if enabled then
                self:UseSkill(skill)
                task.wait(config.Delay)
            end
        end

        task.wait(config.Delay)
    end)
end

function Combat:StopSkillSpam()
    self.SkillSpamEnabled = false
    if self.SkillSpamConnection then
        self.SkillSpamConnection:Disconnect()
        self.SkillSpamConnection = nil
    end
end

-- ========== HAKI ==========

function Combat:EnableBusoHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Buso")
    end)
    return success
end

function Combat:DisableBusoHaki()
    -- Buso é toggle, chamar novamente desativa
    return self:EnableBusoHaki()
end

function Combat:IsBusoActive()
    local character = LocalPlayer.Character
    if not character then return false end

    for _, child in ipairs(character:GetChildren()) do
        if child.Name:lower():find("haki") or child.Name:lower():find("buso") then
            return true
        end
    end
    return false
end

function Combat:StartAutoHaki()
    if self.AutoHakiEnabled then return end
    self.AutoHakiEnabled = true

    task.spawn(function()
        while self.AutoHakiEnabled do
            if not self:IsBusoActive() then
                self:EnableBusoHaki()
            end
            task.wait(1)
        end
    end)
end

function Combat:StopAutoHaki()
    self.AutoHakiEnabled = false
end

-- ========== KEN HAKI ==========

function Combat:EnableKenHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Ken", true)
    end)
    return success
end

function Combat:DisableKenHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Ken", false)
    end)
    return success
end

function Combat:IsKenActive()
    local character = LocalPlayer.Character
    if not character then return false end

    for _, child in ipairs(character:GetChildren()) do
        if child.Name:lower():find("ken") then
            return true
        end
    end
    return false
end

function Combat:StartAutoKen(config)
    config = config or self.Config
    if self.AutoKenEnabled then return end
    self.AutoKenEnabled = true

    task.spawn(function()
        while self.AutoKenEnabled do
            if not self:IsKenActive() then
                self:EnableKenHaki()
                task.wait(config.KenDuration or 5)
                self:DisableKenHaki()
            end
            task.wait(1)
        end
    end)
end

function Combat:StopAutoKen()
    self.AutoKenEnabled = false
    self:DisableKenHaki()
end

-- ========== WEAPON MANAGEMENT ==========

function Combat:GetEquippedWeapon()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
end

function Combat:GetWeaponType(tool)
    tool = tool or self:GetEquippedWeapon()
    if not tool then return "None" end

    local name = tool.Name:lower()
    if name:find("sword") or name:find("katana") or name:find("blade") or name:find("cutter") then
        return "Sword"
    elseif name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") then
        return "Gun"
    elseif name:find("fruit") or tool:FindFirstChild("Fruit") then
        return "Fruit"
    else
        return "Melee"
    end
end

function Combat:EquipBestWeapon(preferredType)
    preferredType = preferredType or "Melee"
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not backpack or not humanoid then return false end

    local bestTool = nil
    local bestPriority = 0

    -- Prioridades por tipo
    local priorities = {
        Melee = {"Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Godhuman", "Sharkman Karate", "Combat", "Black Leg", "Fishman Karate", "Electro", "Dark Step"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber", "Buddy Sword", "Canvander", "Dual Katana", "Iron Mace", "Triple Katana", "Pipe", "Dual-Headed Blade", "Bisento", "Soul Cane", "Katana", "Cutlass"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Kabucha", "Soul Guitar", "Bazooka", "Cannon", "Musket", "Flintlock", "Slingshot"},
        Fruit = {}, -- Frutas são equipadas automaticamente
    }

    local weaponList = priorities[preferredType] or priorities.Melee

    for _, weaponName in ipairs(weaponList) do
        local tool = backpack:FindFirstChild(weaponName) or (character and character:FindFirstChild(weaponName))
        if tool then
            bestTool = tool
            break
        end
    end

    if bestTool then
        humanoid:EquipTool(bestTool)
        return true
    end

    return false
end

-- ========== TARGET SELECTION ==========

function Combat:GetBestTarget(config)
    config = config or {}
    local range = config.Range or 50
    local targetPlayers = config.TargetPlayers ~= false
    local targetMobs = config.TargetMobs ~= false
    local teamCheck = config.TeamCheck ~= false

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local bestTarget = nil
    local bestScore = -math.huge

    -- Função de score
    local function evaluateTarget(model, targetType)
        local humanoid = model:FindFirstChild("Humanoid")
        local targetRoot = model:FindFirstChild("HumanoidRootPart")
        if not humanoid or not targetRoot or humanoid.Health <= 0 then return -1 end

        local dist = (rootPart.Position - targetRoot.Position).Magnitude
        if dist > range then return -1 end

        -- Score baseado em distância (mais perto = melhor) e vida (menos vida = melhor para kill)
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local score = (1 - dist / range) * 0.7 + (1 - healthPercent) * 0.3

        return score
    end

    if targetMobs then
        local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in ipairs(mobsFolder:GetChildren()) do
                if mob:IsA("Model") then
                    local score = evaluateTarget(mob, "Mob")
                    if score > bestScore then
                        bestScore = score
                        bestTarget = {Model = mob, Type = "Mob"}
                    end
                end
            end
        end
    end

    if targetPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if teamCheck and player.Team == LocalPlayer.Team then continue end
                local score = evaluateTarget(player.Character, "Player")
                if score > bestScore then
                    bestScore = score
                    bestTarget = {Model = player.Character, Type = "Player", Player = player}
                end
            end
        end
    end

    return bestTarget
end

-- ========== CLEANUP ==========

function Combat:Cleanup()
    self:StopAutoClicker()
    self:StopAimBot()
    self:StopKillAura()
    self:StopSkillSpam()
    self:StopAutoHaki()
    self:StopAutoKen()
end

return Combatend)

-- [Core/Inventory]
pcall(function()
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

return Inventoryend)

-- [Core/AntiCheat]
pcall(function()
--[[
    CUZAO HUB - AntiCheat Bypass Module
    Métodos para evitar detecção e banimentos
]]

local AntiCheat = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Estado
AntiCheat.Hooks = {}
AntiCheat.OriginalFunctions = {}
AntiCheat.BypassEnabled = false
AntiCheat.Connections = {}

-- ========== DETECÇÃO DE EXECUTOR ==========

AntiCheat.ExecutorInfo = {
    Name = "Unknown",
    Version = "Unknown",
    IsSupported = false,
}

function AntiCheat:DetectExecutor()
    local executors = {
        {"Synapse X", "syn", "syn_context_get"},
        {"Script-Ware", "sw", "sw_context_get"},
        {"Fluxus", "fluxus", "fluxus_loaded"},
        {"Delta", "delta", "delta_loaded"},
        {"Hydrogen", "hydrogen", "hydrogen_loaded"},
        {"Arceus X", "arceus", "arceus_loaded"},
        {"Codex", "codex", "codex_loaded"},
        {"Vega X", "vega", "vega_loaded"},
        {"Solara", "solara", "solara_loaded"},
        {"Wave", "wave", "wave_loaded"},
    }

    for _, exec in ipairs(executors) do
        local name, globalName, checkFunc = exec[1], exec[2], exec[3]
        if getgenv()[globalName] or getgenv()[checkFunc] or _G[globalName] then
            self.ExecutorInfo.Name = name
            self.ExecutorInfo.IsSupported = true
            break
        end
    end

    -- identifyexecutor se disponível
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success and name then
            self.ExecutorInfo.Name = name
            self.ExecutorInfo.IsSupported = true
        end
    end

    -- getexecutorname se disponível
    if getexecutorname then
        local success, name = pcall(getexecutorname)
        if success and name then
            self.ExecutorInfo.Name = name
            self.ExecutorInfo.IsSupported = true
        end
    end

    return self.ExecutorInfo
end

-- ========== BYPASS KICK/TELEPORT ==========

function AntiCheat:HookKick()
    local player = LocalPlayer
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall

    if not oldNamecall then return false end

    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Bloquear Kick
        if method == "Kick" and self == player then
            warn("[AntiCheat] Kick bloqueado: " .. tostring(args[1]))
            return
        end

        -- Bloquear Teleport não autorizado
        if method == "Teleport" and self == player then
            warn("[AntiCheat] Teleport bloqueado")
            return
        end

        return oldNamecall(self, unpack(args))
    end)

    setreadonly(mt, true)

    self.OriginalFunctions.Kick = oldNamecall
    return true
end

function AntiCheat:UnhookKick()
    if self.OriginalFunctions.Kick then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = self.OriginalFunctions.Kick
        setreadonly(mt, true)
        self.OriginalFunctions.Kick = nil
    end
end

-- ========== BYPASS REMOTE SPY ==========

function AntiCheat:HookRemotes()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local CommF_ = Remotes:WaitForChild("CommF_")
    local CommE = Remotes:WaitForChild("CommE")

    -- Hook CommF_ (InvokeServer)
    local mt = getrawmetatable(game)
    local oldInvoke = mt.__namecall

    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Log de remotes suspeitos (opcional)
        if self == CommF_ and method == "InvokeServer" then
            local remoteName = args[1]
            if type(remoteName) == "string" then
                -- Filtrar remotes de detecção
                local blockedRemotes = {
                    "Ban", "Kick", "Report", "Flag", "Detect", "AntiCheat",
                    "Crash", "Freeze", "Delete", "Remove", "Destroy"
                }

                for _, blocked in ipairs(blockedRemotes) do
                    if remoteName:lower():find(blocked:lower()) then
                        warn("[AntiCheat] Remote suspeito bloqueado: " .. remoteName)
                        return nil
                    end
                end
            end
        end

        return oldInvoke(self, unpack(args))
    end)

    setreadonly(mt, true)

    self.OriginalFunctions.InvokeServer = oldInvoke
    return true
end

function AntiCheat:UnhookRemotes()
    if self.OriginalFunctions.InvokeServer then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = self.OriginalFunctions.InvokeServer
        setreadonly(mt, true)
        self.OriginalFunctions.InvokeServer = nil
    end
end

-- ========== HUMANIZER ==========

AntiCheat.Humanizer = {
    Enabled = true,
    LastAction = 0,
    MinDelay = 0.05,
    MaxDelay = 0.2,
    ClickVariance = 0.03,
    MovementVariance = 0.1,
    CameraVariance = 0.05,
}

function AntiCheat:HumanizeDelay()
    if not self.Humanizer.Enabled then return 0 end

    local now = tick()
    local delay = math.random() * (self.Humanizer.MaxDelay - self.Humanizer.MinDelay) + self.Humanizer.MinDelay
    local timeSinceLast = now - self.Humanizer.LastAction

    if timeSinceLast < delay then
        task.wait(delay - timeSinceLast)
    end

    self.Humanizer.LastAction = tick()
    return delay
end

function AntiCheat:HumanizeClick()
    if not self.Humanizer.Enabled then return end

    local variance = self.Humanizer.ClickVariance
    local offsetX = (math.random() * 2 - 1) * variance * 10
    local offsetY = (math.random() * 2 - 1) * variance * 10

    return offsetX, offsetY
end

function AntiCheat:HumanizePosition(position)
    if not self.Humanizer.Enabled then return position end

    local variance = self.Humanizer.MovementVariance
    return position + Vector3.new(
        (math.random() * 2 - 1) * variance,
        (math.random() * 2 - 1) * variance * 0.5, -- Menos variação no Y
        (math.random() * 2 - 1) * variance
    )
end

function AntiCheat:HumanizeCamera(cframe)
    if not self.Humanizer.Enabled then return cframe end

    local variance = self.Humanizer.CameraVariance
    local angles = cframe:ToEulerAnglesXYZ()
    return CFrame.new(cframe.Position) * CFrame.Angles(
        angles.X + (math.random() * 2 - 1) * variance,
        angles.Y + (math.random() * 2 - 1) * variance,
        angles.Z + (math.random() * 2 - 1) * variance * 0.5
    )
end

-- ========== ANTI-AFK ==========

AntiCheat.AntiAFK = {
    Enabled = false,
    Connection = nil,
    LastInput = tick(),
}

function AntiCheat:EnableAntiAFK()
    if self.AntiAFK.Enabled then return end
    self.AntiAFK.Enabled = true

    local VirtualUser = game:GetService("VirtualUser")

    self.AntiAFK.Connection = LocalPlayer.Idled:Connect(function()
        if not self.AntiAFK.Enabled then return end

        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        self.AntiAFK.LastInput = tick()
    end)

    -- Simular input periódico
    task.spawn(function()
        while self.AntiAFK.Enabled do
            task.wait(math.random(30, 60))
            if self.AntiAFK.Enabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end
    end)
end

function AntiCheat:DisableAntiAFK()
    self.AntiAFK.Enabled = false
    if self.AntiAFK.Connection then
        self.AntiAFK.Connection:Disconnect()
        self.AntiAFK.Connection = nil
    end
end

-- ========== ANTI-CRASH ==========

AntiCheat.AntiCrash = {
    Enabled = false,
    Connections = {},
}

function AntiCheat:EnableAntiCrash()
    if self.AntiCrash.Enabled then return end
    self.AntiCrash.Enabled = true

    -- Prevenir loops infinitos no renderstepped
    local renderSteppedCount = 0
    local lastReset = tick()

    table.insert(self.AntiCrash.Connections, RunService.RenderStepped:Connect(function()
        renderSteppedCount = renderSteppedCount + 1
        if tick() - lastReset >= 1 then
            if renderSteppedCount > 1000 then -- Mais de 1000 callbacks por frame
                warn("[AntiCheat] Possível crash detectado, limpando...")
                self:Cleanup()
            end
            renderSteppedCount = 0
            lastReset = tick()
        end
    end))

    -- Monitorar memória
    task.spawn(function()
        while self.AntiCrash.Enabled do
            task.wait(10)
            local mem = collectgarbage("count")
            if mem > 500000 then -- 500MB
                warn("[AntiCheat] Memória alta: " .. mem .. " KB, coletando lixo...")
                collectgarbage("collect")
            end
        end
    end)
end

function AntiCheat:DisableAntiCrash()
    self.AntiCrash.Enabled = false
    for _, conn in ipairs(self.AntiCrash.Connections) do
        conn:Disconnect()
    end
    self.AntiCrash.Connections = {}
end

-- ========== SAFE MODE ==========

AntiCheat.SafeMode = {
    Enabled = false,
    Checks = {},
}

function AntiCheat:EnableSafeMode()
    self.SafeMode.Enabled = true

    -- Verificações periódicas
    self.SafeMode.Checks.Health = task.spawn(function()
        while self.SafeMode.Enabled do
            task.wait(1)
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                warn("[SafeMode] Personagem morreu, parando features...")
                self:NotifyDeath()
            end
        end
    end)

    self.SafeMode.Checks.Position = task.spawn(function()
        while self.SafeMode.Enabled do
            task.wait(5)
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local pos = rootPart.Position
                -- Verificar se está em área inválida (void, etc.)
                if pos.Y < -500 or pos.Magnitude > 100000 then
                    warn("[SafeMode] Posição inválida detectada: " .. tostring(pos))
                    self:NotifyInvalidPosition(pos)
                end
            end
        end
    end)

    self.SafeMode.Checks.FPS = task.spawn(function()
        while self.SafeMode.Enabled do
            task.wait(5)
            local fps = 1 / RunService.RenderStepped:Wait()
            if fps < 10 then
                warn("[SafeMode] FPS crítico: " .. math.floor(fps))
                self:NotifyLowFPS(fps)
            end
        end
    end)
end

function AntiCheat:DisableSafeMode()
    self.SafeMode.Enabled = false
    for _, thread in pairs(self.SafeMode.Checks) do
        if type(thread) == "thread" then
            task.cancel(thread)
        end
    end
    self.SafeMode.Checks = {}
end

function AntiCheat:NotifyDeath()
    -- Callback para outros módulos
    if self.OnDeath then self.OnDeath() end
end

function AntiCheat:NotifyInvalidPosition(pos)
    if self.OnInvalidPosition then self.OnInvalidPosition(pos) end
end

function AntiCheat:NotifyLowFPS(fps)
    if self.OnLowFPS then self.OnLowFPS(fps) end
end

-- ========== BYPASS DETECÇÃO DE VELOCIDADE ==========

AntiCheat.SpeedBypass = {
    Enabled = false,
    OriginalWalkSpeed = 16,
    Connection = nil,
}

function AntiCheat:EnableSpeedBypass(targetSpeed)
    if self.SpeedBypass.Enabled then return end
    self.SpeedBypass.Enabled = true

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        self.SpeedBypass.OriginalWalkSpeed = humanoid.WalkSpeed
    end

    self.SpeedBypass.Connection = RunService.Heartbeat:Connect(function()
        if not self.SpeedBypass.Enabled then return end

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            -- Não modificar WalkSpeed diretamente (detectável)
            -- Em vez disso, usar BodyVelocity ou CFrame manipulation
            -- Isso é feito no módulo Tween/Movement
        end
    end)
end

function AntiCheat:DisableSpeedBypass()
    self.SpeedBypass.Enabled = false
    if self.SpeedBypass.Connection then
        self.SpeedBypass.Connection:Disconnect()
        self.SpeedBypass.Connection = nil
    end

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = self.SpeedBypass.OriginalWalkSpeed
    end
end

-- ========== PROTEÇÃO DE VARIÁVEIS ==========

function AntiCheat:ProtectVariable(table, key, value)
    -- Usar metatable para proteger variáveis sensíveis
    local mt = getmetatable(table) or {}
    local originalIndex = mt.__index
    local originalNewindex = mt.__newindex

    mt.__index = function(t, k)
        if k == key then
            return value -- Retornar valor falso
        end
        return originalIndex and originalIndex(t, k) or rawget(t, k)
    end

    mt.__newindex = function(t, k, v)
        if k == key then
            -- Ignorar tentativas de modificação
            return
        end
        if originalNewindex then
            originalNewindex(t, k, v)
        else
            rawset(t, k, v)
        end
    end

    setmetatable(table, mt)
end

function AntiCheat:HideFromGetChildren(instance, name)
    -- Hook GetChildren para esconder instâncias
    local mt = getrawmetatable(game)
    local oldGetChildren = mt.__index

    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if k == "GetChildren" and t == instance then
            return function()
                local children = oldGetChildren(t, k)(t)
                local filtered = {}
                for _, child in ipairs(children) do
                    if child.Name ~= name then
                        table.insert(filtered, child)
                    end
                end
                return filtered
            end
        end
        return oldGetChildren(t, k)
    end)

    setreadonly(mt, true)
end

-- ========== INICIALIZAÇÃO ==========

function AntiCheat:Initialize(config)
    config = config or {}

    self:DetectExecutor()

    if config.BypassKick ~= false then
        self:HookKick()
    end

    if config.BypassRemotes ~= false then
        self:HookRemotes()
    end

    if config.AntiAFK ~= false then
        self:EnableAntiAFK()
    end

    if config.AntiCrash ~= false then
        self:EnableAntiCrash()
    end

    if config.SafeMode then
        self:EnableSafeMode()
    end

    if config.Humanizer ~= false then
        self.Humanizer.Enabled = true
    end

    self.BypassEnabled = true
    print("[AntiCheat] Inicializado - Executor: " .. self.ExecutorInfo.Name)

    return true
end

function AntiCheat:Cleanup()
    self:UnhookKick()
    self:UnhookRemotes()
    self:DisableAntiAFK()
    self:DisableAntiCrash()
    self:DisableSafeMode()
    self:DisableSpeedBypass()

    for _, conn in pairs(self.Connections) do
        if conn then conn:Disconnect() end
    end
    self.Connections = {}
    self.Hooks = {}
    self.BypassEnabled = false
end

function AntiCheat:GetStatus()
    return {
        Executor = self.ExecutorInfo.Name,
        BypassEnabled = self.BypassEnabled,
        Humanizer = self.Humanizer.Enabled,
        AntiAFK = self.AntiAFK.Enabled,
        AntiCrash = self.AntiCrash.Enabled,
        SafeMode = self.SafeMode.Enabled,
    }
end

return AntiCheatend)

-- [Core/Movement]
pcall(function()
--[[
    CUZAO HUB - Movement Module
    Sistemas de movimento: noclip, fly, speed, teleport, pathfinding
]]

local Movement = {}

-- Serviços
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

-- Estado
Movement.NoclipEnabled = false
Movement.NoclipConnection = nil
Movement.FlyEnabled = false
Movement.FlyConnection = nil
Movement.FlyBodyVelocity = nil
Movement.FlyBodyGyro = nil
Movement.SpeedEnabled = false
Movement.SpeedConnection = nil
Movement.OriginalWalkSpeed = 16
Movement.OriginalJumpPower = 50
Movement.InfiniteJumpEnabled = false
Movement.InfiniteJumpConnection = nil

-- Configurações
Movement.Config = {
    Noclip = {Enabled = false},
    Fly = {Enabled = false, Speed = 50, Keybind = Enum.KeyCode.F},
    Speed = {Enabled = false, Speed = 50},
    InfiniteJump = {Enabled = false},
    AutoJump = {Enabled = false},
    Teleport = {SafeMode = true, TweenSpeed = 350},
}

-- ========== FUNÇÕES AUXILIARES ==========

local function getRootPart(character)
    character = character or LocalPlayer.Character
    if character then return character:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getHumanoid(character)
    character = character or LocalPlayer.Character
    if character then return character:FindFirstChild("Humanoid") end
    return nil
end

-- ========== NOCLIP ==========

function Movement:EnableNoclip()
    if self.NoclipEnabled then return end
    self.NoclipEnabled = true
    self.Config.Noclip.Enabled = true

    self.NoclipConnection = RunService.Stepped:Connect(function()
        if not self.NoclipEnabled then return end

        local character = LocalPlayer.Character
        if not character then return end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)

    print("[Movement] Noclip ativado")
end

function Movement:DisableNoclip()
    if not self.NoclipEnabled then return end
    self.NoclipEnabled = false
    self.Config.Noclip.Enabled = false

    if self.NoclipConnection then
        self.NoclipConnection:Disconnect()
        self.NoclipConnection = nil
    end

    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end

    print("[Movement] Noclip desativado")
end

function Movement:ToggleNoclip()
    if self.NoclipEnabled then
        self:DisableNoclip()
    else
        self:EnableNoclip()
    end
    return self.NoclipEnabled
end

-- ========== FLY ==========

function Movement:EnableFly(speed)
    if self.FlyEnabled then return end
    speed = speed or self.Config.Fly.Speed

    local character = LocalPlayer.Character
    local rootPart = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not rootPart or not humanoid then return false end

    self.FlyEnabled = true
    self.Config.Fly.Enabled = true
    self.Config.Fly.Speed = speed

    -- BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = rootPart
    self.FlyBodyVelocity = bv

    -- BodyGyro
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart
    self.FlyBodyGyro = bg

    humanoid.PlatformStand = true

    -- Loop de controle
    self.FlyConnection = RunService.Heartbeat:Connect(function()
        if not self.FlyEnabled then return end

        local character = LocalPlayer.Character
        local rootPart = getRootPart(character)
        local humanoid = getHumanoid(character)
        local camera = Workspace.CurrentCamera

        if not rootPart or not humanoid or not camera then
            self:DisableFly()
            return
        end

        local moveVector = Vector3.new(0, 0, 0)
        local cameraCFrame = camera.CFrame

        -- Controles WASD + Space/Shift
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        -- Aplicar velocidade
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * self.Config.Fly.Speed
        end

        self.FlyBodyVelocity.Velocity = moveVector
        self.FlyBodyGyro.CFrame = cameraCFrame
    end)

    print("[Movement] Fly ativado - Velocidade: " .. speed)
    return true
end

function Movement:DisableFly()
    if not self.FlyEnabled then return end
    self.FlyEnabled = false
    self.Config.Fly.Enabled = false

    local character = LocalPlayer.Character
    local rootPart = getRootPart(character)
    local humanoid = getHumanoid(character)

    if self.FlyBodyVelocity then
        self.FlyBodyVelocity:Destroy()
        self.FlyBodyVelocity = nil
    end

    if self.FlyBodyGyro then
        self.FlyBodyGyro:Destroy()
        self.FlyBodyGyro = nil
    end

    if self.FlyConnection then
        self.FlyConnection:Disconnect()
        self.FlyConnection = nil
    end

    if humanoid then
        humanoid.PlatformStand = false
    end

    print("[Movement] Fly desativado")
end

function Movement:ToggleFly(speed)
    if self.FlyEnabled then
        self:DisableFly()
    else
        self:EnableFly(speed)
    end
    return self.FlyEnabled
end

function Movement:SetFlySpeed(speed)
    self.Config.Fly.Speed = speed
end

-- ========== SPEED HACK ==========

function Movement:EnableSpeed(speed)
    if self.SpeedEnabled then return end
    speed = speed or self.Config.Speed.Speed

    local character = LocalPlayer.Character
    local humanoid = getHumanoid(character)

    if not humanoid then return false end

    self.SpeedEnabled = true
    self.Config.Speed.Enabled = true
    self.Config.Speed.Speed = speed
    self.OriginalWalkSpeed = humanoid.WalkSpeed

    self.SpeedConnection = RunService.Heartbeat:Connect(function()
        if not self.SpeedEnabled then return end

        local character = LocalPlayer.Character
        local humanoid = getHumanoid(character)
        local rootPart = getRootPart(character)

        if humanoid and rootPart then
            -- Método 1: BodyVelocity (mais suave, menos detectável)
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local bv = rootPart:FindFirstChild("SpeedVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SpeedVelocity"
                    bv.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Não afetar Y
                    bv.Parent = rootPart
                end
                bv.Velocity = moveDir.Unit * speed
            else
                local bv = rootPart:FindFirstChild("SpeedVelocity")
                if bv then bv:Destroy() end
            end
        end
    end)

    print("[Movement] Speed ativado - Velocidade: " .. speed)
    return true
end

function Movement:DisableSpeed()
    if not self.SpeedEnabled then return end
    self.SpeedEnabled = false
    self.Config.Speed.Enabled = false

    local character = LocalPlayer.Character
    local humanoid = getHumanoid(character)
    local rootPart = getRootPart(character)

    if self.SpeedConnection then
        self.SpeedConnection:Disconnect()
        self.SpeedConnection = nil
    end

    -- Limpar BodyVelocity
    if rootPart then
        local bv = rootPart:FindFirstChild("SpeedVelocity")
        if bv then bv:Destroy() end
    end

    if humanoid then
        humanoid.WalkSpeed = self.OriginalWalkSpeed
    end

    print("[Movement] Speed desativado")
end

function Movement:ToggleSpeed(speed)
    if self.SpeedEnabled then
        self:DisableSpeed()
    else
        self:EnableSpeed(speed)
    end
    return self.SpeedEnabled
end

function Movement:SetSpeed(speed)
    self.Config.Speed.Speed = speed
end

-- ========== INFINITE JUMP ==========

function Movement:EnableInfiniteJump()
    if self.InfiniteJumpEnabled then return end
    self.InfiniteJumpEnabled = true
    self.Config.InfiniteJump.Enabled = true

    self.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not self.InfiniteJumpEnabled then return end

        local character = LocalPlayer.Character
        local humanoid = getHumanoid(character)

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    print("[Movement] Infinite Jump ativado")
end

function Movement:DisableInfiniteJump()
    if not self.InfiniteJumpEnabled then return end
    self.InfiniteJumpEnabled = false
    self.Config.InfiniteJump.Enabled = false

    if self.InfiniteJumpConnection then
        self.InfiniteJumpConnection:Disconnect()
        self.InfiniteJumpConnection = nil
    end

    print("[Movement] Infinite Jump desativado")
end

function Movement:ToggleInfiniteJump()
    if self.InfiniteJumpEnabled then
        self:DisableInfiniteJump()
    else
        self:EnableInfiniteJump()
    end
    return self.InfiniteJumpEnabled
end

-- ========== AUTO JUMP ==========

function Movement:EnableAutoJump()
    if self.Config.AutoJump.Enabled then return end
    self.Config.AutoJump.Enabled = true

    task.spawn(function()
        while self.Config.AutoJump.Enabled do
            task.wait(math.random(2, 5))

            local character = LocalPlayer.Character
            local humanoid = getHumanoid(character)
            local rootPart = getRootPart(character)

            if humanoid and rootPart and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function Movement:DisableAutoJump()
    self.Config.AutoJump.Enabled = false
end

-- ========== TELEPORT ==========

function Movement:TeleportTo(cframe, useTween, tweenSpeed)
    local character = LocalPlayer.Character
    local rootPart = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not rootPart then return false end

    useTween = useTween ~= false -- Default true
    tweenSpeed = tweenSpeed or self.Config.Teleport.TweenSpeed

    if useTween then
        local distance = (rootPart.Position - cframe.Position).Magnitude
        local duration = distance / tweenSpeed

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = cframe})

        tween:Play()
        tween.Completed:Wait()
    else
        rootPart.CFrame = cframe
    end

    return true
end

function Movement:TeleportToPosition(position, useTween, tweenSpeed)
    return self:TeleportTo(CFrame.new(position), useTween, tweenSpeed)
end

function Movement:TeleportToPart(targetPart, useTween, tweenSpeed, offset)
    if not targetPart then return false end

    offset = offset or CFrame.new(0, 3, 0)
    local targetCFrame = targetPart.CFrame * offset

    return self:TeleportTo(targetCFrame, useTween, tweenSpeed)
end

-- Teleport seguro (verifica colisão)
function Movement:SafeTeleport(targetCFrame, character)
    character = character or LocalPlayer.Character
    local rootPart = getRootPart(character)

    if not rootPart then return false end

    -- Raycast para baixo para encontrar chão
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character}
    rayParams.IgnoreWater = true

    local rayResult = Workspace:Raycast(
        targetCFrame.Position + Vector3.new(0, 10, 0),
        Vector3.new(0, -50, 0),
        rayParams
    )

    if rayResult then
        local safeCFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0), targetCFrame.LookVector)
        return self:TeleportTo(safeCFrame)
    else
        -- Sem chão, teleportar direto
        return self:TeleportTo(targetCFrame)
    end
end

-- ========== PATHFINDING ==========

function Movement:PathfindTo(targetPosition, options)
    options = options or {}
    local character = LocalPlayer.Character
    local rootPart = getRootPart(character)
    local humanoid = getHumanoid(character)

    if not rootPart or not humanoid then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = options.Radius or 2,
        AgentHeight = options.Height or 5,
        AgentCanJump = options.CanJump ~= false,
        AgentJumpHeight = options.JumpHeight or 10,
        AgentMaxSlope = options.MaxSlope or 45,
        WaypointSpacing = options.WaypointSpacing or 4,
        Costs = options.Costs,
    })

    local success, errorMsg = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        warn("[Movement] Pathfinding falhou: " .. tostring(errorMsg))
        -- Fallback: teleport direto
        return self:TeleportToPosition(targetPosition, true, options.TweenSpeed or 350)
    end

    local waypoints = path:GetWaypoints()
    if #waypoints < 2 then
        return self:TeleportToPosition(targetPosition, true, options.TweenSpeed or 350)
    end

    local currentWaypoint = 1

    local function moveToNextWaypoint()
        currentWaypoint = currentWaypoint + 1
        if currentWaypoint > #waypoints then
            if options.OnComplete then options.OnComplete(true) end
            return
        end

        local wp = waypoints[currentWaypoint]
        local targetCFrame = CFrame.new(wp.Position + Vector3.new(0, 3, 0))

        -- Verificar se waypoint precisa de pulo
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        local distance = (rootPart.Position - wp.Position).Magnitude
        local duration = distance / (options.TweenSpeed or 350)

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})

        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                moveToNextWaypoint()
            else
                if options.OnComplete then options.OnComplete(false) end
            end
        end)

        tween:Play()
    end

    moveToNextWaypoint()
    return true
end

-- ========== UTILITÁRIOS DE POSIÇÃO ==========

function Movement:GetPosition()
    local rootPart = getRootPart()
    return rootPart and rootPart.Position or Vector3.new(0, 0, 0)
end

function Movement:GetCFrame()
    local rootPart = getRootPart()
    return rootPart and rootPart.CFrame or CFrame.new(0, 0, 0)
end

function Movement:GetVelocity()
    local rootPart = getRootPart()
    return rootPart and rootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
end

function Movement:GetSpeed()
    local vel = self:GetVelocity()
    return Vector3.new(vel.X, 0, vel.Z).Magnitude
end

function Movement:IsGrounded()
    local character = LocalPlayer.Character
    local humanoid = getHumanoid(character)
    return humanoid and humanoid.FloorMaterial ~= Enum.Material.Air
end

function Movement:IsMoving()
    local humanoid = getHumanoid()
    return humanoid and humanoid.MoveDirection.Magnitude > 0
end

function Movement:GetMoveDirection()
    local humanoid = getHumanoid()
    return humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)
end

-- ========== WAYPOINTS ==========

Movement.Waypoints = {}

function Movement:AddWaypoint(name, position)
    self.Waypoints[name] = {
        Name = name,
        Position = position,
        CFrame = CFrame.new(position),
        TimeAdded = tick(),
    }
end

function Movement:RemoveWaypoint(name)
    self.Waypoints[name] = nil
end

function Movement:GetWaypoint(name)
    return self.Waypoints[name]
end

function Movement:TeleportToWaypoint(name, useTween, tweenSpeed)
    local wp = self.Waypoints[name]
    if not wp then return false end
    return self:TeleportToPosition(wp.Position, useTween, tweenSpeed)
end

function Movement:ListWaypoints()
    local list = {}
    for name, wp in pairs(self.Waypoints) do
        table.insert(list, {Name = name, Position = wp.Position})
    end
    return list
end

-- ========== CLEANUP ==========

function Movement:Cleanup()
    self:DisableNoclip()
    self:DisableFly()
    self:DisableSpeed()
    self:DisableInfiniteJump()
    self:DisableAutoJump()
    self.Waypoints = {}
end

function Movement:GetStatus()
    return {
        Noclip = self.NoclipEnabled,
        Fly = self.FlyEnabled,
        FlySpeed = self.Config.Fly.Speed,
        Speed = self.SpeedEnabled,
        SpeedValue = self.Config.Speed.Speed,
        InfiniteJump = self.InfiniteJumpEnabled,
        AutoJump = self.Config.AutoJump.Enabled,
        Position = self:GetPosition(),
        Grounded = self:IsGrounded(),
        Moving = self:IsMoving(),
        Velocity = self:GetVelocity(),
        Speed2D = self:GetSpeed(),
    }
end

return Movementend)

-- [Data/Locations]
pcall(function()
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

return Locationsend)

-- [Data/Fruits]
pcall(function()
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

return Fruitsend)

-- [Data/Weapons]
pcall(function()
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

return Weaponsend)

-- [Utils/Logger]
pcall(function()
--[[
    CUZAO HUB - Logger
    Sistema de logs coloridos e estruturados
]]

local Logger = {}

Logger.Config = {
    Enabled = true,
    Level = "INFO", -- DEBUG, INFO, WARN, ERROR
    ShowTimestamp = true,
    ShowModule = true,
    MaxHistory = 100,
}

Logger.History = {}

-- ANSI color codes for console
local Colors = {
    DEBUG = "\27[36m",   -- Cyan
    INFO = "\27[37m",    -- White
    WARN = "\27[33m",    -- Yellow
    ERROR = "\27[31m",   -- Red
    SUCCESS = "\27[32m", -- Green
    RESET = "\27[0m",
}

local Icons = {
    DEBUG = "🔍",
    INFO = "ℹ️ ",
    WARN = "⚠️ ",
    ERROR = "❌",
    SUCCESS = "✅",
}

local LevelPriority = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    SUCCESS = 2,
}

function Logger:ShouldLog(level)
    if not self.Config.Enabled then return false end
    local current = LevelPriority[self.Config.Level] or 2
    local target = LevelPriority[level] or 2
    return target >= current
end

function Logger:Log(level, module, message, data)
    if not self:ShouldLog(level) then return end

    local timestamp = os.date("%H:%M:%S")
    local prefix = Icons[level] or "•"

    local parts = {}
    if self.Config.ShowTimestamp then
        table.insert(parts, string.format("[%s]", timestamp))
    end
    table.insert(parts, string.format("[%s %s]", prefix, level))
    if self.Config.ShowModule and module then
        table.insert(parts, string.format("[%s]", module))
    end
    table.insert(parts, message)

    local logLine = table.concat(parts, " ")

    -- Console output
    local color = Colors[level] or ""
    print(color .. logLine .. Colors.RESET)

    -- Data dump
    if data then
        print("  Data: " .. tostring(data))
    end

    -- History
    table.insert(self.History, {
        Time = os.time(),
        Level = level,
        Module = module,
        Message = message,
        Data = data,
    })

    -- Trim history
    while #self.History > self.Config.MaxHistory do
        table.remove(self.History, 1)
    end
end

-- Shorthand methods
function Logger:Debug(module, message, data)
    self:Log("DEBUG", module, message, data)
end

function Logger:Info(module, message, data)
    self:Log("INFO", module, message, data)
end

function Logger:Warn(module, message, data)
    self:Log("WARN", module, message, data)
end

function Logger:Error(module, message, data)
    self:Log("ERROR", module, message, data)
end

function Logger:Success(module, message, data)
    self:Log("SUCCESS", module, message, data)
end

function Logger:SetLevel(level)
    self.Config.Level = level
end

function Logger:SetEnabled(enabled)
    self.Config.Enabled = enabled
end

function Logger:GetHistory(level)
    if level then
        local filtered = {}
        for _, entry in ipairs(self.History) do
            if entry.Level == level then
                table.insert(filtered, entry)
            end
        end
        return filtered
    end
    return self.History
end

function Logger:ClearHistory()
    self.History = {}
end

function Logger:ExportHistory()
    local lines = {}
    for _, entry in ipairs(self.History) do
        local line = string.format("[%s] [%s] [%s] %s",
            os.date("%Y-%m-%d %H:%M:%S", entry.Time),
            entry.Level,
            entry.Module or "Global",
            entry.Message
        )
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

return Loggerend)

-- [Utils/Notifications]
pcall(function()
--[[
    CUZAO HUB - Notifications
    Sistema de toast notifications melhorado
    Com suporte a Discord webhooks
]]

local Notifications = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

Notifications.Config = {
    Enabled = true,
    Duration = 4,
    MaxVisible = 5,
    Position = "TopRight",
    SoundEnabled = true,
    DiscordWebhook = "",
    DiscordOnFruit = false,
    DiscordOnFarm = false,
}

Notifications.Queue = {}
Notifications.Visible = {}

local NOTIF_COLORS = {
    Info = Color3.fromRGB(88, 101, 242),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Fruit = Color3.fromRGB(255, 165, 0),
    Raid = Color3.fromRGB(150, 0, 255),
    Farm = Color3.fromRGB(0, 200, 100),
}

local NOTIF_ICONS = {
    Info = "ℹ️",
    Success = "✅",
    Warning = "⚠️",
    Error = "❌",
    Fruit = "🍎",
    Raid = "🏴‍☠️",
    Farm = "⚔️",
}

function Notifications:CreateContainer()
    if self.Container then return self.Container end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CUZAO_Notifications"
    gui.DisplayOrder = 998
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 320, 1, 0)
    container.Position = UDim2.new(1, -330, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = gui

    Instance.new("UIListLayout", container).Padding = UDim.new(0, 6)
    container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    self.Container = container
    self.Gui = gui
    return container
end

function Notifications:Show(title, message, type, duration)
    type = type or "Info"
    duration = duration or self.Config.Duration

    if not self.Config.Enabled then return end

    self:CreateContainer()

    local color = NOTIF_COLORS[type] or NOTIF_COLORS.Info
    local icon = NOTIF_ICONS[type] or "📌"

    local container = self.Container

    -- Limit visible
    local visibleCount = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then visibleCount = visibleCount + 1 end
    end
    if visibleCount >= self.Config.MaxVisible then
        local oldest = container:FindFirstChildWhichIsA("Frame")
        if oldest then oldest:Destroy() end
    end

    -- Build notification
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = container

    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = color
    stroke.Thickness = 1.5

    -- Accent bar
    local bar = Instance.new("Frame", notif)
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0

    -- Icon
    local iconLabel = Instance.new("TextLabel", notif)
    iconLabel.Size = UDim2.new(0, 30, 0, 20)
    iconLabel.Position = UDim2.new(0, 10, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.TextSize = 14
    iconLabel.Font = Enum.Font.Gotham

    -- Title
    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -50, 0, 18)
    titleLabel.Position = UDim2.new(0, 36, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Message
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -50, 0, 14)
    msgLabel.Position = UDim2.new(0, 36, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    msgLabel.TextSize = 11
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextTruncate = Enum.TextTruncate.AtEnd

    -- Close button
    local closeBtn = Instance.new("TextButton", notif)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0, 6)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold

    -- Auto size
    notif.Size = UDim2.new(1, 0, 0, 48)

    -- Animate in
    notif.Position = UDim2.new(0, 340, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()

    -- Close handlers
    local function closeNotif()
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 340, 0, 0),
        }):Play()
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(closeNotif)

    -- Auto close
    task.delay(duration, closeNotif)

    -- Sound
    if self.Config.SoundEnabled then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://6042053626"
            sound.Volume = 0.3
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end

    -- Discord webhook (async)
    if self.Config.DiscordWebhook ~= "" then
        self:SendDiscord(title, message, type, color)
    end

    return notif
end

function Notifications:SendDiscord(title, message, type, color)
    if not self.Config.DiscordWebhook or self.Config.DiscordWebhook == "" then return end
    if type == "Fruit" and not self.Config.DiscordOnFruit then return end
    if type == "Farm" and not self.Config.DiscordOnFarm then return end

    task.spawn(function()
        pcall(function()
            local r = math.floor(color.R * 255)
            local g = math.floor(color.G * 255)
            local b = math.floor(color.B * 255)
            local hexColor = r * 65536 + g * 256 + b

            local embed = {
                title = title,
                description = message,
                color = hexColor,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                footer = {
                    text = "CUZAO HUB v" .. (getgenv().CUZAO_VERSION or "1.0.0"),
                },
            }

            local payload = HttpService:JSONEncode({
                username = "CUZAO HUB",
                embeds = {embed},
            })

            if request then
                request({
                    Url = self.Config.DiscordWebhook,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payload,
                })
            end
        end)
    end)
end

function Notifications:ClearAll()
    if self.Container then
        for _, child in ipairs(self.Container:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
    end
end

-- Convenience
function Notifications:Info(title, msg) self:Show(title, msg, "Info") end
function Notifications:Success(title, msg) self:Show(title, msg, "Success") end
function Notifications:Warn(title, msg) self:Show(title, msg, "Warning") end
function Notifications:Error(title, msg) self:Show(title, msg, "Error") end
function Notifications:Fruit(title, msg) self:Show(title, msg, "Fruit") end
function Notifications:Raid(title, msg) self:Show(title, msg, "Raid") end
function Notifications:Farm(title, msg) self:Show(title, msg, "Farm") end

return Notificationsend)

-- [Utils/Updater]
pcall(function()
--[[
    CUZAO HUB - Updater
    Auto-update via GitHub Releases
]]

local Updater = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

Updater.Config = {
    GitHubUser = "SEU_USER",
    GitHubRepo = "CUZAO-HUB",
    Branch = "main",
    CheckOnStart = true,
    AutoUpdate = false,
    NotifyOnUpdate = true,
}

Updater.CurrentVersion = getgenv().CUZAO_VERSION or "1.0.0"
Updater.LatestVersion = nil
Updater.UpdateAvailable = false

-- ═══════════════════════════════════════════
-- VERSION COMPARISON
-- ═══════════════════════════════════════════
local function ParseVersion(version)
    local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
    return {
        major = tonumber(major) or 0,
        minor = tonumber(minor) or 0,
        patch = tonumber(patch) or 0,
    }
end

function Updater:CompareVersions(v1, v2)
    local a = ParseVersion(v1)
    local b = ParseVersion(v2)

    if a.major ~= b.major then return a.major > b.major end
    if a.minor ~= b.minor then return a.minor > b.minor end
    if a.patch ~= b.patch then return a.patch > b.patch end
    return false
end

-- ═══════════════════════════════════════════
-- CHECK FOR UPDATES
-- ═══════════════════════════════════════════
function Updater:CheckForUpdates()
    local url = string.format(
        "https://api.github.com/repos/%s/%s/releases/latest",
        self.Config.GitHubUser,
        self.Config.GitHubRepo
    )

    local success, response = pcall(function()
        if request then
            return request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/vnd.github.v3+json" },
            })
        elseif http_request then
            return http_request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/vnd.github.v3+json" },
            })
        end
        return nil
    end)

    if success and response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        self.LatestVersion = data.tag_name

        if self:CompareVersions(self.LatestVersion, self.CurrentVersion) then
            self.UpdateAvailable = true
            return {
                Available = true,
                Version = self.LatestVersion,
                Changelog = data.body or "",
                URL = data.html_url or "",
                Assets = data.assets or {},
            }
        end
    end

    self.UpdateAvailable = false
    return { Available = false }
end

-- ═══════════════════════════════════════════
-- GET LATEST FILES
-- ═══════════════════════════════════════════
function Updater:GetFiles()
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents?ref=%s",
        self.Config.GitHubUser,
        self.Config.GitHubRepo,
        self.Config.Branch
    )

    local success, response = pcall(function()
        if request then
            return request({
                Url = url,
                Method = "GET",
            })
        end
        return nil
    end)

    if success and response and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

-- ═══════════════════════════════════════════
-- DOWNLOAD FILE
-- ═══════════════════════════════════════════
function Updater:DownloadFile(path)
    local url = string.format(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        self.Config.GitHubUser,
        self.Config.GitHubRepo,
        self.Config.Branch,
        path
    )

    local success, response = pcall(function()
        if httpget or (syn and syn.request) then
            if httpget then
                return httpget(url)
            else
                return syn.request({ Url = url, Method = "GET" }).Body
            end
        end
        return nil
    end)

    if success and response then
        return response
    end
    return nil
end

-- ═══════════════════════════════════════════
-- AUTO UPDATE
-- ═══════════════════════════════════════════
function Updater:AutoUpdate()
    local updateInfo = self:CheckForUpdates()

    if updateInfo.Available then
        print(string.format(
            "[CUZAO] Atualização disponível: %s (atual: %s)",
            updateInfo.Version,
            self.CurrentVersion
        ))

        if self.Config.NotifyOnUpdate and getgenv().CUZAO then
            pcall(function()
                local Notifications = getgenv().CUZAO.Modules["Notifications"]
                if Notifications then
                    Notifications:Show(
                        "Atualização Disponível",
                        "v" .. updateInfo.Version .. " disponível!",
                        "Info",
                        10
                    )
                end
            end)
        end

        if self.Config.AutoUpdate then
            self:UpdateFiles()
        end

        return updateInfo
    end

    return nil
end

function Updater:UpdateFiles()
    local files = self:GetFiles()
    if not files then return false end

    local updated = 0
    for _, file in ipairs(files) do
        if file.type == "file" and file.name:match("%.lua$") then
            local content = self:DownloadFile(file.path)
            if content and writefile then
                pcall(writefile, file.path, content)
                updated = updated + 1
                print("[CUZAO] Atualizado: " .. file.path)
            end
        end
    end

    print(string.format("[CUZAO] %d arquivos atualizados!", updated))
    return updated > 0
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function Updater:Init()
    if self.Config.CheckOnStart then
        task.spawn(function()
            task.wait(3) -- Wait for hub to load
            self:AutoUpdate()
        end)
    end
end

return Updaterend)

-- [Theme]
pcall(function()
local Theme = {}

Theme.Presets = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(24, 24, 24),
        Tertiary = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentSecondary = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        TextMuted = Color3.fromRGB(120, 120, 120),
        Border = Color3.fromRGB(40, 40, 40),
        BorderActive = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Hover = Color3.fromRGB(36, 36, 36),
        Pressed = Color3.fromRGB(42, 42, 42),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.5),
        TabBackground = Color3.fromRGB(22, 22, 22),
        TabHover = Color3.fromRGB(30, 30, 30),
        TabActive = Color3.fromRGB(88, 101, 242),
        ScrollBar = Color3.fromRGB(60, 60, 60),
        ScrollBarHover = Color3.fromRGB(80, 80, 80),
        NotificationBg = Color3.fromRGB(24, 24, 24),
        NotificationBorder = Color3.fromRGB(40, 40, 40),
        TooltipBg = Color3.fromRGB(30, 30, 30),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(24, 24, 24),
        InputBorder = Color3.fromRGB(40, 40, 40),
        InputFocused = Color3.fromRGB(88, 101, 242),
        Placeholder = Color3.fromRGB(100, 100, 100),
        Divider = Color3.fromRGB(40, 40, 40),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(250, 250, 250),
        Secondary = Color3.fromRGB(240, 240, 240),
        Tertiary = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentSecondary = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(20, 20, 20),
        TextSecondary = Color3.fromRGB(80, 80, 80),
        TextMuted = Color3.fromRGB(140, 140, 140),
        Border = Color3.fromRGB(220, 220, 220),
        BorderActive = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Hover = Color3.fromRGB(235, 235, 235),
        Pressed = Color3.fromRGB(225, 225, 225),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.3),
        TabBackground = Color3.fromRGB(245, 245, 245),
        TabHover = Color3.fromRGB(235, 235, 235),
        TabActive = Color3.fromRGB(88, 101, 242),
        ScrollBar = Color3.fromRGB(180, 180, 180),
        ScrollBarHover = Color3.fromRGB(160, 160, 160),
        NotificationBg = Color3.fromRGB(245, 245, 245),
        NotificationBorder = Color3.fromRGB(220, 220, 220),
        TooltipBg = Color3.fromRGB(30, 30, 30),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(255, 255, 255),
        InputBorder = Color3.fromRGB(200, 200, 200),
        InputFocused = Color3.fromRGB(88, 101, 242),
        Placeholder = Color3.fromRGB(150, 150, 150),
        Divider = Color3.fromRGB(220, 220, 220),
    },
    RGB = {
        Name = "RGB",
        Background = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(20, 20, 28),
        Tertiary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 0, 128),
        AccentSecondary = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        TextMuted = Color3.fromRGB(140, 140, 160),
        Border = Color3.fromRGB(40, 40, 60),
        BorderActive = Color3.fromRGB(255, 0, 128),
        Success = Color3.fromRGB(0, 255, 128),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 64, 64),
        Hover = Color3.fromRGB(30, 30, 45),
        Pressed = Color3.fromRGB(35, 35, 50),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.6),
        TabBackground = Color3.fromRGB(18, 18, 25),
        TabHover = Color3.fromRGB(25, 25, 35),
        TabActive = Color3.fromRGB(255, 0, 128),
        ScrollBar = Color3.fromRGB(50, 50, 70),
        ScrollBarHover = Color3.fromRGB(70, 70, 90),
        NotificationBg = Color3.fromRGB(20, 20, 28),
        NotificationBorder = Color3.fromRGB(40, 40, 60),
        TooltipBg = Color3.fromRGB(25, 25, 35),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(20, 20, 28),
        InputBorder = Color3.fromRGB(40, 40, 60),
        InputFocused = Color3.fromRGB(255, 0, 128),
        Placeholder = Color3.fromRGB(100, 100, 120),
        Divider = Color3.fromRGB(40, 40, 60),
        RGBEnabled = true,
        RGBSpeed = 2,
    },
    CUZAO = {
        Name = "CUZAO",
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 15, 15),
        Tertiary = Color3.fromRGB(28, 18, 18),
        Accent = Color3.fromRGB(255, 0, 0),
        AccentSecondary = Color3.fromRGB(200, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(220, 200, 200),
        TextMuted = Color3.fromRGB(160, 140, 140),
        Border = Color3.fromRGB(60, 30, 30),
        BorderActive = Color3.fromRGB(255, 0, 0),
        Success = Color3.fromRGB(200, 255, 100),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(255, 60, 60),
        Hover = Color3.fromRGB(35, 25, 25),
        Pressed = Color3.fromRGB(45, 30, 30),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(20, 0, 0, 0.7),
        TabBackground = Color3.fromRGB(18, 12, 12),
        TabHover = Color3.fromRGB(28, 18, 18),
        TabActive = Color3.fromRGB(255, 0, 0),
        ScrollBar = Color3.fromRGB(70, 35, 35),
        ScrollBarHover = Color3.fromRGB(100, 50, 50),
        NotificationBg = Color3.fromRGB(20, 15, 15),
        NotificationBorder = Color3.fromRGB(60, 30, 30),
        TooltipBg = Color3.fromRGB(28, 18, 18),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(20, 15, 15),
        InputBorder = Color3.fromRGB(60, 30, 30),
        InputFocused = Color3.fromRGB(255, 0, 0),
        Placeholder = Color3.fromRGB(140, 100, 100),
        Divider = Color3.fromRGB(60, 30, 30),
    },
}

Theme.Current = "Dark"
Theme.Active = Theme.Presets.Dark
Theme.RGBTime = 0
Theme.RGBConnection = nil

function Theme:SetTheme(name)
    local preset = self.Presets[name]
    if not preset then
        warn("[Theme] Tema não encontrado: " .. tostring(name))
        return false
    end

    self.Current = name
    self.Active = preset

    if self.RGBConnection then
        self.RGBConnection:Disconnect()
        self.RGBConnection = nil
    end

    if preset.RGBEnabled then
        self:StartRGB()
    end

    return true
end

function Theme:GetColor(key)
    return self.Active[key]
end

function Theme:GetCurrentThemeName()
    return self.Current
end

function Theme:StartRGB()
    local RunService = game:GetService("RunService")
    self.RGBTime = 0

    self.RGBConnection = RunService.RenderStepped:Connect(function(deltaTime)
        self.RGBTime = self.RGBTime + deltaTime * (self.Active.RGBSpeed or 2)

        local hue = (self.RGBTime * 50) % 360
        local saturation = 1
        local value = 1

        local function hsvToRgb(h, s, v)
            local c = v * s
            local x = c * (1 - math.abs((h / 60) % 2 - 1))
            local m = v - c
            local r, g, b

            if h < 60 then r, g, b = c, x, 0
            elseif h < 120 then r, g, b = x, c, 0
            elseif h < 180 then r, g, b = 0, c, x
            elseif h < 240 then r, g, b = 0, x, c
            elseif h < 300 then r, g, b = x, 0, c
            else r, g, b = c, 0, x end

            return Color3.new(r + m, g + m, b + m)
        end

        local rgbColor = hsvToRgb(hue, saturation, value)
        local rgbColor2 = hsvToRgb((hue + 180) % 360, saturation, value)

        self.Active.Accent = rgbColor
        self.Active.AccentSecondary = rgbColor2
        self.Active.BorderActive = rgbColor
        self.Active.TabActive = rgbColor
        self.Active.InputFocused = rgbColor
        self.Active.ScrollBarHover = rgbColor:Lerp(Color3.new(1, 1, 1), 0.3)
    end)
end

function Theme:StopRGB()
    if self.RGBConnection then
        self.RGBConnection:Disconnect()
        self.RGBConnection = nil
    end
end

function Theme:LerpColor(color1, color2, alpha)
    return color1:Lerp(color2, alpha)
end

function Theme:CreateGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    return gradient
end

function Theme:GetRGBColor(offset)
    if not self.Active.RGBEnabled then return self.Active.Accent end

    local hue = ((self.RGBTime * 50) + (offset or 0)) % 360
    local c = 1 * 1
    local x = c * (1 - math.abs((hue / 60) % 2 - 1))
    local m = 1 - c
    local r, g, b

    if hue < 60 then r, g, b = c, x, 0
    elseif hue < 120 then r, g, b = x, c, 0
    elseif hue < 180 then r, g, b = 0, c, x
    elseif hue < 240 then r, g, b = 0, x, c
    elseif hue < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end

    return Color3.new(r + m, g + m, b + m)
end

return Themeend)

-- [Library]
pcall(function()
--[[
    CUZAO HUB - UI Library (WindUI Customizado)
    Biblioteca principal de interface gráfica
    Baseado no WindUI, simplificado e otimizado para Blox Fruits
]]

local Library = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Modules (carregado do CUZAO global pois require() não funciona com loadstring)
local Theme = getgenv().CUZAO.Modules["Theme"]

-- Config
Library.Config = {
    Title = "CUZAO HUB",
    Subtitle = "Blox Fruits",
    Version = "1.0.0",
    Keybind = Enum.KeyCode.RightControl,
    MobileEnabled = true,
    NotificationDuration = 4,
    AnimationSpeed = 0.2,
    CornerRadius = UDim.new(0, 8),
    SmallCornerRadius = UDim.new(0, 4),
}

-- State
Library.Window = nil
Library.Tabs = {}
Library.CurrentTab = nil
Library.Notifications = {}
Library.Connections = {}
Library.IsOpen = false
Library.Screens = {}

-- Utility Functions
local function Create(className, props)
    local instance = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Children" then
            pcall(function() instance[k] = v end)
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = instance
        end
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

local function Tween(instance, props, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Config.AnimationSpeed,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or Library.Config.CornerRadius,
        Parent = parent,
    })
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        PaddingRight = UDim.new(0, right or 8),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness, mode)
    return Create("UIStroke", {
        Color = color or Theme:GetColor("Border"),
        Thickness = thickness or 1,
        ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function AddShadow(parent)
    return Create("ImageLabel", {
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        ZIndex = parent.ZIndex - 1,
        Parent = parent,
    })
end

local function RemoveConnections(tag)
    for _, conn in ipairs(Library.Connections) do
        if conn.Tag == tag then
            pcall(function() conn.Connection:Disconnect() end)
        end
    end
    Library.Connections = {}
end

-- ═══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════
function Library:Notify(title, message, type, duration)
    type = type or "Info"
    duration = duration or Library.Config.NotificationDuration

    local colors = {
        Info = Theme:GetColor("Accent"),
        Success = Theme:GetColor("Success"),
        Warning = Theme:GetColor("Warning"),
        Error = Theme:GetColor("Error"),
    }

    local icons = {
        Info = "ℹ️",
        Success = "✅",
        Warning = "⚠️",
        Error = "❌",
    }

    local notifContainer = CoreGui:FindFirstChild("CUZAO_Notifications")
    if not notifContainer then
        notifContainer = Create("ScreenGui", {
            Name = "CUZAO_Notifications",
            DisplayOrder = 999,
            ResetOnSpawn = false,
            Parent = CoreGui,
        })
    end

    local count = 0
    for _, v in ipairs(notifContainer:GetChildren()) do
        count = count + 1
    end

    local notif = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 60),
        Position = UDim2.new(1, -340, 0, 20 + (count * 70)),
        BackgroundColor3 = Theme:GetColor("NotificationBg"),
        BorderSizePixel = 0,
        Parent = notifContainer,
    })
    AddCorner(notif)
    AddStroke(notif, colors[type], 1.5)

    Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = colors[type],
        BorderSizePixel = 0,
        Parent = notif,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 25),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Text = (icons[type] or "") .. " " .. title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 16, 0, 32),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif,
    })

    -- Animate in
    notif.Position = UDim2.new(1, 350, 0, 20 + (count * 70))
    Tween(notif, {Position = UDim2.new(1, -340, 0, 20 + (count * 70))}, 0.4, Enum.EasingStyle.Back)

    -- Auto remove
    task.delay(duration, function()
        if not notif then return end
        Tween(notif, {Position = UDim2.new(1, 350, 0, notif.Position.Y.Offset)}, 0.3, Enum.EasingStyle.Quint)
        task.delay(0.35, function()
            notif:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or Library.Config.Title
    local subtitle = config.Subtitle or Library.Config.Subtitle
    local size = config.Size or UDim2.new(0, 620, 0, 420)

    -- Destroy old window
    if Library.Window then
        Library.Window:Destroy()
    end

    -- ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "CUZAO_HUB",
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    Library.Screen = screenGui

    -- Main Frame
    local mainFrame = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme:GetColor("Background"),
        BorderSizePixel = 0,
        Parent = screenGui,
        ClipsDescendants = true,
    })
    AddCorner(mainFrame)
    AddShadow(mainFrame)

    -- Glow effect
    Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    local glowStroke = Create("UIStroke", {
        Color = Theme:GetColor("Accent"),
        Thickness = 1.5,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = mainFrame,
    })

    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    AddCorner(titleBar, UDim.new(0, 8))
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    -- CUZAO Logo / Icon
    Create("TextLabel", {
        Name = "Logo",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "C",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        Parent = titleBar,
    })
    AddCorner(Create("Frame", {Parent = titleBar}), UDim.new(0, 8))

    local logoFrame = titleBar:FindFirstChild("Logo")
    -- re-do logo properly
    logoFrame:ClearAllChildren()
    AddCorner(logoFrame, UDim.new(0, 6))

    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 50, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 50, 0, 26),
        BackgroundTransparency = 1,
        Text = subtitle .. " • v" .. Library.Config.Version,
        TextColor3 = Theme:GetColor("TextMuted"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Close Button
    local closeBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -44, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Error"),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
    })
    AddCorner(closeBtn, UDim.new(0, 6))

    -- Minimize Button
    local minimizeBtn = Create("TextButton", {
        Name = "MinBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Warning"),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
    })
    AddCorner(minimizeBtn, UDim.new(0, 6))

    -- Content Area
    local contentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })

    -- Sidebar (Tabs)
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    AddCorner(sidebar, UDim.new(0, 8))

    -- Tab content area
    local tabContent = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -150, 1, -10),
        Position = UDim2.new(0, 145, 0, 5),
        BackgroundColor3 = Theme:GetColor("Tertiary"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    AddCorner(tabContent)
    AddPadding(tabContent, 8, 8, 8, 8)

    -- Store references
    Library.Window = mainFrame
    Library.Sidebar = sidebar
    Library.TabContent = tabContent
    Library.GlowStroke = glowStroke
    Library.TitleBar = titleBar

    -- ═══ Dragging ═══
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ═══ Close / Minimize ═══
    closeBtn.MouseButton1Click:Connect(function()
        Library:Close()
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(mainFrame, {Size = UDim2.new(0, 620, 0, 50)}, 0.3)
            minimizeBtn.Text = "+"
        else
            Tween(mainFrame, {Size = size}, 0.3)
            minimizeBtn.Text = "−"
        end
    end)

    -- ═══ Keybind Toggle ═══
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.Config.Keybind then
            Library:Toggle()
        end
    end)

    Library.IsOpen = true
    return Library
end

-- ═══════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════
function Library:CreateTab(config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or "📁"
    local tabOrder = #Library.Tabs + 1

    -- Tab Button (Sidebar)
    local tabBtn = Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, -10, 0, 36),
        Position = UDim2.new(0, 5, 0, 10 + (tabOrder * 40)),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        Parent = Library.Sidebar,
    })
    AddCorner(tabBtn, UDim.new(0, 6))

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. name,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })
    AddPadding(tabBtn, 0, 0, 10, 0)

    -- Tab Content Frame
    local tabFrame = Create("ScrollingFrame", {
        Name = "Content_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme:GetColor("ScrollBar"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Library.TabContent,
    })

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = tabFrame,
    })
    AddPadding(tabFrame, 4, 4, 4, 4)

    -- Tab data
    local tabData = {
        Name = name,
        Icon = icon,
        Button = tabBtn,
        Frame = tabFrame,
        Order = tabOrder,
        Sections = {},
    }
    Library.Tabs[name] = tabData

    -- Tab click
    tabBtn.MouseButton1Click:Connect(function()
        Library:SelectTab(name)
    end)

    -- Hover effects
    tabBtn.MouseEnter:Connect(function()
        if Library.CurrentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = Theme:GetColor("TabHover")}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if Library.CurrentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = Theme:GetColor("TabBackground")}, 0.15)
        end
    end)

    -- Auto select first tab
    if tabOrder == 1 then
        Library:SelectTab(name)
    end

    -- Section creator scoped to this tab
    local tabAPI = {}

    function tabAPI:CreateSection(sectionName)
        sectionName = sectionName or "Section"
        local sectionFrame = Create("Frame", {
            Name = "Section_" .. sectionName,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = #tabFrame:GetChildren() * 10,
            Parent = tabFrame,
        })

        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            Parent = sectionFrame,
        })

        -- Section Header
        Create("TextLabel", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = "  " .. sectionName,
            TextColor3 = Theme:GetColor("Accent"),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = sectionFrame,
        })

        local sectionAPI = {}

        function sectionAPI:AddParagraph(config, desc)
            -- Suporta tanto AddParagraph("text", "desc") quanto AddParagraph({Title = "...", Desc = "..."})
            local text, description
            if type(config) == "table" then
                text = config.Title or config.Text or ""
                description = config.Desc or config.Description
            else
                text = config or ""
                description = desc
            end

            local paraFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            local label = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 4),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                Parent = paraFrame,
            })

            if description then
                Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 0),
                    Position = UDim2.new(0, 8, 0, 24),
                    BackgroundTransparency = 1,
                    Text = description,
                    TextColor3 = Theme:GetColor("TextMuted"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    Parent = paraFrame,
                })
            end

            return paraFrame
        end

        function sectionAPI:AddButton(config)
            local btnConfig = config or {}
            local text = btnConfig.Text or "Button"
            local callback = btnConfig.Callback or function() end

            local btnFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme:GetColor("Accent"),
                BorderSizePixel = 0,
                Text = text,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                Parent = btnFrame,
            })
            AddCorner(btn, Library.Config.SmallCornerRadius)

            btn.MouseButton1Click:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
                pcall(callback)
            end)

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("AccentSecondary")}, 0.1)
            end)

            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
            end)

            return btn
        end

        function sectionAPI:AddToggle(config)
            local toggleConfig = config or {}
            local text = toggleConfig.Text or "Toggle"
            local default = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end
            local flag = toggleConfig.Flag

            local toggled = default
            local toggleFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame,
            })

            local toggleBg = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -48, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = toggled and Theme:GetColor("Accent") or Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Parent = toggleFrame,
            })
            AddCorner(toggleBg, UDim.new(1, 0))

            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = toggled and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Parent = toggleBg,
            })
            AddCorner(toggleCircle, UDim.new(1, 0))

            local toggleBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = toggleFrame,
            })

            local function updateToggle()
                toggled = not toggled
                if toggled then
                    Tween(toggleBg, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.2)
                    Tween(toggleCircle, {Position = UDim2.new(1, -20, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                else
                    Tween(toggleBg, {BackgroundColor3 = Theme:GetColor("Border")}, 0.2)
                    Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                end
                pcall(callback, toggled)
            end

            toggleBtn.MouseButton1Click:Connect(updateToggle)

            local toggleAPI = {}
            function toggleAPI:Set(value)
                if value ~= toggled then
                    updateToggle()
                end
            end
            function toggleAPI:Get()
                return toggled
            end

            return toggleAPI
        end

        function sectionAPI:AddSlider(config)
            local sliderConfig = config or {}
            local text = sliderConfig.Text or "Slider"
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or 50
            local callback = sliderConfig.Callback or function() end
            local suffix = sliderConfig.Suffix or ""

            local currentValue = default
            local sliderFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame,
            })

            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -58, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(currentValue) .. suffix,
                TextColor3 = Theme:GetColor("Accent"),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame,
            })

            local track = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 6),
                Position = UDim2.new(0, 8, 0, 30),
                BackgroundColor3 = Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Parent = sliderFrame,
            })
            AddCorner(track, UDim.new(1, 0))

            local fillPercent = (currentValue - min) / (max - min)
            local fill = Create("Frame", {
                Size = UDim2.new(fillPercent, 0, 1, 0),
                BackgroundColor3 = Theme:GetColor("Accent"),
                BorderSizePixel = 0,
                Parent = track,
            })
            AddCorner(fill, UDim.new(1, 0))

            local knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(fillPercent, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Parent = track,
            })
            AddCorner(knob, UDim.new(1, 0))
            AddStroke(knob, Theme:GetColor("Accent"), 2)

            local dragging = false

            local function updateSlider(inputX)
                local trackAbsPos = track.AbsolutePosition.X
                local trackAbsSize = track.AbsoluteSize.X
                local relativeX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                currentValue = math.floor(min + (max - min) * relativeX)

                Tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1)
                Tween(knob, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, 0.1)
                valueLabel.Text = tostring(currentValue) .. suffix
                pcall(callback, currentValue)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position.X)
                end
            end)

            track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            local sliderAPI = {}
            function sliderAPI:Set(value)
                currentValue = math.clamp(value, min, max)
                local pct = (currentValue - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valueLabel.Text = tostring(currentValue) .. suffix
            end
            function sliderAPI:Get()
                return currentValue
            end

            return sliderAPI
        end

        function sectionAPI:AddDropdown(config)
            local ddConfig = config or {}
            local text = ddConfig.Text or "Dropdown"
            local options = ddConfig.Options or {}
            local default = ddConfig.Default or options[1] or ""
            local callback = ddConfig.Callback or function() end

            local isOpen = false
            local currentValue = default

            local ddFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                ClipsDescendants = false,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ddFrame,
            })

            local selectBtn = Create("TextButton", {
                Size = UDim2.new(0, 140, 0, 28),
                Position = UDim2.new(1, -148, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = "",
                Parent = ddFrame,
            })
            AddCorner(selectBtn, Library.Config.SmallCornerRadius)
            AddStroke(selectBtn, Theme:GetColor("InputBorder"))

            local selectedLabel = Create("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = currentValue,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = selectBtn,
            })

            Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme:GetColor("TextMuted"),
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = selectBtn,
            })

            -- Dropdown list (expanded below)
            local listFrame = Create("Frame", {
                Name = "List",
                Size = UDim2.new(0, 140, 0, math.min(#options, 6) * 28 + 8),
                Position = UDim2.new(1, -148, 0, 34),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                ZIndex = 10,
                ClipsDescendants = true,
                Visible = false,
                Parent = ddFrame,
            })
            AddCorner(listFrame, Library.Config.SmallCornerRadius)
            AddStroke(listFrame, Theme:GetColor("InputBorder"))

            local listLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = listFrame,
            })
            AddPadding(listFrame, 4, 4, 4, 4)

            for i, option in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme:GetColor("Hover"),
                    BackgroundTransparency = option == currentValue and 0 or 1,
                    BorderSizePixel = 0,
                    Text = "  " .. option,
                    TextColor3 = Theme:GetColor("Text"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                    Parent = listFrame,
                })
                AddCorner(optBtn, UDim.new(0, 4))

                optBtn.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    isOpen = false
                    listFrame.Visible = false

                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = child.Text == "  " .. option and 0 or 1
                        end
                    end

                    pcall(callback, option)
                end)
            end

            selectBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                listFrame.Visible = isOpen
            end)

            local ddAPI = {}
            function ddAPI:Set(value)
                currentValue = value
                selectedLabel.Text = value
            end
            function ddAPI:Get()
                return currentValue
            end
            function ddAPI:Refresh(newOptions)
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                listFrame.Size = UDim2.new(0, 140, 0, math.min(#newOptions, 6) * 28 + 8)
                for i, opt in ipairs(newOptions) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme:GetColor("Hover"),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = "  " .. opt,
                        TextColor3 = Theme:GetColor("Text"),
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11,
                        Parent = listFrame,
                    })
                    AddCorner(optBtn, UDim.new(0, 4))
                    optBtn.MouseButton1Click:Connect(function()
                        currentValue = opt
                        selectedLabel.Text = opt
                        isOpen = false
                        listFrame.Visible = false
                        pcall(callback, opt)
                    end)
                end
            end

            return ddAPI
        end

        function sectionAPI:AddKeybind(config)
            local kbConfig = config or {}
            local text = kbConfig.Text or "Keybind"
            local default = kbConfig.Default or Enum.KeyCode.Unknown
            local callback = kbConfig.Callback or function() end
            local changedCallback = kbConfig.ChangedCallback or function() end

            local currentBind = default
            local listening = false

            local kbFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = kbFrame,
            })

            local bindBtn = Create("TextButton", {
                Size = UDim2.new(0, 90, 0, 28),
                Position = UDim2.new(1, -98, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = currentBind.Name or "None",
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Parent = kbFrame,
            })
            AddCorner(bindBtn, Library.Config.SmallCornerRadius)
            AddStroke(bindBtn, Theme:GetColor("InputBorder"))

            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
                Tween(bindBtn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.15)
            end)

            local kbConnection
            kbConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentBind = input.KeyCode
                    bindBtn.Text = currentBind.Name
                    listening = false
                    Tween(bindBtn, {BackgroundColor3 = Theme:GetColor("InputBg")}, 0.15)
                    pcall(changedCallback, currentBind)
                end
            end)

            local kbAPI = {}
            function kbAPI:Set(key)
                currentBind = key
                bindBtn.Text = key.Name or "None"
            end
            function kbAPI:Get()
                return currentBind
            end

            return kbAPI
        end

        function sectionAPI:AddColorPicker(config)
            local cpConfig = config or {}
            local text = cpConfig.Text or "Color"
            local default = cpConfig.Default or Theme:GetColor("Accent")
            local callback = cpConfig.Callback or function() end

            local currentColor = default
            local isOpen = false

            local cpFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                ClipsDescendants = false,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cpFrame,
            })

            local colorPreview = Create("TextButton", {
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(1, -36, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0,
                Text = "",
                Parent = cpFrame,
            })
            AddCorner(colorPreview, UDim.new(0, 6))
            AddStroke(colorPreview, Theme:GetColor("Border"))

            local palette = Create("Frame", {
                Name = "Palette",
                Size = UDim2.new(0, 180, 0, 120),
                Position = UDim2.new(1, -188, 0, 42),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                ZIndex = 15,
                ClipsDescendants = true,
                Visible = false,
                Parent = cpFrame,
            })
            AddCorner(palette, UDim.new(0, 6))
            AddStroke(palette, Theme:GetColor("InputBorder"))

            -- Preset colors grid
            local presetColors = {
                Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0),
                Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 128, 255),
                Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128),
                Color3.fromRGB(64, 64, 64), Color3.fromRGB(0, 0, 0),
                Color3.fromRGB(255, 100, 100), Color3.fromRGB(100, 255, 100),
                Color3.fromRGB(100, 100, 255), Color3.fromRGB(255, 200, 50),
                Color3.fromRGB(200, 100, 255), Color3.fromRGB(100, 255, 200),
            }

            local grid = Create("UIGridLayout", {
                CellSize = UDim2.new(0, 26, 0, 26),
                CellPadding = UDim2.new(0, 3, 0, 3),
                Parent = palette,
            })
            AddPadding(palette, 6, 6, 6, 6)

            for _, color in ipairs(presetColors) do
                local swatch = Create("TextButton", {
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 16,
                    Parent = palette,
                })
                AddCorner(swatch, UDim.new(0, 4))

                swatch.MouseButton1Click:Connect(function()
                    currentColor = color
                    Tween(colorPreview, {BackgroundColor3 = color}, 0.15)
                    isOpen = false
                    palette.Visible = false
                    pcall(callback, color)
                end)
            end

            colorPreview.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                palette.Visible = isOpen
            end)

            local cpAPI = {}
            function cpAPI:Set(color)
                currentColor = color
                colorPreview.BackgroundColor3 = color
            end
            function cpAPI:Get()
                return currentColor
            end

            return cpAPI
        end

        function sectionAPI:AddInput(config)
            local inputConfig = config or {}
            local text = inputConfig.Text or "Input"
            local placeholder = inputConfig.Placeholder or ""
            local default = inputConfig.Default or ""
            local callback = inputConfig.Callback or function() end

            local inputFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputFrame,
            })

            local textBox = Create("TextBox", {
                Size = UDim2.new(1, -16, 0, 30),
                Position = UDim2.new(0, 8, 0, 22),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme:GetColor("Placeholder"),
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = inputFrame,
            })
            AddCorner(textBox, Library.Config.SmallCornerRadius)
            AddStroke(textBox, Theme:GetColor("InputBorder"))
            AddPadding(textBox, 0, 0, 8, 8)

            textBox.Focused:Connect(function()
                Tween(textBox, {BorderColor3 = Theme:GetColor("Accent")}, 0.15)
            end)

            textBox.FocusLost:Connect(function()
                Tween(textBox, {BorderColor3 = Theme:GetColor("InputBorder")}, 0.15)
                pcall(callback, textBox.Text)
            end)

            local inputAPI = {}
            function inputAPI:Set(value)
                textBox.Text = value
            end
            function inputAPI:Get()
                return textBox.Text
            end

            return inputAPI
        end

        tabData.Sections[sectionName] = sectionAPI
        return sectionAPI
    end

    return tabAPI
end

-- ═══════════════════════════════════════════
-- TAB NAVIGATION
-- ═══════════════════════════════════════════
function Library:SelectTab(name)
    local tab = Library.Tabs[name]
    if not tab then return end

    -- Deselect all
    for tabName, tabData in pairs(Library.Tabs) do
        tabData.Frame.Visible = false
        Tween(tabData.Button, {BackgroundColor3 = Theme:GetColor("TabBackground")}, 0.15)
        local label = tabData.Button:FindFirstChildWhichIsA("TextLabel")
        if label then
            Tween(label, {TextColor3 = Theme:GetColor("TextSecondary")}, 0.15)
        end
    end

    -- Select target
    tab.Frame.Visible = true
    Tween(tab.Button, {BackgroundColor3 = Theme:GetColor("TabActive")}, 0.15)
    local label = tab.Button:FindFirstChildWhichIsA("TextLabel")
    if label then
        Tween(label, {TextColor3 = Color3.new(1, 1, 1)}, 0.15)
    end

    Library.CurrentTab = name
end

-- ═══════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════
function Library:Toggle()
    if Library.IsOpen then
        Library:Close()
    else
        Library:Open()
    end
end

function Library:Open()
    if not Library.Window then return end
    Library.IsOpen = true
    Library.Window.Visible = true
    Library.Window.Size = UDim2.new(0, 0, 0, 0)
    Library.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(Library.Window, {Size = UDim2.new(0, 620, 0, 420)}, 0.4, Enum.EasingStyle.Back)
end

function Library:Close()
    if not Library.Window then return end
    Library.IsOpen = false
    Tween(Library.Window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
    task.delay(0.3, function()
        if Library.Window then
            Library.Window.Visible = false
        end
    end)
end

function Library:Destroy()
    if Library.Window then
        Library.Window:Destroy()
        Library.Window = nil
    end
    if Library.Screen then
        Library.Screen:Destroy()
        Library.Screen = nil
    end
    Theme:StopRGB()
    Library.Tabs = {}
    Library.IsOpen = false
end

function Library:UpdateTheme(themeName)
    Theme:SetTheme(themeName)
    -- In a full implementation, this would update all UI elements
    self:Notify("Theme", "Tema alterado para " .. themeName, "Info")
end

return Libraryend)

-- [Window]
pcall(function()
--[[
    CUZAO HUB - Window Component
    Janela principal reutilizável com tabs, drag, resize
    Pode ser usada como extensão da Library ou standalone
]]

local Window = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme carregado do CUZAO global (require() não funciona com loadstring/HttpGet)
local Theme = getgenv().CUZAO.Modules["Theme"]

-- ═══════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════
local function Create(className, props)
    local instance = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Children" then
            pcall(function() instance[k] = v end)
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = instance
        end
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

local function Tween(instance, props, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 8),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme:GetColor("Border"),
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function AddPadding(parent, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft = UDim.new(0, l or 8),
        PaddingRight = UDim.new(0, r or 8),
        Parent = parent,
    })
end

-- ═══════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════
function Window.new(config)
    config = config or {}

    local self = setmetatable({}, {__index = Window})

    self.Title = config.Title or "CUZAO HUB"
    self.Subtitle = config.Subtitle or ""
    self.Size = config.Size or UDim2.new(0, 620, 0, 420)
    self.Resizable = config.Resizable ~= false
    self.Keybind = config.Keybind or Enum.KeyCode.RightControl
    self.Parent = config.Parent or game:GetService("CoreGui")

    self.Tabs = {}
    self.CurrentTab = nil
    self.IsOpen = false
    self.IsDragging = false
    self.IsMinimized = false
    self.IsFocused = false
    self.Connections = {}

    self:_Create()
    self:_SetupDrag()
    self:_SetupKeybind()

    return self
end

function Window:_Create()
    -- ScreenGui
    self.Gui = Create("ScreenGui", {
        Name = "CUZAO_Window_" .. self.Title:gsub("%s+", "_"),
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = self.Parent,
    })

    -- Main Container
    self.Container = Create("Frame", {
        Name = "Container",
        Size = self.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme:GetColor("Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
    })
    AddCorner(self.Container)
    self:_AddShadow()

    -- Glow border
    self.BorderGlow = AddStroke(self.Container, Theme:GetColor("Accent"), 1.5)
    self.BorderGlow.Transparency = 0.4

    -- Title Bar
    self:_CreateTitleBar()

    -- Content area
    self:_CreateContentArea()

    self.IsOpen = true
end

function Window:_CreateTitleBar()
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = self.Container,
    })
    AddCorner(self.TitleBar, UDim.new(0, 8))
    -- Fill bottom corners
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = self.TitleBar,
    })

    -- Logo
    local logo = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = self.TitleBar,
    })
    AddCorner(logo, UDim.new(0, 6))
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "C",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBlack,
        ZIndex = 7,
        Parent = logo,
    })

    -- Title text
    Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 18),
        Position = UDim2.new(0, 50, 0, 5),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = self.TitleBar,
    })

    if self.Subtitle ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(0, 300, 0, 14),
            Position = UDim2.new(0, 50, 0, 25),
            BackgroundTransparency = 1,
            Text = self.Subtitle,
            TextColor3 = Theme:GetColor("TextMuted"),
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = self.TitleBar,
        })
    end

    -- Window control buttons
    local function MakeBtn(name, color, text, pos)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = pos,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 6,
            Parent = self.TitleBar,
        })
        AddCorner(btn, UDim.new(0, 6))
        return btn
    end

    self.CloseBtn = MakeBtn("Close", Theme:GetColor("Error"), "×", UDim2.new(1, -40, 0.5, 0))
    self.MinBtn = MakeBtn("Min", Theme:GetColor("Warning"), "−", UDim2.new(1, -72, 0.5, 0))

    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    self.MinBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Hover effects
    for _, btn in ipairs({self.CloseBtn, self.MinBtn}) do
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0}, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.1}, 0.1)
        end)
    end
end

function Window:_CreateContentArea()
    self.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Container,
    })

    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 135, 1, 0),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.Content,
    })
    AddCorner(self.Sidebar)

    -- Tab content wrapper
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -145, 1, -8),
        Position = UDim2.new(0, 140, 0, 4),
        BackgroundColor3 = Theme:GetColor("Tertiary"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Content,
    })
    AddCorner(self.TabContainer)
end

function Window:_AddShadow()
    Create("ImageLabel", {
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        ZIndex = self.Container.ZIndex - 1,
        Parent = self.Container,
    })
end

-- ═══════════════════════════════════════════
-- DRAGGING
-- ═══════════════════════════════════════════
function Window:_SetupDrag()
    local dragStart, startPos

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            dragStart = input.Position
            startPos = self.Container.Position
        end
    end)

    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end)

    local conn = UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    table.insert(self.Connections, conn)
end

-- ═══════════════════════════════════════════
-- KEYBIND
-- ═══════════════════════════════════════════
function Window:_SetupKeybind()
    local conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.Keybind then
            self:Toggle()
        end
    end)
    table.insert(self.Connections, conn)
end

-- ═══════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════
function Window:CreateTab(config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or "📁"
    local order = #self.Tabs + 1

    -- Tab Button
    local tabBtn = Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, -8, 0, 34),
        Position = UDim2.new(0, 4, 0, 8 + (order * 38)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 4,
        Parent = self.Sidebar,
    })
    AddCorner(tabBtn, UDim.new(0, 6))

    Create("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. name,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = tabBtn,
    })

    -- Tab scroll frame
    local tabFrame = Create("ScrollingFrame", {
        Name = "Content_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme:GetColor("ScrollBar"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 2,
        Parent = self.TabContainer,
    })
    AddPadding(tabFrame, 6, 6, 6, 6)

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabFrame,
    })

    -- Tab data
    local tabData = {
        Name = name,
        Icon = icon,
        Button = tabBtn,
        Frame = tabFrame,
        Order = order,
        Sections = {},
    }
    self.Tabs[name] = tabData

    -- Click handler
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = Theme:GetColor("TabHover")
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            tabBtn.BackgroundTransparency = 1
        end
    end)

    -- Auto-select first
    if order == 1 then
        self:SelectTab(name)
    end

    -- Return section factory
    return self:_CreateTabAPI(tabData)
end

function Window:_CreateTabAPI(tabData)
    local api = {}

    function api:CreateSection(name)
        name = name or "Section"
        local sf = Create("Frame", {
            Name = "Section_" .. name,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #tabData.Frame:GetChildren() * 10,
            Parent = tabData.Frame,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
            Parent = sf,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "  " .. string.upper(name),
            TextColor3 = Theme:GetColor("Accent"),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = sf,
        })

        local secAPI = {}

        function secAPI:AddLabel(config)
            local cfg = config or {}
            cfg.Type = "Label"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddButton(config)
            local cfg = config or {}
            cfg.Type = "Button"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddToggle(config)
            local cfg = config or {}
            cfg.Type = "Toggle"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddSlider(config)
            local cfg = config or {}
            cfg.Type = "Slider"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddDropdown(config)
            local cfg = config or {}
            cfg.Type = "Dropdown"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddKeybind(config)
            local cfg = config or {}
            cfg.Type = "Keybind"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddColorPicker(config)
            local cfg = config or {}
            cfg.Type = "ColorPicker"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddInput(config)
            local cfg = config or {}
            cfg.Type = "Input"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddParagraph(title, desc)
            local pf = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #sf:GetChildren() * 10,
                Parent = sf,
            })
            Create("TextLabel", {
                Size = UDim2.new(1, -12, 0, 0),
                Position = UDim2.new(0, 6, 0, 4),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                Parent = pf,
            })
            if desc then
                Create("TextLabel", {
                    Size = UDim2.new(1, -12, 0, 0),
                    Position = UDim2.new(0, 6, 0, 22),
                    BackgroundTransparency = 1,
                    Text = desc,
                    TextColor3 = Theme:GetColor("TextMuted"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    Parent = pf,
                })
            end
            return pf
        end

        function secAPI:AddDivider()
            local d = Create("Frame", {
                Size = UDim2.new(1, -12, 0, 1),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundColor3 = Theme:GetColor("Divider"),
                BorderSizePixel = 0,
                LayoutOrder = #sf:GetChildren() * 10,
                Parent = sf,
            })
            return d
        end

        tabData.Sections[name] = secAPI
        return secAPI
    end

    return api
end

function Window:_AddComponent(parent, config)
    -- Delegate to Library component system or build inline
    -- This is a lightweight inline builder
    local layoutOrder = #parent:GetChildren() * 10

    if config.Type == "Button" then
        local bf = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme:GetColor("Accent"),
            BorderSizePixel = 0,
            Text = config.Text or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Parent = bf,
        })
        AddCorner(btn, UDim.new(0, 6))
        btn.MouseButton1Click:Connect(function()
            pcall(config.Callback or function() end)
        end)
        return { Set = function() end, Get = function() end }
    end

    if config.Type == "Toggle" then
        local tf = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        local state = config.Default or false
        Create("TextLabel", {
            Size = UDim2.new(1, -55, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Toggle",
            TextColor3 = Theme:GetColor("Text"),
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tf,
        })
        local bg = Create("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -44, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border"),
            BorderSizePixel = 0,
            Parent = tf,
        })
        AddCorner(bg, UDim.new(1, 0))
        local circle = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = bg,
        })
        AddCorner(circle, UDim.new(1, 0))

        local toggleBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = tf,
        })

        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            Tween(bg, {BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border")}, 0.15)
            Tween(circle, {Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.15)
            pcall(config.Callback or function() end, state)
        end)

        return {
            Set = function(_, v)
                state = v
                Tween(bg, {BackgroundColor3 = v and Theme:GetColor("Accent") or Theme:GetColor("Border")}, 0.15)
                Tween(circle, {Position = v and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.15)
            end,
            Get = function() return state end,
        }
    end

    if config.Type == "Slider" then
        return Window._BuildSlider(parent, config, layoutOrder)
    end

    if config.Type == "Dropdown" then
        return Window._BuildDropdown(parent, config, layoutOrder)
    end

    if config.Type == "Keybind" then
        return Window._BuildKeybind(parent, config, layoutOrder)
    end

    if config.Type == "Input" then
        return Window._BuildInput(parent, config, layoutOrder)
    end

    return {}
end

-- ═══════════════════════════════════════════
-- COMPONENT BUILDERS (Static)
-- ═══════════════════════════════════════════
function Window._BuildSlider(parent, config, layoutOrder)
    local min = config.Min or 0
    local max = config.Max or 100
    local val = config.Default or 50
    local suffix = config.Suffix or ""

    local sf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 18),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Slider",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sf,
    })

    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0.3, -6, 0, 18),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(val) .. suffix,
        TextColor3 = Theme:GetColor("Accent"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sf,
    })

    local track = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 6),
        Position = UDim2.new(0, 6, 0, 30),
        BackgroundColor3 = Theme:GetColor("Border"),
        BorderSizePixel = 0,
        Parent = sf,
    })
    AddCorner(track, UDim.new(1, 0))

    local pct = (val - min) / (max - min)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(fill, UDim.new(1, 0))

    local knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(pct, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(knob, UDim.new(1, 0))
    AddStroke(knob, Theme:GetColor("Accent"), 1.5)

    local dragging = false
    local function update(x)
        local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valLabel.Text = tostring(val) .. suffix
        pcall(config.Callback or function() end, val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
            i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
            i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)

    return {
        Set = function(_, v)
            val = math.clamp(v, min, max)
            local p = (val - min) / (max - min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valLabel.Text = tostring(val) .. suffix
        end,
        Get = function() return val end,
    }
end

function Window._BuildDropdown(parent, config, layoutOrder)
    local options = config.Options or {}
    local val = config.Default or options[1] or ""
    local isOpen = false

    local df = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        ClipsDescendants = false,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Dropdown",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = df,
    })

    local selBtn = Create("TextButton", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(1, -136, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = "",
        Parent = df,
    })
    AddCorner(selBtn, UDim.new(0, 4))
    AddStroke(selBtn, Theme:GetColor("InputBorder"))

    local selLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = val,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = selBtn,
    })

    Create("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme:GetColor("TextMuted"),
        TextSize = 9,
        Parent = selBtn,
    })

    local listF = Create("Frame", {
        Size = UDim2.new(0, 130, 0, math.min(#options, 5) * 26 + 8),
        Position = UDim2.new(1, -136, 0, 30),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        ZIndex = 10,
        Visible = false,
        ClipsDescendants = true,
        Parent = df,
    })
    AddCorner(listF, UDim.new(0, 4))
    AddStroke(listF, Theme:GetColor("InputBorder"))
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = listF })
    AddPadding(listF, 4, 4, 4, 4)

    for _, opt in ipairs(options) do
        local ob = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = opt == val and 0 or 1,
            BackgroundColor3 = Theme:GetColor("Hover"),
            BorderSizePixel = 0,
            Text = "  " .. opt,
            TextColor3 = Theme:GetColor("Text"),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = listF,
        })
        AddCorner(ob, UDim.new(0, 4))
        ob.MouseButton1Click:Connect(function()
            val = opt
            selLabel.Text = opt
            isOpen = false
            listF.Visible = false
            pcall(config.Callback or function() end, opt)
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listF.Visible = isOpen
    end)

    return {
        Set = function(_, v) val = v; selLabel.Text = v end,
        Get = function() return val end,
    }
end

function Window._BuildKeybind(parent, config, layoutOrder)
    local bind = config.Default or Enum.KeyCode.Unknown
    local listening = false

    local kf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Keybind",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = kf,
    })

    local kBtn = Create("TextButton", {
        Size = UDim2.new(0, 88, 0, 26),
        Position = UDim2.new(1, -94, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = bind.Name or "None",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = kf,
    })
    AddCorner(kBtn, UDim.new(0, 4))
    AddStroke(kBtn, Theme:GetColor("InputBorder"))

    kBtn.MouseButton1Click:Connect(function()
        listening = true
        kBtn.Text = "..."
        Tween(kBtn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            bind = input.KeyCode
            kBtn.Text = bind.Name
            listening = false
            Tween(kBtn, {BackgroundColor3 = Theme:GetColor("InputBg")}, 0.1)
            pcall(config.ChangedCallback or config.Callback or function() end, bind)
        end
    end)

    return {
        Set = function(_, v) bind = v; kBtn.Text = v.Name or "None" end,
        Get = function() return bind end,
    }
end

function Window._BuildInput(parent, config, layoutOrder)
    local inf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Input",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inf,
    })

    local tb = Create("TextBox", {
        Size = UDim2.new(1, -12, 0, 28),
        Position = UDim2.new(0, 6, 0, 20),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "",
        PlaceholderColor3 = Theme:GetColor("Placeholder"),
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inf,
    })
    AddCorner(tb, UDim.new(0, 4))
    AddStroke(tb, Theme:GetColor("InputBorder"))
    AddPadding(tb, 0, 0, 8, 8)

    tb.FocusLost:Connect(function()
        pcall(config.Callback or function() end, tb.Text)
    end)

    return {
        Set = function(_, v) tb.Text = v end,
        Get = function() return tb.Text end,
    }
end

-- ═══════════════════════════════════════════
-- TAB NAVIGATION
-- ═══════════════════════════════════════════
function Window:SelectTab(name)
    local tab = self.Tabs[name]
    if not tab then return end

    for _, t in pairs(self.Tabs) do
        t.Frame.Visible = false
        t.Button.BackgroundTransparency = 1
        local lbl = t.Button:FindFirstChildWhichIsA("TextLabel")
        if lbl then lbl.TextColor3 = Theme:GetColor("TextSecondary") end
    end

    tab.Frame.Visible = true
    tab.Button.BackgroundTransparency = 0
    tab.Button.BackgroundColor3 = Theme:GetColor("TabActive")
    local lbl = tab.Button:FindFirstChildWhichIsA("TextLabel")
    if lbl then lbl.TextColor3 = Color3.new(1, 1, 1) end
    self.CurrentTab = name
end

-- ═══════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════
function Window:Toggle()
    if self.IsOpen then self:Close() else self:Open() end
end

function Window:Open()
    self.IsOpen = true
    self.Container.Visible = true
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Container, {Size = self.Size}, 0.35, Enum.EasingStyle.Back)
end

function Window:Close()
    self.IsOpen = false
    Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
    task.delay(0.25, function()
        self.Container.Visible = false
    end)
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then
        Tween(self.Container, {Size = UDim2.new(0, 620, 0, 48)}, 0.25)
        self.MinBtn.Text = "+"
    else
        Tween(self.Container, {Size = self.Size}, 0.25)
        self.MinBtn.Text = "−"
    end
end

function Window:Destroy()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.Gui then self.Gui:Destroy() end
end

function Window:Notify(title, message, notifType, duration)
    -- Delegate to Library notify or build inline
    notifType = notifType or "Info"
    duration = duration or 4

    local colors = {
        Info = Theme:GetColor("Accent"),
        Success = Theme:GetColor("Success"),
        Warning = Theme:GetColor("Warning"),
        Error = Theme:GetColor("Error"),
    }

    local container = self.Gui:FindFirstChild("Notifications")
    if not container then
        container = Create("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -310, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.Gui,
        })
    end

    local count = #container:GetChildren()
    local n = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, count * 58),
        BackgroundColor3 = Theme:GetColor("NotificationBg"),
        BorderSizePixel = 0,
        Parent = container,
    })
    AddCorner(n, UDim.new(0, 6))
    AddStroke(n, colors[notifType] or Theme:GetColor("Border"), 1)

    Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = colors[notifType] or Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        Parent = n,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 18),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = n,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 14),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = n,
    })

    n.Position = UDim2.new(0, 310, 0, count * 58)
    Tween(n, {Position = UDim2.new(0, 0, 0, count * 58)}, 0.3, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(n, {Position = UDim2.new(0, 310, 0, n.Position.Y.Offset)}, 0.25)
        task.delay(0.3, function() n:Destroy() end)
    end)
end

return Windowend)

-- [Tab/MainTab]
pcall(function()
--[[
    CUZAO HUB - Main Tab
    Informações do hub, status, botões rápidos, atualização
]]

local MainTab = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

function MainTab.Build(window)
    local tab = window:CreateTab({ Name = "Main", Icon = "🏠" })

    -- ═══ Hub Info ═══
    local infoSection = tab:CreateSection("Informações")
    infoSection:AddParagraph({
        Title = "CUZAO HUB",
        Desc = "Script Hub premium para Blox Fruits\nVersão: " .. (getgenv and getgenv().CUZAO_VERSION or "1.0.0"),
    })

    infoSection:AddParagraph({
        Title = "Status",
        Desc = "Conectado • Executor: " .. (identifyexecutor and identifyexecutor() or "N/A"),
    })

    infoSection:AddParagraph({
        Title = "Jogador",
        Desc = function()
            local plr = Players.LocalPlayer
            return plr.Name .. " | Level " .. (plr.Data and plr.Data.Level and plr.Data.Level.Value or "?")
        end,
    })

    -- ═══ Quick Actions ═══
    local quickSection = tab:CreateSection("Ações Rápidas")

    quickSection:AddButton({
        Text = "🔄 Reiniciar Script",
        Callback = function()
            -- Future: trigger loader restart
            print("[CUZAO] Reiniciando...")
        end,
    })

    quickSection:AddButton({
        Text = "📋 Copiar IP do Servidor",
        Callback = function()
            local ip = game.JobId
            if setclipboard then
                setclipboard(ip)
            end
        end,
    })

    quickSection:AddButton({
        Text = "🚪 Server Hop",
        Callback = function()
            local HttpService = game:GetService("HttpService")
            local tpService = game:GetService("TeleportService")
            local servers = HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        tpService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                        break
                    end
                end
            end
        end,
    })

    quickSection:AddButton({
        Text = "🎯 Rejoin Atual",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
        end,
    })

    -- ═══ Player Info ═══
    local playerSection = tab:CreateSection("Informações do Jogador")

    playerSection:AddParagraph({
        Title = "Fruit Atual",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Beli",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Fragments",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Meios de Combate",
        Desc = "Verificando...",
    })

    -- Auto-refresh info
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(function()
                local plr = Players.LocalPlayer
                local data = plr:FindFirstChild("Data")
                if data then
                    local level = data:FindFirstChild("Level")
                    local beli = data:FindFirstChild("Beli")
                    local fragment = data:FindFirstChild("Fragments")

                    infoSection:SetTitle("Status")
                    -- Update paragraphs with real data
                end
            end)
        end
    end)

    return tab
end

return MainTabend)

-- [Tab/FarmTab]
pcall(function()
--[[
    CUZAO HUB - Farm Tab
    Configurações de AutoFarm: Level, Bone, Katakuri, Factory
]]

local FarmTab = {}

function FarmTab.Build(window)
    local tab = window:CreateTab({ Name = "Farm", Icon = "⚔️" })

    -- ═══ Auto Farm Level ═══
    local levelSection = tab:CreateSection("Auto Farm Level")

    levelSection:AddToggle({
        Text = "Auto Farm Level",
        Default = false,
        Callback = function(value)
            -- Integration: EventBus:Emit("AutoFarm.Level.Toggle", value)
            print("[CUZAO] AutoFarm Level: " .. tostring(value))
        end,
    })

    levelSection:AddDropdown({
        Text = "Farm Method",
        Options = {"Below", "Behind", "Tween", "Circle"},
        Default = "Below",
        Callback = function(value)
            -- ConfigManager:Set("AutoFarm.Method", value)
            print("[CUZAO] Farm Method: " .. value)
        end,
    })

    levelSection:AddSlider({
        Text = "Tween Speed",
        Min = 50,
        Max = 300,
        Default = 200,
        Suffix = " studs/s",
        Callback = function(value)
            print("[CUZAO] Tween Speed: " .. tostring(value))
        end,
    })

    levelSection:AddSlider({
        Text = "Attack Distance",
        Min = 5,
        Max = 50,
        Default = 15,
        Suffix = " studs",
        Callback = function(value)
            print("[CUZAO] Attack Distance: " .. tostring(value))
        end,
    })

    levelSection:AddToggle({
        Text = "Auto Quest",
        Default = true,
        Callback = function(value) end,
    })

    levelSection:AddToggle({
        Text = "Auto Haki",
        Default = true,
        Callback = function(value) end,
    })

    levelSection:AddToggle({
        Text = "Auto Ken Haki",
        Default = false,
        Callback = function(value) end,
    })

    levelSection:AddToggle({
        Text = "Fast Attack",
        Default = true,
        Callback = function(value) end,
    })

    levelSection:AddToggle({
        Text = "Auto Click",
        Default = false,
        Callback = function(value) end,
    })

    levelSection:AddSlider({
        Text = "Auto Click Interval",
        Min = 10,
        Max = 500,
        Default = 50,
        Suffix = "ms",
        Callback = function(value) end,
    })

    -- ═══ Farm Bone ═══
    local boneSection = tab:CreateSection("Farm Bone")

    boneSection:AddToggle({
        Text = "Auto Farm Bone",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Bone Farm: " .. tostring(value))
        end,
    })

    boneSection:AddDropdown({
        Text = "Bone Method",
        Options = {"Below", "Behind", "Tween"},
        Default = "Below",
        Callback = function(value) end,
    })

    boneSection:AddToggle({
        Text = "Auto Buy Powers",
        Default = false,
        Callback = function(value) end,
    })

    boneSection:AddToggle({
        Text = "Auto Mirage",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Farm Katakuri ═══
    local kataSection = tab:CreateSection("Farm Katakuri")

    kataSection:AddToggle({
        Text = "Auto Farm Katakuri",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Katakuri Farm: " .. tostring(value))
        end,
    })

    kataSection:AddDropdown({
        Text = "Katakuri Mode",
        Options = {"Cookie", "Poundcake", "Any"},
        Default = "Any",
        Callback = function(value) end,
    })

    kataSection:AddToggle({
        Text = "Auto Sea Beast",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Farm Factory ═══
    local factorySection = tab:CreateSection("Farm Factory")

    factorySection:AddToggle({
        Text = "Auto Farm Factory",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Factory Farm: " .. tostring(value))
        end,
    })

    factorySection:AddDropdown({
        Text = "Target",
        Options = {"Core", "Guard", "All"},
        Default = "Core",
        Callback = function(value) end,
    })

    factorySection:AddToggle({
        Text = "Auto Summon Core",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Mastery Farm ═══
    local masterySection = tab:CreateSection("Mastery Farm")

    masterySection:AddToggle({
        Text = "Auto Mastery",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Mastery Farm: " .. tostring(value))
        end,
    })

    masterySection:AddDropdown({
        Text = "Weapon Type",
        Options = {"Sword", "Gun", "Blox Fruit"},
        Default = "Sword",
        Callback = function(value) end,
    })

    masterySection:AddSlider({
        Text = "Mastery Target Level",
        Min = 1,
        Max = 600,
        Default = 600,
        Suffix = "",
        Callback = function(value) end,
    })

    -- ═══ General Farm Settings ═══
    local generalSection = tab:CreateSection("Configurações Gerais")

    generalSection:AddToggle({
        Text = "Auto Buso Haki",
        Default = true,
        Callback = function(value) end,
    })

    generalSection:AddToggle({
        Text = "Auto Observation Haki",
        Default = false,
        Callback = function(value) end,
    })

    generalSection:AddToggle({
        Text = "Click to Position",
        Default = false,
        Callback = function(value) end,
    })

    generalSection:AddToggle({
        Text = "Disable Dead",
        Default = true,
        Callback = function(value) end,
    })

    generalSection:AddToggle({
        Text = "Auto Stop on Missing Quest",
        Default = false,
        Callback = function(value) end,
    })

    generalSection:AddDropdown({
        Text = "Team",
        Options = {"Pirates", "Marines", "Auto"},
        Default = "Auto",
        Callback = function(value) end,
    })

    return tab
end

return FarmTabend)

-- [Tab/RaidTab]
pcall(function()
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

return RaidTabend)

-- [Tab/FruitTab]
pcall(function()
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

return FruitTabend)

-- [Tab/TeleportTab]
pcall(function()
--[[
    CUZAO HUB - Teleport Tab
    Teleporte para ilhas, NPCs, jogadores e waypoints
    Com detecção automática de Sea (1º, 2º, 3º)
]]

local TeleportTab = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function GetLocalCharacter()
    local plr = Players.LocalPlayer
    if plr and plr.Character then
        return plr.Character
    end
    return nil
end

local function GetRootPart()
    local char = GetLocalCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function TeleportToPosition(position, useTween, tweenSpeed)
    local rootPart = GetRootPart()
    if not rootPart then
        warn("[CUZAO] Personagem não encontrado!")
        return false
    end

    if useTween then
        -- Tween suave (mais difícil de detectar)
        local distance = (position - rootPart.Position).Magnitude
        local duration = distance / (tweenSpeed or 300)

        -- Primeiro vai pra cima pra evitar obstáculos
        local highPos = Vector3.new(position.X, math.max(position.Y, rootPart.Position.Y) + 50, position.Z)
        local tweenUp = TweenService:Create(rootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(highPos)
        })
        tweenUp:Play()
        tweenUp.Completed:Wait()

        -- Depois desce pro destino
        local tweenDown = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(position)
        })
        tweenDown:Play()
        tweenDown.Completed:Wait()
    else
        -- TP direto
        rootPart.CFrame = CFrame.new(position)
    end

    return true
end

function TeleportTab.Build(window, Locations)
    local tab = window:CreateTab({ Name = "Teleport", Icon = "🗺️" })

    -- ═══ SEA INFO ═══
    local currentSea = 1
    if Locations then
        currentSea = Locations:GetCurrentSea()
    end
    local seaNames = { [1] = "1º Sea", [2] = "2º Sea", [3] = "3º Sea" }
    local seaName = seaNames[currentSea] or "Desconhecido"

    -- ═══ SEA STATUS ═══
    local seaSection = tab:CreateSection("Sea Atual")
    seaSection:AddParagraph({
        Title = "🌊 " .. seaName .. " detectado automaticamente",
        Desc = "As ilhas mostradas são do seu sea atual.",
    })

    -- ═══ SEA SELECTOR (manual override) ═══
    local overrideDropdown = seaSection:AddDropdown({
        Text = "Override Sea",
        Options = {"Auto (detectar)", "1º Sea", "2º Sea", "3º Sea"},
        Default = "Auto (detectar)",
        Callback = function(value)
            if Locations then
                if value == "Auto (detectar)" then
                    Locations:ClearSeaCache()
                    currentSea = Locations:GetCurrentSea()
                elseif value == "1º Sea" then
                    Locations:SetSea(1)
                    currentSea = 1
                elseif value == "2º Sea" then
                    Locations:SetSea(2)
                    currentSea = 2
                elseif value == "3º Sea" then
                    Locations:SetSea(3)
                    currentSea = 3
                end
                -- Atualizar ilhas no dropdown
                if RefreshIslands then
                    RefreshIslands()
                end
                print("[CUZAO] Sea: " .. (seaNames[currentSea] or "?"))
            end
        end,
    })

    -- ═══ ISLAND TELEPORT ═══
    local islandSection = tab:CreateSection("Teleporte por Ilha")

    local selectedIsland = nil
    local islandDropdown = nil

    local function GetIslandNames()
        if Locations then
            return Locations:GetCurrentIslandNames()
        end
        -- Fallback hardcoded
        return {
            "Starter Island", "Marine Fortress", "Jungle",
            "Pirate Village", "Desert", "Frozen Village",
        }
    end

    local islandNames = GetIslandNames()
    if #islandNames == 0 then
        islandNames = {"Nenhuma ilha encontrada"}
    end

    islandDropdown = islandSection:AddDropdown({
        Text = "Ilha",
        Options = islandNames,
        Default = islandNames[1] or "Nenhuma",
        Callback = function(value)
            selectedIsland = value
        end,
    })

    -- Função refresh (chamada quando muda o sea)
    function RefreshIslands()
        islandNames = GetIslandNames()
        if #islandNames == 0 then
            islandNames = {"Nenhuma ilha encontrada"}
        end
        selectedIsland = islandNames[1]
        if islandDropdown and islandDropdown.Refresh then
            islandDropdown:Refresh(islandNames)
        end
    end

    local useTween = true
    local tweenSpeed = 300

    islandSection:AddButton({
        Text = "🚀 Teleportar",
        Callback = function()
            if not selectedIsland or selectedIsland == "Nenhuma ilha encontrada" then
                print("[CUZAO] Nenhuma ilha selecionada!")
                return
            end

            -- Buscar posição da ilha
            local position = nil
            if Locations then
                local seaIslands = Locations:GetCurrentSeaIslands()
                if seaIslands and seaIslands[selectedIsland] then
                    position = seaIslands[selectedIsland].Position
                end
            end

            if position then
                print("[CUZAO] Teleportando para " .. selectedIsland .. "...")
                TeleportToPosition(position, useTween, tweenSpeed)
                print("[CUZAO] Chegou em " .. selectedIsland .. "!")
            else
                print("[CUZAO] Posição não encontrada para: " .. selectedIsland)
            end
        end,
    })

    islandSection:AddToggle({
        Text = "Tween (suave)",
        Default = true,
        Callback = function(value)
            useTween = value
        end,
    })

    islandSection:AddSlider({
        Text = "Velocidade",
        Min = 50,
        Max = 500,
        Default = 300,
        Suffix = " studs/s",
        Callback = function(value)
            tweenSpeed = value
        end,
    })

    -- ═══ NPC TELEPORT ═══
    local npcSection = tab:CreateSection("Teleporte NPC")

    local npcsForSea = {
        [1] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Haki Trainer", "Sword Dealer", "Gun Dealer",
            "Fighting Style Teacher",
        },
        [2] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Awakening Expert", "Blacksmith",
            "Bartilo", "Mysterious Dealer",
            "Law Raid",
        },
        [3] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Awakening Expert", "Blacksmith",
            "Sword Dealer", "Gun Dealer",
            "Haki Trainer", "Title Hunter",
            "Factory Core",
        },
    }

    local function GetCurrentNPCs()
        return npcsForSea[currentSea] or npcsForSea[1]
    end

    local selectedNPC = nil
    local npcDropdown = npcSection:AddDropdown({
        Text = "NPC",
        Options = GetCurrentNPCs(),
        Default = GetCurrentNPCs()[1] or "Blox Fruit Dealer",
        Callback = function(value)
            selectedNPC = value
        end,
    })

    npcSection:AddButton({
        Text = "🚀 Teleportar para NPC",
        Callback = function()
            if not selectedNPC then return end

            if Locations then
                local npcPos = Locations.NPCs[selectedNPC]
                if npcPos then
                    print("[CUZAO] TP para NPC: " .. selectedNPC)
                    TeleportToPosition(npcPos, useTween, tweenSpeed)
                else
                    print("[CUZAO] NPC não encontrado: " .. selectedNPC)
                end
            end
        end,
    })

    -- ═══ PLAYER TELEPORT ═══
    local playerSection = tab:CreateSection("Teleporte Jogador")

    local playerNames = {}
    local selectedPlayer = nil

    local function RefreshPlayerList()
        playerNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(playerNames, plr.Name)
            end
        end
        if #playerNames == 0 then
            playerNames = {"Nenhum jogador"}
        end
        return playerNames
    end

    RefreshPlayerList()

    local playerDropdown = playerSection:AddDropdown({
        Text = "Jogador",
        Options = playerNames,
        Default = playerNames[1] or "Nenhum",
        Callback = function(value)
            selectedPlayer = value
        end,
    })

    playerSection:AddButton({
        Text = "🚀 Teleportar para Jogador",
        Callback = function()
            if not selectedPlayer or selectedPlayer == "Nenhum jogador" then return end

            local targetPlr = Players:FindFirstChild(selectedPlayer)
            if targetPlr and targetPlr.Character then
                local targetRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    print("[CUZAO] TP para " .. selectedPlayer)
                    TeleportToPosition(targetRoot.Position + Vector3.new(0, 5, 0), useTween, tweenSpeed)
                end
            end
        end,
    })

    playerSection:AddButton({
        Text = "🔄 Atualizar Lista",
        Callback = function()
            RefreshPlayerList()
            if playerDropdown and playerDropdown.Refresh then
                playerDropdown:Refresh(playerNames)
            end
            print("[CUZAO] Lista atualizada!")
        end,
    })

    playerSection:AddToggle({
        Text = "Auto Refresh",
        Default = false,
        Callback = function(value)
            -- Placeholder: auto refresh loop
            print("[CUZAO] Auto Refresh: " .. tostring(value))
        end,
    })

    -- Auto refresh on player join/leave
    Players.PlayerAdded:Connect(function()
        task.wait(1)
        RefreshPlayerList()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(playerNames)
        end
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.5)
        RefreshPlayerList()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(playerNames)
        end
    end)

    -- ═══ WAYPOINT TELEPORT ═══
    local wpSection = tab:CreateSection("Waypoints")

    wpSection:AddInput({
        Text = "X",
        Placeholder = "Coordenada X",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddInput({
        Text = "Y",
        Placeholder = "Coordenada Y",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddInput({
        Text = "Z",
        Placeholder = "Coordenada Z",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddButton({
        Text = "🚀 Teleportar para Waypoint",
        Callback = function()
            local root = GetRootPart()
            if root then
                print("[CUZAO] Posição atual: " .. tostring(root.Position))
            end
        end,
    })

    wpSection:AddButton({
        Text = "📋 Copiar Posição Atual",
        Callback = function()
            local root = GetRootPart()
            if root then
                local pos = root.Position
                local text = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
                if setclipboard then
                    setclipboard(text)
                end
                print("[CUZAO] Posição copiada: " .. text)
            end
        end,
    })

    -- ═══ AUTO TELEPORT ═══
    local autoTP = tab:CreateSection("Auto TP")

    autoTP:AddToggle({
        Text = "Auto TP to Quest",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto TP Quest: " .. tostring(value))
        end,
    })

    autoTP:AddToggle({
        Text = "Auto TP to Mob",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto TP Mob: " .. tostring(value))
        end,
    })

    autoTP:AddToggle({
        Text = "Safe Teleport (avoid void)",
        Default = true,
        Callback = function(value) end,
    })

    autoTP:AddSlider({
        Text = "Safe TP Height",
        Min = 50,
        Max = 300,
        Default = 100,
        Suffix = " studs",
        Callback = function(value) end,
    })

    -- ═══ FISHMAN ISLAND (acesso especial) ═══
    if currentSea == 2 or currentSea == 3 then
        local specialSection = tab:CreateSection("Locais Especiais")

        specialSection:AddButton({
            Text = "🏝️ Teleport to Underwater City",
            Callback = function()
                if Locations then
                    local pos = Locations.Sea1["Underwater City"]
                    if pos then
                        TeleportToPosition(pos.Position, useTween, tweenSpeed)
                    end
                end
            end,
        })

        if currentSea == 3 then
            specialSection:AddButton({
                Text = "🏝️ Teleport to Floating Turtle",
                Callback = function()
                    local pos = Vector3.new(-12550, 334, -7380)
                    TeleportToPosition(pos, useTween, tweenSpeed)
                end,
            })

            specialSection:AddButton({
                Text = "🏝️ Teleport to Haunted Castle",
                Callback = function()
                    local pos = Vector3.new(-9515, 142, 5545)
                    TeleportToPosition(pos, useTween, tweenSpeed)
                end,
            })
        end
    end

    return tab
end

return TeleportTabend)

-- [Tab/ESPTab]
pcall(function()
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

return ESPTabend)

-- [Tab/CombatTab]
pcall(function()
--[[
    CUZAO HUB - Combat Tab
    AutoClicker, AimBot, KillAura, SkillSpam, Haki
]]

local CombatTab = {}

function CombatTab.Build(window)
    local tab = window:CreateTab({ Name = "Combat", Icon = "🗡️" })

    -- ═══ Auto Clicker ═══
    local clickerSection = tab:CreateSection("Auto Clicker")

    clickerSection:AddToggle({
        Text = "Auto Clicker",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Clicker: " .. tostring(value))
        end,
    })

    clickerSection:AddSlider({
        Text = "Click Interval",
        Min = 10,
        Max = 500,
        Default = 50,
        Suffix = "ms",
        Callback = function(value)
            print("[CUZAO] Click Interval: " .. tostring(value))
        end,
    })

    clickerSection:AddDropdown({
        Text = "Click Method",
        Options = {"Tap", "Button", "Remote"},
        Default = "Tap",
        Callback = function(value) end,
    })

    clickerSection:AddToggle({
        Text = "Hold to Click",
        Default = true,
        Callback = function(value) end,
    })

    clickerSection:AddToggle({
        Text = "Auto Click While Farming",
        Default = true,
        Callback = function(value) end,
    })

    -- ═══ AimBot ═══
    local aimSection = tab:CreateSection("AimBot")

    aimSection:AddToggle({
        Text = "AimBot",
        Default = false,
        Callback = function(value)
            print("[CUZAO] AimBot: " .. tostring(value))
        end,
    })

    aimSection:AddDropdown({
        Text = "AimBot Mode",
        Options = {"Silent", "Legit", "FOV"},
        Default = "Silent",
        Callback = function(value)
            print("[CUZAO] AimBot Mode: " .. value)
        end,
    })

    aimSection:AddDropdown({
        Text = "Target Part",
        Options = {"Head", "HumanoidRootPart", "Closest"},
        Default = "Head",
        Callback = function(value) end,
    })

    aimSection:AddSlider({
        Text = "FOV Size",
        Min = 30,
        Max = 500,
        Default = 150,
        Suffix = "px",
        Callback = function(value) end,
    })

    aimSection:AddToggle({
        Text = "Show FOV Circle",
        Default = false,
        Callback = function(value) end,
    })

    aimSection:AddColorPicker({
        Text = "FOV Circle Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(color) end,
    })

    aimSection:AddToggle({
        Text = "Team Check",
        Default = true,
        Callback = function(value) end,
    })

    aimSection:AddToggle({
        Text = "Wall Check",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Kill Aura ═══
    local auraSection = tab:CreateSection("Kill Aura")

    auraSection:AddToggle({
        Text = "Kill Aura",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Kill Aura: " .. tostring(value))
        end,
    })

    auraSection:AddSlider({
        Text = "Aura Range",
        Min = 5,
        Max = 60,
        Default = 20,
        Suffix = " studs",
        Callback = function(value) end,
    })

    auraSection:AddDropdown({
        Text = "Aura Mode",
        Options = {"Auto", "Semi-Auto", "Hold"},
        Default = "Auto",
        Callback = function(value) end,
    })

    auraSection:AddToggle({
        Text = "Aura on Players",
        Default = false,
        Callback = function(value) end,
    })

    auraSection:AddToggle({
        Text = "Aura on NPCs",
        Default = true,
        Callback = function(value) end,
    })

    auraSection:AddToggle({
        Text = "Smooth Aura",
        Default = true,
        Callback = function(value) end,
    })

    -- ═══ Skill Spam ═══
    local skillSection = tab:CreateSection("Skill Spam")

    skillSection:AddToggle({
        Text = "Skill Spam",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Skill Spam: " .. tostring(value))
        end,
    })

    skillSection:AddToggle({
        Text = "Z Skill",
        Default = true,
        Callback = function(value) end,
    })

    skillSection:AddToggle({
        Text = "X Skill",
        Default = true,
        Callback = function(value) end,
    })

    skillSection:AddToggle({
        Text = "C Skill",
        Default = true,
        Callback = function(value) end,
    })

    skillSection:AddToggle({
        Text = "V Skill",
        Default = true,
        Callback = function(value) end,
    })

    skillSection:AddToggle({
        Text = "F Skill",
        Default = false,
        Callback = function(value) end,
    })

    skillSection:AddSlider({
        Text = "Skill Delay",
        Min = 100,
        Max = 3000,
        Default = 500,
        Suffix = "ms",
        Callback = function(value) end,
    })

    -- ═══ Haki ═══
    local hakiSection = tab:CreateSection("Haki & Ken")

    hakiSection:AddToggle({
        Text = "Auto Buso Haki",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Buso: " .. tostring(value))
        end,
    })

    hakiSection:AddToggle({
        Text = "Auto Ken Haki",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto Ken: " .. tostring(value))
        end,
    })

    hakiSection:AddToggle({
        Text = "Auto Advance Ken",
        Default = false,
        Callback = function(value) end,
    })

    hakiSection:AddSlider({
        Text = "Ken Haki Refresh",
        Min = 1,
        Max = 10,
        Default = 3,
        Suffix = "s",
        Callback = function(value) end,
    })

    return tab
end

return CombatTabend)

-- [Tab/MiscTab]
pcall(function()
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

return MiscTabend)

-- [Tab/SettingsTab]
pcall(function()
--[[
    CUZAO HUB - Settings Tab
    Configurações gerais: tema, keybind, UI, updater
]]

local SettingsTab = {}

local Players = game:GetService("Players")

function SettingsTab.Build(window)
    local tab = window:CreateTab({ Name = "Settings", Icon = "⚙️" })

    -- ═══ Theme ═══
    local themeSection = tab:CreateSection("Tema")

    themeSection:AddDropdown({
        Text = "Tema",
        Options = {"Dark", "Light", "RGB", "CUZAO"},
        Default = "Dark",
        Callback = function(value)
            print("[CUZAO] Tema alterado: " .. value)
            -- Theme:SetTheme(value)
        end,
    })

    themeSection:AddColorPicker({
        Text = "Cor Customizada",
        Default = Color3.fromRGB(88, 101, 242),
        Callback = function(color) end,
    })

    themeSection:AddSlider({
        Text = "RGB Speed",
        Min = 1,
        Max = 10,
        Default = 2,
        Suffix = "x",
        Callback = function(value) end,
    })

    -- ═══ UI Settings ═══
    local uiSection = tab:CreateSection("Interface")

    uiSection:AddKeybind({
        Text = "Toggle UI Keybind",
        Default = Enum.KeyCode.RightControl,
        ChangedCallback = function(key)
            print("[CUZAO] Keybind alterado: " .. key.Name)
        end,
    })

    uiSection:AddSlider({
        Text = "UI Transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Show Notifications",
        Default = true,
        Callback = function(value) end,
    })

    uiSection:AddSlider({
        Text = "Notification Duration",
        Min = 1,
        Max = 10,
        Default = 4,
        Suffix = "s",
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Blur Background",
        Default = false,
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Start Minimized",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Execution ═══
    local execSection = tab:CreateSection("Execução")

    execSection:AddDropdown({
        Text = "Executor",
        Options = {"Auto Detect", "Synapse X", "Script-Ware", "Fluxus", "Delta", "Hydrogen", "Arceus X", "Solara"},
        Default = "Auto Detect",
        Callback = function(value) end,
    })

    execSection:AddToggle({
        Text = "Auto Execute on Join",
        Default = false,
        Callback = function(value) end,
    })

    execSection:AddToggle({
        Text = "Anti-Cheat Bypass",
        Default = true,
        Callback = function(value) end,
    })

    -- ═══ Key System ═══
    local keySection = tab:CreateSection("Key System")

    keySection:AddToggle({
        Text = "Enable Key System",
        Default = false,
        Callback = function(value) end,
    })

    keySection:AddDropdown({
        Text = "Key Provider",
        Options = {"None", "Linkvertise", "LootLabs", "Custom"},
        Default = "None",
        Callback = function(value) end,
    })

    keySection:AddInput({
        Text = "Custom Key",
        Placeholder = "Enter your key",
        Default = "",
        Callback = function(value) end,
    })

    -- ═══ Config Management ═══
    local configSection = tab:CreateSection("Configurações")

    configSection:AddDropdown({
        Text = "Preset",
        Options = {"Default", "Aggressive", "Passive", "Custom"},
        Default = "Default",
        Callback = function(value) end,
    })

    configSection:AddButton({
        Text = "💾 Salvar Configurações",
        Callback = function()
            print("[CUZAO] Config salva!")
        end,
    })

    configSection:AddButton({
        Text = "📂 Carregar Configurações",
        Callback = function()
            print("[CUZAO] Config carregada!")
        end,
    })

    configSection:AddButton({
        Text = "🔄 Resetar Configurações",
        Callback = function()
            print("[CUZAO] Config resetada!")
        end,
    })

    configSection:AddButton({
        Text = "📋 Exportar Config",
        Callback = function()
            print("[CUZAO] Exportando config...")
        end,
    })

    -- ═══ About ═══
    local aboutSection = tab:CreateSection("Sobre")

    aboutSection:AddParagraph({
        Title = "CUZAO HUB v1.0.0",
        Desc = "Script Hub premium para Blox Fruits\nDesenvolvido com ❤️",
    })

    aboutSection:AddButton({
        Text = "Discord Server",
        Callback = function()
            print("[CUZAO] Abrindo Discord...")
        end,
    })

    aboutSection:AddButton({
        Text = "GitHub",
        Callback = function()
            print("[CUZAO] Abrindo GitHub...")
        end,
    })

    aboutSection:AddButton({
        Text = "Check for Updates",
        Callback = function()
            print("[CUZAO] Verificando atualizações...")
        end,
    })

    return tab
end

return SettingsTabend)

-- ═══════════════════════════════════════════
-- LOADING SEQUENCE
-- ═══════════════════════════════════════════
print("[CUZAO] Módulos carregados. Inicializando UI...")

local Library = CUZAO.Modules["Library"]
if Library then
    local window = Library:CreateWindow({
        Title = "CUZAO HUB",
        Subtitle = "Blox Fruits",
        Size = UDim2.new(0, 620, 0, 420),
    })
    CUZAO.Window = window

    local tabModules = {
        "MainTab", "FarmTab", "RaidTab", "FruitTab",
        "TeleportTab", "ESPTab", "CombatTab", "MiscTab", "SettingsTab",
    }
    for _, name in ipairs(tabModules) do
        local tabMod = CUZAO.Modules["Tab/" .. name]
        if tabMod and tabMod.Build then
            pcall(function()
                if name == "TeleportTab" then
                    tabMod.Build(window, CUZAO.Modules["Locations"])
                else
                    tabMod.Build(window)
                end
            end)
        end
    end

    CUZAO.Loaded = true
    print("[CUZAO HUB] v" .. CUZAO.Version .. " carregado com sucesso!")
    print("[CUZAO HUB] Pressione RightControl para abrir/fechar")
else
    warn("[CUZAO HUB] ERRO: Library não encontrada!")
end

-- Anti-AFK
task.spawn(function()
    pcall(function()
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)
