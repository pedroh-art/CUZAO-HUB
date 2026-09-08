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

return Movement