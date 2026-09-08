# CUZAO HUB - Contexto do Projeto

## Visão Geral
Script hub para Blox Fruits (Roblox) com arquitetura modular, inspirado nos melhores scripts da comunidade (Zenith, Vape, W-Azure, Hydrogen).

## Estado Atual da Implementação

**Última atualização**: 2026-09-07 | **Progresso geral**: ~75% Concluído

### ✅ Concluído - Core Modules
- `modules/core/Services.lua` - Serviços Roblox centralizados + Remotes do Blox Fruits
- `modules/core/Utilities.lua` - Funções utilitárias (math, vector, combat, inventory, movement, etc.)
- `modules/core/EventBus.lua` - Sistema de eventos desacoplado (On, Once, Emit, WaitFor)
- `modules/core/ConfigManager.lua` - Save/Load JSON, presets, merge profundo, auto-save
- `modules/core/Http.lua` - HTTP robusto, webhooks Discord, GitHub API, queue system
- `modules/core/Tween.lua` - Movimento suave, pathfinding, circle/behind/above, noclip tween, fly
- `modules/core/Combat.lua` - AutoClicker, AimBot (Silent/Legit/FOV), KillAura, SkillSpam, Haki, Ken
- `modules/core/Inventory.lua` - Gestão de frutas, armas, acessórios, materiais, stats, auto-stats
- `modules/core/AntiCheat.lua` - Bypass kick/teleport, remote spy, humanizer, anti-AFK, anti-crash, safe mode
- `modules/core/Movement.lua` - Noclip, Fly, Speed, Infinite Jump, Teleport, Pathfinding, Waypoints

### ✅ Concluído - UI Library (WindUI Customizado)
- `modules/ui/Theme.lua` - Sistema de temas (Dark, Light, RGB, CUZAO) com RGB animado
- `modules/ui/Library.lua` - Biblioteca principal com Window, Tabs, Components
- `modules/ui/Window.lua` - Janela reutilizável com drag, minimize, keybind toggle
- `modules/ui/Components/` - 9 componentes (Toggle, Slider, Dropdown, Button, Keybind, ColorPicker, Section, Paragraph, Input)
- `modules/ui/Tabs/` - 9 tabs (Main, Farm, Raid, Fruit, Teleport, ESP, Combat, Misc, Settings)

### ✅ Concluído - Data Modules
- `data/Locations.lua` - Coordenadas completas (Sea1/2/3), NPCs, spawns de frutas
- `data/Fruits.lua` - Banco de dados de frutas com preço, raridade, cores, habilidades
- `data/Weapons.lua` - Espadas, armas de fogo, estilos de luta

### ✅ Concluído - Utils
- `utils/Logger.lua` - Logs coloridos com níveis, histórico e exportação
- `utils/Notifications.lua` - Toast notifications com Discord webhook
- `utils/Updater.lua` - Auto-update via GitHub Releases
- `utils/KeySystem.lua` - Sistema de chave opcional (Linkvertise, LootLabs, Custom)

### ✅ Concluído - Loader
- `loader.lua` - Entry point com splash screen, progresso e carregamento ordenado
- `init.lua` - Carregamento rápido sem splash

### 📁 Estrutura de Diretórios Criada
```
CUZAO HUB/
├── loader.lua ✅
├── init.lua ✅
├── modules/
│   ├── core/ (10 arquivos ✅)
│   │   ├── Services.lua, Utilities.lua, EventBus.lua
│   │   ├── ConfigManager.lua, Http.lua, Tween.lua
│   │   ├── Combat.lua, Inventory.lua, AntiCheat.lua, Movement.lua
│   ├── features/
│   │   ├── AutoFarm/ (pendente)
│   │   ├── Raid/ (pendente)
│   │   ├── Fruit/ (pendente)
│   │   ├── Teleport/ (pendente)
│   │   ├── ESP/ (pendente)
│   │   ├── Combat/ (pendente)
│   │   ├── Misc/ (pendente)
│   │   └── SeaEvents/ (pendente)
│   └── ui/ (21 arquivos ✅)
│       ├── Library.lua, Theme.lua, Window.lua
│       ├── Components/ (9 arquivos)
│       │   ├── Toggle.lua, Slider.lua, Dropdown.lua
│       │   ├── Button.lua, Keybind.lua, ColorPicker.lua
│       │   ├── Section.lua, Paragraph.lua, Input.lua
│       └── Tabs/ (9 arquivos)
│           ├── MainTab.lua, FarmTab.lua, RaidTab.lua
│           ├── FruitTab.lua, TeleportTab.lua, ESPTab.lua
│           ├── CombatTab.lua, MiscTab.lua, SettingsTab.lua
├── data/ (3 arquivos ✅)
│   ├── Locations.lua, Fruits.lua, Weapons.lua
├── settings/ (pendente)
└── utils/ (4 arquivos ✅)
    ├── Logger.lua, Notifications.lua, Updater.lua, KeySystem.lua
```
**Total: 40 arquivos Lua (~8.700 linhas)**

### ⏳ Pendente - Próximas Fases

#### Fase 2: UI Library (WindUI Customizado)
- `modules/ui/Library.lua` - Biblioteca principal
- `modules/ui/Theme.lua` - Temas (Dark, Light, RGB, CUZAO)
- `modules/ui/Window.lua` - Janela principal
- `modules/ui/Tabs/` - 9 tabs (Main, Farm, Raid, Fruit, Teleport, ESP, Combat, Misc, Settings)
- `modules/ui/Components/` - Toggle, Slider, Dropdown, Button, Keybind, ColorPicker, Section

#### Fase 3: Features MVP
- `modules/features/AutoFarm/LevelFarm.lua`
- `modules/features/AutoFarm/BoneFarm.lua`
- `modules/features/AutoFarm/KatakuriFarm.lua`
- `modules/features/AutoFarm/FactoryFarm.lua`
- `modules/features/Teleport/IslandTP.lua`
- `modules/features/Teleport/NPC_TP.lua`
- `modules/features/Teleport/PlayerTP.lua`
- `modules/features/ESP/PlayerESP.lua`
- `modules/features/ESP/FruitESP.lua`
- `modules/features/ESP/ChestESP.lua`
- `modules/features/Combat/AutoClicker.lua`
- `modules/features/Combat/AimBot.lua`
- `modules/features/Combat/KillAura.lua`

#### Fase 4: Data & Loader
- `data/Locations.lua` - Coordenadas de todas ilhas, NPCs, spawns
- `data/Fruits.lua` - Dados completos de frutas (preço, raridade, spawn, mastery)
- `data/Weapons.lua` - Dados de armas/spells
- `data/Quests.lua` - Missões por nível
- `data/Raids.lua` - Configuração de raids
- `loader.lua` - Entry point com carregamento ordenado
- `init.lua` - Inicialização do hub
- `settings/Presets.lua` - Presets pré-definidos
- `utils/Logger.lua` - Sistema de logs coloridos
- `utils/Notifications.lua` - Toast notifications
- `utils/KeySystem.lua` - Sistema de key (opcional)
- `utils/Updater.lua` - Auto-update GitHub

## Decisões Técnicas

### Executor Alvo: Multiplataforma
- Synapse X, Script-Ware, Fluxus, Delta, Hydrogen, Arceus X, Codex, Vega X, Solara, Wave
- Detecção automática via `identifyexecutor` / `getexecutorname` / globals

### UI Library: WindUI Customizado
- Leve, moderno, suporte a temas, animações suaves
- Mobile-friendly (touch)
- Tema "CUZAO" (vermelho/preto)

### Key System: Opcional
- Suporte a Linkvertise, LootLabs, custom
- Configurável via ConfigManager

### Webhook Discord: Sim
- Fruit Sniper com ping @everyone
- Logs de farm
- Embeds formatados com cores por raridade

### Idiomas: PT-BR (prioritário), EN, ES
- Sistema de localização no ConfigManager

### Atualização: GitHub Releases
- Verificação automática no loader
- Prompt de atualização

## Padrões de Código

### Module Pattern (Singleton)
```lua
local Module = {}
Module.Config = {}
function Module:Method() end
return Module
```

### Event-Driven
```lua
EventBus:On("eventName", callback)
EventBus:Emit("eventName", data)
```

### Config Access
```lua
ConfigManager:Get("AutoFarm.TweenSpeed")
ConfigManager:Set("AutoFarm.Enabled", true)
```

### Error Handling
```lua
local success, result = pcall(function() ... end)
if not success then warn("[Module] Erro: " .. tostring(result)) end
```

## Comandos Úteis para Próxima Sessão

```bash
# Ver estrutura
ls -la "/home/xercs/CUZAO HUB"/modules/core/

# Ver arquivos criados
find "/home/xercs/CUZAO HUB" -name "*.lua" | head -20
```

## Próximos Passos Imediatos

1. **Criar UI Library base** - WindUI customizado em `modules/ui/Library.lua`
2. **Criar tabs principais** - MainTab, FarmTab, etc.
3. **Implementar AutoFarm Level** - Usar Combat, Movement, Tween, Inventory
4. **Criar data/Locations.lua** - Coordenadas essenciais
5. **Criar loader.lua** - Carregamento ordenado com error handling

## Notas Importantes

- Todos os módulos core usam `pcall` para robustez
- ConfigManager faz merge profundo com defaults
- AntiCheat tem humanizer para evitar detecção
- Tween module suporta pathfinding e movimento humanizado
- Combat module tem AimBot com 3 modos (Silent/Legit/FOV)
- Inventory module detecta frutas/armas automaticamente