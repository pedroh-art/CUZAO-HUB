--!strict
--[[
    CUZAO HUB - Teleport Tab
    Teleporte para ilhas, NPCs, jogadores e waypoints
    Com detecção automática de Sea (1º, 2º, 3º)
]]

local TeleportTab = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function GetLocalCharacter()
    local plr = Players.LocalPlayer
    if plr and plr.Character then
        return plr.Character
    end
    return nil
end

local function GetRootPart()
    local char = GetLocalCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function TeleportToPosition(position, useTween, tweenSpeed)
    local rootPart = GetRootPart()
    if not rootPart then
        warn("[CUZAO] Personagem não encontrado!")
        return false
    end

    if useTween then
        -- Tween suave (mais difícil de detectar)
        local distance = (position - rootPart.Position).Magnitude
        local duration = distance / (tweenSpeed or 300)

        -- Primeiro vai pra cima pra evitar obstáculos
        local highPos = Vector3.new(position.X, math.max(position.Y, rootPart.Position.Y) + 50, position.Z)
        local tweenUp = TweenService:Create(rootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(highPos)
        })
        tweenUp:Play()
        tweenUp.Completed:Wait()

        -- Depois desce pro destino
        local tweenDown = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(position)
        })
        tweenDown:Play()
        tweenDown.Completed:Wait()
    else
        -- TP direto
        rootPart.CFrame = CFrame.new(position)
    end

    return true
end

function TeleportTab.Build(window, Locations)
    local tab = window:CreateTab({ Name = "Teleport", Icon = "🗺️" })

    -- ═══ SEA INFO ═══
    local currentSea = 1
    if Locations then
        currentSea = Locations:GetCurrentSea()
    end
    local seaNames = { [1] = "1º Sea", [2] = "2º Sea", [3] = "3º Sea" }
    local seaName = seaNames[currentSea] or "Desconhecido"

    -- ═══ SEA STATUS ═══
    local seaSection = tab:CreateSection("Sea Atual")
    seaSection:AddParagraph({
        Title = "🌊 " .. seaName .. " detectado automaticamente",
        Desc = "As ilhas mostradas são do seu sea atual.",
    })

    -- ═══ SEA SELECTOR (manual override) ═══
    local overrideDropdown = seaSection:AddDropdown({
        Text = "Override Sea",
        Options = {"Auto (detectar)", "1º Sea", "2º Sea", "3º Sea"},
        Default = "Auto (detectar)",
        Callback = function(value)
            if Locations then
                if value == "Auto (detectar)" then
                    Locations:ClearSeaCache()
                    currentSea = Locations:GetCurrentSea()
                elseif value == "1º Sea" then
                    Locations:SetSea(1)
                    currentSea = 1
                elseif value == "2º Sea" then
                    Locations:SetSea(2)
                    currentSea = 2
                elseif value == "3º Sea" then
                    Locations:SetSea(3)
                    currentSea = 3
                end
                -- Atualizar ilhas no dropdown
                if RefreshIslands then
                    RefreshIslands()
                end
                print("[CUZAO] Sea: " .. (seaNames[currentSea] or "?"))
            end
        end,
    })

    -- ═══ ISLAND TELEPORT ═══
    local islandSection = tab:CreateSection("Teleporte por Ilha")

    local selectedIsland = nil
    local islandDropdown = nil

    local function GetIslandNames()
        if Locations then
            return Locations:GetCurrentIslandNames()
        end
        -- Fallback hardcoded
        return {
            "Starter Island", "Marine Fortress", "Jungle",
            "Pirate Village", "Desert", "Frozen Village",
        }
    end

    local islandNames = GetIslandNames()
    if #islandNames == 0 then
        islandNames = {"Nenhuma ilha encontrada"}
    end

    islandDropdown = islandSection:AddDropdown({
        Text = "Ilha",
        Options = islandNames,
        Default = islandNames[1] or "Nenhuma",
        Callback = function(value)
            selectedIsland = value
        end,
    })

    -- Função refresh (chamada quando muda o sea)
    function RefreshIslands()
        islandNames = GetIslandNames()
        if #islandNames == 0 then
            islandNames = {"Nenhuma ilha encontrada"}
        end
        selectedIsland = islandNames[1]
        if islandDropdown and islandDropdown.Refresh then
            islandDropdown:Refresh(islandNames)
        end
    end

    local useTween = true
    local tweenSpeed = 300

    islandSection:AddButton({
        Text = "🚀 Teleportar",
        Callback = function()
            if not selectedIsland or selectedIsland == "Nenhuma ilha encontrada" then
                print("[CUZAO] Nenhuma ilha selecionada!")
                return
            end

            -- Buscar posição da ilha
            local position = nil
            if Locations then
                local seaIslands = Locations:GetCurrentSeaIslands()
                if seaIslands and seaIslands[selectedIsland] then
                    position = seaIslands[selectedIsland].Position
                end
            end

            if position then
                print("[CUZAO] Teleportando para " .. selectedIsland .. "...")
                TeleportToPosition(position, useTween, tweenSpeed)
                print("[CUZAO] Chegou em " .. selectedIsland .. "!")
            else
                print("[CUZAO] Posição não encontrada para: " .. selectedIsland)
            end
        end,
    })

    islandSection:AddToggle({
        Text = "Tween (suave)",
        Default = true,
        Callback = function(value)
            useTween = value
        end,
    })

    islandSection:AddSlider({
        Text = "Velocidade",
        Min = 50,
        Max = 500,
        Default = 300,
        Suffix = " studs/s",
        Callback = function(value)
            tweenSpeed = value
        end,
    })

    -- ═══ NPC TELEPORT ═══
    local npcSection = tab:CreateSection("Teleporte NPC")

    local npcsForSea = {
        [1] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Haki Trainer", "Sword Dealer", "Gun Dealer",
            "Fighting Style Teacher",
        },
        [2] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Awakening Expert", "Blacksmith",
            "Bartilo", "Mysterious Dealer",
            "Law Raid",
        },
        [3] = {
            "Blox Fruit Dealer", "Blox Fruit Dealer Cousin",
            "Awakening Expert", "Blacksmith",
            "Sword Dealer", "Gun Dealer",
            "Haki Trainer", "Title Hunter",
            "Factory Core",
        },
    }

    local function GetCurrentNPCs()
        return npcsForSea[currentSea] or npcsForSea[1]
    end

    local selectedNPC = nil
    local npcDropdown = npcSection:AddDropdown({
        Text = "NPC",
        Options = GetCurrentNPCs(),
        Default = GetCurrentNPCs()[1] or "Blox Fruit Dealer",
        Callback = function(value)
            selectedNPC = value
        end,
    })

    npcSection:AddButton({
        Text = "🚀 Teleportar para NPC",
        Callback = function()
            if not selectedNPC then return end

            if Locations then
                local npcPos = Locations.NPCs[selectedNPC]
                if npcPos then
                    print("[CUZAO] TP para NPC: " .. selectedNPC)
                    TeleportToPosition(npcPos, useTween, tweenSpeed)
                else
                    print("[CUZAO] NPC não encontrado: " .. selectedNPC)
                end
            end
        end,
    })

    -- ═══ PLAYER TELEPORT ═══
    local playerSection = tab:CreateSection("Teleporte Jogador")

    local playerNames = {}
    local selectedPlayer = nil

    local function RefreshPlayerList()
        playerNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(playerNames, plr.Name)
            end
        end
        if #playerNames == 0 then
            playerNames = {"Nenhum jogador"}
        end
        return playerNames
    end

    RefreshPlayerList()

    local playerDropdown = playerSection:AddDropdown({
        Text = "Jogador",
        Options = playerNames,
        Default = playerNames[1] or "Nenhum",
        Callback = function(value)
            selectedPlayer = value
        end,
    })

    playerSection:AddButton({
        Text = "🚀 Teleportar para Jogador",
        Callback = function()
            if not selectedPlayer or selectedPlayer == "Nenhum jogador" then return end

            local targetPlr = Players:FindFirstChild(selectedPlayer)
            if targetPlr and targetPlr.Character then
                local targetRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    print("[CUZAO] TP para " .. selectedPlayer)
                    TeleportToPosition(targetRoot.Position + Vector3.new(0, 5, 0), useTween, tweenSpeed)
                end
            end
        end,
    })

    playerSection:AddButton({
        Text = "🔄 Atualizar Lista",
        Callback = function()
            RefreshPlayerList()
            if playerDropdown and playerDropdown.Refresh then
                playerDropdown:Refresh(playerNames)
            end
            print("[CUZAO] Lista atualizada!")
        end,
    })

    playerSection:AddToggle({
        Text = "Auto Refresh",
        Default = false,
        Callback = function(value)
            -- Placeholder: auto refresh loop
            print("[CUZAO] Auto Refresh: " .. tostring(value))
        end,
    })

    -- Auto refresh on player join/leave
    Players.PlayerAdded:Connect(function()
        task.wait(1)
        RefreshPlayerList()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(playerNames)
        end
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.5)
        RefreshPlayerList()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(playerNames)
        end
    end)

    -- ═══ WAYPOINT TELEPORT ═══
    local wpSection = tab:CreateSection("Waypoints")

    wpSection:AddInput({
        Text = "X",
        Placeholder = "Coordenada X",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddInput({
        Text = "Y",
        Placeholder = "Coordenada Y",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddInput({
        Text = "Z",
        Placeholder = "Coordenada Z",
        Default = "0",
        Callback = function(value) end,
    })

    wpSection:AddButton({
        Text = "🚀 Teleportar para Waypoint",
        Callback = function()
            local root = GetRootPart()
            if root then
                print("[CUZAO] Posição atual: " .. tostring(root.Position))
            end
        end,
    })

    wpSection:AddButton({
        Text = "📋 Copiar Posição Atual",
        Callback = function()
            local root = GetRootPart()
            if root then
                local pos = root.Position
                local text = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
                if setclipboard then
                    setclipboard(text)
                end
                print("[CUZAO] Posição copiada: " .. text)
            end
        end,
    })

    -- ═══ AUTO TELEPORT ═══
    local autoTP = tab:CreateSection("Auto TP")

    autoTP:AddToggle({
        Text = "Auto TP to Quest",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto TP Quest: " .. tostring(value))
        end,
    })

    autoTP:AddToggle({
        Text = "Auto TP to Mob",
        Default = false,
        Callback = function(value)
            print("[CUZAO] Auto TP Mob: " .. tostring(value))
        end,
    })

    autoTP:AddToggle({
        Text = "Safe Teleport (avoid void)",
        Default = true,
        Callback = function(value) end,
    })

    autoTP:AddSlider({
        Text = "Safe TP Height",
        Min = 50,
        Max = 300,
        Default = 100,
        Suffix = " studs",
        Callback = function(value) end,
    })

    -- ═══ FISHMAN ISLAND (acesso especial) ═══
    if currentSea == 2 or currentSea == 3 then
        local specialSection = tab:CreateSection("Locais Especiais")

        specialSection:AddButton({
            Text = "🏝️ Teleport to Underwater City",
            Callback = function()
                if Locations then
                    local pos = Locations.Sea1["Underwater City"]
                    if pos then
                        TeleportToPosition(pos.Position, useTween, tweenSpeed)
                    end
                end
            end,
        })

        if currentSea == 3 then
            specialSection:AddButton({
                Text = "🏝️ Teleport to Floating Turtle",
                Callback = function()
                    local pos = Vector3.new(-12550, 334, -7380)
                    TeleportToPosition(pos, useTween, tweenSpeed)
                end,
            })

            specialSection:AddButton({
                Text = "🏝️ Teleport to Haunted Castle",
                Callback = function()
                    local pos = Vector3.new(-9515, 142, 5545)
                    TeleportToPosition(pos, useTween, tweenSpeed)
                end,
            })
        end
    end

    return tab
end

return TeleportTab