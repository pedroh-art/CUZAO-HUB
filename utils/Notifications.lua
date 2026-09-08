--[[
    CUZAO HUB - Notifications
    Sistema de toast notifications melhorado
    Com suporte a Discord webhooks
]]

local Notifications = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

Notifications.Config = {
    Enabled = true,
    Duration = 4,
    MaxVisible = 5,
    Position = "TopRight",
    SoundEnabled = true,
    DiscordWebhook = "",
    DiscordOnFruit = false,
    DiscordOnFarm = false,
}

Notifications.Queue = {}
Notifications.Visible = {}

local NOTIF_COLORS = {
    Info = Color3.fromRGB(88, 101, 242),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Fruit = Color3.fromRGB(255, 165, 0),
    Raid = Color3.fromRGB(150, 0, 255),
    Farm = Color3.fromRGB(0, 200, 100),
}

local NOTIF_ICONS = {
    Info = "ℹ️",
    Success = "✅",
    Warning = "⚠️",
    Error = "❌",
    Fruit = "🍎",
    Raid = "🏴‍☠️",
    Farm = "⚔️",
}

function Notifications:CreateContainer()
    if self.Container then return self.Container end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CUZAO_Notifications"
    gui.DisplayOrder = 998
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 320, 1, 0)
    container.Position = UDim2.new(1, -330, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = gui

    Instance.new("UIListLayout", container).Padding = UDim.new(0, 6)
    container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    self.Container = container
    self.Gui = gui
    return container
end

function Notifications:Show(title, message, type, duration)
    type = type or "Info"
    duration = duration or self.Config.Duration

    if not self.Config.Enabled then return end

    self:CreateContainer()

    local color = NOTIF_COLORS[type] or NOTIF_COLORS.Info
    local icon = NOTIF_ICONS[type] or "📌"

    local container = self.Container

    -- Limit visible
    local visibleCount = 0
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then visibleCount = visibleCount + 1 end
    end
    if visibleCount >= self.Config.MaxVisible then
        local oldest = container:FindFirstChildWhichIsA("Frame")
        if oldest then oldest:Destroy() end
    end

    -- Build notification
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = container

    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = color
    stroke.Thickness = 1.5

    -- Accent bar
    local bar = Instance.new("Frame", notif)
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0

    -- Icon
    local iconLabel = Instance.new("TextLabel", notif)
    iconLabel.Size = UDim2.new(0, 30, 0, 20)
    iconLabel.Position = UDim2.new(0, 10, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.TextSize = 14
    iconLabel.Font = Enum.Font.Gotham

    -- Title
    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -50, 0, 18)
    titleLabel.Position = UDim2.new(0, 36, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Message
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -50, 0, 14)
    msgLabel.Position = UDim2.new(0, 36, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    msgLabel.TextSize = 11
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextTruncate = Enum.TextTruncate.AtEnd

    -- Close button
    local closeBtn = Instance.new("TextButton", notif)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0, 6)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold

    -- Auto size
    notif.Size = UDim2.new(1, 0, 0, 48)

    -- Animate in
    notif.Position = UDim2.new(0, 340, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()

    -- Close handlers
    local function closeNotif()
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 340, 0, 0),
        }):Play()
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(closeNotif)

    -- Auto close
    task.delay(duration, closeNotif)

    -- Sound
    if self.Config.SoundEnabled then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://6042053626"
            sound.Volume = 0.3
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end

    -- Discord webhook (async)
    if self.Config.DiscordWebhook ~= "" then
        self:SendDiscord(title, message, type, color)
    end

    return notif
end

function Notifications:SendDiscord(title, message, type, color)
    if not self.Config.DiscordWebhook or self.Config.DiscordWebhook == "" then return end
    if type == "Fruit" and not self.Config.DiscordOnFruit then return end
    if type == "Farm" and not self.Config.DiscordOnFarm then return end

    task.spawn(function()
        pcall(function()
            local r = math.floor(color.R * 255)
            local g = math.floor(color.G * 255)
            local b = math.floor(color.B * 255)
            local hexColor = r * 65536 + g * 256 + b

            local embed = {
                title = title,
                description = message,
                color = hexColor,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                footer = {
                    text = "CUZAO HUB v" .. (getgenv().CUZAO_VERSION or "1.0.0"),
                },
            }

            local payload = HttpService:JSONEncode({
                username = "CUZAO HUB",
                embeds = {embed},
            })

            if request then
                request({
                    Url = self.Config.DiscordWebhook,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payload,
                })
            end
        end)
    end)
end

function Notifications:ClearAll()
    if self.Container then
        for _, child in ipairs(self.Container:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
    end
end

-- Convenience
function Notifications:Info(title, msg) self:Show(title, msg, "Info") end
function Notifications:Success(title, msg) self:Show(title, msg, "Success") end
function Notifications:Warn(title, msg) self:Show(title, msg, "Warning") end
function Notifications:Error(title, msg) self:Show(title, msg, "Error") end
function Notifications:Fruit(title, msg) self:Show(title, msg, "Fruit") end
function Notifications:Raid(title, msg) self:Show(title, msg, "Raid") end
function Notifications:Farm(title, msg) self:Show(title, msg, "Farm") end

return Notifications