--!strict
--[[
    CUZAO HUB - Settings Tab
    Configurações gerais: tema, keybind, UI, updater
]]

local SettingsTab = {}

local Players = game:GetService("Players")

function SettingsTab.Build(window)
    local tab = window:CreateTab({ Name = "Settings", Icon = "⚙️" })

    -- ═══ Theme ═══
    local themeSection = tab:CreateSection("Tema")

    themeSection:AddDropdown({
        Text = "Tema",
        Options = {"Dark", "Light", "RGB", "CUZAO"},
        Default = "Dark",
        Callback = function(value)
            print("[CUZAO] Tema alterado: " .. value)
            -- Theme:SetTheme(value)
        end,
    })

    themeSection:AddColorPicker({
        Text = "Cor Customizada",
        Default = Color3.fromRGB(88, 101, 242),
        Callback = function(color) end,
    })

    themeSection:AddSlider({
        Text = "RGB Speed",
        Min = 1,
        Max = 10,
        Default = 2,
        Suffix = "x",
        Callback = function(value) end,
    })

    -- ═══ UI Settings ═══
    local uiSection = tab:CreateSection("Interface")

    uiSection:AddKeybind({
        Text = "Toggle UI Keybind",
        Default = Enum.KeyCode.RightControl,
        ChangedCallback = function(key)
            print("[CUZAO] Keybind alterado: " .. key.Name)
        end,
    })

    uiSection:AddSlider({
        Text = "UI Transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Show Notifications",
        Default = true,
        Callback = function(value) end,
    })

    uiSection:AddSlider({
        Text = "Notification Duration",
        Min = 1,
        Max = 10,
        Default = 4,
        Suffix = "s",
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Blur Background",
        Default = false,
        Callback = function(value) end,
    })

    uiSection:AddToggle({
        Text = "Start Minimized",
        Default = false,
        Callback = function(value) end,
    })

    -- ═══ Execution ═══
    local execSection = tab:CreateSection("Execução")

    execSection:AddDropdown({
        Text = "Executor",
        Options = {"Auto Detect", "Synapse X", "Script-Ware", "Fluxus", "Delta", "Hydrogen", "Arceus X", "Solara"},
        Default = "Auto Detect",
        Callback = function(value) end,
    })

    execSection:AddToggle({
        Text = "Auto Execute on Join",
        Default = false,
        Callback = function(value) end,
    })

    execSection:AddToggle({
        Text = "Anti-Cheat Bypass",
        Default = true,
        Callback = function(value) end,
    })

    -- ═══ Key System ═══
    local keySection = tab:CreateSection("Key System")

    keySection:AddToggle({
        Text = "Enable Key System",
        Default = false,
        Callback = function(value) end,
    })

    keySection:AddDropdown({
        Text = "Key Provider",
        Options = {"None", "Linkvertise", "LootLabs", "Custom"},
        Default = "None",
        Callback = function(value) end,
    })

    keySection:AddInput({
        Text = "Custom Key",
        Placeholder = "Enter your key",
        Default = "",
        Callback = function(value) end,
    })

    -- ═══ Config Management ═══
    local configSection = tab:CreateSection("Configurações")

    configSection:AddDropdown({
        Text = "Preset",
        Options = {"Default", "Aggressive", "Passive", "Custom"},
        Default = "Default",
        Callback = function(value) end,
    })

    configSection:AddButton({
        Text = "💾 Salvar Configurações",
        Callback = function()
            print("[CUZAO] Config salva!")
        end,
    })

    configSection:AddButton({
        Text = "📂 Carregar Configurações",
        Callback = function()
            print("[CUZAO] Config carregada!")
        end,
    })

    configSection:AddButton({
        Text = "🔄 Resetar Configurações",
        Callback = function()
            print("[CUZAO] Config resetada!")
        end,
    })

    configSection:AddButton({
        Text = "📋 Exportar Config",
        Callback = function()
            print("[CUZAO] Exportando config...")
        end,
    })

    -- ═══ About ═══
    local aboutSection = tab:CreateSection("Sobre")

    aboutSection:AddParagraph({
        Title = "CUZAO HUB v1.0.0",
        Desc = "Script Hub premium para Blox Fruits\nDesenvolvido com ❤️",
    })

    aboutSection:AddButton({
        Text = "Discord Server",
        Callback = function()
            print("[CUZAO] Abrindo Discord...")
        end,
    })

    aboutSection:AddButton({
        Text = "GitHub",
        Callback = function()
            print("[CUZAO] Abrindo GitHub...")
        end,
    })

    aboutSection:AddButton({
        Text = "Check for Updates",
        Callback = function()
            print("[CUZAO] Verificando atualizações...")
        end,
    })

    return tab
end

return SettingsTab