--[[
    CUZAO HUB - Stat Assign Module
    Distribuição automática de pontos de stats

    Stats disponíveis:
    - Melee (Força)
    - Defense (Defesa)
    - Sword (Espada)
    - Gun (Arma de fogo)
    - Demon Fruit (Fruta)

    Métodos:
    - Auto: Distribui automaticamente baseado na prioridade
    - OneShot: Coloca todos os pontos em uma stat específica
    - Balanced: Distribui equilibradamente entre stats
]]

local StatAssign = {}

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
StatAssign._running = false
StatAssign._autoAssignConnection = nil
StatAssign._sessionStart = 0
StatAssign._totalAssigned = 0

-- Configurações
StatAssign.Config = {
    Enabled = false,
    Mode = "Auto",              -- Auto, OneShot, Balanced, Custom
    Priority = {"Melee", "Defense", "Sword", "Gun", "Fruit"},

    -- Modo Auto: percentual分配
    AutoPercentages = {
        Melee = 40,
        Defense = 40,
        Sword = 10,
        Gun = 0,
        Fruit = 10,
    },

    -- Modo OneShot: stats a distribuir
    OneShotStat = "Melee",

    -- Modo Custom: distribuição personalizada
    CustomDistribution = {
        Melee = 30,
        Defense = 30,
        Sword = 20,
        Gun = 10,
        Fruit = 10,
    },

    -- Intervalo de verificação
    AssignInterval = 2,         -- Segundos entre cada distribuição
    MaxPerCycle = 5,            -- Máximo de pontos por ciclo (evita flood)
    AutoAssignOnLevelUp = true, -- Auto distribuir ao subir de nível
}

-- ══════════════════════════════════════════════════════════════════
-- DADOS DE STATS
-- ══════════════════════════════════════════════════════════════════

StatAssign.Stats = {
    "Melee", "Defense", "Sword", "Gun", "Fruit",
}

StatAssign.StatNames = {
    ["Melee"] = "Melee",
    ["Defense"] = "Defense",
    ["Sword"] = "Sword",
    ["Gun"] = "Gun",
    ["Fruit"] = "Demon Fruit",     -- Nome que o CommF_ espera
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

--[[
    Obter pontos disponíveis para distribuir
]]
function StatAssign:GetAvailablePoints()
    local success, points = pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local stats = data:FindFirstChild("Stats")
            if stats then
                local pointsVal = stats:FindFirstChild("Points")
                if pointsVal then
                    return pointsVal.Value
                end
            end
        end
        return 0
    end)

    return success and points or 0
end

--[[
    Obter nível atual
]]
function StatAssign:GetLevel()
    local success, level = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return success and level or 0
end

--[[
    Obter valor de uma stat específica
]]
function StatAssign:GetStatValue(statName)
    local success, value = pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local stats = data:FindFirstChild("Stats")
            if stats then
                local stat = stats:FindFirstChild(statName)
                if stat then
                    return stat.Value
                end
            end
        end
        return 0
    end)

    return success and value or 0
end

--[[
    Obter todas as stats atuais
]]
function StatAssign:GetAllStats()
    local stats = {}
    for _, statName in ipairs(self.Stats) do
        stats[statName] = self:GetStatValue(statName)
    end
    stats.Points = self:GetAvailablePoints()
    stats.Level = self:GetLevel()
    return stats
end

--[[
    Adicionar pontos em uma stat
    Retorna: success, pontos restantes
]]
function StatAssign:AddPoints(statName, amount)
    if amount <= 0 then return true, 0 end

    local remoteName = self.StatNames[statName] or statName

    local success, err = pcall(function()
        CommF_:InvokeServer("AddPoint", remoteName, amount)
    end)

    if success then
        self._totalAssigned = self._totalAssigned + amount
    else
        warn("[StatAssign] Erro ao adicionar " .. amount .. " pontos em " .. statName .. ": " .. tostring(err))
    end

    return success, amount
end

-- ══════════════════════════════════════════════════════════════════
-- MÉTODOS DE DISTRIBUIÇÃO
-- ══════════════════════════════════════════════════════════════════

--[[
    Modo Auto: Distribui baseado em percentuais configurados
]]
function StatAssign:DistributeAuto()
    local availablePoints = self:GetAvailablePoints()
    if availablePoints <= 0 then return 0 end

    local totalAssigned = 0
    local maxPerCycle = math.min(self.Config.MaxPerCycle, availablePoints)

    -- Calcular distribuição baseada em percentuais
    local distribution = {}
    local totalPercent = 0

    for _, statName in ipairs(self.Stats) do
        local percent = self.Config.AutoPercentages[statName] or 0
        totalPercent = totalPercent + percent
    end

    if totalPercent <= 0 then return 0 end

    -- Normalizar percentuais
    local normalizedPoints = {}
    for _, statName in ipairs(self.Stats) do
        local percent = self.Config.AutoPercentages[statName] or 0
        normalizedPoints[statName] = math.floor((percent / totalPercent) * maxPerCycle)
    end

    -- Distribuir pontos
    for _, statName in ipairs(self.Stats) do
        local points = normalizedPoints[statName]
        if points > 0 then
            local success, _ = self:AddPoints(statName, points)
            if success then
                totalAssigned = totalAssigned + points
            end
        end
    end

    return totalAssigned
end

--[[
    Modo OneShot: Coloca todos os pontos em uma stat
]]
function StatAssign:DistributeOneShot()
    local availablePoints = self:GetAvailablePoints()
    if availablePoints <= 0 then return 0 end

    local statName = self.Config.OneShotStat
    local maxPerCycle = math.min(self.Config.MaxPerCycle, availablePoints)

    local success, _ = self:AddPoints(statName, maxPerCycle)
    return success and maxPerCycle or 0
end

--[[
    Modo Balanced: Distribui equilibradamente
]]
function StatAssign:DistributeBalanced()
    local availablePoints = self:GetAvailablePoints()
    if availablePoints <= 0 then return 0 end

    local maxPerCycle = math.min(self.Config.MaxPerCycle, availablePoints)
    local perStat = math.floor(maxPerCycle / #self.Stats)
    local remainder = maxPerCycle - (perStat * #self.Stats)

    local totalAssigned = 0

    for _, statName in ipairs(self.Stats) do
        local points = perStat
        if remainder > 0 then
            points = points + 1
            remainder = remainder - 1
        end

        if points > 0 then
            local success, _ = self:AddPoints(statName, points)
            if success then
                totalAssigned = totalAssigned + points
            end
        end
    end

    return totalAssigned
end

--[[
    Modo Custom: Distribuição personalizada
]]
function StatAssign:DistributeCustom()
    local availablePoints = self:GetAvailablePoints()
    if availablePoints <= 0 then return 0 end

    local totalPercent = 0
    for _, percent in pairs(self.Config.CustomDistribution) do
        totalPercent = totalPercent + percent
    end

    if totalPercent <= 0 then return 0 end

    local maxPerCycle = math.min(self.Config.MaxPerCycle, availablePoints)
    local totalAssigned = 0

    for _, statName in ipairs(self.Stats) do
        local percent = self.Config.CustomDistribution[statName] or 0
        local points = math.floor((percent / totalPercent) * maxPerCycle)

        if points > 0 then
            local success, _ = self:AddPoints(statName, points)
            if success then
                totalAssigned = totalAssigned + points
            end
        end
    end

    return totalAssigned
end

--[[
    Distribuir pontos baseado no modo selecionado
]]
function StatAssign:Distribute()
    local mode = self.Config.Mode

    if mode == "Auto" then
        return self:DistributeAuto()
    elseif mode == "OneShot" then
        return self:DistributeOneShot()
    elseif mode == "Balanced" then
        return self:DistributeBalanced()
    elseif mode == "Custom" then
        return self:DistributeCustom()
    else
        warn("[StatAssign] Modo desconhecido: " .. tostring(mode))
        return 0
    end
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function StatAssign:Start()
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("Misc.AutoStats")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()
    self._totalAssigned = 0

    print("[StatAssign] Iniciado | Modo: " .. self.Config.Mode)

    if EventBus then
        EventBus:Emit("Misc.StatAssign.Started", {Mode = self.Config.Mode})
    end

    -- Loop de distribuição
    self._autoAssignConnection = task.spawn(function()
        while self._running do
            local points = self:GetAvailablePoints()

            if points > 0 then
                local assigned = self:Distribute()
                if assigned > 0 then
                    -- Emitir evento de atualização
                    if EventBus then
                        EventBus:Emit("Misc.StatAssign.PointsAssigned", {
                            Points = assigned,
                            Remaining = points - assigned,
                            Mode = self.Config.Mode,
                        })
                    end
                end
            end

            task.wait(self.Config.AssignInterval)
        end
    end)

    -- Distribuir imediatamente ao iniciar
    task.spawn(function()
        task.wait(1)
        if self._running then
            self:Distribute()
        end
    end)

    return true
end

function StatAssign:Stop()
    if not self._running then return false end

    self._running = false

    if self._autoAssignConnection then
        task.cancel(self._autoAssignConnection)
        self._autoAssignConnection = nil
    end

    print("[StatAssign] Parado | Total distribuído: " .. self._totalAssigned)

    if EventBus then
        EventBus:Emit("Misc.StatAssign.Stopped", {
            TotalAssigned = self._totalAssigned,
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function StatAssign:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- API PÚBLICA
-- ══════════════════════════════════════════════════════════════════

--[[
    Definir prioridade de stats
]]
function StatAssign:SetPriority(priority)
    self.Config.Priority = priority

    -- Atualizar percentuais baseado na prioridade
    local totalStats = #priority
    local basePercent = math.floor(100 / totalStats)
    local remainder = 100 - (basePercent * totalStats)

    for i, statName in ipairs(priority) do
        self.Config.AutoPercentages[statName] = basePercent
        if i == 1 then
            self.Config.AutoPercentages[statName] = basePercent + remainder
        end
    end

    -- Zerar stats não prioritárias
    for _, statName in ipairs(self.Stats) do
        if not table.find(priority, statName) then
            self.Config.AutoPercentages[statName] = 0
        end
    end

    print("[StatAssign] Prioridade atualizada: " .. table.concat(priority, ", "))
end

--[[
    Definir modo de distribuição
]]
function StatAssign:SetMode(mode)
    local validModes = {"Auto", "OneShot", "Balanced", "Custom"}
    for _, validMode in ipairs(validModes) do
        if mode == validMode then
            self.Config.Mode = mode
            print("[StatAssign] Modo alterado para: " .. mode)
            return true
        end
    end

    warn("[StatAssign] Modo inválido: " .. tostring(mode))
    return false
end

--[[
    Atribuir pontos manualmente em uma stat
]]
function StatAssign:ManualAssign(statName, amount)
    if amount <= 0 then return false end

    local availablePoints = self:GetAvailablePoints()
    if amount > availablePoints then
        warn("[StatAssign] Pontos insuficientes: " .. availablePoints .. " disponíveis, " .. amount .. " solicitados")
        return false
    end

    return self:AddPoints(statName, amount)
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function StatAssign:GetStatus()
    local stats = self:GetAllStats()

    return {
        Running = self._running,
        Mode = self.Config.Mode,
        Points = stats.Points,
        Level = stats.Level,
        Stats = stats,
        TotalAssigned = self._totalAssigned,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function StatAssign:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("Misc.StatAssign.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)

        EventBus:On("Misc.StatAssign.SetMode", function(mode)
            self:SetMode(mode)
        end)

        EventBus:On("Misc.StatAssign.SetPriority", function(priority)
            self:SetPriority(priority)
        end)
    end

    print("[StatAssign] Módulo inicializado")
    return true
end

function StatAssign:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("Misc.StatAssign.Toggle")
        EventBus:Clear("Misc.StatAssign.SetMode")
        EventBus:Clear("Misc.StatAssign.SetPriority")
    end
    print("[StatAssign] Módulo limpo")
end

return StatAssign
