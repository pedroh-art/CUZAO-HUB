--!strict
--[[
    CUZAO HUB - Main Tab
    Informações do hub, status, botões rápidos, atualização
]]

local MainTab = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

function MainTab.Build(window)
    local tab = window:CreateTab({ Name = "Main", Icon = "🏠" })

    -- ═══ Hub Info ═══
    local infoSection = tab:CreateSection("Informações")
    infoSection:AddParagraph({
        Title = "CUZAO HUB",
        Desc = "Script Hub premium para Blox Fruits\nVersão: " .. (getgenv and getgenv().CUZAO_VERSION or "1.0.0"),
    })

    infoSection:AddParagraph({
        Title = "Status",
        Desc = "Conectado • Executor: " .. (identifyexecutor and identifyexecutor() or "N/A"),
    })

    infoSection:AddParagraph({
        Title = "Jogador",
        Desc = function()
            local plr = Players.LocalPlayer
            return plr.Name .. " | Level " .. (plr.Data and plr.Data.Level and plr.Data.Level.Value or "?")
        end,
    })

    -- ═══ Quick Actions ═══
    local quickSection = tab:CreateSection("Ações Rápidas")

    quickSection:AddButton({
        Text = "🔄 Reiniciar Script",
        Callback = function()
            -- Future: trigger loader restart
            print("[CUZAO] Reiniciando...")
        end,
    })

    quickSection:AddButton({
        Text = "📋 Copiar IP do Servidor",
        Callback = function()
            local ip = game.JobId
            if setclipboard then
                setclipboard(ip)
            end
        end,
    })

    quickSection:AddButton({
        Text = "🚪 Server Hop",
        Callback = function()
            local HttpService = game:GetService("HttpService")
            local tpService = game:GetService("TeleportService")
            local servers = HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        tpService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                        break
                    end
                end
            end
        end,
    })

    quickSection:AddButton({
        Text = "🎯 Rejoin Atual",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
        end,
    })

    -- ═══ Player Info ═══
    local playerSection = tab:CreateSection("Informações do Jogador")

    playerSection:AddParagraph({
        Title = "Fruit Atual",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Beli",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Fragments",
        Desc = "Verificando...",
    })

    playerSection:AddParagraph({
        Title = "Meios de Combate",
        Desc = "Verificando...",
    })

    -- Auto-refresh info
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(function()
                local plr = Players.LocalPlayer
                local data = plr:FindFirstChild("Data")
                if data then
                    local level = data:FindFirstChild("Level")
                    local beli = data:FindFirstChild("Beli")
                    local fragment = data:FindFirstChild("Fragments")

                    infoSection:SetTitle("Status")
                    -- Update paragraphs with real data
                end
            end)
        end
    end)

    return tab
end

return MainTab