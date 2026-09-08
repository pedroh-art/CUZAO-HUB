--[[
    CUZAO HUB - Player ESP Module
    Exibe informações de jogadores sobre seus personagens via BillboardGui

    Elementos exibidos:
    - Nome do jogador
    - Distância
    - Vida (HP bar)
    - Fruta equipada
    - Arma equipada
    - Cor por time/inimigo

    Usa BillboardGui + TextLabel para compatibilidade máxima
    (não depende de Drawing API que pode não existir em todos executors)
]]

local PlayerESP = {}

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
PlayerESP._running = false
PlayerESP._connection = nil
PlayerESP._espInstances = {}    -- [player] = {billboard, labels, connections}
PlayerESP._sessionStart = 0

-- Configurações
PlayerESP.Config = {
    Enabled = false,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowFruit = true,
    ShowWeapon = true,
    ShowTeam = true,
    MaxDistance = 5000,
    Color = Color3.fromRGB(255, 0, 0),         -- Vermelho (inimigos)
    TeamColor = Color3.fromRGB(0, 255, 0),      -- Verde (aliados)
    HighlightEnabled = false,
    FontSize = 14,
    UpdateInterval = 0.5,                        -- Segundos entre atualizações
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

--[[
    Formatar distância para exibição
]]
local function FormatDistance(meters)
    if meters < 1000 then
        return string.format("%.0f M", meters)
    else
        return string.format("%.1f KM", meters / 1000)
    end
end

--[[
    Formatar barra de vida
]]
local function FormatHealthBar(health, maxHealth)
    if maxHealth <= 0 then return "[DEAD]" end
    local percent = math.clamp(health / maxHealth * 100, 0, 100)
    local bars = math.floor(percent / 10)
    local empty = 10 - bars
    return string.format("[%s%s] %d%%", string.rep("█", bars), string.rep("░", empty), math.floor(percent))
end

--[[
    Formatar vida como texto
]]
local function FormatHealth(health, maxHealth)
    if maxHealth <= 0 then return "0/0" end
    return string.format("%d/%d", math.floor(health), math.floor(maxHealth))
end

--[[
    Obter cor baseada no time
]]
local function GetTeamColor(player)
    if player.Team and player.Team == LocalPlayer.Team then
        return PlayerESP.Config.TeamColor
    end
    return PlayerESP.Config.Color
end

--[[
    Obter fruta equipada do jogador (de forma segura)
]]
local function GetEquippedFruit(player)
    local success, fruitName = pcall(function()
        local char = player.Character
        if char then
            -- Verificar Tool com atributo Fruit
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Fruit") then
                    return tool.Name
                end
            end
            -- Verificar Backpack
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Fruit") then
                        return tool.Name
                    end
                end
            end
        end
        return nil
    end)
    return success and fruitName or nil
end

--[[
    Obter arma equipada
]]
local function GetEquippedWeapon(player)
    local success, weaponName = pcall(function()
        local char = player.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and not tool:FindFirstChild("Fruit") then
                    return tool.Name
                end
            end
        end
        return nil
    end)
    return success and weaponName or nil
end

-- ══════════════════════════════════════════════════════════════════
-- CRIAÇÃO DE ESP
-- ══════════════════════════════════════════════════════════════════

--[[
    Criar BillboardGui de ESP para um jogador
]]
local function CreateESPForPlayer(player)
    local espData = PlayerESP._espInstances[player]
    if espData then return espData end

    -- Criar BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CUZAO_ESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = PlayerESP.Config.MaxDistance
    billboard.Size = UDim2.new(1, 200, 1, 60)
    billboard.ExtentsOffset = Vector3.new(0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.LightInfluence = 0

    -- Container
    local container = Instance.new("Frame")
    container.Name = "ESPContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    -- Label: Nome + Distância
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = PlayerESP.Config.FontSize
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Text = player.Name
    nameLabel.Parent = container

    -- Label: Vida
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.35, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = PlayerESP.Config.FontSize - 2
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.Text = ""
    healthLabel.Parent = container

    -- Label: Info (Fruta/Arma)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, 0, 0.25, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.6, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = PlayerESP.Config.FontSize - 3
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Text = ""
    infoLabel.Parent = container

    -- Barra de vida (Frame)
    local healthBarBG = Instance.new("Frame")
    healthBarBG.Name = "HealthBarBG"
    healthBarBG.Size = UDim2.new(0.8, 0, 0, 4)
    healthBarBG.Position = UDim2.new(0.1, 0, 0.92, 0)
    healthBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBG.BorderSizePixel = 1
    healthBarBG.BorderColor3 = Color3.fromRGB(100, 100, 100)
    healthBarBG.Parent = container

    local healthBarFill = Instance.new("Frame")
    healthBarFill.Name = "HealthBarFill"
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBarFill.BorderSizePixel = 0
    healthBarFill.Parent = healthBarBG

    espData = {
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthLabel = healthLabel,
        InfoLabel = infoLabel,
        HealthBarBG = healthBarBG,
        HealthBarFill = healthBarFill,
        Container = container,
        Player = player,
        Connections = {},
    }

    PlayerESP._espInstances[player] = espData
    return espData
end

--[[
    Remover ESP de um jogador
]]
local function RemoveESPForPlayer(player)
    local espData = PlayerESP._espInstances[player]
    if not espData then return end

    -- Desconectar eventos
    for _, conn in ipairs(espData.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end

    -- Destruir instâncias
    if espData.Billboard and espData.Billboard.Parent then
        espData.Billboard:Destroy()
    end

    PlayerESP._espInstances[player] = nil
end

-- ══════════════════════════════════════════════════════════════════
-- ATUALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

--[[
    Atualizar ESP de um jogador específico
]]
local function UpdateESPForPlayer(player)
    local espData = PlayerESP._espInstances[player]
    if not espData then return end

    pcall(function()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")

        if not character or not rootPart or not humanoid then
            espData.Billboard.Enabled = false
            return
        end

        -- Verificar distância
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            espData.Billboard.Enabled = false
            return
        end

        local distance = (myRoot.Position - rootPart.Position).Magnitude

        -- Verificar se está muito longe
        if distance > PlayerESP.Config.MaxDistance then
            espData.Billboard.Enabled = false
            return
        end

        -- Atualizar posição
        espData.Billboard.Adornee = rootPart
        espData.Billboard.Enabled = true

        -- Cor baseada no time
        local teamColor = GetTeamColor(player)

        -- Atualizar nome
        if PlayerESP.Config.ShowName then
            local distanceText = ""
            if PlayerESP.Config.ShowDistance then
                distanceText = " | " .. FormatDistance(distance)
            end
            espData.NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")" .. distanceText
            espData.NameLabel.TextColor3 = teamColor
            espData.NameLabel.Visible = true
        else
            espData.NameLabel.Visible = false
        end

        -- Atualizar vida
        if PlayerESP.Config.ShowHealth and humanoid then
            local hp = humanoid.Health
            local maxHp = humanoid.MaxHealth

            espData.HealthLabel.Text = FormatHealth(hp, maxHp)
            espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

            -- Cor da barra de vida
            local healthPercent = maxHp > 0 and hp / maxHp or 0
            if healthPercent > 0.6 then
                espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end

            espData.HealthBarFill.Size = UDim2.new(math.clamp(healthPercent, 0, 1), 0, 1, 0)
            espData.HealthLabel.Visible = true
            espData.HealthBarBG.Visible = true
        else
            espData.HealthLabel.Visible = false
            espData.HealthBarBG.Visible = false
        end

        -- Atualizar info (fruta/arma)
        local infoParts = {}
        if PlayerESP.Config.ShowFruit then
            local fruit = GetEquippedFruit(player)
            if fruit then
                table.insert(infoParts, "[FRUIT] " .. fruit)
            end
        end
        if PlayerESP.Config.ShowWeapon then
            local weapon = GetEquippedWeapon(player)
            if weapon then
                table.insert(infoParts, "[WP] " .. weapon)
            end
        end

        if #infoParts > 0 then
            espData.InfoLabel.Text = table.concat(infoParts, " | ")
            espData.InfoLabel.Visible = true
        else
            espData.InfoLabel.Visible = false
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function PlayerESP:Start()
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("ESP.Player")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()

    print("[PlayerESP] Iniciado | Distância máxima: " .. self.Config.MaxDistance .. " M")

    if EventBus then
        EventBus:Emit("ESP.Player.Started")
    end

    -- Criar ESP para jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPForPlayer(player)
        end
    end

    -- Conectar eventos de jogadores entrando/saindo
    local joinConn = Players.PlayerAdded:Connect(function(player)
        if self._running and player ~= LocalPlayer then
            task.wait(1) -- Esperar personagem carregar
            CreateESPForPlayer(player)
        end
    end)

    local leaveConn = Players.PlayerRemoving:Connect(function(player)
        RemoveESPForPlayer(player)
    end)

    table.insert(self._espInstances._connections or {}, joinConn)
    table.insert(self._espInstances._connections or {}, leaveConn)

    -- Loop de atualização
    self._connection = task.spawn(function()
        while self._running do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    -- Criar ESP se não existe
                    if not self._espInstances[player] then
                        CreateESPForPlayer(player)
                    end
                    -- Atualizar
                    UpdateESPForPlayer(player)
                end
            end
            task.wait(self.Config.UpdateInterval)
        end
    end)

    return true
end

function PlayerESP:Stop()
    if not self._running then return false end

    self._running = false

    if self._connection then
        task.cancel(self._connection)
        self._connection = nil
    end

    -- Remover todos os ESPs
    for player, _ in pairs(self._espInstances) do
        if player ~= "_connections" then
            RemoveESPForPlayer(player)
        end
    end
    self._espInstances = {}

    print("[PlayerESP] Desativado")

    if EventBus then
        EventBus:Emit("ESP.Player.Stopped")
    end

    return true
end

function PlayerESP:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function PlayerESP:GetStatus()
    local count = 0
    for k, _ in pairs(self._espInstances) do
        if k ~= "_connections" then count = count + 1 end
    end
    return {
        Running = self._running,
        ActiveESPs = count,
        MaxDistance = self.Config.MaxDistance,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function PlayerESP:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("ESP.Player.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)
    end

    print("[PlayerESP] Módulo inicializado")
    return true
end

function PlayerESP:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("ESP.Player.Toggle")
    end
    print("[PlayerESP] Módulo limpo")
end

return PlayerESP
