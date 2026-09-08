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

-- Referências diretas pra uso no splash/progress
local TweenService = game:GetService("TweenService")

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
    -- 1. Cache local (instantâneo)
    if readfile and isfile and isfile(path) then
        local cached = readfile(path)
        if cached and cached ~= "" then
            local ok, fn = pcall(loadstring, cached)
            if ok and fn then
                local s, r = pcall(fn)
                if s then return r end
            end
            if delfile then pcall(delfile, path) end
        end
    end

    -- 2. Baixar do GitHub com timeout
    local rawContent = nil
    local downloadThread = task.spawn(function()
        local ok, content = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/" .. path, true)
        end)
        if ok and content then rawContent = content end
    end)

    -- Esperar no máximo 5 segundos pelo download
    local waited = 0
    while rawContent == nil and waited < 5 do
        task.wait(0.1)
        waited = waited + 0.1
    end

    if rawContent and rawContent ~= "" and not rawContent:find("<!DOCTYPE") and not rawContent:find("<html") then
        if writefile then pcall(writefile, path, rawContent) end
        local ok, fn = pcall(loadstring, rawContent)
        if ok and fn then
            local s, r = pcall(fn)
            if s then return r end
        end
    end

    return nil
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

    -- Animate (sem TweenService pra evitar erros de cache)
    local function UpdateProgress(percent, text)
        ProgressBar.Size = UDim2.new(percent / 100, 0, 1, 0)
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

    -- Step 2: Core Modules
    CUZAO._UpdateProgress(15, "Carregando Core Modules...")
    local coreModules = {
        "Services", "Utilities", "EventBus", "ConfigManager",
        "Http", "Tween", "Combat", "Inventory", "AntiCheat", "Movement",
    }
    for i, name in ipairs(coreModules) do
        CUZAO._UpdateProgress(15 + (i / #coreModules) * 30, "Core: " .. name)
        local module = LoadModule("modules/core/" .. name .. ".lua")
        if module then CUZAO.Modules[name] = module end
    end

    -- Step 3: UI Modules
    CUZAO._UpdateProgress(50, "Carregando UI...")
    for i, name in ipairs({"Theme", "Library", "Window"}) do
        CUZAO._UpdateProgress(50 + (i / 3) * 15, "UI: " .. name)
        local module = LoadModule("modules/ui/" .. name .. ".lua")
        if module then CUZAO.Modules[name] = module end
    end

    -- Step 4: Data Modules
    CUZAO._UpdateProgress(65, "Carregando Data...")
    for i, name in ipairs({"Locations", "Fruits", "Weapons"}) do
        CUZAO._UpdateProgress(65 + (i / 3) * 10, "Data: " .. name)
        local module = LoadModule("data/" .. name .. ".lua")
        if module then CUZAO.Modules[name] = module end
    end

    -- Step 5: Feature Modules
    CUZAO._UpdateProgress(75, "Carregando Features...")
    for i, name in ipairs({"AutoFarm", "Raid", "Fruit", "Teleport", "ESP", "Combat", "Misc", "SeaEvents"}) do
        CUZAO._UpdateProgress(75 + (i / 8) * 10, "Feature: " .. name)
        local module = LoadModule("modules/features/" .. name .. ".lua")
        if module then CUZAO.Modules[name] = module end
    end

    -- Step 6: Utils
    CUZAO._UpdateProgress(85, "Carregando Utils...")
    for i, name in ipairs({"Logger", "Notifications", "Updater"}) do
        CUZAO._UpdateProgress(85 + (i / 3) * 5, "Utils: " .. name)
        local module = LoadModule("utils/" .. name .. ".lua")
        if module then CUZAO.Modules[name] = module end
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

-- Run in protected mode with stack trace
local success, err = xpcall(Initialize, function(err)
    return tostring(err) .. "\n\nSTACK TRACE:\n" .. debug.traceback()
end)
if not success then
    Log("ERROR", "Loader", "ERRO CRÍTICO: " .. tostring(err))
    if CUZAO._Splash then
        pcall(function() CUZAO._Splash:Destroy() end)
    end
    -- Mostrar erro na tela
    pcall(function()
        local errGui = Instance.new("ScreenGui")
        errGui.Name = "CUZAO_Error"
        errGui.DisplayOrder = 99999
        errGui.Parent = game:GetService("CoreGui")

        local errFrame = Instance.new("Frame")
        errFrame.Size = UDim2.new(0, 600, 0, 350)
        errFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        errFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        errFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
        errFrame.BorderSizePixel = 0
        errFrame.Parent = errGui
        Instance.new("UICorner", errFrame).CornerRadius = UDim.new(0, 10)

        local errStroke = Instance.new("UIStroke")
        errStroke.Color = Color3.fromRGB(255, 0, 0)
        errStroke.Thickness = 2
        errStroke.Parent = errFrame

        local errTitle = Instance.new("TextLabel")
        errTitle.Size = UDim2.new(1, -20, 0, 30)
        errTitle.Position = UDim2.new(0, 10, 0, 15)
        errTitle.BackgroundTransparency = 1
        errTitle.Text = "❌ CUZAO HUB - Erro ao carregar"
        errTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
        errTitle.TextSize = 16
        errTitle.Font = Enum.Font.GothamBold
        errTitle.TextXAlignment = Enum.TextXAlignment.Left
        errTitle.Parent = errFrame

        local errMsg = Instance.new("TextLabel")
        errMsg.Size = UDim2.new(1, -20, 0, 130)
        errMsg.Position = UDim2.new(0, 10, 0, 50)
        errMsg.BackgroundTransparency = 1
        errMsg.Text = "Erro: " .. tostring(err)
        errMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
        errMsg.TextSize = 10
        errMsg.Font = Enum.Font.Code
        errMsg.TextXAlignment = Enum.TextXAlignment.Left
        errMsg.TextYAlignment = Enum.TextYAlignment.Top
        errMsg.TextWrapped = true
        errMsg.TextScaled = false
        errMsg.Parent = errFrame

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeBtn.Text = "Fechar"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = errFrame
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

        closeBtn.MouseButton1Click:Connect(function()
            errGui:Destroy()
        end)

        -- Auto-destruir depois de 30s
        task.delay(30, function()
            if errGui and errGui.Parent then
                errGui:Destroy()
            end
        end)
    end)
end