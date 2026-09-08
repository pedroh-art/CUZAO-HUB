# Guia de Continuação - CUZAO HUB

## Para a Próxima Sessão

### 1. Ler o Contexto do Projeto
```bash
cat "/home/xercs/CUZAO HUB/.claude/project.md"
```

### 2. Verificar Estado Atual
```bash
find "/home/xercs/CUZAO HUB" -name "*.lua" | sort
```

### 3. Continuar Implementação - Ordem Recomendada

#### A. UI Library (WindUI Customizado) - PRIORIDADE ALTA
Arquivo: `/home/xercs/CUZAO HUB/modules/ui/Library.lua`

Basear no WindUI (https://github.com/Footagesus/WindUI) mas simplificado:
- Window com tabs laterais
- Componentes: Toggle, Slider, Dropdown, Button, Keybind, ColorPicker, Section, Paragraph, Input
- Temas: Dark, Light, RGB, CUZAO (vermelho/preto)
- Notificações toast
- Keybind global (RightControl padrão)
- Mobile touch support

#### B. Theme System
Arquivo: `/home/xercs/CUZAO HUB/modules/ui/Theme.lua`
```lua
Themes = {
    Dark = {Background = ..., Text = ..., Accent = ...},
    Light = {...},
    RGB = {...},
    CUZAO = {Background = Color3.fromRGB(15,15,15), Accent = Color3.fromRGB(255,0,0), ...}
}
```

#### C. Main Tab + Farm Tab
Arquivos: `/home/xercs/CUZAO HUB/modules/ui/Tabs/MainTab.lua`, `FarmTab.lua`

MainTab: Info do script, versão, executor, status, botões rápidos
FarmTab: AutoFarm config (Level/Bone/Katakuri/Factory), weapon, method, toggles

#### D. Data Locations - ESSENCIAL PARA FARM
Arquivo: `/home/xercs/CUZAO HUB/data/Locations.lua`

Coordenadas necessárias:
```lua
Islands = {
    ["Starter"] = Vector3.new(1061, 16, 1445),
    ["Jungle"] = Vector3.new(-1612, 36, 149),
    ["Pirate Village"] = Vector3.new(-1131, 4, 3828),
    ["Desert"] = Vector3.new(944, 6, 4373),
    ["Snow"] = Vector3.new(1384, 87, -1298),
    ["Marine Fortress"] = Vector3.new(-4505, 20, 4260),
    ["Skylands"] = Vector3.new(-4968, 717, -2623),
    ["Prison"] = Vector3.new(4875, 5, 734),
    ["Colosseum"] = Vector3.new(-1576, 7, -2983),
    ["Magma Village"] = Vector3.new(-5247, 12, 8534),
    ["Underwater"] = Vector3.new(61163, 11, 1819),
    ["Fountain"] = Vector3.new(5256, 39, 4050),
    ["Haunted Castle"] = Vector3.new(-9515, 142, 5545),
    ["Ice Castle"] = Vector3.new(6148, 294, -6741),
    ["Forgotten Island"] = Vector3.new(-3032, 240, -10172),
    ["Port Town"] = Vector3.new(-290, 44, 5590),
    ["Hydra Island"] = Vector3.new(5746, 610, -253),
    ["Great Tree"] = Vector3.new(2681, 1682, -7190),
    ["Kitsune Island"] = Vector3.new(-1598, 245, -1254),
    ["Prehistoric Island"] = Vector3.new(-11645, 334, -9725),
    ["Mirage Island"] = Vector3.new(-6653, 259, -2231),
}
NPCs = {
    ["Blox Fruit Dealer"] = Vector3.new(-434, 73, 334),
    ["Blox Fruit Dealer Cousin"] = Vector3.new(-434, 73, 334),
    ["Awakening Expert"] = Vector3.new(-12463, 333, -9970),
    ["Blacksmith"] = Vector3.new(-12463, 333, -9970),
    ["Sword Dealer"] = {...},
    ["Gun Dealer"] = {...},
    ["Haki Trainer"] = {...},
    ["Quest NPCs"] = {...},
}
```

#### E. AutoFarm Level Farm
Arquivo: `/home/xercs/CUZAO HUB/modules/features/AutoFarm/LevelFarm.lua`

Usar módulos core:
- Combat para atacar
- Movement para mover
- Tween para tween suave
- Inventory para equipar arma
- ConfigManager para settings
- EventBus para eventos

```lua
local LevelFarm = {
    Enabled = false,
    CurrentTarget = nil,
    Connections = {},
    Config = { -- do ConfigManager }
}

function LevelFarm:Start()
    -- Loop principal
    -- GetBestTarget
    -- TweenToBehind/Below
    -- AttackTarget
    -- AutoHaki/Ken
end
```

#### F. Loader Principal
Arquivo: `/home/xercs/CUZAO HUB/loader.lua`

```lua
local function LoadModule(path)
    -- loadstring com error handling
end

-- Ordem de carregamento:
-- 1. Core (Services, Utilities, EventBus, ConfigManager)
-- 2. Core (Http, Tween, Combat, Inventory, AntiCheat, Movement)
-- 3. UI Library
-- 4. Data (Locations, Fruits, Weapons)
-- 5. Features
-- 6. Tabs
-- 7. Initialize Hub
```

### 4. Testar no Jogo

```lua
-- No executor, executar:
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/CUZAO-HUB/main/loader.lua"))()
```

### 5. Checklist de Validação por Feature

| Feature | Teste |
|---------|-------|
| UI | Abre/fecha com RightControl, tabs navegam, toggles salvam |
| AutoFarm Level | Mata mobs, ganha XP, não trava, humanizer funciona |
| Teleport | Vai para ilhas/NPCs, safe mode evita void |
| ESP | Renderiza boxes/names, sem memory leak |
| Combat | AutoClicker clica, AimBot mira, KillAura ataca área |
| Config | Salva/carrega JSON, presets funcionam |
| AntiCheat | Não kick, não detecta, humanizer ativo |

### 6. Comandos Rápidos

```bash
# Ver todos arquivos Lua
find "/home/xercs/CUZAO HUB" -name "*.lua"

# Contar linhas
wc -l "/home/xercs/CUZAO HUB"/modules/core/*.lua

# Ver estrutura
tree "/home/xercs/CUZAO HUB" -I "*.md"
```

---

## Notas para o Próximo Claude

### Contexto Importante
- Projeto está em `/home/xercs/CUZAO HUB/`
- 9 módulos core já implementados e funcionais
- Arquitetura modular com EventBus, ConfigManager, Services centralizados
- AntiCheat com humanizer, bypass kick, anti-AFK
- Tween com pathfinding, circle/behind/above, noclip tween
- Combat com AimBot (3 modos), KillAura, SkillSpam, Haki/Ken auto

### O que NÃO fazer
- Não reescrever módulos core (já estão bons)
- Não criar arquivos fora da estrutura definida
- Não usar bibliotecas externas não permitidas (só Roblox APIs)

### O que FAZER
- Seguir o padrão Module existente
- Usar pcall em tudo que pode falhar
- Integrar com ConfigManager:Get/Set
- Emitir eventos no EventBus para comunicação
- Documentar funções públicas

### Estilo de Código
```lua
local Module = {}
Module.Config = {defaults}
function Module:Method(args) -- usar self
    local success, result = pcall(function() ... end)
    if not success then warn("[Module] " .. result) end
    return result
end
return Module
```

---

## Status da Implementação

```
████████████████░░░░░░░░░░  40% Concluído
├── Core Modules: ████████████  100% (9/9)
├── UI Library:   ░░░░░░░░░░░░  0%  (0/12)
├── Features:     ░░░░░░░░░░░░  0%  (0/20+)
├── Data:         ░░░░░░░░░░░░  0%  (0/5)
├── Loader:       ░░░░░░░░░░░░  0%  (0/3)
└── Utils:        ░░░░░░░░░░░░  0%  (0/4)
```

---

**Próximo passo imediato**: Criar `modules/ui/Library.lua` com WindUI customizado.