#!/bin/bash
OUTPUT="cuzao_all.lua"
SRC="/home/xercs/CUZAO HUB"

# Header
cat > "$OUTPUT" << 'HEADER'
--[[
    CUZAO HUB - All-in-One Bundle
    Uso: loadstring(game:HttpGet("https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/cuzao_all.lua"))()
]]
local CUZAO = {}
CUZAO.Version = "1.0.0"
CUZAO.StartTime = tick()
CUZAO.Loaded = false
CUZAO.Modules = {}
CUZAO.Errors = {}
getgenv().CUZAO = CUZAO
getgenv().CUZAO_VERSION = CUZAO.Version
HEADER

# Function to add a module file
add_mod() {
    local filepath="$1"
    local modname="$2"
    if [ -f "$SRC/$filepath" ]; then
        echo "" >> "$OUTPUT"
        echo "-- [$modname]" >> "$OUTPUT"
        echo "pcall(function()" >> "$OUTPUT"
        # Copy file content, replace the last 'return X' with assignment
        # Remove '--!strict' directives
        sed '/^--!strict$/d' "$SRC/$filepath" >> "$OUTPUT"
        echo "end)" >> "$OUTPUT"
        echo "  ✓ $modname"
    else
        echo "  ✗ $modname (skip)"
    fi
}

echo "Building bundle..."

# Core
for m in Services Utilities EventBus ConfigManager Http Tween Combat Inventory AntiCheat Movement; do
    add_mod "modules/core/$m.lua" "Core/$m"
done

# Data
for m in Locations Fruits Weapons; do
    add_mod "data/$m.lua" "Data/$m"
done

# Utils
for m in Logger Notifications Updater; do
    add_mod "utils/$m.lua" "Utils/$m"
done

# UI - Theme & Library (inline)
add_mod "modules/ui/Theme.lua" "Theme"
add_mod "modules/ui/Library.lua" "Library"
add_mod "modules/ui/Window.lua" "Window"

# Features
for m in LevelFarm BoneFarm KatakuriFarm; do
    add_mod "modules/features/AutoFarm/$m.lua" "Feature/AutoFarm/$m"
done
add_mod "modules/features/Combat/AutoClicker.lua" "Feature/Combat/AutoClicker"
for m in PlayerESP FruitESP; do
    add_mod "modules/features/ESP/$m.lua" "Feature/ESP/$m"
done
add_mod "modules/features/Teleport/IslandTP.lua" "Feature/Teleport/IslandTP"
for m in ServerHop Fly StatAssign; do
    add_mod "modules/features/Misc/$m.lua" "Feature/Misc/$m"
done

# Tabs
for m in MainTab FarmTab RaidTab FruitTab TeleportTab ESPTab CombatTab MiscTab SettingsTab; do
    add_mod "modules/ui/Tabs/$m.lua" "Tab/$m"
done

# Add the main loading sequence at the end
cat >> "$OUTPUT" << 'FOOTER'

-- ═══════════════════════════════════════════
-- LOADING SEQUENCE
-- ═══════════════════════════════════════════
print("[CUZAO] Módulos carregados. Inicializando UI...")

local Library = CUZAO.Modules["Library"]
if Library then
    local window = Library:CreateWindow({
        Title = "CUZAO HUB",
        Subtitle = "Blox Fruits",
        Size = UDim2.new(0, 620, 0, 420),
    })
    CUZAO.Window = window

    local tabModules = {
        "MainTab", "FarmTab", "RaidTab", "FruitTab",
        "TeleportTab", "ESPTab", "CombatTab", "MiscTab", "SettingsTab",
    }
    for _, name in ipairs(tabModules) do
        local tabMod = CUZAO.Modules["Tab/" .. name]
        if tabMod and tabMod.Build then
            pcall(function()
                if name == "TeleportTab" then
                    tabMod.Build(window, CUZAO.Modules["Locations"])
                else
                    tabMod.Build(window)
                end
            end)
        end
    end

    -- Initialize feature modules
    local featureNames = {
        "Feature/AutoFarm/LevelFarm", "Feature/AutoFarm/BoneFarm", "Feature/AutoFarm/KatakuriFarm",
        "Feature/Combat/AutoClicker",
        "Feature/ESP/PlayerESP", "Feature/ESP/FruitESP",
        "Feature/Teleport/IslandTP",
        "Feature/Misc/ServerHop", "Feature/Misc/Fly", "Feature/Misc/StatAssign",
    }
    for _, name in ipairs(featureNames) do
        local mod = CUZAO.Modules[name]
        if mod and mod.Initialize then
            pcall(function()
                mod:Initialize({
                    EventBus = CUZAO.Modules["EventBus"],
                    ConfigManager = CUZAO.Modules["ConfigManager"],
                    Services = CUZAO.Modules["Services"],
                    Logger = CUZAO.Modules["Logger"],
                })
            end)
        end
    end

    CUZAO.Loaded = true
    print("[CUZAO HUB] v" .. CUZAO.Version .. " carregado com sucesso!")
    print("[CUZAO HUB] Pressione RightControl para abrir/fechar")
else
    warn("[CUZAO HUB] ERRO: Library não encontrada!")
end

-- Anti-AFK
task.spawn(function()
    pcall(function()
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)
FOOTER

LINES=$(wc -l < "$OUTPUT")
SIZE=$(du -h "$OUTPUT" | cut -f1)
echo ""
echo "✅ Bundle criado: $OUTPUT ($LINES linhas, $SIZE)"
