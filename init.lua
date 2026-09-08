--[[
    CUZAO HUB - Initialization Script
    Ponto de entrada secundário para uso direto via executor

    Uso rápido (via executor):
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/CUZAO-HUB/main/init.lua"))()

    Ou via loader:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/CUZAO-HUB/main/loader.lua"))()

    Diferença:
    - loader.lua: Splash screen, carregamento com progresso, verificações completas
    - init.lua: Carregamento direto e rápido, sem splash
]]

-- ═══════════════════════════════════════════
-- QUICK INIT
-- ═══════════════════════════════════════════
local CUZAO = getgenv().CUZAO

-- Se o loader já foi executado, usar o que já existe
if CUZAO and CUZAO.Loaded then
    warn("[CUZAO] Hub já está carregado! Pressione RightControl para abrir.")
    if CUZAO.Window then
        CUZAO.Window:Toggle()
    end
    return
end

-- Criar novo CUZAO se não existe
if not CUZAO then
    CUZAO = {}
    CUZAO.Version = "1.0.0"
    CUZAO.StartTime = tick()
    CUZAO.Loaded = false
    CUZAO.Modules = {}
    CUZAO.Errors = {}
    getgenv().CUZAO = CUZAO
    getgenv().CUZAO_VERSION = CUZAO.Version
end

-- ═══════════════════════════════════════════
-- QUICK LOAD FUNCTION
-- ═══════════════════════════════════════════
local function LoadFile(path)
    local success, result = pcall(function()
        if readfile and isfile and isfile(path) then
            local source = readfile(path)
            local fn = loadstring(source)
            if fn then
                return fn()
            end
        end
        return nil
    end)
    if success then return result end
    warn("[CUZAO] Erro carregando: " .. path .. " - " .. tostring(result))
    return nil
end

-- ═══════════════════════════════════════════
-- LOAD CORE
-- ═══════════════════════════════════════════
local coreModules = {
    "Services", "Utilities", "EventBus", "ConfigManager",
    "Http", "Tween", "Combat", "Inventory", "AntiCheat", "Movement",
}

for _, name in ipairs(coreModules) do
    local mod = LoadFile("modules/core/" .. name .. ".lua")
    if mod then CUZAO.Modules[name] = mod end
end

-- ═══════════════════════════════════════════
-- LOAD UI
-- ═══════════════════════════════════════════
local uiModules = { "Theme", "Library", "Window" }
for _, name in ipairs(uiModules) do
    local mod = LoadFile("modules/ui/" .. name .. ".lua")
    if mod then CUZAO.Modules[name] = mod end
end

-- ═══════════════════════════════════════════
-- BUILD WINDOW
-- ═══════════════════════════════════════════
local Library = CUZAO.Modules["Library"]
if Library then
    local window = Library:CreateWindow({
        Title = "CUZAO HUB",
        Subtitle = "Blox Fruits",
        Size = UDim2.new(0, 620, 0, 420),
    })
    CUZAO.Window = window

    -- Load tabs
    local tabs = {
        "MainTab", "FarmTab", "RaidTab", "FruitTab",
        "TeleportTab", "ESPTab", "CombatTab", "MiscTab", "SettingsTab",
    }

    for _, name in ipairs(tabs) do
        local tabModule = LoadFile("modules/ui/Tabs/" .. name .. ".lua")
        if tabModule and tabModule.Build then
            -- TeleportTab precisa do Locations pra detecção de Sea
            if name == "TeleportTab" then
                local Locations = CUZAO.Modules["Locations"]
                pcall(tabModule.Build, window, Locations)
            else
                pcall(tabModule.Build, window)
            end
        end
    end

    CUZAO.Loaded = true
    print("[CUZAO HUB] Carregado rapidamente! (init.lua)")
    print("[CUZAO HUB] Pressione RightControl para abrir/fechar")
else
    warn("[CUZAO] UI Library não encontrada! Execute loader.lua primeiro.")
end

-- ═══════════════════════════════════════════
-- ANTI-AFK
-- ═══════════════════════════════════════════
task.spawn(function()
    pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        local Players = game:GetService("Players")
        Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end)