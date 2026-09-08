--[[
    CUZAO HUB - Combat Module
    Funções de combate: attack, aim, skills, haki, ken
]]

local Combat = {}

-- Serviços
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

-- Estado
Combat.AutoClickerEnabled = false
Combat.AutoClickerConnection = nil
Combat.AimBotEnabled = false
Combat.AimBotConnection = nil
Combat.KillAuraEnabled = false
Combat.KillAuraConnection = nil
Combat.SkillSpamEnabled = false
Combat.SkillSpamConnection = nil
Combat.AutoHakiEnabled = false
Combat.AutoKenEnabled = false
Combat.KenConnection = nil

-- Configurações
Combat.Config = {
    AutoClicker = { Delay = 0.05, RightClick = false },
    AimBot = { FOV = 100, Smoothness = 0.5, TargetPart = "Head", TeamCheck = true, WallCheck = true, Prediction = 0.1 },
    KillAura = { Range = 30, TargetPlayers = false, TargetMobs = true, AttackDelay = 0.1 },
    SkillSpam = { Skills = {Z = true, X = true, C = true, V = false, F = false}, Delay = 0.5 },
    AutoHaki = true,
    AutoKen = false,
    KenDuration = 5,
}

-- ========== AUTO CLICKER ==========

function Combat:StartAutoClicker(config)
    config = config or self.Config.AutoClicker
    self:StopAutoClicker()

    self.AutoClickerEnabled = true
    self.AutoClickerConnection = RunService.Heartbeat:Connect(function()
        if not self.AutoClickerEnabled then return end

        local character = LocalPlayer.Character
        if not character then return end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            -- Tentar equipar arma do backpack
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                tool = backpack:FindFirstChildOfClass("Tool")
                if tool then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then humanoid:EquipTool(tool) end
                end
            end
        end

        if tool then
            if config.RightClick then
                tool:Activate()
            else
                -- Simular click esquerdo
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end

        task.wait(config.Delay)
    end)
end

function Combat:StopAutoClicker()
    self.AutoClickerEnabled = false
    if self.AutoClickerConnection then
        self.AutoClickerConnection:Disconnect()
        self.AutoClickerConnection = nil
    end
end

function Combat:SetAutoClickerDelay(delay)
    self.Config.AutoClicker.Delay = delay
end

-- ========== AIM BOT ==========

Combat.AimBotTarget = nil

function Combat:GetAimBotTarget(config)
    config = config or self.Config.AimBot
    local camera = Workspace.CurrentCamera
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not camera or not rootPart then return nil end

    local nearest = nil
    local shortestDistance = config.FOV
    local mousePos = UserInputService:GetMouseLocation()

    -- Verificar jogadores
    if config.TargetPlayers ~= false then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if config.TeamCheck and player.Team == LocalPlayer.Team then continue end

                local targetPart = player.Character:FindFirstChild(config.TargetPart)
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDistance then
                            -- Wall check
                            if config.WallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {character, player.Character}
                                local rayResult = Workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 500, rayParams)
                                if rayResult and rayResult.Instance:IsDescendantOf(player.Character) then
                                    -- Parede na frente, pular
                                else
                                    shortestDistance = dist
                                    nearest = {Player = player, Part = targetPart, ScreenPos = screenPos}
                                end
                            else
                                shortestDistance = dist
                                nearest = {Player = player, Part = targetPart, ScreenPos = screenPos}
                            end
                        end
                    end
                end
            end
        end
    end

    -- Verificar mobs
    if config.TargetMobs ~= false then
        local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in ipairs(mobsFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    local targetPart = mob:FindFirstChild(config.TargetPart) or mob:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortestDistance then
                                if config.WallCheck then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    rayParams.FilterDescendantsInstances = {character, mob}
                                    local rayResult = Workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 500, rayParams)
                                    if rayResult and rayResult.Instance:IsDescendantOf(mob) then
                                    else
                                        shortestDistance = dist
                                        nearest = {Mob = mob, Part = targetPart, ScreenPos = screenPos}
                                    end
                                else
                                    shortestDistance = dist
                                    nearest = {Mob = mob, Part = targetPart, ScreenPos = screenPos}
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nearest
end

function Combat:StartAimBot(config)
    config = config or self.Config.AimBot
    self:StopAimBot()

    self.AimBotEnabled = true
    self.AimBotConnection = RunService.RenderStepped:Connect(function()
        if not self.AimBotEnabled then return end

        local target = self:GetAimBotTarget(config)
        if target and target.Part then
            self.AimBotTarget = target

            local camera = Workspace.CurrentCamera
            local targetPos = target.Part.Position

            -- Prediction
            if config.Prediction and config.Prediction > 0 then
                local velocity = target.Part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                targetPos = targetPos + velocity * config.Prediction
            end

            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)

            if config.Mode == "Silent" then
                -- Silent aim: apenas modificar onde a bala vai (precisa de hook no remote)
                -- Por enquanto, apenas rotação da câmera
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, config.Smoothness)
            elseif config.Mode == "Legit" then
                -- Legit aim: mover mouse suavemente
                local currentCFrame = camera.CFrame
                camera.CFrame = currentCFrame:Lerp(targetCFrame, config.Smoothness)
            elseif config.Mode == "FOV" then
                -- Apenas mostrar FOV, não aimar automaticamente
            end
        else
            self.AimBotTarget = nil
        end
    end)
end

function Combat:StopAimBot()
    self.AimBotEnabled = false
    self.AimBotTarget = nil
    if self.AimBotConnection then
        self.AimBotConnection:Disconnect()
        self.AimBotConnection = nil
    end
end

-- ========== KILL AURA ==========

function Combat:StartKillAura(config)
    config = config or self.Config.KillAura
    self:StopKillAura()

    self.KillAuraEnabled = true
    self.KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not self.KillAuraEnabled then return end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local targets = {}

        -- Mobs
        if config.TargetMobs then
            local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
            if mobsFolder then
                for _, mob in ipairs(mobsFolder:GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mobRoot then
                            local dist = (rootPart.Position - mobRoot.Position).Magnitude
                            if dist <= config.Range then
                                table.insert(targets, {Model = mob, RootPart = mobRoot, Distance = dist, Type = "Mob"})
                            end
                        end
                    end
                end
            end
        end

        -- Players
        if config.TargetPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if player.Team == LocalPlayer.Team then continue end
                    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if playerRoot and humanoid and humanoid.Health > 0 then
                        local dist = (rootPart.Position - playerRoot.Position).Magnitude
                        if dist <= config.Range then
                            table.insert(targets, {Model = player.Character, RootPart = playerRoot, Distance = dist, Type = "Player"})
                        end
                    end
                end
            end
        end

        -- Ordenar por distância
        table.sort(targets, function(a, b) return a.Distance < b.Distance end)

        -- Atacar alvos
        for _, target in ipairs(targets) do
            self:AttackTarget(target.Model)
            task.wait(config.AttackDelay)
        end
    end)
end

function Combat:StopKillAura()
    self.KillAuraEnabled = false
    if self.KillAuraConnection then
        self.KillAuraConnection:Disconnect()
        self.KillAuraConnection = nil
    end
end

-- ========== ATTACK TARGET ==========

function Combat:AttackTarget(targetModel)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetModel:FindFirstChild("Humanoid")

    if not humanoid or not rootPart or not targetRoot or not targetHumanoid then return end
    if targetHumanoid.Health <= 0 then return end

    -- Olhar para o alvo
    rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z))

    -- Equipar arma se necessário
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            tool = backpack:FindFirstChildOfClass("Tool")
            if tool and humanoid then humanoid:EquipTool(tool) end
        end
    end

    -- Atacar
    if tool then
        tool:Activate()
    else
        -- Click vazio
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- ========== SKILLS ==========

Combat.SkillKeys = {
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
    F = Enum.KeyCode.F,
}

function Combat:UseSkill(skillKey)
    local keyCode = self.SkillKeys[skillKey]
    if not keyCode then return false end

    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    return true
end

function Combat:StartSkillSpam(config)
    config = config or self.Config.SkillSpam
    self:StopSkillSpam()

    self.SkillSpamEnabled = true
    self.SkillSpamConnection = RunService.Heartbeat:Connect(function()
        if not self.SkillSpamEnabled then return end

        for skill, enabled in pairs(config.Skills) do
            if enabled then
                self:UseSkill(skill)
                task.wait(config.Delay)
            end
        end

        task.wait(config.Delay)
    end)
end

function Combat:StopSkillSpam()
    self.SkillSpamEnabled = false
    if self.SkillSpamConnection then
        self.SkillSpamConnection:Disconnect()
        self.SkillSpamConnection = nil
    end
end

-- ========== HAKI ==========

function Combat:EnableBusoHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Buso")
    end)
    return success
end

function Combat:DisableBusoHaki()
    -- Buso é toggle, chamar novamente desativa
    return self:EnableBusoHaki()
end

function Combat:IsBusoActive()
    local character = LocalPlayer.Character
    if not character then return false end

    for _, child in ipairs(character:GetChildren()) do
        if child.Name:lower():find("haki") or child.Name:lower():find("buso") then
            return true
        end
    end
    return false
end

function Combat:StartAutoHaki()
    if self.AutoHakiEnabled then return end
    self.AutoHakiEnabled = true

    task.spawn(function()
        while self.AutoHakiEnabled do
            if not self:IsBusoActive() then
                self:EnableBusoHaki()
            end
            task.wait(1)
        end
    end)
end

function Combat:StopAutoHaki()
    self.AutoHakiEnabled = false
end

-- ========== KEN HAKI ==========

function Combat:EnableKenHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Ken", true)
    end)
    return success
end

function Combat:DisableKenHaki()
    local success = pcall(function()
        CommF_:InvokeServer("Ken", false)
    end)
    return success
end

function Combat:IsKenActive()
    local character = LocalPlayer.Character
    if not character then return false end

    for _, child in ipairs(character:GetChildren()) do
        if child.Name:lower():find("ken") then
            return true
        end
    end
    return false
end

function Combat:StartAutoKen(config)
    config = config or self.Config
    if self.AutoKenEnabled then return end
    self.AutoKenEnabled = true

    task.spawn(function()
        while self.AutoKenEnabled do
            if not self:IsKenActive() then
                self:EnableKenHaki()
                task.wait(config.KenDuration or 5)
                self:DisableKenHaki()
            end
            task.wait(1)
        end
    end)
end

function Combat:StopAutoKen()
    self.AutoKenEnabled = false
    self:DisableKenHaki()
end

-- ========== WEAPON MANAGEMENT ==========

function Combat:GetEquippedWeapon()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
end

function Combat:GetWeaponType(tool)
    tool = tool or self:GetEquippedWeapon()
    if not tool then return "None" end

    local name = tool.Name:lower()
    if name:find("sword") or name:find("katana") or name:find("blade") or name:find("cutter") then
        return "Sword"
    elseif name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("cannon") then
        return "Gun"
    elseif name:find("fruit") or tool:FindFirstChild("Fruit") then
        return "Fruit"
    else
        return "Melee"
    end
end

function Combat:EquipBestWeapon(preferredType)
    preferredType = preferredType or "Melee"
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not backpack or not humanoid then return false end

    local bestTool = nil
    local bestPriority = 0

    -- Prioridades por tipo
    local priorities = {
        Melee = {"Superhuman", "Death Step", "Electric Claw", "Dragon Talon", "Godhuman", "Sharkman Karate", "Combat", "Black Leg", "Fishman Karate", "Electro", "Dark Step"},
        Sword = {"Cursed Dual Katana", "Tushita", "Yama", "Hallow Scythe", "Saber", "Buddy Sword", "Canvander", "Dual Katana", "Iron Mace", "Triple Katana", "Pipe", "Dual-Headed Blade", "Bisento", "Soul Cane", "Katana", "Cutlass"},
        Gun = {"Acidum Rifle", "Serpent Bow", "Kabucha", "Soul Guitar", "Bazooka", "Cannon", "Musket", "Flintlock", "Slingshot"},
        Fruit = {}, -- Frutas são equipadas automaticamente
    }

    local weaponList = priorities[preferredType] or priorities.Melee

    for _, weaponName in ipairs(weaponList) do
        local tool = backpack:FindFirstChild(weaponName) or (character and character:FindFirstChild(weaponName))
        if tool then
            bestTool = tool
            break
        end
    end

    if bestTool then
        humanoid:EquipTool(bestTool)
        return true
    end

    return false
end

-- ========== TARGET SELECTION ==========

function Combat:GetBestTarget(config)
    config = config or {}
    local range = config.Range or 50
    local targetPlayers = config.TargetPlayers ~= false
    local targetMobs = config.TargetMobs ~= false
    local teamCheck = config.TeamCheck ~= false

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local bestTarget = nil
    local bestScore = -math.huge

    -- Função de score
    local function evaluateTarget(model, targetType)
        local humanoid = model:FindFirstChild("Humanoid")
        local targetRoot = model:FindFirstChild("HumanoidRootPart")
        if not humanoid or not targetRoot or humanoid.Health <= 0 then return -1 end

        local dist = (rootPart.Position - targetRoot.Position).Magnitude
        if dist > range then return -1 end

        -- Score baseado em distância (mais perto = melhor) e vida (menos vida = melhor para kill)
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local score = (1 - dist / range) * 0.7 + (1 - healthPercent) * 0.3

        return score
    end

    if targetMobs then
        local mobsFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in ipairs(mobsFolder:GetChildren()) do
                if mob:IsA("Model") then
                    local score = evaluateTarget(mob, "Mob")
                    if score > bestScore then
                        bestScore = score
                        bestTarget = {Model = mob, Type = "Mob"}
                    end
                end
            end
        end
    end

    if targetPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if teamCheck and player.Team == LocalPlayer.Team then continue end
                local score = evaluateTarget(player.Character, "Player")
                if score > bestScore then
                    bestScore = score
                    bestTarget = {Model = player.Character, Type = "Player", Player = player}
                end
            end
        end
    end

    return bestTarget
end

-- ========== CLEANUP ==========

function Combat:Cleanup()
    self:StopAutoClicker()
    self:StopAimBot()
    self:StopKillAura()
    self:StopSkillSpam()
    self:StopAutoHaki()
    self:StopAutoKen()
end

return Combat