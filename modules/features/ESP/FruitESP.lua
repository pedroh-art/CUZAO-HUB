--[[
    CUZAO HUB - Fruit ESP Module
    Exibe informações de frutas no mundo via BillboardGui

    Frutas são encontradas:
    - Spawns no mapa (spawn points)
    - Dropadas por jogadores
    - No chão após reset de fruta

    Exibe:
    - Nome da fruta
    - Distância
    - Raridade
    - Valor estimado
    - Cor baseada na raridade
]]

local FruitESP = {}

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Referências de módulos
local ConfigManager = nil
local EventBus = nil

-- Estado
FruitESP._running = false
FruitESP._connection = nil
FruitESP._espInstances = {}
FruitESP._sessionStart = 0

-- Nomes de frutas do Blox Fruits
FruitESP.FruitDatabase = {
    -- Common
    Rocket = {Value = 5000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Spin = {Value = 7500, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Chop = {Value = 30000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Spring = {Value = 60000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Bomb = {Value = 80000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Smoke = {Value = 100000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},
    Spike = {Value = 180000, Rarity = "Common", Color = Color3.fromRGB(180, 180, 180)},

    -- Uncommon
    Flame = {Value = 250000, Rarity = "Uncommon", Color = Color3.fromRGB(0, 200, 255)},
    Falcon = {Value = 300000, Rarity = "Uncommon", Color = Color3.fromRGB(0, 200, 255)},
    Ice = {Value = 350000, Rarity = "Uncommon", Color = Color3.fromRGB(0, 200, 255)},
    Sand = {Value = 420000, Rarity = "Uncommon", Color = Color3.fromRGB(0, 200, 255)},
    Dark = {Value = 500000, Rarity = "Uncommon", Color = Color3.fromRGB(0, 200, 255)},

    -- Rare
    Ghost = {Value = 940000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},
    Diamond = {Value = 1000000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},
    Light = {Value = 650000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},
    Rubber = {Value = 750000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},
    Barrier = {Value = 800000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},
    Magma = {Value = 850000, Rarity = "Rare", Color = Color3.fromRGB(0, 255, 0)},

    -- Legendary
    Quake = {Value = 1000000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Buddha = {Value = 1200000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Love = {Value = 700000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Spider = {Value = 1500000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Sound = {Value = 1700000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Phoenix = {Value = 1800000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Portal = {Value = 1900000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Rumble = {Value = 2100000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Pain = {Value = 2300000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Blizzard = {Value = 2400000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Gravity = {Value = 2500000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Mammoth = {Value = 2700000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    ["T-Rex"] = {Value = 2800000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Dough = {Value = 2800000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Shadow = {Value = 2900000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Venom = {Value = 3000000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Control = {Value = 3200000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},
    Spirit = {Value = 3400000, Rarity = "Legendary", Color = Color3.fromRGB(255, 170, 0)},

    -- Mythical
    Dragon = {Value = 3500000, Rarity = "Mythical", Color = Color3.fromRGB(255, 0, 255)},
    Leopard = {Value = 5000000, Rarity = "Mythical", Color = Color3.fromRGB(255, 0, 255)},
    Kitsune = {Value = 8000000, Rarity = "Mythical", Color = Color3.fromRGB(255, 0, 255)},
}

-- Configurações
FruitESP.Config = {
    Enabled = false,
    ShowName = true,
    ShowDistance = true,
    ShowPrice = true,
    ShowRarity = true,
    MaxDistance = 10000,
    UpdateInterval = 1,
    HighlightFruits = true,
    FontSize = 14,
}

-- ══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ══════════════════════════════════════════════════════════════════

local function FormatDistance(meters)
    if meters < 1000 then
        return string.format("%.0f M", meters)
    else
        return string.format("%.1f KM", meters / 1000)
    end
end

local function FormatPrice(value)
    if value >= 1000000 then
        return string.format("$%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("$%.1fK", value / 1000)
    end
    return "$" .. tostring(value)
end

--[[
    Obter dados da fruta pelo nome
]]
function FruitESP:GetFruitData(fruitName)
    -- Busca exata
    if self.FruitDatabase[fruitName] then
        return self.FruitDatabase[fruitName]
    end

    -- Busca parcial
    local lowerName = fruitName:lower()
    for name, data in pairs(self.FruitDatabase) do
        if name:lower():find(lowerName) or lowerName:find(name:lower()) then
            return data
        end
    end

    return nil
end

--[[
    Verificar se uma instância é uma fruta
]]
function FruitESP:IsFruitModel(instance)
    if not instance or not instance:IsA("Model") then return false end

    -- Verificar nome
    local name = instance.Name
    if self:GetFruitData(name) then return true end

    -- Verificar se tem Handle e é uma fruit
    local handle = instance:FindFirstChild("Handle")
    if handle then
        for fruitName in pairs(self.FruitDatabase) do
            if name:find(fruitName) then return true end
        end
    end

    -- Verificar atributo
    if instance:FindFirstChild("Fruit") or instance:GetAttribute("Fruit") then
        return true
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════
-- CRIAÇÃO DE ESP
-- ══════════════════════════════════════════════════════════════════

function FruitESP:CreateESPForFruit(fruitModel)
    if self._espInstances[fruitModel] then return end

    local fruitData = self:GetFruitData(fruitModel.Name)
    local espColor = fruitData and fruitData.Color or Color3.fromRGB(255, 255, 0)

    -- Criar BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CUZAO_FruitESP_" .. fruitModel.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(1, 200, 1, 60)
    billboard.ExtentsOffset = Vector3.new(0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    -- Label: Nome da fruta
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = espColor
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = self.Config.FontSize
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Text = fruitModel.Name
    nameLabel.Parent = container

    -- Label: Distância
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distLabel.Position = UDim2.new(0, 0, 0.4, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = self.Config.FontSize - 2
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Text = ""
    distLabel.Parent = container

    -- Label: Preço/Raridade
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, 0, 0.3, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.7, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = espColor
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = self.Config.FontSize - 3
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Text = ""
    infoLabel.Parent = container

    -- Adornar ao Handle se disponível
    local handle = fruitModel:FindFirstChild("Handle")
    if handle then
        billboard.Adornee = handle
    elseif fruitModel.PrimaryPart then
        billboard.Adornee = fruitModel.PrimaryPart
    end

    -- Highlight (brilho visual)
    local highlight = nil
    if self.Config.HighlightFruits then
        highlight = Instance.new("Highlight")
        highlight.Name = "CUZAO_FruitHighlight"
        highlight.FillColor = espColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Adornee = fruitModel
        highlight.Parent = fruitModel
    end

    billboard.Parent = fruitModel

    local espData = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistLabel = distLabel,
        InfoLabel = infoLabel,
        Highlight = highlight,
        Model = fruitModel,
        FruitData = fruitData,
    }

    self._espInstances[fruitModel] = espData
end

function FruitESP:RemoveESPForFruit(fruitModel)
    local espData = self._espInstances[fruitModel]
    if not espData then return end

    if espData.Billboard and espData.Billboard.Parent then
        espData.Billboard:Destroy()
    end

    if espData.Highlight and espData.Highlight.Parent then
        espData.Highlight:Destroy()
    end

    self._espInstances[fruitModel] = nil
end

-- ══════════════════════════════════════════════════════════════════
-- ATUALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function FruitESP:ScanForFruits()
    local fruits = {}

    pcall(function()
        -- Verificar no workspace inteiro
        for _, instance in ipairs(Workspace:GetDescendants()) do
            if self:IsFruitModel(instance) then
                table.insert(fruits, instance)
            end
        end
    end)

    return fruits
end

function FruitESP:UpdateAllFruits()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Escanear frutas
    local foundFruits = self:ScanForFruits()

    -- Criar ESP para frutas novas
    for _, fruit in ipairs(foundFruits) do
        if not self._espInstances[fruit] then
            self:CreateESPForFruit(fruit)
        end
    end

    -- Remover ESP de frutas que não existem mais
    for fruitModel, espData in pairs(self._espInstances) do
        if fruitModel == "_running" or fruitModel == "_sessionStart" then continue end
        if not fruitModel or not fruitModel.Parent then
            self:RemoveESPForFruit(fruitModel)
        end
    end

    -- Atualizar informações
    for fruitModel, espData in pairs(self._espInstances) do
        if fruitModel == "_running" or fruitModel == "_sessionStart" then continue end

        pcall(function()
            -- Determinar posição da fruta
            local fruitPos = nil
            if fruitModel.PrimaryPart then
                fruitPos = fruitModel.PrimaryPart.Position
            elseif fruitModel:FindFirstChild("Handle") then
                fruitPos = fruitModel.Handle.Position
            else
                local part = fruitModel:FindFirstChildOfClass("BasePart")
                if part then fruitPos = part.Position end
            end

            if not fruitPos then
                espData.Billboard.Enabled = false
                return
            end

            -- Calcular distância
            local distance = (myRoot.Position - fruitPos).Magnitude

            if distance > self.Config.MaxDistance then
                espData.Billboard.Enabled = false
                return
            end

            espData.Billboard.Enabled = true

            -- Atualizar distância
            if self.Config.ShowDistance then
                espData.DistLabel.Text = FormatDistance(distance)
                espData.DistLabel.Visible = true
            else
                espData.DistLabel.Visible = false
            end

            -- Atualizar preço/raridade
            local infoParts = {}
            if self.Config.ShowRarity and espData.FruitData then
                table.insert(infoParts, espData.FruitData.Rarity)
            end
            if self.Config.ShowPrice and espData.FruitData then
                table.insert(infoParts, FormatPrice(espData.FruitData.Value))
            end

            if #infoParts > 0 then
                espData.InfoLabel.Text = table.concat(infoParts, " | ")
                espData.InfoLabel.Visible = true
            else
                espData.InfoLabel.Visible = false
            end
        end)
    end
end

-- ══════════════════════════════════════════════════════════════════
-- CONTROLES
-- ══════════════════════════════════════════════════════════════════

function FruitESP:Start()
    if self._running then return false end

    -- Sincronizar config
    if ConfigManager then
        local cfg = ConfigManager:Get("ESP.Fruit")
        if cfg then
            for k, v in pairs(cfg) do
                if self.Config[k] ~= nil then self.Config[k] = v end
            end
        end
    end

    self._running = true
    self._sessionStart = tick()

    print("[FruitESP] Iniciado | Distância máxima: " .. self.Config.MaxDistance .. " M")

    if EventBus then
        EventBus:Emit("ESP.Fruit.Started")
    end

    -- Escaneamento periódico
    self._connection = task.spawn(function()
        while self._running do
            self:UpdateAllFruits()
            task.wait(self.Config.UpdateInterval)
        end
    end)

    return true
end

function FruitESP:Stop()
    if not self._running then return false end

    self._running = false

    if self._connection then
        task.cancel(self._connection)
        self._connection = nil
    end

    -- Remover todos os ESPs
    for fruitModel, _ in pairs(self._espInstances) do
        if fruitModel ~= "_running" and fruitModel ~= "_sessionStart" then
            self:RemoveESPForFruit(fruitModel)
        end
    end
    self._espInstances = {}

    print("[FruitESP] Desativado")

    if EventBus then
        EventBus:Emit("ESP.Fruit.Stopped")
    end

    return true
end

function FruitESP:IsRunning()
    return self._running
end

-- ══════════════════════════════════════════════════════════════════
-- STATUS
-- ══════════════════════════════════════════════════════════════════

function FruitESP:GetStatus()
    local count = 0
    for k, _ in pairs(self._espInstances) do
        if k ~= "_running" and k ~= "_sessionStart" then count = count + 1 end
    end
    return {
        Running = self._running,
        ActiveFruits = count,
        MaxDistance = self.Config.MaxDistance,
        SessionTime = tick() - self._sessionStart,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ══════════════════════════════════════════════════════════════════

function FruitESP:Initialize(deps)
    deps = deps or {}
    ConfigManager = deps.ConfigManager
    EventBus = deps.EventBus

    if EventBus then
        EventBus:On("ESP.Fruit.Toggle", function(enabled)
            if enabled then
                self:Start()
            else
                self:Stop()
            end
        end)
    end

    print("[FruitESP] Módulo inicializado")
    return true
end

function FruitESP:Cleanup()
    self:Stop()
    if EventBus then
        EventBus:Clear("ESP.Fruit.Toggle")
    end
    print("[FruitESP] Módulo limpo")
end

return FruitESP
