--[[
    ╔═══════════════════════════════════════════════════╗
    ║           CUZAO HUB - Main Loader                ║
    ║   Script Hub premium para Blox Fruits            ║
    ║   Versão: 1.0.0                                  ║
    ╚═══════════════════════════════════════════════════╝

    Uso:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/CUZAO-HUB/main/loader.lua"))()
]]

-- ═══════════════════════════════════════════
-- ENVIRONMENT SETUP
-- ═══════════════════════════════════════════
local CUZAO = {}

CUZAO.Version = "1.0.0"
CUZAO.StartTime = tick()
CUZAO.Loaded = false
CUZAO.Modules = {}
CUZAO.Errors = {}

-- Global access
getgenv().CUZAO = CUZAO
getgenv().CUZAO_VERSION = CUZAO.Version

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualUser = game:GetService("VirtualUser"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService"),
}

CUZAO.Services = Services

-- ═══════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════
local function Log(level, module, message)
    local prefix = {
        INFO = "ℹ️ ",
        WARN = "⚠️ ",
        ERROR = "❌",
        SUCCESS = "✅",
    }
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] [%s] [%s] %s", timestamp, prefix[level] or "•", module, message))
end

local function LoadModule(path)
    local success, result = pcall(function()
        local source

        -- Tentar readfile primeiro (se rodando localmente)
        if readfile and isfile and isfile(path) then
            source = readfile(path)
        end

        -- Se não encontrou localmente, baixar do GitHub
        if not source then
            local rawContent = game:HttpGet(
                "https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/" .. path,
                true -- silent
            )
            if rawContent and rawContent ~= "" then
                source = rawContent
                -- Salvar localmente para próxima vez (se o executor suporta)
                if writefile then
                    pcall(writefile, path, source)
                end
            end
        end

        if source and source ~= "" then
            local fn, err = loadstring(source)
            if fn then
                return fn()
            else
                warn("[CUZAO] Loadstring error in " .. path .. ": " .. tostring(err))
                return nil
            end
        end
        return nil
    end)

    if success and result then
        Log("SUCCESS", "Loader", "Carregado: " .. path)
        return result
    elseif not success then
        local errMsg = "Falha ao carregar " .. path .. ": " .. tostring(result)
        Log("ERROR", "Loader", errMsg)
        table.insert(CUZAO.Errors, errMsg)
        return nil
    else
        Log("WARN", "Loader", "Módulo vazio: " .. path)
        return nil
    end
end

CUZAO.LoadModule = LoadModule

-- ═══════════════════════════════════════════
-- EXECUTOR DETECTION
-- ═══════════════════════════════════════════
local function DetectExecutor()
    local executor = "Unknown"

    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success and name then
            executor = name
        end
    elseif getexecutorname then
        local success, name = pcall(getexecutorname)
        if success and name then
            executor = name
        end
    elseif syn then
        executor = "Synapse X"
    elseif KRNL_LOADED then
        executor = "KRNL"
    elseif fluxus then
        executor = "Fluxus"
    elseif pebble then
        executor = "Pebble"
    end

    CUZAO.Executor = executor
    Log("INFO", "Loader", "Executor detectado: " .. executor)
    return executor
end

-- ═══════════════════════════════════════════
-- FEATURE CHECKS
-- ═══════════════════════════════════════════
local function CheckFeatures()
    local features = {
        http = (syn and syn.request) or http_request or httprequest or (getgenv and getgenv().request),
        write = writefile and readfile and isfile,
        clipboard = setclipboard,
        drawing = Drawing and Drawing.new,
        websocket = WebSocket and WebSocket.connect,
        hookfunction = hookfunction or hookmetamethod,
        firetouchinterest = firetouchinterest or firetouchtransmitter,
        fireclickdetector = fireclickdetector,
        getnamecallmethod = getnamecallmethod,
    }

    CUZAO.Features = features

    local supported = 0
    local total = 0
    for name, exists in pairs(features) do
        total = total + 1
        if exists then supported = supported + 1 end
    end

    Log("INFO", "Loader", string.format("Features: %d/%d suportadas", supported, total))
    return features
end

-- ═══════════════════════════════════════════
-- GAME CHECK
-- ═══════════════════════════════════════════
local function CheckGame()
    local gameId = game.PlaceId

    -- Blox Fruits Place IDs
    local bloxFruitsIds = {
        [2753915549] = true,  -- Blox Fruits
        [4442272183] = true,  -- Blox Fruits (Second Sea)
        [7449423635] = true,  -- Blox Fruits (Third Sea)
    }

    if not bloxFruitsIds[gameId] then
        Log("WARN", "Loader", "Este jogo NÃO é Blox Fruits! PlaceId: " .. tostring(gameId))
        Log("WARN", "Loader", "Continuando mesmo assim (modo compatível)...")
    else
        Log("SUCCESS", "Loader", "Blox Fruits detectado! PlaceId: " .. tostring(gameId))
    end

    return true
end

-- ═══════════════════════════════════════════
-- SPLASH SCREEN
-- ═══════════════════════════════════════════
local function ShowSplash()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CUZAO_Splash"
    ScreenGui.DisplayOrder = 9999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 120)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 1.5
    Stroke.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "CUZAO HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 28
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Frame

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, 0, 0, 20)
    Sub.Position = UDim2.new(0, 0, 0, 50)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Carregando módulos..."
    Sub.TextColor3 = Color3.fromRGB(160, 160, 160)
    Sub.TextSize = 12
    Sub.Font = Enum.Font.Gotham
    Sub.Parent = Frame

    local ProgressBarBg = Instance.new("Frame")
    ProgressBarBg.Size = UDim2.new(0.8, 0, 0, 6)
    ProgressBarBg.Position = UDim2.new(0.1, 0, 0, 85)
    ProgressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ProgressBarBg.BorderSizePixel = 0
    ProgressBarBg.Parent = Frame
    Instance.new("UICorner", ProgressBarBg).CornerRadius = UDim.new(1, 0)

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressBarBg
    Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 16)
    StatusLabel.Position = UDim2.new(0, 0, 0, 98)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "0%"
    StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = Frame

    -- Animate
    local function UpdateProgress(percent, text)
        ProgressBar:TweenSize(UDim2.new(percent / 100, 0, 1, 0), Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0.3, true)
        StatusLabel.Text = math.floor(percent) .. "%"
        if text then
            Sub.Text = text
        end
    end

    CUZAO._Splash = ScreenGui
    CUZAO._UpdateProgress = UpdateProgress

    return ScreenGui, UpdateProgress
end

local function HideSplash()
    if CUZAO._Splash then
        task.delay(0.5, function()
            pcall(function() CUZAO._Splash:Destroy() end)
        end)
    end
end

-- ═══════════════════════════════════════════
-- LOADING SEQUENCE
-- ═══════════════════════════════════════════
local function Initialize()
    Log("INFO", "Loader", "═══════════════════════════════════")
    Log("INFO", "Loader", "    CUZAO HUB v" .. CUZAO.Version)
    Log("INFO", "Loader", "═══════════════════════════════════")

    -- Step 1: Environment
    CUZAO._UpdateProgress(5, "Verificando ambiente...")
    DetectExecutor()
    CheckFeatures()
    CheckGame()
    task.wait(0.3)

    -- Step 2: Core Modules (já devem existir no repo)
    CUZAO._UpdateProgress(15, "Carregando Core Modules...")
    local coreModules = {
        "Services",
        "Utilities",
        "EventBus",
        "ConfigManager",
        "Http",
        "Tween",
        "Combat",
        "Inventory",
        "AntiCheat",
        "Movement",
    }

    local coreBase = "modules/core/"
    for i, name in ipairs(coreModules) do
        CUZAO._UpdateProgress(15 + (i / #coreModules) * 30, "Core: " .. name)
        local module = LoadModule(coreBase .. name .. ".lua")
        if module then
            CUZAO.Modules[name] = module
        end
        task.wait(0.1)
    end

    -- Step 3: UI Modules
    CUZAO._UpdateProgress(50, "Carregando UI...")
    local uiBase = "modules/ui/"
    local uiModules = {
        "Theme",
        "Library",
        "Window",
    }

    for i, name in ipairs(uiModules) do
        CUZAO._UpdateProgress(50 + (i / #uiModules) * 15, "UI: " .. name)
        local module = LoadModule(uiBase .. name .. ".lua")
        if module then
            CUZAO.Modules[name] = module
        end
        task.wait(0.1)
    end

    -- Step 4: Data Modules
    CUZAO._UpdateProgress(65, "Carregando Data...")
    local dataModules = {
        "Locations",
        "Fruits",
        "Weapons",
    }

    local dataBase = "data/"
    for i, name in ipairs(dataModules) do
        CUZAO._UpdateProgress(65 + (i / #dataModules) * 10, "Data: " .. name)
        local module = LoadModule(dataBase .. name .. ".lua")
        if module then
            CUZAO.Modules[name] = module
        end
        task.wait(0.1)
    end

    -- Step 5: Feature Modules
    CUZAO._UpdateProgress(75, "Carregando Features...")
    local featureCategories = {
        "AutoFarm",
        "Raid",
        "Fruit",
        "Teleport",
        "ESP",
        "Combat",
        "Misc",
        "SeaEvents",
    }

    for i, category in ipairs(featureCategories) do
        CUZAO._UpdateProgress(75 + (i / #featureCategories) * 10, "Feature: " .. category)
        local module = LoadModule("modules/features/" .. category .. ".lua")
        if module then
            CUZAO.Modules[category] = module
        end
        task.wait(0.05)
    end

    -- Step 6: Utils
    CUZAO._UpdateProgress(85, "Carregando Utils...")
    local utils = {
        "Logger",
        "Notifications",
        "Updater",
    }

    for i, name in ipairs(utils) do
        CUZAO._UpdateProgress(85 + (i / #utils) * 5, "Utils: " .. name)
        local module = LoadModule("utils/" .. name .. ".lua")
        if module then
            CUZAO.Modules[name] = module
        end
        task.wait(0.05)
    end

    -- Step 7: Build UI
    CUZAO._UpdateProgress(92, "Construindo interface...")

    local Library = CUZAO.Modules["Library"]
    if Library then
        -- Create main window
        local window = Library:CreateWindow({
            Title = "CUZAO HUB",
            Subtitle = "Blox Fruits",
            Size = UDim2.new(0, 620, 0, 420),
        })

        CUZAO.Window = window

        -- Load tabs
        local tabModules = {
            { path = "modules/ui/Tabs/MainTab.lua",      name = "MainTab" },
            { path = "modules/ui/Tabs/FarmTab.lua",       name = "FarmTab" },
            { path = "modules/ui/Tabs/RaidTab.lua",       name = "RaidTab" },
            { path = "modules/ui/Tabs/FruitTab.lua",      name = "FruitTab" },
            { path = "modules/ui/Tabs/TeleportTab.lua",   name = "TeleportTab" },
            { path = "modules/ui/Tabs/ESPTab.lua",        name = "ESPTab" },
            { path = "modules/ui/Tabs/CombatTab.lua",     name = "CombatTab" },
            { path = "modules/ui/Tabs/MiscTab.lua",       name = "MiscTab" },
            { path = "modules/ui/Tabs/SettingsTab.lua",   name = "SettingsTab" },
        }

        for i, tabInfo in ipairs(tabModules) do
            CUZAO._UpdateProgress(92 + (i / #tabModules) * 5, "Tab: " .. tabInfo.name)
            local tabModule = LoadModule(tabInfo.path)
            if tabModule and tabModule.Build then
                -- TeleportTab precisa do módulo Locations pra detecção de Sea
                if tabInfo.name == "TeleportTab" then
                    local Locations = CUZAO.Modules["Locations"]
                    pcall(tabModule.Build, window, Locations)
                else
                    pcall(tabModule.Build, window)
                end
            end
            task.wait(0.05)
        end
    else
        Log("ERROR", "Loader", "UI Library não encontrada!")
    end

    -- Step 8: Initialize Features
    CUZAO._UpdateProgress(98, "Inicializando features...")
    task.wait(0.2)

    -- Step 9: Done!
    CUZAO._UpdateProgress(100, "Pronto!")
    CUZAO.Loaded = true

    local elapsed = tick() - CUZAO.StartTime
    Log("SUCCESS", "Loader", string.format("CUZAO HUB carregado em %.2f segundos!", elapsed))
    Log("INFO", "Loader", "Pressione RightControl para abrir/fechar")

    task.delay(1, HideSplash)
end

-- ═══════════════════════════════════════════
-- ANTI-AFK (padrão)
-- ═══════════════════════════════════════════
task.spawn(function()
    pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        Services.Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            Log("INFO", "AntiAFK", "Anti-AFK ativado")
        end)
    end)
end)

-- ═══════════════════════════════════════════
-- STARTUP
-- ═══════════════════════════════════════════
ShowSplash()

-- Small delay for splash to render
task.wait(0.5)

-- Run in protected mode
local success, err = pcall(Initialize)
if not success then
    Log("ERROR", "Loader", "ERRO CRÍTICO: " .. tostring(err))
    if CUZAO._Splash then
        pcall(function() CUZAO._Splash:Destroy() end)
    end
    -- Fallback: try loading with simpler method
    pcall(function()
        warn("[CUZAO] Tentando carregamento simplificado...")
        Initialize()
    end)
end