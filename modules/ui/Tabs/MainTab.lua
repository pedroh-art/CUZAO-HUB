--!strict
--[[
    CUZAO HUB - Main Tab
    Informações do hub, status do jogador, botões rápidos
]]

local MainTab = {}

local Players = game:GetService("Players")

function MainTab.Build(window)
    local CUZAO = getgenv().CUZAO
    local tab = window:CreateTab({ Name = "Main", Icon = "🏠" })

    -- ═══ Hub Info ═══
    local infoSection = tab:CreateSection("Informações")
    infoSection:AddParagraph({
        Title = "CUZAO HUB v1.0.0",
        Desc = "Script Hub premium para Blox Fruits",
    })

    infoSection:AddParagraph({
        Title = "Executor",
        Desc = (identifyexecutor and identifyexecutor() or "Desconhecido"),
    })

    -- ═══ Status do Jogador ═══
    local statusSection = tab:CreateSection("Status do Jogador")

    local levelText = statusSection:AddParagraph({
        Title = "📊 Level",
        Desc = "Carregando...",
    })

    local beliText = statusSection:AddParagraph({
        Title = "💰 Beli",
        Desc = "Carregando...",
    })

    local fragText = statusSection:AddParagraph({
        Title = "💎 Fragments",
        Desc = "Carregando...",
    })

    local fruitText = statusSection:AddParagraph({
        Title = "🍎 Fruit Atual",
        Desc = "Carregando...",
    })

    local raceText = statusSection:AddParagraph({
        Title = "🧬 Race",
        Desc = "Carregando...",
    })

    local seaText = statusSection:AddParagraph({
        Title = "🌊 Sea",
        Desc = "Carregando...",
    })

    local weaponText = statusSection:AddParagraph({
        Title = "⚔️ Arma Equipada",
        Desc = "Carregando...",
    })

    -- Atualizar info a cada 2 segundos
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                local plr = Players.LocalPlayer
                local data = plr:FindFirstChild("Data")

                if data then
                    local level = data:FindFirstChild("Level")
                    local beli = data:FindFirstChild("Beli")
                    local frag = data:FindFirstChild("Fragments")
                    local race = data:FindFirstChild("Race")

                    if levelText and levelText.SetDesc then
                        levelText:SetDesc(tostring(level and level.Value or "?"))
                    end
                    if beliText and beliText.SetDesc then
                        beliText:SetDesc(tostring(beli and beli.Value or "?"))
                    end
                    if fragText and fragText.SetDesc then
                        fragText:SetDesc(tostring(frag and frag.Value or "?"))
                    end
                    if raceText and raceText.SetDesc then
                        raceText:SetDesc(tostring(race and race.Value or "?"))
                    end
                end

                -- Fruit
                if fruitText and fruitText.SetDesc then
                    local char = plr.Character
                    local fruitName = "Nenhuma"
                    if char then
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then
                                fruitName = tool.Name
                                break
                            end
                        end
                        if fruitName == "Nenhuma" then
                            for _, tool in pairs(plr.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then
                                    fruitName = tool.Name
                                    break
                                end
                            end
                        end
                    end
                    fruitText:SetDesc(fruitName)
                end

                -- Weapon
                if weaponText and weaponText.SetDesc then
                    local char = plr.Character
                    local wepName = "Nenhuma"
                    if char then
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") and tool.ToolTip ~= "Blox Fruit" then
                                wepName = tool.Name .. " (" .. tool.ToolTip .. ")"
                                break
                            end
                        end
                    end
                    weaponText:SetDesc(wepName)
                end

                -- Sea
                if seaText and seaText.SetDesc then
                    local Locations = CUZAO and CUZAO.Modules["Locations"]
                    if Locations then
                        seaText:SetDesc(Locations:GetCurrentSeaName())
                    else
                        seaText:SetDesc("Sea " .. tostring(CUZAO and CUZAO.Modules["Locations"] and CUZAO.Modules["Locations"]:GetCurrentSea() or "?"))
                    end
                end
            end)
        end
    end)

    -- ═══ Ações Rápidas ═══
    local quickSection = tab:CreateSection("Ações Rápidas")

    quickSection:AddButton({
        Text = "📋 Copiar Job ID",
        Callback = function()
            if setclipboard then
                setclipboard(tostring(game.JobId))
            end
        end,
    })

    quickSection:AddButton({
        Text = "🎯 Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
        end,
    })

    quickSection:AddButton({
        Text = "🔄 Server Hop",
        Callback = function()
            pcall(function()
                local HttpService = game:GetService("HttpService")
                local tpService = game:GetService("TeleportService")
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = game:HttpGet(url)
                local servers = HttpService:JSONDecode(response)
                if servers and servers.data then
                    for _, server in ipairs(servers.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            tpService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                            break
                        end
                    end
                end
            end)
        end,
    })

    quickSection:AddButton({
        Text = "🎫 Resgatar Todos os Códigos",
        Callback = function()
            pcall(function()
                local codes = {
                    "LIGHTNINGABUSE","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
                    "WildDares","BossBuild","GetPranked","EARN_FRUITS",
                    "SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
                    "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
                    "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
                    "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123",
                    "Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
                    "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN",
                    "ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle","NOEXPLOIT",
                    "NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares",
                }
                local RedeemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Redeem")
                if RedeemRemote then
                    for _, code in ipairs(codes) do
                        task.wait(0)
                        pcall(function()
                            if RedeemRemote.InvokeServer then
                                RedeemRemote:InvokeServer(code)
                            else
                                RedeemRemote:FireServer(code)
                            end
                        end)
                    end
                end
            end)
        end,
    })

    -- ═══ Status do Servidor ═══
    local serverSection = tab:CreateSection("Servidor")

    local serverInfo = serverSection:AddParagraph({
        Title = "👥 Jogadores",
        Desc = #Players:GetPlayers() .. "/" .. Players.MaxPlayers,
    })

    Players.PlayerAdded:Connect(function()
        if serverInfo and serverInfo.SetDesc then
            serverInfo:SetDesc(#Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.5)
        if serverInfo and serverInfo.SetDesc then
            serverInfo:SetDesc(#Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end
    end)

    serverSection:AddParagraph({
        Title = "🆔 Job ID",
        Desc = game.JobId ~= "" and game.JobId or "N/A",
    })

    return tab
end

return MainTab
