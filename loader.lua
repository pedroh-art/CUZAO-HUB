--[[
    ╔═══════════════════════════════════════════════════╗
    ║           CUZAO HUB - Main Loader                ║
    ║   Script Hub premium para Blox Fruits            ║
    ║   Versão: 1.0.0                                  ║
    ╚═══════════════════════════════════════════════════╝

    Uso:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/loader.lua"))()
]]

-- Splash screen rápido
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CUZAO_Splash"
ScreenGui.DisplayOrder = 9999
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 100)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Frame)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 1.5

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "CUZAO HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundTransparency = 1
Status.Text = "Baixando script..."
Status.TextColor3 = Color3.fromRGB(160, 160, 160)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.8, 0, 0, 4)
BarBg.Position = UDim2.new(0.1, 0, 0, 78)
BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BarBg.BorderSizePixel = 0
BarBg.Parent = Frame
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0.3, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Bar.BorderSizePixel = 0
Bar.Parent = BarBg
Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

-- Animação da barra (sem TweenService dependency)
task.spawn(function()
    while Bar and Bar.Parent do
        for i = 0.3, 0.9, 0.05 do
            if not Bar or not Bar.Parent then break end
            Bar.Size = UDim2.new(i, 0, 1, 0)
            task.wait(0.05)
        end
        for i = 0.9, 0.3, -0.05 do
            if not Bar or not Bar.Parent then break end
            Bar.Size = UDim2.new(i, 0, 1, 0)
            task.wait(0.05)
        end
    end
end)

-- ═══════════════════════════════════════════
-- BUNDLE LOADER
-- ═══════════════════════════════════════════
local BUNDLE_URL = "https://raw.githubusercontent.com/pedroh-art/CUZAO-HUB/main/cuzao_all.lua"

local function LoadAndRun()
    Status.Text = "Baixando CUZAO HUB..."
    Bar.Size = UDim2.new(0.5, 0, 1, 0)

    -- Tentar cache primeiro
    local source = nil
    if readfile and isfile and isfile("cuzao_all.lua") then
        local cached = readfile("cuzao_all.lua")
        if cached and cached ~= "" and #cached > 1000 then
            source = cached
            Status.Text = "Carregando do cache..."
        end
    end

    -- Baixar do GitHub se não tem cache
    if not source then
        local ok, content = pcall(function()
            return game:HttpGet(BUNDLE_URL, true)
        end)
        if ok and content and #content > 1000 then
            source = content
            if writefile then
                pcall(writefile, "cuzao_all.lua", source)
            end
            Status.Text = "Download completo!"
        end
    end

    if source then
        Bar.Size = UDim2.new(1, 0, 1, 0)
        Status.Text = "Carregando..."

        local fn, err = loadstring(source)
        if fn then
            -- Destruir splash antes de rodar
            task.wait(0.2)
            pcall(function() ScreenGui:Destroy() end)
            fn()
        else
            warn("[CUZAO] Erro ao compilar: " .. tostring(err))
            Status.Text = "Erro: " .. tostring(err)
            task.wait(3)
            pcall(function() ScreenGui:Destroy() end)
        end
    else
        warn("[CUZAO] Falha ao baixar o script!")
        Status.Text = "Falha ao baixar! Verifique sua internet."
        task.wait(3)
        pcall(function() ScreenGui:Destroy() end)
    end
end

LoadAndRun()
