# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CUZAO HUB** — Script hub premium para Blox Fruits (Roblox) com arquitetura modular, executado via executors (Synapse X, Fluxus, Delta, Hydrogen, etc.). Idioma do projeto: PT-BR.

**Execução:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/CUZAO-HUB/main/loader.lua"))()
```

## Architecture

### Loading Order (loader.lua → init.lua)
O loader carrega módulos nesta ordem exata via `loadstring(readfile(path))`:
1. **Core** — Services, Utilities, EventBus, ConfigManager, Http, Tween, Combat, Inventory, AntiCheat, Movement
2. **UI** — Theme, Library, Window (só então Tabs e Components)
3. **Data** — Locations, Fruits, Weapons
4. **Utils** — Logger, Notifications, Updater, KeySystem
5. **Tabs** — MainTab, FarmTab, RaidTab, FruitTab, TeleportTab, ESPTab, CombatTab, MiscTab, SettingsTab

O TeleportTab recebe `Locations` como 2º argumento (`Build(window, Locations)`) para detecção de Sea.

### Module Pattern (Singleton)
Todo módulo usa este padrão — NÃO quebrar:
```lua
local Module = {}
Module.Config = { defaults }
function Module:Method(args)
    local success, result = pcall(function() ... end)
    if not success then warn("[Module] Erro: " .. tostring(result)) end
    return result
end
return Module
```

### Communication
- **EventBus** — `EventBus:On(name, cb)`, `EventBus:Emit(name, data)`, `EventBus:Once(name, cb)`
- **ConfigManager** — `ConfigManager:Get("AutoFarm.TweenSpeed")`, `ConfigManager:Set("AutoFarm.Enabled", true)`
- **Remotes do jogo** — Acessíveis via `Services.Remotes.CommF_` e `Services.Remotes.CommE`

### Key Remotes (Blox Fruits)
```lua
Services.Remotes.CommF_  -- Comunicação principal (quests, compras, tp)
Services.Remotes.CommE   -- Eventos secundários
-- Acesso: game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AcceptQuest", questName)
```

### UI System
- **Library.lua** — Cria Window, Tabs, e todos os components inline
- **Theme.lua** — 4 temas com RGB animado (`Theme:SetTheme("CUZAO")`)
- **Components** — Toggle, Slider, Dropdown, Button, Keybind, ColorPicker, Section, Paragraph, Input (todos em `modules/ui/Components/`)
- **Tabs** — Cada tab tem uma função `TabName.Build(window, ...)` que recebe a window

### Sea Detection
`data/Locations.lua` detecta automaticamente o Sea (1/2/3) por PlaceId:
- `2753915549` → Sea 1
- `4442272183` → Sea 2
- `7449423635` → Sea 3
- Fallback por posição do jogador
- Override manual: `Locations:SetSea(n)`

## Code Conventions

- **pcall** em toda chamada que pode falhar (remotes, teleport, http)
- **self** em todos os métodos públicos
- **UTF-8 PT-BR** com acentos (não ASCII equivalents)
- Comentários e logs em PT-BR
- Log prefix: `[ModuleName] mensagem`
- Components usam TweenService para animações suaves
- Dropdown API: `:Set(v)`, `:Get()`, `:Refresh(options)`
- Tabs carregam modules via `LoadModule(path)` com error handling

## Status (75% completo)

| Módulo | Status | Arquivos |
|--------|--------|----------|
| Core | ✅ 100% | 10 |
| UI Library | ✅ 100% | 21 |
| Data | ✅ 100% | 3 |
| Utils | ✅ 100% | 4 |
| Loader | ✅ 100% | 2 |
| **Features** | ❌ 0% | 0/20+ |

**40 arquivos Lua, ~13.900 linhas.**

## What NOT To Do

- Não reescrever core modules (Services, EventBus, ConfigManager, etc.)
- Não criar arquivos fora da estrutura `modules/features/`, `data/`, `utils/`
- Não usar bibliotecas externas (só Roblox APIs)
- Não alterar a ordem de carregamento do loader.lua
- Não quebrar o Module Pattern singleton
- Não usar `print()` direto — usar Logger ou warn com prefixo `[Module]`

## Next Steps (Features MVP)

Pastas vazias em `modules/features/` que precisam ser implementadas:
- `AutoFarm/LevelFarm.lua` — Usar Combat, Movement, Tween, Inventory, ConfigManager
- `AutoFarm/BoneFarm.lua`, `KatakuriFarm.lua`, `FactoryFarm.lua`
- `ESP/PlayerESP.lua`, `FruitESP.lua`, `ChestESP.lua` — Drawing API
- `Teleport/IslandTP.lua` — Usar data/Locations.lua com Sea detection
- `Combat/AutoClicker.lua`, `AimBot.lua`, `KillAura.lua` — Baseado em core/Combat.lua
