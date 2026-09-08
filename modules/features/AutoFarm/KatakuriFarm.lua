--[[
    CUZAO HUB - Katakuri / Cake Farm Module
    Farm do Cake Prince no Sea 3

    Localização: Whole Cake Island
    Posição: CFrame.new(-1970, 45, -12330)

    Mobs:
    - Peanut Scout
    - Peanut President
    - Ice Cream Chef
    - Cake Guard
    - Baking Staff
    - Head Baker
    - Chocolate Battler
    - Candy Crawler

    Boss: Cake Prince
    - Spawna após 500 kills
    - CommF_:InvokeServer("CakePrinceSpawner") para verificar progresso

    Katakuri (Dough V2):
    - Dropa do Cake Prince
    - CommF_:InvokeServer("CakePrinceSpawner") retorna nil quando spawnado
]]

local KatakuriFarm = {}

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
KatakuriFarm._running = false
KatakuriFarm._connection = nil
KatakuriFarm._respawnConnection = nil
KatakuriFarm._root = nil
KatakuriFarm._humanoid = nil
KatakuriFarm._sessionKills = 0
KatakuriFarm._sessionStart = 0
KatakuriFarm._princeKills = 0
KatakuriFarm._princeSpawned = false

-- Localização
KatakuriFarm.Location = {
    IslandCenter = CFrame.new(-1970, 45, -12330),
    MobsArea = {
        CFrame.new(-1970, 45, -12330),
        CFrame.new(-2000, 45, -12360),
        CFrame.new(-1940, 45, -12300),
        CFrame.new(-1990, 45, -12290),
        CFrame.new(-1950, 45, -12350),
        CFrame.new(-2020, 45, -12320),
        CFrame.new(-1920, 45, -12340),
    },
}

-- Mobs do Cake Island
KatakuriFarm.MobNames = {
    "Peanut Scout",
    "Peanut President",
    "Ice Cream Chef",
    "Cake Guard",
    "Baking Staff",
    "Head Baker",
    "Chocolate Battler",
    "Candy Crawler",
}

-- Boss
KatakuriFarm.BossName = "Cake Prince"

-- Configurações
KatakuriFarm.Config = {
    Enabled = false,
    KillPrince = true,          -- Atacar o Cake Prince quando spawnar
    Method = "Below",
    AttackDistance = 20,
    AutoEquip = true,
    FastAttack = true,
    AutoHaki = true,
    UseSkills = true,
    SkillZ = true,
    SkillX = true,
    SkillC = true,
    SkillV = false,
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

local function EquipWeapon()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not backpack or not humanoid then return end

    local priorities = {"Godhuman", "Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Combat"}
    for _, name in ipairs(priorities) do
        local tool = backpack:FindFirstChild(name)
        if tool then humanoid:EquipTool(tool) return end
    end
    local fallback = backpack:FindFirstChildOfClass("Tool")
    if fallback then humanoid:EquipTool(fallback) end
end

--[[
    Verificar progresso do Cake Prince
    Retorna: kills atuais (0-500), ou nil se já spawnou
]]
function KatakuriFarm:GetCakePrinceProgress()
    local success, result = pcall(function()
        return CommF_:InvokeServer("CakePrinceSpawner")
    end)

    if success and result then
        -- result é uma string como "500" ou número de kills restantes
        if type(result) == "number" then
            return result
        elseif type(result) == "string" then
            local num = tonumber(result:match("(%d+)"))
            return num
        end
    end

    -- Se retornar nil/vazio, o boss pode ter spawnado
    return 0, true -- 0 kills, possivelmente spawnado
end

--[[
    Obter mobs do Cake Island
]]
function KatakuriFarm:GetCakeMobs()
    local mobs = {}
    local root = self._root
    if not root then return mobs end

    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob:IsA("Model") then
                local humanoid = mob:FindFirstChild("Humanoid")
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")

                if humanoid and mobRoot and humanoid.Health > 0 then
                    -- Verificar se é mob do Cake Island
                    for _, name in ipairs(self.MobNames) do
                        if mob.Name == name then
                            local dist = (root.Position - mobRoot.Position).Magnitude
                            table.insert(mobs, {
                                Model = mob,
                                RootPart = mobRoot,
                                Name = mob.Name,
                                Distance = dist,
                                Health = humanoid.Health,
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
    Verificar se o Cake Prince está spawnado
]]
function KatakuriFarm:IsPrinceSpawned()
    local success, result = pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return nil end

        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name == self.BossName then
                local humanoid = mob:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return mob
                end
            end
        end
        return nil
    end)

    return success and result or nil
end

--[[
    Atacar entidade específica
]]
function KatakuriFarm:AttackEntity(model, rootPart)
    if not model or not rootPart then return end

    if self._root then
        self._root.CFrame = CFrame.new(self._root.Position, Vector3.new(rootPart.Position.X, self._root.Position.Y, rootPart.Position.Z))
    end

    EquipWeapon()

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

function KatakuriFarm:UseSkills()
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
-- CONTROLES PRINCIPAIS
-- ══════════════════════════════════════════════════════════════════

function KatakuriFarm:Start()
    if self._running then return false end

    -- Verificar Sea 3
    local currentSea = 1
    pcall(function()
        local Locations = getgenv().CUZAO and getgenv().CUZAO.Modules["Locations"]
        if Locations then currentSea = Locations:GetCurrentSea() end
    end)
    if currentSea < 3 then
        warn("[KatakuriFarm] Requer Sea 3")
        return false
    end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("KatakuriFarm")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()
    self._sessionKills = 0
    self._princeKills = 0

    local root, hum = EnsureCharacter()
    self._root = root
    self._humanoid = hum

    self._respawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        self._root = char:WaitForChild("HumanoidRootPart", 30)
        self._humanoid = char:WaitForChild("Humanoid", 30)
        task.wait(2)
    end)

    -- Teleportar para Cake Island
    if self._root then
        self._root.CFrame = self.Location.IslandCenter
        task.wait(1)
    end

    if self.Config.AutoHaki then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end

    print("[KatakuriFarm] Farm iniciado | Cake Prince Farm")

    if EventBus then
        EventBus:Emit("AutoFarm.Katakuri.Started")
    end

    self._connection = task.spawn(function()
        self:MainLoop()
    end)

    return true
end

function KatakuriFarm:Stop()
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

    print("[KatakuriFarm] Farm parado | Kills: " .. self._sessionKills .. " | Prince Kills: " .. self._princeKills)

    if EventBus then
        EventBus:Emit("AutoFarm.Katakuri.Stopped", {
            Kills = self._sessionKills,
            PrinceKills = self._princeKills,
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function KatakuriFarm:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ══════════════════════════════════════════════════════════════════

function KatakuriFarm:MainLoop()
    while self._running do
        -- Verificar personagem
        if not self._root or not self._root.Parent then
            local root, hum = EnsureCharacter()
            self._root = root
            self._humanoid = hum
            task.wait(1)
            continue
        end

        if self._humanoid and self._humanoid.Health <= 0 then
            task.wait(3)
            continue
        end

        -- Verificar se Cake Prince spawnou
        local prince = self:IsPrinceSpawned()

        if prince and self.Config.KillPrince then
            -- Boss encontrado! Atacar com prioridade
            self._princeSpawned = true
            local princeRoot = prince:FindFirstChild("HumanoidRootPart")
            local princeHum = prince:FindFirstChild("Humanoid")

            if princeRoot and princeHum and princeHum.Health > 0 then
                -- Posicionar perto do boss
                self._root.CFrame = princeRoot.CFrame * CFrame.new(0, -10, 0)
                task.wait(0.2)

                -- Atacar boss
                local startTime = tick()
                while self._running and princeHum.Health > 0 and prince.Parent do
                    self:AttackEntity(prince, princeRoot)
                    if math.random(1, 3) == 1 then
                        self:UseSkills()
                    end
                    task.wait(0.05)
                end

                if princeHum.Health <= 0 or not prince.Parent then
                    self._princeKills = self._princeKills + 1
                    self._sessionKills = self._sessionKills + 1
                    print("[KatakuriFarm] Cake Prince derrotado! Total: " .. self._princeKills)

                    if EventBus then
                        EventBus:Emit("AutoFarm.Katakuri.PrinceKilled", {
                            TotalPrinceKills = self._princeKills,
                        })
                    end
                end

                self._princeSpawned = false
                task.wait(2)
                continue
            end
        end

        -- Farm normal: matar mobs para progredir kills
        local mobs = self:GetCakeMobs()

        if #mobs == 0 then
            -- Nenhum mob, reposicionar
            local randomIdx = math.random(1, #self.Location.MobsArea)
            self._root.CFrame = self.Location.MobsArea[randomIdx]
            task.wait(1.5)
            continue
        end

        for _, mobData in ipairs(mobs) do
            if not self._running then break end

            if not mobData.Model or not mobData.Model.Parent then continue end
            local hum = mobData.Model:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then
                self._sessionKills = self._sessionKills + 1
                continue
            end

            -- Posicionar
            local mobCF = mobData.RootPart.CFrame
            if self.Config.Method == "Below" then
                self._root.CFrame = CFrame.new(mobCF.Position + Vector3.new(0, -10, 0))
            else
                self._root.CFrame = mobCF * CFrame.new(0, 0, 5)
            end

            self:AttackEntity(mobData.Model, mobData.RootPart)

            if math.random(1, 4) == 1 then
                self:UseSkills()
            end

            task.wait(0.05)
        end

        -- Emitir progresso periodicamente
        if math.random(1, 30) == 1 then
            local remaining = self:GetCakePrinceProgress()
            if EventBus then
                EventBus:Emit("AutoFarm.Katakuri.Progress", {
                    Kills = self._sessionKills,
                    PrinceKills = self._princeKills,
                    Remaining = remaining,
                })
            end
        end

        task.wait(0.1)
    end
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function KatakuriFarm:GetStatus()
    return {
        Running = self._running,
        SessionKills = self._sessionKills,
        PrinceKills = self._princeKills,
        PrinceSpawned = self._princeSpawned,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function KatakuriFarm:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("AutoFarm.Katakuri.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)
    end

    print("[KatakuriFarm] Módulo inicializado")
    return true
end

function KatakuriFarm:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("AutoFarm.Katakuri.Toggle")
    end
    print("[KatakuriFarm] Módulo limpo")
end

return KatakuriFarm
