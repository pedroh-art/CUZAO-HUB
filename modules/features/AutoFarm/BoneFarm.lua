--[[
    CUZAO HUB - Bone Farm Module
    Farm de ossos na area Haunted Castle (Sea 3)

    Localização: Spawn Point (-8764, 142, 5963)
    NPCs de quest:
    - Reborn Skeleton
    - Living Zombie
    - Demonic Soul
    - Possessed Mummy

    Recompensas:
    - Bones (moeda de evento)
    - Pray no gravestone: CommF_:InvokeServer("gravestoneEvent", 2)
    - Lucky no gravestone: CommF_:InvokeServer("gravestoneEvent", 1)
]]

local BoneFarm = {}

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
BoneFarm._running = false
BoneFarm._connection = nil
BoneFarm._respawnConnection = nil
BoneFarm._root = nil
BoneFarm._humanoid = nil
BoneFarm._bonesCount = 0
BoneFarm._sessionKills = 0
BoneFarm._sessionStart = 0

-- Localização do Haunted Castle
BoneFarm.HauntedCastle = {
    SpawnPos = CFrame.new(-8764, 142, 5963),
    QuestNPC = CFrame.new(-8750, 152, 5907),
    MobsArea = {
        CFrame.new(-8764, 142, 5963),
        CFrame.new(-8793, 142, 5944),
        CFrame.new(-8746, 142, 5927),
        CFrame.new(-8808, 142, 5960),
        CFrame.new(-8735, 142, 5973),
        CFrame.new(-8782, 142, 5993),
        CFrame.new(-8812, 142, 5985),
    },
    Gravestone = CFrame.new(-8750, 142, 5907),
}

-- Mobs da quest
BoneFarm.MobNames = {
    "Reborn Skeleton",
    "Living Zombie",
    "Demonic Soul",
    "Possessed Mummy",
}

-- Configurações
BoneFarm.Config = {
    Enabled = false,
    Method = "Below",
    TweenSpeed = 350,
    AttackDistance = 20,
    AutoQuest = true,
    AutoEquip = true,
    FastAttack = true,
    AutoHaki = true,
    AutoPray = false,           -- Auto rezar no gravestone
    AutoLucky = false,          -- Auto lucky no gravestone
    AutoCollectBones = true,
    UseSkills = true,
    SkillZ = true,
    SkillX = true,
    SkillC = true,
    SkillV = false,
    BringMobs = true,
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

local function GetLevel()
    local ok, v = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return ok and v or 0
end

local function EnsureCharacter()
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 30), char:WaitForChild("Humanoid", 30)
    end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
end

local function EquipWeapon(weaponType)
    weaponType = weaponType or "Melee"
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not backpack or not humanoid then return false end

    local priorities = {
        Melee = {"Godhuman", "Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Combat"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Soul Guitar"},
    }

    local weaponList = priorities[weaponType] or priorities.Melee
    for _, name in ipairs(weaponList) do
        local tool = backpack:FindFirstChild(name)
        if tool then humanoid:EquipTool(tool) return true end
    end

    local fallback = backpack:FindFirstChildOfClass("Tool")
    if fallback then humanoid:EquipTool(fallback) return true end
    return false
end

--[[
    Obter mobs da área do Haunted Castle
]]
local function GetBoneMobs()
    local mobs = {}
    local root = BoneFarm._root
    if not root then return mobs end

    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") then
                local humanoid = mob:FindFirstChild("Humanoid")
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")

                if humanoid and mobRoot and humanoid.Health > 0 then
                    -- Verificar se é mob do bone farm
                    for _, name in ipairs(BoneFarm.MobNames) do
                        if mob.Name == name or mob.Name:find(name) then
                            local dist = (root.Position - mobRoot.Position).Magnitude
                            table.insert(mobs, {
                                Model = mob,
                                RootPart = mobRoot,
                                Name = mob.Name,
                                Distance = dist,
                                Health = humanoid.Health,
                                MaxHealth = humanoid.MaxHealth,
                            })
                            break
                        end
                    end
                end
            end
        end
    end)

    table.sort(mobs, function(a, b) return a.Distance < b.Distance end)
    return mobs
end

--[[
    Aceitar quest de bone
]]
local function AcceptBoneQuest()
    local success, err = pcall(function()
        CommF_:InvokeServer("AcceptQuest", "HauntedQuest")
    end)
    if not success then
        warn("[BoneFarm] Erro ao aceitar quest: " .. tostring(err))
    end
    return success
end

--[[
    Verificar se tem quest ativa
]]
local function HasActiveQuest()
    local ok, result = pcall(function()
        local questGui = LocalPlayer.PlayerGui.Main.Quest
        if questGui and questGui.Visible then
            local title = questGui.Container.QuestTitle.Title
            if title and title.Text and title.Text:find("Haunted") then
                return true
            end
        end
        return false
    end)
    return ok and result or false
end

-- ══════════════════════════════════════════════════════════════════
-- SISTEMA DE COLETA DE BONES
-- ══════════════════════════════════════════════════════════════════

function BoneFarm:CollectBones()
    pcall(function()
        -- Verificar se há bones no chão
        local boneFolder = Workspace:FindFirstChild("Bones")
        if boneFolder then
            for _, bone in ipairs(boneFolder:GetChildren()) do
                if bone:IsA("BasePart") or bone:IsA("Model") then
                    local boneRoot = bone.PrimaryPart or bone:FindFirstChild("Handle") or bone
                    if boneRoot and boneRoot:IsA("BasePart") then
                        local dist = (self._root.Position - boneRoot.Position).Magnitude
                        if dist < 50 then
                            -- Puxar bone via CFrame
                            self._root.CFrame = CFrame.new(boneRoot.Position + Vector3.new(0, 3, 0))
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end)
end

--[[
    Usar gravestone (rezar ou lucky)
]]
function BoneFarm:UseGravestone(action)
    local success, err = pcall(function()
        if action == "pray" then
            CommF_:InvokeServer("gravestoneEvent", 2)
        elseif action == "lucky" then
            CommF_:InvokeServer("gravestoneEvent", 1)
        end
    end)

    if not success then
        warn("[BoneFarm] Erro no gravestone: " .. tostring(err))
    end
    return success
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES PRINCIPAIS
-- ══════════════════════════════════════════════════════════════════

function BoneFarm:Start()
    if self._running then return false end

    -- Verificar se está no Sea 3
    local currentSea = 1
    pcall(function()
        local Locations = getgenv().CUZAO and getgenv().CUZAO.Modules["Locations"]
        if Locations then currentSea = Locations:GetCurrentSea() end
    end)
    if currentSea < 3 then
        warn("[BoneFarm] Requer Sea 3. Sea atual: " .. currentSea)
        return false
    end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("BoneFarm")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()
    self._sessionKills = 0

    local root, hum = EnsureCharacter()
    self._root = root
    self._humanoid = hum

    -- Conectar respawn
    self._respawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        self._root = char:WaitForChild("HumanoidRootPart", 30)
        self._humanoid = char:WaitForChild("Humanoid", 30)
        task.wait(2)
    end)

    -- Teleportar para Haunted Castle
    if self._root then
        self._root.CFrame = self.HauntedCastle.SpawnPos
        task.wait(1)
    end

    -- Ativar Haki
    if self.Config.AutoHaki then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end

    print("[BoneFarm] Farm iniciado | Sea 3 - Haunted Castle")

    if EventBus then
        EventBus:Emit("AutoFarm.Bone.Started")
    end

    self._connection = task.spawn(function()
        self:MainLoop()
    end)

    return true
end

function BoneFarm:Stop()
    if not self._running then return false end

    self._running = false

    if self._connection then
        task.cancel(self._connection)
        self._connection = nil
    end

    if self._respawnConnection then
        self._respawnConnection:Disconnect()
        self._respawnConnection = nil
    end

    -- Abandonar quest
    pcall(function() CommF_:InvokeServer("AbandonQuest") end)

    print("[BoneFarm] Farm parado | Kills: " .. self._sessionKills)

    if EventBus then
        EventBus:Emit("AutoFarm.Bone.Stopped", {
            Kills = self._sessionKills,
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function BoneFarm:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ══════════════════════════════════════════════════════════════════

function BoneFarm:MainLoop()
    while self._running do
        -- Verificar personagem
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            task.wait(1)
            continue
        end

        -- Verificar morte
        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(3)
            continue
        end

        -- Aceitar quest se necessário
        if self.Config.AutoQuest and not HasActiveQuest() then
            AcceptBoneQuest()
            task.wait(1)
        end

        -- Encontrar mobs
        local mobs = GetBoneMobs()

        if #mobs == 0 then
            -- Nenhum mob, reposicionar
            local randomIdx = math.random(1, #self.HauntedCastle.MobsArea)
            self._root.CFrame = self.HauntedCastle.MobsArea[randomIdx]
            task.wait(1.5)
            continue
        end

        -- Coletar bones se habilitado
        if self.Config.AutoCollectBones then
            self:CollectBones()
        end

        -- Atacar mobs
        for _, mobData in ipairs(mobs) do
            if not self._running then break end

            -- Verificar mob vivo
            if not mobData.Model or not mobData.Model.Parent then continue end
            local hum = mobData.Model:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then
                self._sessionKills = self._sessionKills + 1
                continue
            end

            -- Posicionar
            local mobCFrame = mobData.RootPart.CFrame
            if self.Config.Method == "Below" then
                self._root.CFrame = CFrame.new(mobCFrame.Position + Vector3.new(0, -10, 0))
            else
                self._root.CFrame = mobCFrame * CFrame.new(0, 0, 5)
            end

            -- Equipar arma
            if self.Config.AutoEquip then
                EquipWeapon("Melee")
            end

            -- Atacar
            self:AttackMob(mobData.Model, mobData.RootPart)

            -- Skills
            if self.Config.UseSkills and math.random(1, 4) == 1 then
                self:UseSkills()
            end

            task.wait(0.05)
        end

        -- Usar gravestone periodicamente
        if self.Config.AutoPray and math.random(1, 50) == 1 then
            self:UseGravestone("pray")
            task.wait(1)
        end

        if self.Config.AutoLucky and math.random(1, 100) == 1 then
            self:UseGravestone("lucky")
            task.wait(1)
        end

        task.wait(0.1)
    end
end

function BoneFarm:AttackMob(model, rootPart)
    if not model or not rootPart then return end

    if self._root then
        self._root.CFrame = CFrame.new(self._root.Position, Vector3.new(rootPart.Position.X, self._root.Position.Y, rootPart.Position.Z))
    end

    if self.Config.FastAttack then
        pcall(function()
            local registerAttack = Remotes:FindFirstChild("RegisterAttack")
            local registerHit = Remotes:FindFirstChild("RegisterHit")
            if registerAttack and registerHit then
                registerAttack:FireServer(0)
                registerHit:FireServer(rootPart, {model})
            end
        end)
    end

    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function BoneFarm:UseSkills()
    local skills = {
        {key = "Z", enabled = self.Config.SkillZ},
        {key = "X", enabled = self.Config.SkillX},
        {key = "C", enabled = self.Config.SkillC},
        {key = "V", enabled = self.Config.SkillV},
    }
    for _, skill in ipairs(skills) do
        if skill.enabled then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, skill.key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, skill.key, false, game)
            end)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function BoneFarm:GetStatus()
    return {
        Running = self._running,
        SessionKills = self._sessionKills,
        SessionTime = tick() - self._sessionStart,
        AutoPray = self.Config.AutoPray,
        AutoLucky = self.Config.AutoLucky,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function BoneFarm:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("AutoFarm.Bone.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)
    end

    print("[BoneFarm] Módulo inicializado")
    return true
end

function BoneFarm:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("AutoFarm.Bone.Toggle")
    end
    print("[BoneFarm] Módulo limpo")
end

return BoneFarm
