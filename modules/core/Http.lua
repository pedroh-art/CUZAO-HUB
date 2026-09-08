--[[
    CUZAO HUB - HTTP Module
    Sistema HTTP robusto para webhooks, APIs e atualizações
]]

local Http = {}
Http.RequestQueue = {}
Http.Processing = false

-- Serviços
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configurações
Http.DefaultTimeout = 10
Http.MaxRetries = 3
Http.RetryDelay = 1
Http.UserAgent = "CUZAO-HUB/1.0.0 (Roblox; Blox Fruits)"

-- ========== FUNÇÕES AUXILIARES ==========

local function buildHeaders(customHeaders)
    local headers = {
        ["User-Agent"] = Http.UserAgent,
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
    }

    if customHeaders then
        for k, v in pairs(customHeaders) do
            headers[k] = v
        end
    end

    return headers
end

local function requestWithRetry(options)
    local retries = 0
    local lastError = nil

    while retries <= Http.MaxRetries do
        local success, result = pcall(function()
            return request(options)
        end)

        if success and result.Success then
            return true, result
        end

        lastError = result and result.StatusMessage or "Unknown error"
        retries = retries + 1

        if retries <= Http.MaxRetries then
            task.wait(Http.RetryDelay * retries) -- Backoff exponencial
        end
    end

    return false, lastError
end

-- ========== MÉTODOS HTTP ==========

function Http:Get(url, headers, timeout)
    local options = {
        Url = url,
        Method = "GET",
        Headers = buildHeaders(headers),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Post(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "POST",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Put(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "PUT",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Delete(url, headers, timeout)
    local options = {
        Url = url,
        Method = "DELETE",
        Headers = buildHeaders(headers),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

function Http:Patch(url, data, headers, timeout)
    local options = {
        Url = url,
        Method = "PATCH",
        Headers = buildHeaders(headers),
        Body = HttpService:JSONEncode(data),
        Timeout = timeout or Http.DefaultTimeout,
    }

    return requestWithRetry(options)
end

-- ========== WEBHOOKS DISCORD ==========

Http.WebhookCache = {}

function Http:SendWebhook(url, data)
    -- Rate limiting simples por webhook
    local now = tick()
    local cache = self.WebhookCache[url] or {lastSent = 0, count = 0}

    if now - cache.lastSent < 1 then -- Mínimo 1 segundo entre webhooks
        cache.count = cache.count + 1
        if cache.count > 5 then
            warn("[Http] Rate limit atingido para webhook")
            return false, "Rate limited"
        end
    else
        cache.count = 1
    end

    cache.lastSent = now
    self.WebhookCache[url] = cache

    -- Formatar para Discord
    local payload = {
        embeds = data.embeds or {},
        content = data.content or "",
        username = data.username or "CUZAO HUB",
        avatar_url = data.avatar_url or "https://i.imgur.com/CUZAO.png",
    }

    -- Adicionar timestamp se não tiver
    if payload.embeds then
        for _, embed in ipairs(payload.embeds) do
            if not embed.timestamp then
                embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            end
            if not embed.color then
                embed.color = 0xFF0000 -- Vermelho CUZAO
            end
            if not embed.footer then
                embed.footer = {
                    text = "CUZAO HUB | Blox Fruits",
                    icon_url = "https://i.imgur.com/CUZAO.png"
                }
            end
        end
    end

    return self:Post(url, payload)
end

function Http:CreateEmbed(title, description, color, fields, thumbnail, image)
    local embed = {
        title = title,
        description = description,
        color = color or 0xFF0000,
        fields = fields or {},
        thumbnail = thumbnail and {url = thumbnail} or nil,
        image = image and {url = image} or nil,
    }
    return embed
end

function Http:CreateField(name, value, inline)
    return {name = name, value = value, inline = inline or false}
end

-- Webhook específico para Fruit Sniper
function Http:SendFruitWebhook(webhookUrl, fruitData, playerData)
    local embed = self:CreateEmbed(
        "🍎 Fruta Encontrada!",
        string.format("**%s** spawnou no servidor!", fruitData.Name),
        fruitData.RarityColor or 0xFFD700,
        {
            self:CreateField("📍 Localização", fruitData.Location or "Desconhecido", true),
            self:CreateField("💰 Preço", self:FormatNumber(fruitData.Price or 0) .. " Beli", true),
            self:CreateField("⭐ Raridade", fruitData.Rarity or "Desconhecido", true),
            self:CreateField("👤 Jogador", playerData.Name or "Desconhecido", true),
            self:CreateField("🆔 User ID", tostring(playerData.UserId or "N/A"), true),
            self:CreateField("🌐 Servidor", "JobId: " .. (game.JobId or "N/A"), false),
        },
        fruitData.Thumbnail,
        fruitData.Image
    )

    return self:SendWebhook(webhookUrl, {
        content = playerData.Ping or "@everyone",
        embeds = {embed}
    })
end

-- Webhook para logs de farm
function Http:SendFarmLog(webhookUrl, farmData)
    local embed = self:CreateEmbed(
        "📊 Log de Farm",
        farmData.Message or "Atividade de farm registrada",
        0x00FF00,
        {
            self:CreateField("🎯 Tipo", farmData.Type or "Auto Farm", true),
            self:CreateField("📈 XP Ganho", self:FormatNumber(farmData.XP or 0), true),
            self:CreateField("💰 Beli Ganho", self:FormatNumber(farmData.Beli or 0), true),
            self:CreateField("⏱️ Tempo", self:FormatTime(farmData.Duration or 0), true),
            self:CreateField("👤 Jogador", farmData.Player or "Desconhecido", true),
            self:CreateField("🌐 Servidor", "JobId: " .. (game.JobId or "N/A"), false),
        }
    )

    return self:SendWebhook(webhookUrl, {embeds = {embed}})
end

-- ========== GITHUB API ==========

function Http:GetLatestRelease(repo)
    local url = "https://api.github.com/repos/" .. repo .. "/releases/latest"
    local success, result = self:Get(url, {["Accept"] = "application/vnd.github.v3+json"})

    if success then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(result.Body)
        end)
        if decodeSuccess then
            return true, data
        end
    end

    return false, result
end

function Http:GetFileContent(repo, path, branch)
    branch = branch or "main"
    local url = "https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/" .. path
    return self:Get(url, {}, 15)
end

function Http:CheckForUpdates(currentVersion, repo)
    local success, release = self:GetLatestRelease(repo)
    if not success then return false, release end

    local latestVersion = release.tag_name:gsub("^v", "")
    currentVersion = currentVersion:gsub("^v", "")

    local function versionToNumber(ver)
        local parts = {}
        for part in ver:gmatch("%d+") do
            table.insert(parts, tonumber(part))
        end
        return parts[1] * 10000 + (parts[2] or 0) * 100 + (parts[3] or 0)
    end

    local hasUpdate = versionToNumber(latestVersion) > versionToNumber(currentVersion)
    return true, {
        hasUpdate = hasUpdate,
        currentVersion = currentVersion,
        latestVersion = latestVersion,
        releaseNotes = release.body,
        downloadUrl = release.html_url,
        publishedAt = release.published_at,
    }
end

-- ========== UTILITÁRIOS ==========

function Http:FormatNumber(num)
    if num >= 1e9 then return string.format("%.1fB", num / 1e9) end
    if num >= 1e6 then return string.format("%.1fM", num / 1e6) end
    if num >= 1e3 then return string.format("%.1fK", num / 1e3) end
    return tostring(num)
end

function Http:FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

-- ========== QUEUE SYSTEM (para evitar rate limits) ==========

function Http:QueueRequest(options, callback)
    table.insert(self.RequestQueue, {options = options, callback = callback})
    self:ProcessQueue()
end

function Http:ProcessQueue()
    if self.Processing or #self.RequestQueue == 0 then return end

    self.Processing = true

    task.spawn(function()
        while #self.RequestQueue > 0 do
            local req = table.remove(self.RequestQueue, 1)
            local success, result = requestWithRetry(req.options)
            if req.callback then
                task.spawn(req.callback, success, result)
            end
            task.wait(0.1) -- Pequeno delay entre requests
        end
        self.Processing = false
    end)
end

return Http