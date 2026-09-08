--[[
    CUZAO HUB - Fly Module
    Sistema de voo usando BodyGyro + BodyVelocity

    Controles:
    - W/S: Frente/Trás
    - A/D: Esquerda/Direita
    - Space: Subir
    - LeftShift: Descer
    - Câmera define direção do voo

    Segurança:
    - Verifica personagem antes de ativar
    - Limpa BodyVelocity/BodyGyro ao desativar
    - Restaura PlatformStand ao desativar
    - Suporta respawn automático
]]

local Fly = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
Fly._running = false
Fly._bodyVelocity = nil
Fly._bodyGyro = nil
Fly._connection = nil
Fly._respawnConnection = nil
Fly._root = nil
Fly._humanoid = nil
Fly._sessionStart = 0

-- Configurações
Fly.Config = {
    Enabled = false,
    Speed = 50,
    FastSpeed = 100,
    SlowSpeed = 25,
    Keybind = Enum.KeyCode.F,        -- Tecla para toggle
    DisableOnDeath = true,
    AutoDisableOnKick = true,
    EnableNoclip = true,              -- Noclip durante voo
    UseCameraDirection = true,        -- Usar direção da câmera
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

-- ══════════════════════════════════════════════════════════════════
-- SISTEMA DE VOO
-- ══════════════════════════════════════════════════════════════════

--[[
    Criar BodyVelocity e BodyGyro para voo
]]
function Fly:CreateFlyParts(rootPart)
    -- Limpar partes anteriores
    self:DestroyFlyParts()

    -- BodyVelocity para movimento
    local bv = Instance.new("BodyVelocity")
    bv.Name = "CUZAO_FlyVelocity"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 9000
    bv.Parent = rootPart
    self._bodyVelocity = bv

    -- BodyGyro para estabilização e rotação
    local bg = Instance.new("BodyGyro")
    bg.Name = "CUZAO_FlyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart
    self._bodyGyro = bg

    return bv, bg
end

--[[
    Destruir BodyVelocity e BodyGyro
]]
function Fly:DestroyFlyParts()
    if self._bodyVelocity then
        pcall(function() self._bodyVelocity:Destroy() end)
        self._bodyVelocity = nil
    end

    if self._bodyGyro then
        pcall(function() self._bodyGyro:Destroy() end)
        self._bodyGyro = nil
    end
end

--[[
    Ativar voo
]]
function Fly:Enable()
    if self._running then return false end

    local root, humanoid = EnsureCharacter()
    if not root or not humanoid then
        warn("[Fly] Personagem não encontrado")
        return false
    end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("Misc.Fly")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._root = root
    self._humanoid = humanoid
    self._running = true
    self._sessionStart = tick()

    -- Criar partes de voo
    self:CreateFlyParts(root)

    -- Ativar PlatformStand para estabilizar
    humanoid.PlatformStand = true

    -- Conectar respawn para recriar partes
    self._respawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        self._root = char:WaitForChild("HumanoidRootPart", 30)
        self._humanoid = char:WaitForChild("Humanoid", 30)

        if self._running and self._root then
            task.wait(0.5)
            self:CreateFlyParts(self._root)
            if self._humanoid then
                self._humanoid.PlatformStand = true
            end
        end
    end)

    -- Loop principal de controle
    self._connection = RunService.Heartbeat:Connect(function()
        if not self._running then return end

        -- Verificar personagem
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            if self._root then
                self:CreateFlyParts(self._root)
            end
            return
        end

        -- Verificar morte
        if self.Config.DisableOnDeath and self._humanoid and self._humanoid.Health <= 0 then
            self:Disable()
            return
        end

        -- Atualizar Camera
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local cameraCFrame = camera.CFrame
        local moveVector = Vector3.new(0, 0, 0)

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

        -- Determinar velocidade (Shift rápido, Ctrl lento)
        local currentSpeed = self.Config.Speed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            currentSpeed = self.Config.SlowSpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
            currentSpeed = self.Config.FastSpeed
        end

        -- Normalizar e aplicar velocidade
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * currentSpeed
        end

        -- Aplicar ao BodyVelocity
        if self._bodyVelocity then
            self._bodyVelocity.Velocity = moveVector
        end

        -- Aplicar rotação ao BodyGyro (seguir câmera)
        if self._bodyGyro then
            self._bodyGyro.CFrame = cameraCFrame
        end

        -- Noclip durante voo
        if self.Config.EnableNoclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    print("[Fly] Ativado | Velocidade: " .. self.Config.Speed)

    if EventBus then
        EventBus:Emit("Misc.Fly.Started", {Speed = self.Config.Speed})
    end

    return true
end

--[[
    Desativar voo
]]
function Fly:Disable()
    if not self._running then return false end

    self._running = false

    -- Limpar partes de voo
    self:DestroyFlyParts()

    -- Desconectar eventos
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end

    if self._respawnConnection then
        self._respawnConnection:Disconnect()
        self._respawnConnection = nil
    end

    -- Restaurar PlatformStand
    if self._humanoid then
        self._humanoid.PlatformStand = false
    end

    -- Restaurar CanCollide
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end

    print("[Fly] Desativado")

    if EventBus then
        EventBus:Emit("Misc.Fly.Stopped")
    end

    return true
end

--[[
    Toggle voo
]]
function Fly:Toggle()
    if self._running then
        return self:Disable()
    else
        return self:Enable()
    end
end

--[[
    Definir velocidade do voo
]]
function Fly:SetSpeed(speed)
    self.Config.Speed = speed
    if self._running then
        print("[Fly] Velocidade alterada para: " .. speed)
    end
end

--[[
    Verificar se está voando
]]
function Fly:IsFlying()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function Fly:Start()
    return self:Enable()
end

function Fly:Stop()
    return self:Disable()
end

function Fly:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function Fly:GetStatus()
    return {
        Running = self._running,
        Speed = self.Config.Speed,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function Fly:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    -- Conectar toggle por tecla
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == self.Config.Keybind then
            self:Toggle()
        end
    end)

    if EventBus then
        EventBus:On("Misc.Fly.Toggle", function(enabled)
            if enabled then
                self:Enable()
            else
                self:Disable()
            end
        end)

        EventBus:On("Misc.Fly.SetSpeed", function(speed)
            self:SetSpeed(speed)
        end)
    end

    print("[Fly] Módulo inicializado | Toggle: " .. tostring(self.Config.Keybind))
    return true
end

function Fly:Cleanup()
    self:Disable()
    if EventBus then
        EventBus:Clear("Misc.Fly.Toggle")
        EventBus:Clear("Misc.Fly.SetSpeed")
    end
    print("[Fly] Módulo limpo")
end

return Fly
