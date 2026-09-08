--[[
    CUZAO HUB - Level Farm Module
    Auto-farm por nível com sistema de quests automático
    Suporta Sea 1, Sea 2 e Sea 3

    Fluxo principal:
    1. Detectar nível do jogador
    2. Encontrar ilha/quest apropriada
    3. Aceitar quest no NPC
    4. Teleportar para spawn dos mobs
    5. Matar mobs até completar quest
    6. Repetir ciclo
]]

local LevelFarm = {}

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

-- Referências de módulos (injetadas via Initialize)
local ConfigManager = nil
local EventBus = nil
local Combat = nil
local Movement = nil
local TweenModule = nil
local Locations = nil
local Inventory = nil

-- Estado interno
LevelFarm._running = false
LevelFarm._connection = nil
LevelFarm._attackConnection = nil
LevelFarm._respawnConnection = nil
LevelFarm._characterConnection = nil
LevelFarm._currentQuest = nil
LevelFarm._currentIsland = nil
LevelFarm._currentLevel = 0
LevelFarm._targetLevel = nil
LevelFarm._killsCount = 0
LevelFarm._sessionKills = 0
LevelFarm._sessionStart = 0

-- Referência do personagem
LevelFarm._root = nil
LevelFarm._humanoid = nil

-- Configurações padrão
LevelFarm.Config = {
    Enabled = false,
    Weapon = "Melee",
    Method = "Below",           -- Below, Behind, Above, Tween
    TweenSpeed = 350,
    AttackDistance = 15,
    AutoQuest = true,
    AutoEquip = true,
    FastAttack = true,
    AutoHaki = true,
    AutoKen = false,
    BringMobs = false,
    UseSkills = true,
    SkillZ = true,
    SkillX = true,
    SkillC = true,
    SkillV = false,
    SkillF = false,
    BypassTP = true,
    StopOnNoQuest = false,
    TargetLevel = nil,          -- Nível para parar (nil = nunca)
}

-- ══════════════════════════════════════════════════════════════════
-- DADOS DE QUEST POR NÍVEL
-- Cada entry: { questName, npcCFrame, mobPositions, levelRange }
-- ══════════════════════════════════════════════════════════════════

LevelFarm.QuestData = {
    -- ═══ SEA 1 ═══
    { questName = "BanditQuest1",           npcCFrame = CFrame.new(1059, 16, 1455),     mobPos = CFrame.new(1097, 16, 1495),     levelRange = {1, 10} },
    { questName = "MonkeyQuest",            npcCFrame = CFrame.new(-1612, 36, 149),     mobPos = CFrame.new(-1602, 36, 149),     levelRange = {10, 20} },
    { questName = "GorillaQuest",           npcCFrame = CFrame.new(-1612, 36, 149),     mobPos = CFrame.new(-1624, 36, 145),     levelRange = {20, 30} },
    { questName = "PirateQuest",            npcCFrame = CFrame.new(-1131, 4, 3828),     mobPos = CFrame.new(-1120, 4, 3830),     levelRange = {30, 40} },
    { questName = "DesertQuest",            npcCFrame = CFrame.new(944, 6, 4373),       mobPos = CFrame.new(940, 6, 4370),       levelRange = {60, 75} },
    { questName = "FrozenQuest",            npcCFrame = CFrame.new(1384, 87, -1298),    mobPos = CFrame.new(1380, 87, -1295),    levelRange = {90, 110} },
    { questName = "SkyQuest",               npcCFrame = CFrame.new(-4968, 717, -2623),  mobPos = CFrame.new(-4970, 717, -2620),  levelRange = {110, 140} },
    { questName = "PrisonQuest",            npcCFrame = CFrame.new(4875, 5, 734),       mobPos = CFrame.new(4880, 5, 730),       levelRange = {150, 175} },
    { questName = "ColosseumQuest",         npcCFrame = CFrame.new(-1576, 7, -2983),    mobPos = CFrame.new(-1580, 7, -2980),    levelRange = {175, 210} },
    { questName = "MagmaQuest",             npcCFrame = CFrame.new(-5247, 12, 8534),    mobPos = CFrame.new(-5245, 12, 8530),    levelRange = {210, 250} },
    { questName = "UnderwaterQuest",        npcCFrame = CFrame.new(61163, 11, 1819),    mobPos = CFrame.new(61160, 11, 1815),    levelRange = {300, 375} },
    { questName = "FountainQuest",          npcCFrame = CFrame.new(5256, 39, 4050),     mobPos = CFrame.new(5260, 39, 4055),     levelRange = {375, 450} },
    { questName = "ForgottenQuest",         npcCFrame = CFrame.new(-3032, 240, -10172), mobPos = CFrame.new(-3030, 240, -10170), levelRange = {450, 525} },

    -- ═══ SEA 2 ═══
    { questName = "KingdomQuest",           npcCFrame = CFrame.new(-379, 36, 5594),     mobPos = CFrame.new(-380, 36, 5590),     levelRange = {700, 850}, sea = 2 },
    { questName = "GreenZoneQuest",         npcCFrame = CFrame.new(-2373, 25, -3221),   mobPos = CFrame.new(-2370, 25, -3218),   levelRange = {850, 1000}, sea = 2 },
    { questName = "GraveyardQuest",         npcCFrame = CFrame.new(-5370, 19, -792),    mobPos = CFrame.new(-5370, 19, -790),    levelRange = {1000, 1150}, sea = 2 },
    { questName = "SnowMountainQuest",      npcCFrame = CFrame.new(647, 400, -13000),   mobPos = CFrame.new(645, 400, -13000),   levelRange = {1150, 1300}, sea = 2 },
    { questName = "HotColdQuest",           npcCFrame = CFrame.new(6540, 50, -13100),   mobPos = CFrame.new(6540, 50, -13100),   levelRange = {1250, 1450}, sea = 2 },
    { questName = "CursedShipQuest",        npcCFrame = CFrame.new(923, 125, 32800),    mobPos = CFrame.new(920, 125, 32800),    levelRange = {1450, 1550}, sea = 2 },

    -- ═══ SEA 3 ═══
    { questName = "PortTownQuest",          npcCFrame = CFrame.new(-290, 44, 5590),     mobPos = CFrame.new(-290, 44, 5590),     levelRange = {1700, 1850}, sea = 3 },
    { questName = "HydraQuest",             npcCFrame = CFrame.new(5746, 610, -253),    mobPos = CFrame.new(5746, 610, -253),    levelRange = {1850, 2000}, sea = 3 },
    { questName = "GreatTreeQuest",         npcCFrame = CFrame.new(2681, 1682, -7190),  mobPos = CFrame.new(2681, 1682, -7190),  levelRange = {1950, 2100}, sea = 3 },
    { questName = "TikiOutpostQuest",       npcCFrame = CFrame.new(-16400, 350, -500),  mobPos = CFrame.new(-16400, 350, -500),  levelRange = {2100, 2250}, sea = 3 },
    { questName = "KitsuneQuest",           npcCFrame = CFrame.new(-1598, 245, -1254),  mobPos = CFrame.new(-1598, 245, -1254),  levelRange = {2250, 2400}, sea = 3 },
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

--[[
    Obtém o nível atual do jogador de forma confiável
    Nunca usar valor cacheado — sempre consultar Data
]]
local function GetLevel()
    local ok, v = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return ok and v or 0
end

--[[
    Garante que o personagem existe e tem HumanoidRootPart
    Retorna: rootPart, humanoid (ou nil, nil se falhar)
]]
local function EnsureCharacter()
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 30)
        local hum = char:WaitForChild("Humanoid", 30)
        return root, hum
    end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
end

--[[
    Busca a quest apropriada para o nível atual
    Retorna: table da quest ou nil
]]
local function GetQuestForLevel(level)
    local currentSea = 1
    if Locations then
        currentSea = Locations:GetCurrentSea()
    end

    -- Procurar quest que cubra o nível atual
    for _, quest in ipairs(LevelFarm.QuestData) do
        local minLv = quest.levelRange[1]
        local maxLv = quest.levelRange[2]
        local questSea = quest.sea or 1

        if questSea <= currentSea and level >= minLv and level <= maxLv then
            return quest
        end
    end

    -- Fallback: pegar a quest com range mais próximo
    local bestQuest = nil
    local bestDist = math.huge

    for _, quest in ipairs(LevelFarm.QuestData) do
        local questSea = quest.sea or 1
        if questSea <= currentSea then
            local midLevel = (quest.levelRange[1] + quest.levelRange[2]) / 2
            local dist = math.abs(level - midLevel)
            if dist < bestDist then
                bestDist = dist
                bestQuest = quest
            end
        end
    end

    return bestQuest
end

--[[
    Verifica se há quest ativa no GUI
    Retorna: nome da quest ativa ou nil
]]
local function GetActiveQuest()
    local success, questName = pcall(function()
        local questGui = LocalPlayer.PlayerGui.Main.Quest
        if questGui and questGui.Visible then
            local title = questGui.Container.QuestTitle.Title
            if title then
                return title.Text
            end
        end
        return nil
    end)
    return success and questName or nil
end

--[[
    Aceita uma quest específica
]]
local function AcceptQuest(questName)
    local success, err = pcall(function()
        CommF_:InvokeServer("AcceptQuest", questName)
    end)
    if not success then
        warn("[LevelFarm] Erro ao aceitar quest '" .. tostring(questName) .. "': " .. tostring(err))
    end
    return success
end

--[[
    Abandonar quest atual
]]
local function AbandonQuest()
    local success, err = pcall(function()
        CommF_:InvokeServer("AbandonQuest")
    end)
    if not success then
        warn("[LevelFarm] Erro ao abandonar quest: " .. tostring(err))
    end
    return success
end

--[[
    Equipar arma do tipo configurado
]]
local function EquipWeapon(weaponType)
    weaponType = weaponType or LevelFarm.Config.Weapon

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not backpack or not humanoid then return false end

    local priorities = {
        Melee = {"Godhuman", "Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Sharkman Karate", "Black Leg", "Combat"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber", "Buddy Sword", "Dual Katana", "Katana", "Cutlass"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Kabucha", "Soul Guitar", "Bazooka", "Cannon", "Flintlock"},
    }

    local weaponList = priorities[weaponType] or priorities.Melee

    for _, weaponName in ipairs(weaponList) do
        local tool = backpack:FindFirstChild(weaponName)
        if tool then
            humanoid:EquipTool(tool)
            return true
        end
    end

    -- Fallback: primeira tool disponível
    local tool = backpack:FindFirstChildOfClass("Tool")
    if tool then
        humanoid:EquipTool(tool)
        return true
    end

    return false
end

--[[
    Coletar posições dos mobs da quest no workspace
    Retorna array de CFrames dos mobs vivos
]]
local function GetMobPositions(mobName)
    local positions = {}

    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") and mob.Name == mobName then
                local humanoid = mob:FindFirstChild("Humanoid")
                local rootPart = mob:FindFirstChild("HumanoidRootPart")
                if humanoid and rootPart and humanoid.Health > 0 then
                    table.insert(positions, {
                        CFrame = rootPart.CFrame,
                        Model = mob,
                        Health = humanoid.Health,
                        MaxHealth = humanoid.MaxHealth,
                    })
                end
            end
        end
    end)

    return positions
end

--[[
    Encontrar mob mais próximo
]]
local function GetNearestMob(mobName, maxDistance)
    local root = LevelFarm._root
    if not root then return nil end

    maxDistance = maxDistance or 500
    local nearest = nil
    local nearestDist = maxDistance

    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") and mob.Name == mobName then
                local humanoid = mob:FindFirstChild("Humanoid")
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                if humanoid and mobRoot and humanoid.Health > 0 then
                    local dist = (root.Position - mobRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = mob
                    end
                end
            end
        end
    end)

    return nearest
end

--[[
    Posicionar personagem em relação ao mob (baseado no método configurado)
]]
local function PositionToMob(mobModel, method)
    local root = LevelFarm._root
    if not root or not mobModel then return end

    local mobRoot = mobModel:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return end

    local targetCFrame

    if method == "Below" then
        -- Ficar abaixo do mob
        local mobPos = mobRoot.Position
        local belowPos = Vector3.new(mobPos.X, mobPos.Y - 10, mobPos.Z)
        targetCFrame = CFrame.new(belowPos)
    elseif method == "Behind" then
        -- Ficar atrás do mob
        targetCFrame = mobRoot.CFrame * CFrame.new(0, 0, 5)
    elseif method == "Above" then
        -- Ficar acima do mob
        local mobPos = mobRoot.Position
        local abovePos = Vector3.new(mobPos.X, mobPos.Y + 15, mobPos.Z)
        targetCFrame = CFrame.new(abovePos)
    else
        -- Default: acima
        targetCFrame = mobRoot.CFrame * CFrame.new(0, 30, 0)
    end

    -- Aplicar teleport direto (rápido) ou suavizado
    root.CFrame = targetCFrame
end

--[[
    Atacar mob específico usando os remotes do jogo
]]
local function AttackMob(mobModel)
    if not mobModel then return end

    local root = LevelFarm._root
    if not root then return end

    local mobRoot = mobModel:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return end

    -- Olhar para o mob
    root.CFrame = CFrame.new(root.Position, Vector3.new(mobRoot.Position.X, root.Position.Y, mobRoot.Position.Z))

    -- Equipar arma
    if LevelFarm.Config.AutoEquip then
        EquipWeapon(LevelFarm.Config.Weapon)
    end

    -- Fast Attack usando remotes
    if LevelFarm.Config.FastAttack then
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                -- Ataque rápido via RegisterAttack/RegisterHit
                pcall(function()
                    local registerAttack = Remotes:FindFirstChild("RegisterAttack")
                    local registerHit = Remotes:FindFirstChild("RegisterHit")
                    if registerAttack and registerHit then
                        registerAttack:FireServer(0)
                        registerHit:FireServer(mobRoot, {mobModel})
                    end
                end)
            end
        end
    end

    -- Click para atacar (fallback)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

--[[
    Usar habilidades configuradas
]]
local function UseSkills()
    if not LevelFarm.Config.UseSkills then return end

    local skills = {
        {key = "Z", enabled = LevelFarm.Config.SkillZ},
        {key = "X", enabled = LevelFarm.Config.SkillX},
        {key = "C", enabled = LevelFarm.Config.SkillC},
        {key = "V", enabled = LevelFarm.Config.SkillV},
        {key = "F", enabled = LevelFarm.Config.SkillF},
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

--[[
    Ativar Buso Haki se disponível
]]
local function ActivateHaki()
    if not LevelFarm.Config.AutoHaki then return end
    pcall(function()
        CommF_:InvokeServer("Buso")
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL DO FARM
-- ══════════════════════════════════════════════════════════════════

function LevelFarm:Start()
    if self._running then
        warn("[LevelFarm] Farm já está em execução")
        return false
    end

    -- Sincronizar config com ConfigManager
    if ConfigManager then
        local cfg = ConfigManager:Get("AutoFarm")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then
                    self.Config[k] = v
                end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()
    self._sessionKills = 0
    self._currentLevel = GetLevel()

    -- Garantir personagem
    local root, hum = EnsureCharacter()
    self._root = root
    self._humanoid = hum

    -- Conectar respawn do personagem
    self._respawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        self._root = char:WaitForChild("HumanoidRootPart", 30)
        self._humanoid = char:WaitForChild("Humanoid", 30)
        task.wait(1) -- Esperar carregar
        self:OnCharacterRespawned()
    end)

    -- Ativar haki
    if self.Config.AutoHaki then
        ActivateHaki()
    end

    print("[LevelFarm] Farm iniciado | Nível: " .. self._currentLevel .. " | Método: " .. self.Config.Method)

    -- Emitir evento
    if EventBus then
        EventBus:Emit("AutoFarm.Level.Started", {
            Level = self._currentLevel,
            Method = self.Config.Method,
        })
    end

    -- Iniciar loop principal
    self._connection = task.spawn(function()
        self:MainLoop()
    end)

    return true
end

function LevelFarm:Stop()
    if not self._running then return false end

    self._running = false

    -- Cancelar loops
    if self._connection then
        task.cancel(self._connection)
        self._connection = nil
    end

    if self._attackConnection then
        task.cancel(self._attackConnection)
        self._attackConnection = nil
    end

    -- Desconectar eventos
    if self._respawnConnection then
        self._respawnConnection:Disconnect()
        self._respawnConnection = nil
    end

    if self._characterConnection then
        self._characterConnection:Disconnect()
        self._characterConnection = nil
    end

    -- Abandonar quest ativa
    if self._currentQuest then
        AbandonQuest()
        self._currentQuest = nil
    end

    print("[LevelFarm] Farm parado | Kills na sessão: " .. self._sessionKills)

    if EventBus then
        EventBus:Emit("AutoFarm.Level.Stopped", {
            Kills = self._sessionKills,
            Level = GetLevel(),
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function LevelFarm:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ══════════════════════════════════════════════════════════════════

function LevelFarm:MainLoop()
    while self._running do
        -- Verificar se atingiu nível alvo
        local currentLevel = GetLevel()
        self._currentLevel = currentLevel

        if self.Config.TargetLevel and currentLevel >= self.Config.TargetLevel then
            print("[LevelFarm] Nível alvo atingido: " .. currentLevel .. "/" .. self.Config.TargetLevel)
            self:Stop()
            return
        end

        -- Verificar personagem
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            task.wait(1)
            continue
        end

        -- Verificar se morreu
        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(3) -- Esperar respawn
            continue
        end

        -- Buscar quest apropriada
        local questData = GetQuestForLevel(currentLevel)

        if not questData then
            if self.Config.StopOnNoQuest then
                warn("[LevelFarm] Nenhuma quest encontrada para nível " .. currentLevel)
                self:Stop()
                return
            end
            warn("[LevelFarm] Nenhuma quest encontrada, aguardando...")
            task.wait(5)
            continue
        end

        -- Verificar se precisa aceitar quest
        if self.Config.AutoQuest then
            local activeQuest = GetActiveQuest()

            if not activeQuest or activeQuest ~= questData.questName then
                -- Abandonar quest anterior se existir
                if activeQuest then
                    AbandonQuest()
                    task.wait(0.5)
                end

                -- Aceitar nova quest
                AcceptQuest(questData.questName)
                self._currentQuest = questData.questName
                task.wait(1)
            end
        end

        -- Encontrar mobs da quest
        local questMobs = self:GetQuestMobs(questData)

        if #questMobs == 0 then
            -- Nenhum mob vivo, teleportar para spawn
            self._root.CFrame = questData.mobPos * CFrame.new(0, 10, 0)
            task.wait(1.5)
            continue
        end

        -- Atacar mobs
        self:AttackQuestMobs(questMobs, questData)

        -- Delay entre ciclos
        task.wait(0.1)
    end
end

--[[
    Obter mobs da quest atual
]]
function LevelFarm:GetQuestMobs(questData)
    local mobs = {}

    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end

        -- Nome do mob baseado no nome da quest
        -- Remover "Quest" do final e capitalizar
        local mobName = questData.questName:gsub("Quest", "")

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") then
                local humanoid = mob:FindFirstChild("Humanoid")
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")

                if humanoid and mobRoot and humanoid.Health > 0 then
                    -- Verificar se é da quest (nome ou distância)
                    local isQuestMob = false

                    -- Verificar por nome parcial
                    if mobName:lower():find(mob.Name:lower()) or mob.Name:lower():find(mobName:lower()) then
                        isQuestMob = true
                    end

                    -- Verificar por distância do spawn
                    if not isQuestMob then
                        local dist = (mobRoot.Position - questData.mobPos.Position).Magnitude
                        if dist < 150 then
                            isQuestMob = true
                        end
                    end

                    if isQuestMob then
                        table.insert(mobs, {
                            Model = mob,
                            RootPart = mobRoot,
                            Distance = (self._root.Position - mobRoot.Position).Magnitude,
                            Health = humanoid.Health,
                            MaxHealth = humanoid.MaxHealth,
                        })
                    end
                end
            end
        end
    end)

    -- Ordenar por distância
    table.sort(mobs, function(a, b) return a.Distance < b.Distance end)

    return mobs
end

--[[
    Atacar todos os mobs da quest
]]
function LevelFarm:AttackQuestMobs(mobs, questData)
    for _, mobData in ipairs(mobs) do
        if not self._running then break end

        -- Verificar se mob ainda está vivo
        if not mobData.Model or not mobData.Model.Parent then continue end
        local humanoid = mobData.Model:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            self._sessionKills = self._sessionKills + 1
            continue
        end

        -- Reposicionar perto do mob
        PositionToMob(mobData.Model, self.Config.Method)

        -- Atacar
        AttackMob(mobData.Model)

        -- Usar skills a cada poucos hits
        if math.random(1, 3) == 1 then
            UseSkills()
        end

        task.wait(0.05)
    end
end

-- ══════════════════════════════════════════════════════════════════
-- CALLBACKS
-- ══════════════════════════════════════════════════════════════════

function LevelFarm:OnCharacterRespawned()
    if not self._running then return end

    print("[LevelFarm] Personagem respawning, reajustando...")

    -- Esperar carregar
    task.wait(2)

    -- Reativar haki
    if self.Config.AutoHaki then
        ActivateHaki()
    end

    -- Atualizar referências
    local root, hum = EnsureCharacter()
    self._root = root
    self._humanoid = hum

    -- Emitir evento
    if EventBus then
        EventBus:Emit("AutoFarm.Level.Respawned", {
            Level = GetLevel(),
        })
    end
end

-- ══════════════════════════════════════════════════════════════════
-- API DE CONFIGURAÇÃO
-- ══════════════════════════════════════════════════════════════════

function LevelFarm:SetMethod(method)
    self.Config.Method = method
    print("[LevelFarm] Método alterado para: " .. method)
end

function LevelFarm:SetTargetLevel(level)
    self.Config.TargetLevel = level
    print("[LevelFarm] Nível alvo definido: " .. tostring(level))
end

function LevelFarm:SetWeapon(weaponType)
    self.Config.Weapon = weaponType
    print("[LevelFarm] Arma definida: " .. weaponType)
end

function LevelFarm:SetTweenSpeed(speed)
    self.Config.TweenSpeed = speed
end

function LevelFarm:GetStatus()
    return {
        Running = self._running,
        Level = self._currentLevel,
        TargetLevel = self.Config.TargetLevel,
        CurrentQuest = self._currentQuest,
        SessionKills = self._sessionKills,
        SessionTime = tick() - self._sessionStart,
        Method = self.Config.Method,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function LevelFarm:Initialize(deps)
    deps = deps or {}

    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus
    Combat = deps.Combat
    Movement = deps.Movement
    TweenModule = deps.TweenModule
    Locations = deps.Locations
    Inventory = deps.Inventory

    -- Escutar eventos
    if EventBus then
        EventBus:On("AutoFarm.Level.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)

        EventBus:On("AutoFarm.Level.UpdateConfig", function(cfg)
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then
                    self.Config[k] = v
                end
            end
        end)
    end

    print("[LevelFarm] Módulo inicializado")
    return true
end

function LevelFarm:Cleanup()
    self:Stop()

    if EventBus then
        EventBus:Clear("AutoFarm.Level.Toggle")
        EventBus:Clear("AutoFarm.Level.UpdateConfig")
    end

    print("[LevelFarm] Módulo limpo")
end

return LevelFarm
