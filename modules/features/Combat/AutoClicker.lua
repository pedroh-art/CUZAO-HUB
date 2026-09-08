--[[
    CUZAO HUB - Auto Clicker / Fast Attack Module
    Sistema de ataque rápido sem cooldown usando remotes do jogo

    Principais remotes:
    - RegisterAttack:FireServer(0) — Registra ataque sem delay
    - RegisterHit:FireServer(headPart, targets) — Registra hit no alvo

    Métodos de ataque:
    1. Fast Attack — Usa remotes RegisterAttack/RegisterHit (sem cooldown)
    2. Skill Attack — Usa VirtualInputManager para skills Z/X/C/V/F
    3. Click Attack — Usa click de mouse (mais lento mas seguro)
    4. Toggle Attack — Alterna entre modos rapidamente
]]

local AutoClicker = {}

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local RegisterAttack = Remotes:FindFirstChild("RegisterAttack")
local RegisterHit = Remotes:FindFirstChild("RegisterHit")

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
AutoClicker._running = false
AutoClicker._connection = nil
AutoClicker._skillConnection = nil
AutoClicker._mode = "FastAttack" -- FastAttack, SkillSpam, ClickAttack
AutoClicker._attackCount = 0
AutoClicker._sessionStart = 0
AutoClicker._currentTarget = nil

-- Cache de referências
AutoClicker._root = nil
AutoClicker._humanoid = nil

-- Configurações
AutoClicker.Config = {
    Enabled = false,
    Mode = "FastAttack",            -- FastAttack, SkillSpam, ClickAttack
    AttackDelay = 0,                -- Delay entre ataques (0 = sem delay)
    AttackRange = 60,               -- Distância máxima para atacar
    ClickDelay = 0.05,              -- Delay para modo click
    AutoEquip = true,
    Weapon = "Melee",

    -- Fast Attack
    FastAttack = {
        Enabled = true,
        AttackSpeed = 0,            -- 0 =最快, sem delay
        HitMultiple = true,         -- Atacar múltiplos alvos
    },

    -- Skill Spam
    SkillSpam = {
        Enabled = false,
        Skills = {Z = true, X = true, C = true, V = false, F = false},
        Delay = 0.5,
    },

    -- Alvo
    TargetMobs = true,
    TargetPlayers = false,
    TargetBosses = true,

    -- Haki
    AutoHaki = true,
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
    Equipar arma mais forte do tipo configurado
]]
local function EquipWeapon()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not backpack or not humanoid then return false end

    local priorities = {
        Melee = {"Godhuman", "Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Sharkman Karate", "Combat"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Soul Guitar", "Kabucha"},
    }

    local weaponList = priorities[AutoClicker.Config.Weapon] or priorities.Melee

    for _, name in ipairs(weaponList) do
        local tool = backpack:FindFirstChild(name)
        if tool then
            humanoid:EquipTool(tool)
            return true
        end
    end

    -- Fallback
    local fallback = backpack:FindFirstChildOfClass("Tool")
    if fallback then
        humanoid:EquipTool(fallback)
        return true
    end
    return false
end

--[[
    Obter todos os alvos dentro do alcance
]]
local function GetTargetsInRange()
    local targets = {}
    local root = AutoClicker._root
    if not root then return targets end

    local range = AutoClicker.Config.AttackRange

    pcall(function()
        -- Alvos: mobs
        if AutoClicker.Config.TargetMobs then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob:IsA("Model") then
                        local humanoid = mob:FindFirstChild("Humanoid")
                        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                        if humanoid and mobRoot and humanoid.Health > 0 then
                            local dist = (root.Position - mobRoot.Position).Magnitude
                            if dist <= range then
                                table.insert(targets, {
                                    Model = mob,
                                    RootPart = mobRoot,
                                    Head = mob:FindFirstChild("Head") or mobRoot,
                                    Distance = dist,
                                    Health = humanoid.Health,
                                    MaxHealth = humanoid.MaxHealth,
                                    Type = "Mob",
                                })
                            end
                        end
                    end
                end
            end
        end

        -- Alvos: jogadores (PvP)
        if AutoClicker.Config.TargetPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoid and playerRoot and humanoid.Health > 0 then
                        local dist = (root.Position - playerRoot.Position).Magnitude
                        if dist <= range then
                            table.insert(targets, {
                                Model = player.Character,
                                RootPart = playerRoot,
                                Head = player.Character:FindFirstChild("Head") or playerRoot,
                                Distance = dist,
                                Health = humanoid.Health,
                                MaxHealth = humanoid.MaxHealth,
                                Type = "Player",
                                Player = player,
                            })
                        end
                    end
                end
            end
        end
    end)

    -- Ordenar por distância
    table.sort(targets, function(a, b) return a.Distance < b.Distance end)

    return targets
end

-- ══════════════════════════════════════════════════════════════════
-- MÉTODOS DE ATAQUE
-- ══════════════════════════════════════════════════════════════════

--[[
    Fast Attack — Usa remotes RegisterAttack e RegisterHit
    Este é o método mais rápido, sem cooldown
]]
function AutoClicker:FastAttack(target)
    if not target or not target.RootPart then return end

    local root = self._root
    if not root then return end

    -- Olhar para o alvo
    root.CFrame = CFrame.new(root.Position, Vector3.new(target.RootPart.Position.X, root.Position.Y, target.RootPart.Position.Z))

    -- Equipar arma
    if self.Config.AutoEquip then
        EquipWeapon()
    end

    -- Ataque rápido via remotes
    pcall(function()
        if RegisterAttack and RegisterHit then
            -- Registrar ataque (0 = sem delay)
            RegisterAttack:FireServer(self.Config.FastAttack.AttackSpeed)

            -- Registrar hit no alvo
            local hitPart = target.Head or target.RootPart
            local hitTargets = {target.Model}

            -- Se habilitado múltiplos alvos, incluir todos na área
            if self.Config.FastAttack.HitMultiple then
                local allTargets = GetTargetsInRange()
                for _, t in ipairs(allTargets) do
                    if t.Model ~= target.Model then
                        table.insert(hitTargets, t.Model)
                    end
                end
            end

            RegisterHit:FireServer(hitPart, hitTargets)
        end
    end)

    self._attackCount = self._attackCount + 1
end

--[[
    Click Attack — Usa click de mouse (mais lento, mais seguro)
]]
function AutoClicker:ClickAttack(target)
    if not target or not target.RootPart then return end

    local root = self._root
    if not root then return end

    -- Olhar para o alvo
    root.CFrame = CFrame.new(root.Position, Vector3.new(target.RootPart.Position.X, root.Position.Y, target.RootPart.Position.Z))

    -- Equipar arma
    if self.Config.AutoEquip then
        EquipWeapon()
    end

    -- Click esquerdo
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

    self._attackCount = self._attackCount + 1
end

--[[
    Usar skill específica
]]
function AutoClicker:UseSkill(skillKey)
    local keyCode = {
        Z = Enum.KeyCode.Z,
        X = Enum.KeyCode.X,
        C = Enum.KeyCode.C,
        V = Enum.KeyCode.V,
        F = Enum.KeyCode.F,
    }

    local key = keyCode[skillKey]
    if not key then return end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

--[[
    Usar todas as skills habilitadas
]]
function AutoClicker:UseAllSkills()
    local skills = self.Config.SkillSpam.Skills
    local delay = self.Config.SkillSpam.Delay

    for skillKey, enabled in pairs(skills) do
        if enabled then
            self:UseSkill(skillKey)
            task.wait(delay)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function AutoClicker:Start(mode)
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("Combat.AutoClicker")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    mode = mode or self.Config.Mode
    self._running = true
    self._mode = mode
    self._sessionStart = tick()
    self._attackCount = 0

    local root, hum = EnsureCharacter()
    self._root = root
    self._humanoid = hum

    -- Conectar respawn
    local respawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
        self._root = char:WaitForChild("HumanoidRootPart", 30)
        self._humanoid = char:WaitForChild("Humanoid", 30)
    end)
    self._respawnConnection = respawnConn

    -- Ativar Haki
    if self.Config.AutoHaki then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end

    print("[AutoClicker] Iniciado | Modo: " .. mode)

    if EventBus then
        EventBus:Emit("Combat.AutoClicker.Started", {Mode = mode})
    end

    -- Loop do modo selecionado
    self._connection = task.spawn(function()
        if mode == "FastAttack" then
            self:FastAttackLoop()
        elseif mode == "ClickAttack" then
            self:ClickAttackLoop()
        elseif mode == "SkillSpam" then
            self:SkillSpamLoop()
        end
    end)

    -- Loop de skills (se SkillSpam habilitado em qualquer modo)
    if mode ~= "SkillSpam" and self.Config.SkillSpam.Enabled then
        self._skillConnection = task.spawn(function()
            while self._running do
                self:UseAllSkills()
                task.wait(self.Config.SkillSpam.Delay)
            end
        end)
    end

    return true
end

function AutoClicker:Stop()
    if not self._running then return false end

    self._running = false

    if self._connection then
        task.cancel(self._connection)
        self._connection = nil
    end

    if self._skillConnection then
        task.cancel(self._skillConnection)
        self._skillConnection = nil
    end

    if self._respawnConnection then
        self._respawnConnection:Disconnect()
        self._respawnConnection = nil
    end

    print("[AutoClicker] Parado | Total de ataques: " .. self._attackCount)

    if EventBus then
        EventBus:Emit("Combat.AutoClicker.Stopped", {
            Attacks = self._attackCount,
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function AutoClicker:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- LOOPS POR MODO
-- ══════════════════════════════════════════════════════════════════

function AutoClicker:FastAttackLoop()
    while self._running do
        -- Verificar personagem
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            task.wait(0.5)
            continue
        end

        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(2)
            continue
        end

        -- Obter alvos
        local targets = GetTargetsInRange()

        if #targets > 0 then
            -- Atacar cada alvo
            for _, target in ipairs(targets) do
                if not self._running then break end

                -- Verificar se alvo ainda existe e está vivo
                if target.Model and target.Model.Parent then
                    local hum = target.Model:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        self:FastAttack(target)
                    end
                end

                task.wait(self.Config.AttackDelay)
            end
        else
            -- Nenhum alvo, esperar
            task.wait(0.2)
        end
    end
end

function AutoClicker:ClickAttackLoop()
    while self._running do
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            task.wait(0.5)
            continue
        end

        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(2)
            continue
        end

        local targets = GetTargetsInRange()

        if #targets > 0 then
            for _, target in ipairs(targets) do
                if not self._running then break end

                if target.Model and target.Model.Parent then
                    local hum = target.Model:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        self:ClickAttack(target)
                    end
                end

                task.wait(self.Config.ClickDelay)
            end
        else
            task.wait(0.3)
        end
    end
end

function AutoClicker:SkillSpamLoop()
    while self._running do
        if not self._root or not self._root.Parent then
            task.wait(1)
            continue
        end

        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(2)
            continue
        end

        local targets = GetTargetsInRange()
        if #targets > 0 then
            self:UseAllSkills()
        end

        task.wait(self.Config.SkillSpam.Delay)
    end
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function AutoClicker:GetStatus()
    return {
        Running = self._running,
        Mode = self._mode,
        AttackCount = self._attackCount,
        SessionTime = tick() - self._sessionStart,
    }
end

function AutoClicker:SetMode(mode)
    if self._running then
        self:Stop()
        task.wait(0.2)
        self:Start(mode)
    else
        self.Config.Mode = mode
    end
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function AutoClicker:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    -- Atualizar referências de remotes (podem não existir no load)
    pcall(function()
        RegisterAttack = Remotes:FindFirstChild("RegisterAttack")
        RegisterHit = Remotes:FindFirstChild("RegisterHit")
    end)

    if EventBus then
        EventBus:On("Combat.AutoClicker.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)

        EventBus:On("Combat.FastAttack.Toggle", function(enabled)
            if enabled then
                self:Start("FastAttack")
            else
                self:Stop()
            end
        end)
    end

    print("[AutoClicker] Módulo inicializado")
    return true
end

function AutoClicker:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("Combat.AutoClicker.Toggle")
        EventBus:Clear("Combat.FastAttack.Toggle")
    end
    print("[AutoClicker] Módulo limpo")
end

return AutoClicker
