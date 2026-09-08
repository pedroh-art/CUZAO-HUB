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

return TweenModule