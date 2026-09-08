--[[
    CUZAO HUB - Island Teleport Module
    Teleporte entre ilhas com bypass e entrance requests

    Suporta:
    - Teleporte direto (CFrame)
    - Tween suave (TweenService)
    - Bypass teleport (para áreas protegidas)
    - RequestEntrance (para entrar em áreas específicas)
    - Detecção de Sea automática
]]

local IslandTP = {}

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil
local Locations = nil

-- Estado
IslandTP._running = false
IslandTP._tweening = false
IslandTP._currentTween = nil
IslandTP._sessionStart = 0

-- Configurações
IslandTP.Config = {
    Enabled = false,
    TweenSpeed = 350,           -- Studs por segundo
    TweenEnabled = true,        -- Usar tween ou TP direto
    BypassTP = true,            -- Usar bypass quando disponível
    SafeMode = true,            -- Verificar posição antes de teleportar
    EntranceRequest = true,     -- Pedir entrance para áreas específicas
    NoClipDuring = true,        -- Ativar noclip durante tween
}

-- ══════════════════════════════════════════════════════════════════
-- DADOS DE ILHAS COM ENTRANCE REQUESTS
-- ══════════════════════════════════════════════════════════════════

-- Áreas que precisam de entrance request
IslandTP.EntranceAreas = {
    ["Underwater City"] = { PlaceId = 2753915549, Position = Vector3.new(61163, 11, 1819) },
    ["Hot and Cold"] = { PlaceId = 2753915549, Position = Vector3.new(61163, 11, 1819) },
    ["Cursed Ship"] = { PlaceId = 4442272183, Position = Vector3.new(923, 125, 32800) },
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

local function EnsureCharacter()
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 30), char:WaitForChild("Humanoid", 30)
    end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
end

--[[
    Verificar se a posição de destino é segura (não void, não out of bounds)
]]
local function IsSafePosition(position)
    if not IslandTP.Config.SafeMode then return true end

    -- Verificar se não está no void
    if position.Y < -500 then return false end

    -- Verificar se não está muito longe
    if position.Magnitude > 100000 then return false end

    -- Verificar colisão no destino
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    local character = LocalPlayer.Character
    if character then
        rayParams.FilterDescendantsInstances = {character}
    end

    local rayResult = Workspace:Raycast(
        position + Vector3.new(0, 50, 0),
        Vector3.new(0, -100, 0),
        rayParams
    )

    -- Se não há chão detectado embaixo, pode ser perigoso mas aceitar
    return true
end

--[[
    Solicitar entrance para áreas que precisam
]]
local function RequestEntrance(areaName)
    if not IslandTP.Config.EntranceRequest then return end

    local area = IslandTP.EntranceAreas[areaName]
    if not area then return end

    pcall(function()
        CommF_:InvokeServer("requestEntrance", area.Position)
    end)

    task.wait(1)
end

-- ══════════════════════════════════════════════════════════════════
-- MÉTODOS DE TELEPORTE
-- ══════════════════════════════════════════════════════════════════

--[[
    Teleporte direto (instantâneo)
]]
function IslandTP:DirectTeleport(targetCFrame)
    local root = EnsureCharacter()
    if not root then return false end

    root.CFrame = targetCFrame
    return true
end

--[[
    Tween suave até o destino
]]
function IslandTP:TweenTeleport(targetCFrame)
    local root, humanoid = EnsureCharacter()
    if not root then return false end

    self._tweening = true

    -- Noclip durante tween
    local noclipConnection = nil
    if self.Config.NoClipDuring then
        noclipConnection = RunService.Stepped:Connect(function()
            if not self._tweening then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / self.Config.TweenSpeed

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    self._currentTween = tween

    tween.Completed:Connect(function()
        self._tweening = false
        self._currentTween = nil

        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end)

    tween:Play()
    return true, tween
end

--[[
    Cancelar tween em andamento
]]
function IslandTP:CancelTeleport()
    if self._currentTween then
        self._currentTween:Cancel()
        self._currentTween = nil
        self._tweening = false

        -- Parar noclip
        return true
    end
    return false
end

--[[
    Teleporte com bypass (usa CommF_ para bypass de anti-cheat)
]]
function IslandTP:BypassTeleport(targetCFrame)
    if not self.Config.BypassTP then
        return self:DirectTeleport(targetCFrame)
    end

    -- Método bypass: teleportar em steps
    local root = EnsureCharacter()
    if not root then return false end

    local currentPos = root.Position
    local targetPos = targetCFrame.Position
    local steps = 3

    for i = 1, steps do
        local alpha = i / steps
        local stepPos = currentPos:Lerp(targetPos, alpha)
        local stepCFrame = CFrame.new(stepPos, targetPos)

        root.CFrame = stepCFrame
        task.wait(0.1)
    end

    -- Posição final
    root.CFrame = targetCFrame
    return true
end

-- ══════════════════════════════════════════════════════════════════
-- API PÚBLICA DE TELEPORTE
-- ══════════════════════════════════════════════════════════════════

--[[
    Teleportar para uma ilha pelo nome
]]
function IslandTP:TeleportToIsland(islandName)
    if self._tweening then
        self:CancelTeleport()
        task.wait(0.2)
    end

    -- Buscar ilha nos dados
    if not Locations then
        warn("[IslandTP] Módulo Locations não disponível")
        return false
    end

    local currentSea = Locations:GetCurrentSea()
    local islands = Locations:GetIslands(currentSea)

    local islandData = islands[islandName]
    if not islandData then
        warn("[IslandTP] Ilha não encontrada: " .. islandName)
        return false
    end

    local targetCFrame = CFrame.new(islandData.Position)

    -- Verificar segurança
    if not IsSafePosition(islandData.Position) then
        warn("[IslandTP] Posição considerada insegura: " .. islandName)
        return false
    end

    -- Solicitar entrance se necessário
    RequestEntrance(islandName)

    print("[IslandTP] Teleportando para: " .. islandName .. " (Sea " .. currentSea .. ")")

    if EventBus then
        EventBus:Emit("Teleport.Island.Started", {Island = islandName, Sea = currentSea})
    end

    -- Executar teleporte
    local success
    if self.Config.TweenEnabled then
        success = self:TweenTeleport(targetCFrame)
    else
        success = self:BypassTeleport(targetCFrame)
    end

    if EventBus then
        EventBus:Emit("Teleport.Island.Completed", {Island = islandName, Success = success})
    end

    return success
end

--[[
    Teleportar para posição específica
]]
function IslandTP:TeleportToPosition(position)
    if self._tweening then
        self:CancelTeleport()
        task.wait(0.2)
    end

    local targetCFrame = CFrame.new(position)

    if not IsSafePosition(position) then
        warn("[IslandTP] Posição insegura")
        return false
    end

    if self.Config.TweenEnabled then
        return self:TweenTeleport(targetCFrame)
    else
        return self:BypassTeleport(targetCFrame)
    end
end

--[[
    Teleportar para NPC pelo nome
]]
function IslandTP:TeleportToNPC(npcName)
    local npcData = Locations and Locations.NPCs and Locations.NPCs[npcName]
    if npcData then
        return self:TeleportToPosition(npcData)
    end
    warn("[IslandTP] NPC não encontrado: " .. npcName)
    return false
end

--[[
    Listar ilhas disponíveis para o sea atual
]]
function IslandTP:GetAvailableIslands()
    if not Locations then return {} end

    local currentSea = Locations:GetCurrentSea()
    local islands = Locations:GetIslands(currentSea)
    local names = {}

    for name, data in pairs(islands) do
        table.insert(names, {
            Name = name,
            Position = data.Position,
            Level = data.Level,
        })
    end

    table.sort(names, function(a, b)
        local levelA = a.Level and a.Level[1] or 0
        local levelB = b.Level and b.Level[1] or 0
        return levelA < levelB
    end)

    return names
end

--[[
    Obter ilha mais próxima da posição atual
]]
function IslandTP:GetNearestIsland()
    local root = EnsureCharacter()
    if not root then return nil end

    if not Locations then return nil end

    local currentSea = Locations:GetCurrentSea()
    return Locations:GetNearestIsland(root.Position, currentSea)
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function IslandTP:Start()
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("Teleport")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()

    print("[IslandTP] Módulo ativado | Velocidade: " .. self.Config.TweenSpeed .. " studs/s")

    if EventBus then
        EventBus:Emit("Teleport.Island.Ready")
    end

    return true
end

function IslandTP:Stop()
    if not self._running then return false end

    self:CancelTeleport()
    self._running = false

    print("[IslandTP] Módulo desativado")

    if EventBus then
        EventBus:Emit("Teleport.Island.Stopped")
    end

    return true
end

function IslandTP:IsRunning()
    return self._running
end

function IslandTP:IsTweening()
    return self._tweening
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function IslandTP:GetStatus()
    local root = EnsureCharacter()
    local currentPos = root and root.Position or Vector3.new(0, 0, 0)

    return {
        Running = self._running,
        Tweening = self._tweening,
        Position = currentPos,
        Speed = self.Config.TweenSpeed,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

local RunService = game:GetService("RunService")

function IslandTP:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus
    Locations = deps.Locations

    if EventBus then
        EventBus:On("Teleport.Island.Go", function(data)
            if data and data.Island then
                self:TeleportToIsland(data.Island)
            elseif data and data.Position then
                self:TeleportToPosition(data.Position)
            end
        end)

        EventBus:On("Teleport.Island.Cancel", function()
            self:CancelTeleport()
        end)
    end

    print("[IslandTP] Módulo inicializado")
    return true
end

function IslandTP:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("Teleport.Island.Go")
        EventBus:Clear("Teleport.Island.Cancel")
    end
    print("[IslandTP] Módulo limpo")
end

return IslandTP
