--[[
    CUZAO HUB - Key System
    Sistema de chave opcional (Linkvertise, LootLabs, Custom)
]]

local KeySystem = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

KeySystem.Config = {
    Enabled = false,
    Provider = "Custom", -- "None", "Linkvertise", "LootLabs", "Custom"
    Key = "",
    HWID = nil,
    MaxDevices = 3,
    ServerURL = "",
    KeyLength = 16,
}

KeySystem.IsAuthenticated = false
KeySystem.Key = nil

-- ═══════════════════════════════════════════
-- HWID GENERATION
-- ═══════════════════════════════════════════
function KeySystem:GetHWID()
    if self.Config.HWID then return self.Config.HWID end

    local hwid = ""
    pcall(function()
        -- Try different executor methods
        if gethwid then
            hwid = gethwid()
        elseif getexecutorname then
            hwid = getexecutorname()
        else
            hwid = tostring(Players.LocalPlayer.UserId) .. "_" .. tostring(game.JobId):sub(1, 8)
        end
    end)

    self.Config.HWID = hwid
    return hwid
end

-- ═══════════════════════════════════════════
-- KEY VALIDATION
-- ═══════════════════════════════════════════
function KeySystem:ValidateKey(key)
    if not self.Config.Enabled then
        self.IsAuthenticated = true
        return true
    end

    if self.Config.Provider == "None" then
        self.IsAuthenticated = true
        return true
    end

    if self.Config.Provider == "Custom" then
        -- Simple hash-based validation
        if key == self.Config.Key then
            self.IsAuthenticated = true
            self.Key = key
            return true
        end
    end

    if self.Config.Provider == "Linkvertise" then
        return self:ValidateLinkvertise(key)
    end

    if self.Config.Provider == "LootLabs" then
        return self:ValidateLootLabs(key)
    end

    return false
end

function KeySystem:ValidateLinkvertise(key)
    -- Placeholder for Linkvertise integration
    -- In production, this would call the Linkvertise API
    self.IsAuthenticated = true
    self.Key = key
    return true
end

function KeySystem:ValidateLootLabs(key)
    -- Placeholder for LootLabs integration
    self.IsAuthenticated = true
    self.Key = key
    return true
end

-- ═══════════════════════════════════════════
-- SERVER VALIDATION
-- ═══════════════════════════════════════════
function KeySystem:ServerValidate(key)
    if self.Config.ServerURL == "" then return self:ValidateKey(key) end

    local hwid = self:GetHWID()
    local success, response = pcall(function()
        if request then
            return request({
                Url = self.Config.ServerURL .. "/validate",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    key = key,
                    hwid = hwid,
                    game = game.PlaceId,
                }),
            })
        end
        return nil
    end)

    if success and response then
        local data = HttpService:JSONDecode(response.Body)
        if data.valid then
            self.IsAuthenticated = true
            self.Key = key
            return true
        end
    end

    return false
end

-- ═══════════════════════════════════════════
-- KEY PROMPT UI
-- ═══════════════════════════════════════════
function KeySystem:ShowKeyPrompt(callback)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CUZAO_KeySystem"
    ScreenGui.DisplayOrder = 9999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 200)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 1.5

    -- Title
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "CUZAO HUB - Key System"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold

    -- Instruction
    local Instruction = Instance.new("TextLabel", Frame)
    Instruction.Size = UDim2.new(1, -30, 0, 16)
    Instruction.Position = UDim2.new(0, 15, 0, 55)
    Instruction.BackgroundTransparency = 1
    Instruction.Text = "Insira sua chave para continuar:"
    Instruction.TextColor3 = Color3.fromRGB(160, 160, 160)
    Instruction.TextSize = 12
    Instruction.Font = Enum.Font.Gotham
    Instruction.TextXAlignment = Enum.TextXAlignment.Left

    -- Key Input
    local InputBox = Instance.new("TextBox", Frame)
    InputBox.Size = UDim2.new(1, -30, 0, 32)
    InputBox.Position = UDim2.new(0, 15, 0, 78)
    InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InputBox.BorderSizePixel = 0
    InputBox.PlaceholderText = "Cole sua chave aqui..."
    InputBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    InputBox.TextColor3 = Color3.new(1, 1, 1)
    InputBox.TextSize = 13
    InputBox.Font = Enum.Font.Gotham
    InputBox.Text = ""
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Frame
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", InputBox).PaddingLeft = UDim.new(0, 8)

    -- Status
    local Status = Instance.new("TextLabel", Frame)
    Status.Size = UDim2.new(1, -30, 0, 14)
    Status.Position = UDim2.new(0, 15, 0, 116)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = Color3.fromRGB(200, 80, 80)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left

    -- Submit Button
    local SubmitBtn = Instance.new("TextButton", Frame)
    SubmitBtn.Size = UDim2.new(1, -30, 0, 32)
    SubmitBtn.Position = UDim2.new(0, 15, 0, 136)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Text = "Verificar Chave"
    SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
    SubmitBtn.TextSize = 13
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Parent = Frame
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

    -- Get Key Button
    local GetKeyBtn = Instance.new("TextButton", Frame)
    GetKeyBtn.Size = UDim2.new(1, -30, 0, 24)
    GetKeyBtn.Position = UDim2.new(0, 15, 0, 172)
    GetKeyBtn.BackgroundTransparency = 1
    GetKeyBtn.Text = "Obter Chave →"
    GetKeyBtn.TextColor3 = Color3.fromRGB(88, 101, 242)
    GetKeyBtn.TextSize = 11
    GetKeyBtn.Font = Enum.Font.Gotham
    GetKeyBtn.Parent = Frame

    -- Submit logic
    SubmitBtn.MouseButton1Click:Connect(function()
        local key = InputBox.Text
        if key == "" then
            Status.Text = "Por favor insira uma chave"
            return
        end

        SubmitBtn.Text = "Verificando..."
        task.wait(0.5)

        local valid = self:ServerValidate(key)
        if valid then
            Status.Text = "✓ Chave válida!"
            Status.TextColor3 = Color3.fromRGB(80, 200, 80)
            SubmitBtn.Text = "Acesso Liberado!"

            task.delay(1, function()
                ScreenGui:Destroy()
                if callback then callback(true) end
            end)
        else
            Status.Text = "✗ Chave inválida!"
            Status.TextColor3 = Color3.fromRGB(200, 80, 80)
            SubmitBtn.Text = "Verificar Chave"
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            -- Copy key system URL to clipboard
            local url = "https://linkvertise.com/SEU_USER/cuzao-hub-key"
            setclipboard(url)
            Status.Text = "Link copiado! Cole no navegador."
            Status.TextColor3 = Color3.fromRGB(88, 101, 242)
        end
    end)
end

function KeySystem:RequireKey(callback)
    if not self.Config.Enabled then
        if callback then callback(true) end
        return true
    end

    -- Check saved key
    local savedKey = nil
    pcall(function()
        if readfile and isfile and isfile("cuzao_key.txt") then
            savedKey = readfile("cuzao_key.txt")
        end
    end)

    if savedKey and self:ValidateKey(savedKey) then
        if callback then callback(true) end
        return true
    end

    -- Show prompt
    self:ShowKeyPrompt(function(success)
        if success and self.Key and writefile then
            pcall(writefile, "cuzao_key.txt", self.Key)
        end
        if callback then callback(success) end
    end)

    return false
end

return KeySystem