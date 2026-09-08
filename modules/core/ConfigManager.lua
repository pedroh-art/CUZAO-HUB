--[[
    CUZAO HUB - Config Manager Module
    Gerenciamento de configurações (Save/Load JSON, Presets, Merge)
]]

local ConfigManager = {}
ConfigManager.FileName = "CUZAO_HUB_Config.json"
ConfigManager.FolderName = "CUZAO_HUB"
ConfigManager.CurrentConfig = {}
ConfigManager.DefaultConfig = {}

-- Serviços
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========== CONFIGURAÇÃO PADRÃO ==========

ConfigManager.DefaultConfig = {
    Version = "1.0.0",
    UI = {
        Theme = "Dark",           -- Dark, Light, RGB, CUZAO
        Keybind = "RightControl", -- Tecla para abrir/fechar UI
        Transparency = 0.15,      -- Transparência da UI (0-1)
        Scale = 1.0,              -- Escala da UI
        Language = "PT-BR",       -- PT-BR, EN, ES
        Notifications = true,     -- Mostrar notificações toast
        SoundEnabled = true,      -- Sons da UI
        AnimationSpeed = 1.0,     -- Velocidade das animações
    },
    AutoFarm = {
        Enabled = false,
        SelectedFarm = "Level",   -- Level, Bone, Katakuri, Factory
        Weapon = "Melee",         -- Melee, Sword, Gun, Fruit
        FarmMethod = "Below",     -- Below, Behind, Above, Tween
        Distance = 15,
        TweenSpeed = 350,
        AutoHaki = true,
        AutoKen = false,
        BringMobs = true,
        AttackDelay = 0.1,
        UseSkills = true,
        SkillZ = true,
        SkillX = true,
        SkillC = true,
        SkillV = false,
        SkillF = false,
        AutoStats = false,
        StatPriority = "Melee",   -- Melee, Defense, Sword, Gun, Fruit
    },
    Raid = {
        Enabled = false,
        SelectedRaid = "Flame",   -- Flame, Ice, Quake, Light, Dark, String, Rumbling, Magma, Phoenix, Dough
        AutoStart = true,
        AutoNextIsland = true,
        AutoBuyChip = false,
        ChipAmount = 1,
        KillAura = true,
        TweenSpeed = 400,
    },
    Fruit = {
        Enabled = false,
        SniperEnabled = false,
        WebhookURL = "",
        WebhookPing = "@everyone",
        StoreFruits = true,
        MasteryFarm = false,
        SelectedFruit = "All",
        AutoAwaken = false,
        FragmentThreshold = 5000,
        NotifyOnFind = true,
        SoundOnFind = true,
    },
    Teleport = {
        Enabled = false,
        TweenSpeed = 350,
        SafeMode = true,          -- Verificar se área é segura antes de TP
        Islands = {},
        NPCs = {},
        Players = {},
        CustomWaypoints = {},
    },
    ESP = {
        Enabled = false,
        Player = {
            Enabled = false,
            Box = true,
            Name = true,
            Health = true,
            Distance = true,
            Team = true,
            Weapon = true,
            Fruit = true,
            MaxDistance = 5000,
            Color = Color3.fromRGB(255, 0, 0),
            TeamColor = Color3.fromRGB(0, 255, 0),
        },
        Fruit = {
            Enabled = false,
            ShowName = true,
            ShowPrice = true,
            ShowRarity = true,
            MaxDistance = 10000,
            Color = Color3.fromRGB(255, 255, 0),
        },
        Chest = {
            Enabled = false,
            ShowName = true,
            MaxDistance = 5000,
            Color = Color3.fromRGB(139, 69, 19),
        },
        Mob = {
            Enabled = false,
            ShowName = true,
            ShowHealth = true,
            ShowLevel = true,
            MaxDistance = 3000,
            Color = Color3.fromRGB(255, 100, 100),
        },
        Flower = {
            Enabled = false,
            MaxDistance = 5000,
            Color = Color3.fromRGB(255, 0, 255),
        },
    },
    Combat = {
        Enabled = false,
        AutoClicker = {
            Enabled = false,
            ClickDelay = 0.05,
            RightClick = false,
        },
        AimBot = {
            Enabled = false,
            Mode = "Silent",      -- Silent, Legit, FOV
            FOV = 100,
            Smoothness = 0.5,
            TargetPart = "Head",  -- Head, HumanoidRootPart, Torso
            TeamCheck = true,
            WallCheck = true,
            Prediction = 0.1,
        },
        KillAura = {
            Enabled = false,
            Range = 30,
            TargetPlayers = false,
            TargetMobs = true,
            AttackDelay = 0.1,
        },
        SkillSpam = {
            Enabled = false,
            Skills = {Z = true, X = true, C = true, V = false, F = false},
            Delay = 0.5,
        },
        AutoHaki = true,
        AutoKen = false,
        KenDuration = 5,
    },
    Misc = {
        Enabled = false,
        ServerHop = {
            Enabled = false,
            Mode = "LowPlayers",  -- LowPlayers, HighPlayers, Specific
            MinPlayers = 1,
            MaxPlayers = 12,
            SpecificServer = "",
            Delay = 10,
        },
        Rejoin = {
            Enabled = false,
            OnKick = true,
            OnCrash = true,
            OnLowFPS = false,
            FPSThreshold = 15,
        },
        AntiAFK = true,
        AutoStats = {
            Enabled = false,
            Priority = {"Melee", "Defense", "Sword", "Gun", "Fruit"},
        },
        FPSCap = 60,
        NoClip = false,
        Fly = {
            Enabled = false,
            Speed = 50,
            Keybind = "F",
        },
    },
    SeaEvents = {
        Enabled = false,
        ShipRaid = false,
        SeaBeast = false,
        KitsuneEvent = false,
        SharkAnchor = false,
        AutoCollect = true,
    },
    KeySystem = {
        Enabled = false,
        Key = "",
        Premium = false,
        Discord = "https://discord.gg/cuzahub",
    },
    Advanced = {
        DebugMode = false,
        LogLevel = "INFO",        -- DEBUG, INFO, WARN, ERROR
        BypassAntiCheat = true,
        HumanizerEnabled = true,
        RandomDelays = true,
        MinDelay = 0.05,
        MaxDelay = 0.2,
        SafeMode = false,
    }
}

-- ========== FUNÇÕES AUXILIARES ==========

local function getConfigPath()
    -- Tentar pasta do jogo primeiro, depois pasta do executor
    local success, path = pcall(function()
        return LocalPlayer:GetAttribute("ExecutorFolder") or ""
    end)

    if success and path ~= "" then
        return path .. "/" .. ConfigManager.FolderName .. "/" .. ConfigManager.FileName
    end

    -- Fallback: usar workspace do executor se disponível
    local executorFolder = identifyexecutor and "workspace" or ""
    if executorFolder ~= "" then
        return executorFolder .. "/" .. ConfigManager.FolderName .. "/" .. ConfigManager.FileName
    end

    -- Último recurso: path relativo
    return ConfigManager.FileName
end

local function ensureFolder()
    local path = getConfigPath()
    local folder = path:match("(.+)/[^/]+$")
    if folder and makefolder then
        pcall(makefolder, folder)
    end
end

-- ========== MERGE PROFUNDO ==========

local function deepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            deepMerge(target[key], value)
        else
            if target[key] == nil then
                target[key] = value
            end
        end
    end
end

local function deepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- ========== API PÚBLICA ==========

function ConfigManager:Load()
    local path = getConfigPath()
    local config = deepCopy(self.DefaultConfig)

    -- Tentar ler arquivo existente
    local success, content = pcall(function()
        if readfile and isfile and isfile(path) then
            return readfile(path)
        end
        return nil
    end)

    if success and content then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)

        if decodeSuccess and decoded then
            -- Merge com defaults (preserva novos campos do default)
            deepMerge(config, decoded)
            self.CurrentConfig = config
            return true, config
        else
            warn("[ConfigManager] Erro ao decodificar JSON, usando defaults")
        end
    end

    self.CurrentConfig = config
    return false, config
end

function ConfigManager:Save(config)
    config = config or self.CurrentConfig
    config.Version = self.DefaultConfig.Version
    config.LastSaved = os.date("%Y-%m-%d %H:%M:%S")

    local path = getConfigPath()
    ensureFolder()

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)

    if not success then
        warn("[ConfigManager] Erro ao codificar JSON: " .. tostring(encoded))
        return false
    end

    local writeSuccess, err = pcall(function()
        if writefile then
            writefile(path, encoded)
        end
    end)

    if writeSuccess then
        self.CurrentConfig = config
        return true
    else
        warn("[ConfigManager] Erro ao salvar arquivo: " .. tostring(err))
        return false
    end
end

function ConfigManager:Get(path)
    -- Suporte a path com pontos (ex: "UI.Theme")
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.CurrentConfig
    for _, key in ipairs(keys) do
        if type(current) == "table" then
            current = current[key]
        else
            return nil
        end
    end

    return current
end

function ConfigManager:Set(path, value)
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.CurrentConfig
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end

    current[keys[#keys]] = value
    return self:Save()
end

function ConfigManager:Reset(path)
    if path then
        -- Reset apenas uma seção
        local keys = {}
        for key in path:gmatch("[^%.]+") do
            table.insert(keys, key)
        end

        local current = self.CurrentConfig
        local default = self.DefaultConfig

        for i = 1, #keys - 1 do
            local key = keys[i]
            current = current[key]
            default = default[key]
            if not current or not default then return false end
        end

        current[keys[#keys]] = deepCopy(default[keys[#keys]])
    else
        -- Reset completo
        self.CurrentConfig = deepCopy(self.DefaultConfig)
    end

    return self:Save()
end

function ConfigManager:GetAll()
    return deepCopy(self.CurrentConfig)
end

function ConfigManager:GetDefault(path)
    if not path then return deepCopy(self.DefaultConfig) end

    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local current = self.DefaultConfig
    for _, key in ipairs(keys) do
        if type(current) == "table" then
            current = current[key]
        else
            return nil
        end
    end

    return deepCopy(current)
end

-- ========== PRESETS ==========

ConfigManager.Presets = {
    ["Legit Farm"] = {
        AutoFarm = {
            Enabled = true,
            FarmMethod = "Behind",
            Distance = 20,
            TweenSpeed = 300,
            AutoHaki = true,
            AutoKen = true,
            BringMobs = false,
            AttackDelay = 0.3,
        },
        Combat = {
            AimBot = { Enabled = false },
            KillAura = { Enabled = false },
        },
        Misc = { AntiAFK = true },
    },
    ["Raid Speedrun"] = {
        Raid = {
            Enabled = true,
            AutoStart = true,
            AutoNextIsland = true,
            KillAura = true,
            TweenSpeed = 500,
        },
        Combat = {
            KillAura = { Enabled = true, Range = 50 },
            SkillSpam = { Enabled = true, Skills = {Z = true, X = true, C = true, V = true, F = true}, Delay = 0.3 },
        },
        Movement = { Fly = { Enabled = true, Speed = 80 } },
    },
    ["Fruit Sniper"] = {
        Fruit = {
            Enabled = true,
            SniperEnabled = true,
            NotifyOnFind = true,
            SoundOnFind = true,
            StoreFruits = true,
        },
        Misc = { ServerHop = { Enabled = true, Mode = "LowPlayers", Delay = 5 } },
    },
    ["PvP God"] = {
        Combat = {
            AimBot = { Enabled = true, Mode = "Silent", FOV = 150, Smoothness = 0.3 },
            KillAura = { Enabled = true, Range = 40, TargetPlayers = true },
            AutoHaki = true,
            AutoKen = true,
            KenDuration = 8,
        },
        ESP = { Player = { Enabled = true, MaxDistance = 3000 } },
    },
    ["AFK Farm (Safe)"] = {
        AutoFarm = {
            Enabled = true,
            FarmMethod = "Below",
            Distance = 25,
            TweenSpeed = 200,
            AutoHaki = true,
            AutoKen = true,
            BringMobs = false,
            AttackDelay = 0.5,
        },
        Misc = {
            AntiAFK = true,
            Rejoin = { Enabled = true, OnCrash = true, OnKick = true },
            ServerHop = { Enabled = true, Mode = "LowPlayers", Delay = 30 },
        },
        Advanced = { SafeMode = true, HumanizerEnabled = true },
    }
}

function ConfigManager:ApplyPreset(presetName)
    local preset = self.Presets[presetName]
    if not preset then
        warn("[ConfigManager] Preset não encontrado: " .. presetName)
        return false
    end

    deepMerge(self.CurrentConfig, preset)
    return self:Save()
end

function ConfigManager:GetPresets()
    local names = {}
    for name, _ in pairs(self.Presets) do
        table.insert(names, name)
    end
    return names
end

-- ========== EXPORT/IMPORT ==========

function ConfigManager:ExportToString()
    return HttpService:JSONEncode(self.CurrentConfig)
end

function ConfigManager:ImportFromString(jsonStr)
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(jsonStr)
    end)

    if success and decoded then
        deepMerge(self.CurrentConfig, decoded)
        return self:Save()
    end

    return false, "JSON inválido"
end

function ConfigManager:ExportToClipboard()
    local str = self:ExportToString()
    if setclipboard then
        setclipboard(str)
        return true
    end
    return false, "Clipboard não disponível"
end

function ConfigManager:ImportFromClipboard()
    if getclipboard then
        local str = getclipboard()
        return self:ImportFromString(str)
    end
    return false, "Clipboard não disponível"
end

-- ========== AUTO-SAVE ==========

ConfigManager._autoSaveConnection = nil
ConfigManager._autoSaveInterval = 30 -- segundos

function ConfigManager:StartAutoSave(interval)
    interval = interval or self._autoSaveInterval

    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
    end

    self._autoSaveConnection = RunService.Heartbeat:Connect(function()
        self._autoSaveTimer = (self._autoSaveTimer or 0) + 1/60
        if self._autoSaveTimer >= interval then
            self._autoSaveTimer = 0
            self:Save()
        end
    end)
end

function ConfigManager:StopAutoSave()
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
        self._autoSaveConnection = nil
    end
end

-- ========== INICIALIZAÇÃO ==========

function ConfigManager:Initialize()
    local loaded, config = self:Load()
    if loaded then
        print("[ConfigManager] Configuração carregada com sucesso")
    else
        print("[ConfigManager] Usando configuração padrão")
        self:Save() -- Criar arquivo inicial
    end

    -- Auto-save periódico
    self:StartAutoSave()

    return self.CurrentConfig
end

return ConfigManager