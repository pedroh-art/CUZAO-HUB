--[[
    CUZAO HUB - Core Services Module
    Centraliza todos os serviços do Roblox para acesso fácil
]]

local Services = {}

-- Serviços Principais
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.RunService = game:GetService("RunService")
Services.TweenService = game:GetService("TweenService")
Services.HttpService = game:GetService("HttpService")
Services.UserInputService = game:GetService("UserInputService")
Services.Lighting = game:GetService("Lighting")
Services.SoundService = game:GetService("SoundService")
Services.VirtualUser = game:GetService("VirtualUser")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.CoreGui = game:GetService("CoreGui")
Services.StarterGui = game:GetService("StarterGui")
Services.StarterPlayer = game:GetService("StarterPlayer")
Services.TeleportService = game:GetService("TeleportService")
Services.MarketplaceService = game:GetService("MarketplaceService")
Services.PathfindingService = game:GetService("PathfindingService")
Services.PhysicsService = game:GetService("PhysicsService")
Services.LocalizationService = game:GetService("LocalizationService")
Services.TextChatService = game:GetService("TextChatService")

-- Referências Comuns
Services.LocalPlayer = Services.Players.LocalPlayer
Services.Camera = Services.Workspace.CurrentCamera
Services.Mouse = Services.LocalPlayer:GetMouse()

-- Remotes Comuns do Blox Fruits
Services.Remotes = {}
Services.Remotes.CommF_ = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
Services.Remotes.CommE = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")

-- Net Modules (para comunicação cliente-servidor)
Services.Net = {}
local NetFolder = Services.ReplicatedStorage:WaitForChild("Net")
if NetFolder then
    Services.Net.Fruit = NetFolder:FindFirstChild("Fruit")
    Services.Net.Weapon = NetFolder:FindFirstChild("Weapon")
    Services.Net.Combat = NetFolder:FindFirstChild("Combat")
end

-- Módulos do Jogo
Services.Modules = {}
local ModulesFolder = Services.ReplicatedStorage:WaitForChild("Modules")
if ModulesFolder then
    Services.Modules.Fruit = ModulesFolder:FindFirstChild("Fruit")
    Services.Modules.Weapon = ModulesFolder:FindFirstChild("Weapon")
    Services.Modules.Combat = ModulesFolder:FindFirstChild("Combat")
    Services.Modules.Quest = ModulesFolder:FindFirstChild("Quest")
end

-- Dados do Jogador
Services.PlayerData = {}
Services.PlayerData.Stats = Services.LocalPlayer:WaitForChild("Data"):WaitForChild("Stats")
Services.PlayerData.Level = Services.PlayerData.Stats:WaitForChild("Level")
Services.PlayerData.Beli = Services.PlayerData.Stats:WaitForChild("Beli")
Services.PlayerData.Fragments = Services.PlayerData.Stats:WaitForChild("Fragments")
Services.PlayerData.DevilFruit = Services.PlayerData.Stats:WaitForChild("DevilFruit")
Services.PlayerData.Melee = Services.PlayerData.Stats:WaitForChild("Melee")
Services.PlayerData.Defense = Services.PlayerData.Stats:WaitForChild("Defense")
Services.PlayerData.Sword = Services.PlayerData.Stats:WaitForChild("Sword")
Services.PlayerData.Gun = Services.PlayerData.Stats:WaitForChild("Gun")
Services.PlayerData.Fruit = Services.PlayerData.Stats:WaitForChild("Fruit")

-- Configurações do Personagem
Services.Character = Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait()
Services.Humanoid = Services.Character:WaitForChild("Humanoid")
Services.HumanoidRootPart = Services.Character:WaitForChild("HumanoidRootPart")

-- Atualizar referências quando personagem respawna
Services.LocalPlayer.CharacterAdded:Connect(function(char)
    Services.Character = char
    Services.Humanoid = char:WaitForChild("Humanoid")
    Services.HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Utilitário para pegar remote com segurança
function Services:GetRemote(name, parent)
    parent = parent or Services.ReplicatedStorage.Remotes
    local remote = parent:FindFirstChild(name)
    if not remote then
        warn("[Services] Remote não encontrado: " .. name)
    end
    return remote
end

-- Utilitário para invocar CommF_ com segurança
function Services:CommF_(...)
    local args = {...}
    local success, result = pcall(function()
        return Services.Remotes.CommF_:InvokeServer(unpack(args))
    end)
    if not success then
        warn("[Services] CommF_ falhou: " .. tostring(result))
    end
    return success, result
end

-- Utilitário para disparar CommE com segurança
function Services:CommE(...)
    local args = {...}
    local success, result = pcall(function()
        return Services.Remotes.CommE:FireServer(unpack(args))
    end)
    if not success then
        warn("[Services] CommE falhou: " .. tostring(result))
    end
    return success, result
end

return Services