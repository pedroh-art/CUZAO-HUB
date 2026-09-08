--[[
    CUZAO HUB - Server Hop Module
    Sistema de troca de servidor, rejoin e job ID teleport

    Funcionalidades:
    - Server Hop: Buscar e conectar a servidor com menos/mais jogadores
    - Rejoin: Reconectar ao mesmo servidor
    - Job ID Teleport: Conectar a servidor específico pelo JobId
    - Auto Hop: Trocar de servidor automaticamente em intervalos
]]

local ServerHop = {}

-- Serviços
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
ServerHop._running = false
ServerHop._autoHopConnection = nil
ServerHop._sessionStart = 0
ServerHop._hopCount = 0
ServerHop._lastHopTime = 0

-- Configurações
ServerHop.Config = {
    Enabled = false,
    Mode = "LowPlayers",        -- LowPlayers, HighPlayers, Random, Specific
    MinPlayers = 1,
    MaxPlayers = 12,
    SpecificJobId = "",
    AutoHop = false,
    AutoHopInterval = 300,      -- Segundos entre hops automáticos (5 min)
    MaxHops = 0,                -- 0 = ilimitado
    RejoinOnKick = true,
    RejoinOnCrash = true,
    ExcludeFull = true,
    DelayBetweenHops = 5,       -- Delay entre tentativas de hop
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES DE API ROBLOX
-- ══════════════════════════════════════════════════════════════════

--[[
    Buscar lista de servidores para o jogo atual
]]
function ServerHop:FetchServers(cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
        PlaceId,
        cursor and ("&cursor=" .. cursor) or ""
    )

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success and result then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(result)
        end)

        if decodeSuccess and decoded then
            return decoded
        end
    end

    return nil
end

--[[
    Buscar todos os servidores (com paginação)
]]
function ServerHop:FetchAllServers(maxPages)
    maxPages = maxPages or 5
    local allServers = {}
    local cursor = nil

    for i = 1, maxPages do
        local data = self:FetchServers(cursor)
        if not data or not data.data then break end

        for _, server in ipairs(data.data) do
            table.insert(allServers, server)
        end

        cursor = data.nextPageCursor
        if not cursor then break end

        task.wait(0.5) -- Rate limit
    end

    return allServers
end

-- ══════════════════════════════════════════════════════════════════
-- FILTROS DE SERVIDOR
-- ══════════════════════════════════════════════════════════════════

--[[
    Filtrar servidores com base no modo
]]
function ServerHop:FilterServers(servers)
    local currentJobId = game.JobId
    local filtered = {}

    for _, server in ipairs(servers) do
        -- Ignorar servidor atual
        if server.id == currentJobId then continue end

        -- Ignorar servidores lotados
        if self.Config.ExcludeFull and server.playing and server.maxPlayers then
            if server.playing >= server.maxPlayers then continue end
        end

        -- Ignorar servidores vazios
        if not server.playing or server.playing == 0 then continue end

        -- Filtro por modo
        if self.Config.Mode == "LowPlayers" then
            if server.playing <= self.Config.MaxPlayers then
                table.insert(filtered, server)
            end
        elseif self.Config.Mode == "HighPlayers" then
            if server.playing >= self.Config.MinPlayers then
                table.insert(filtered, server)
            end
        elseif self.Config.Mode == "Random" then
            table.insert(filtered, server)
        end
    end

    return filtered
end

--[[
    Selecionar melhor servidor da lista filtrada
]]
function ServerHop:SelectBestServer(servers)
    if #servers == 0 then return nil end

    if self.Config.Mode == "LowPlayers" then
        -- Ordenar por menos jogadores
        table.sort(servers, function(a, b)
            return (a.playing or 0) < (b.playing or 0)
        end)
        return servers[1]
    elseif self.Config.Mode == "HighPlayers" then
        -- Ordenar por mais jogadores
        table.sort(servers, function(a, b)
            return (a.playing or 0) > (b.playing or 0)
        end)
        return servers[1]
    elseif self.Config.Mode == "Random" then
        return servers[math.random(1, #servers)]
    end

    return servers[1]
end

-- ══════════════════════════════════════════════════════════════════
-- AÇÕES
-- ══════════════════════════════════════════════════════════════════

--[[
    Server Hop: Trocar para outro servidor
]]
function ServerHop:Hop()
    print("[ServerHop] Buscando servidores...")

    -- Verificar limite de hops
    if self.Config.MaxHops > 0 and self._hopCount >= self.Config.MaxHops then
        warn("[ServerHop] Limite de hops atingido: " .. self._hopCount)
        return false
    end

    -- Buscar servidores
    local servers = self:FetchAllServers(3)
    if #servers == 0 then
        warn("[ServerHop] Nenhum servidor encontrado")
        return false
    end

    -- Filtrar
    local filtered = self:FilterServers(servers)
    if #filtered == 0 then
        warn("[ServerHop] Nenhum servidor passou no filtro")
        return false
    end

    -- Selecionar melhor
    local bestServer = self:SelectBestServer(filtered)
    if not bestServer or not bestServer.id then
        warn("[ServerHop] Falha ao selecionar servidor")
        return false
    end

    print("[ServerHop] Conectando ao servidor: " .. bestServer.id ..
          " (" .. (bestServer.playing or 0) .. "/" .. (bestServer.maxPlayers or 0) .. " jogadores)")

    -- Teleportar
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, LocalPlayer)
    end)

    if success then
        self._hopCount = self._hopCount + 1
        self._lastHopTime = tick()
        print("[ServerHop] Hop #" .. self._hopCount .. " iniciado")

        if EventBus then
            EventBus:Emit("Misc.ServerHop.Hopped", {
                ServerId = bestServer.id,
                Players = bestServer.playing,
                HopCount = self._hopCount,
            })
        end

        return true
    else
        warn("[ServerHop] Erro ao teleportar: " .. tostring(err))
        return false
    end
end

--[[
    Rejoin: Reconectar ao mesmo servidor
]]
function ServerHop:Rejoin()
    print("[ServerHop] Reconectando ao servidor atual...")

    local success, err = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)

    if success then
        print("[ServerHop] Rejoin iniciado")
        if EventBus then
            EventBus:Emit("Misc.ServerHop.Rejoined")
        end
        return true
    else
        warn("[ServerHop] Erro no rejoin: " .. tostring(err))
        return false
    end
end

--[[
    Job ID Teleport: Conectar a servidor específico
]]
function ServerHop:TeleportToJobId(jobId)
    if not jobId or jobId == "" then
        warn("[ServerHop] JobId inválido")
        return false
    end

    -- Verificar se é o servidor atual
    if jobId == game.JobId then
        warn("[ServerHop] Já está neste servidor")
        return false
    end

    print("[ServerHop] Conectando ao JobId: " .. jobId)

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
    end)

    if success then
        self._hopCount = self._hopCount + 1
        self._lastHopTime = tick()
        print("[ServerHop] Teleporte para JobId iniciado")

        if EventBus then
            EventBus:Emit("Misc.ServerHop.Teleported", {JobId = jobId})
        end

        return true
    else
        warn("[ServerHop] Erro ao teleportar para JobId: " .. tostring(err))
        return false
    end
end

--[[
    Copiar JobId do servidor atual para o clipboard
]]
function ServerHop:CopyJobId()
    local jobId = game.JobId
    if setclipboard then
        setclipboard(jobId)
        print("[ServerHop] JobId copiado: " .. jobId)
        return jobId
    end
    warn("[ServerHop] Clipboard não disponível")
    return nil
end

-- ══════════════════════════════════════════════════════════════════
-- AUTO HOP
-- ══════════════════════════════════════════════════════════════════

function ServerHop:StartAutoHop()
    if self._autoHopConnection then return end

    self.Config.AutoHop = true
    local interval = self.Config.AutoHopInterval

    print("[ServerHop] Auto Hop ativado | Intervalo: " .. interval .. "s")

    self._autoHopConnection = task.spawn(function()
        while self.Config.AutoHop do
            task.wait(interval)

            if not self.Config.AutoHop then break end

            -- Verificar limite
            if self.Config.MaxHops > 0 and self._hopCount >= self.Config.MaxHops then
                print("[ServerHop] Limite de auto hops atingido")
                break
            end

            self:Hop()
        end
    end)
end

function ServerHop:StopAutoHop()
    self.Config.AutoHop = false

    if self._autoHopConnection then
        task.cancel(self._autoHopConnection)
        self._autoHopConnection = nil
    end

    print("[ServerHop] Auto Hop desativado")
end

-- ══════════════════════════════════════════════════════════════════
-- AUTO REJOIN ON KICK/CRASH
-- ══════════════════════════════════════════════════════════════════

function ServerHop:EnableAutoRejoin()
    -- Detectar desconexão
    LocalPlayer.CharacterRemoving:Connect(function()
        if not self.Config.RejoinOnKick then return end

        task.wait(5) -- Esperar um pouco

        -- Verificar se ainda está no jogo
        if not LocalPlayer.Parent then
            print("[ServerHop] Desconectado, tentando rejoin...")
            self:Rejoin()
        end
    end)

    -- Detectar erro de conexão
    game:GetService("RunService").Heartbeat:Connect(function()
        -- Esta é uma verificação leve, não precisa ser chamada frequentemente
    end)

    print("[ServerHop] Auto Rejoin habilitado")
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function ServerHop:Start()
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("Misc.ServerHop")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()

    -- Auto Hop
    if self.Config.AutoHop then
        self:StartAutoHop()
    end

    -- Auto Rejoin
    if self.Config.RejoinOnKick then
        self:EnableAutoRejoin()
    end

    print("[ServerHop] Módulo ativado | Modo: " .. self.Config.Mode)

    if EventBus then
        EventBus:Emit("Misc.ServerHop.Started", {Mode = self.Config.Mode})
    end

    return true
end

function ServerHop:Stop()
    if not self._running then return false end

    self._running = false
    self:StopAutoHop()

    print("[ServerHop] Módulo desativado | Hops realizados: " .. self._hopCount)

    if EventBus then
        EventBus:Emit("Misc.ServerHop.Stopped", {
            TotalHops = self._hopCount,
            SessionTime = tick() - self._sessionStart,
        })
    end

    return true
end

function ServerHop:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function ServerHop:GetStatus()
    return {
        Running = self._running,
        Mode = self.Config.Mode,
        AutoHop = self.Config.AutoHop,
        HopCount = self._hopCount,
        CurrentJobId = game.JobId,
        CurrentPlayers = #Players:GetPlayers(),
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function ServerHop:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("Misc.ServerHop.Hop", function()
            self:Hop()
        end)

        EventBus:On("Misc.ServerHop.Rejoin", function()
            self:Rejoin()
        end)

        EventBus:On("Misc.ServerHop.ToggleAutoHop", function(enabled)
            if enabled then
                self:StartAutoHop()
            else
                self:StopAutoHop()
            end
        end)
    end

    print("[ServerHop] Módulo inicializado")
    return true
end

function ServerHop:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("Misc.ServerHop.Hop")
        EventBus:Clear("Misc.ServerHop.Rejoin")
        EventBus:Clear("Misc.ServerHop.ToggleAutoHop")
    end
    print("[ServerHop] Módulo limpo")
end

return ServerHop
