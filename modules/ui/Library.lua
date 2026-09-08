--!strict
--[[
    CUZAO HUB - UI Library (WindUI Customizado)
    Biblioteca principal de interface gráfica
    Baseado no WindUI, simplificado e otimizado para Blox Fruits
]]

local Library = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Modules
local Theme = require(script.Parent.Theme)

-- Config
Library.Config = {
    Title = "CUZAO HUB",
    Subtitle = "Blox Fruits",
    Version = "1.0.0",
    Keybind = Enum.KeyCode.RightControl,
    MobileEnabled = true,
    NotificationDuration = 4,
    AnimationSpeed = 0.2,
    CornerRadius = UDim.new(0, 8),
    SmallCornerRadius = UDim.new(0, 4),
}

-- State
Library.Window = nil
Library.Tabs = {}
Library.CurrentTab = nil
Library.Notifications = {}
Library.Connections = {}
Library.IsOpen = false
Library.Screens = {}

-- Utility Functions
local function Create(className, props)
    local instance = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Children" then
            pcall(function() instance[k] = v end)
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = instance
        end
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

local function Tween(instance, props, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Config.AnimationSpeed,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or Library.Config.CornerRadius,
        Parent = parent,
    })
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        PaddingRight = UDim.new(0, right or 8),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness, mode)
    return Create("UIStroke", {
        Color = color or Theme:GetColor("Border"),
        Thickness = thickness or 1,
        ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function AddShadow(parent)
    return Create("ImageLabel", {
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        ZIndex = parent.ZIndex - 1,
        Parent = parent,
    })
end

local function RemoveConnections(tag)
    for _, conn in ipairs(Library.Connections) do
        if conn.Tag == tag then
            pcall(function() conn.Connection:Disconnect() end)
        end
    end
    Library.Connections = {}
end

-- ═══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════
function Library:Notify(title, message, type, duration)
    type = type or "Info"
    duration = duration or Library.Config.NotificationDuration

    local colors = {
        Info = Theme:GetColor("Accent"),
        Success = Theme:GetColor("Success"),
        Warning = Theme:GetColor("Warning"),
        Error = Theme:GetColor("Error"),
    }

    local icons = {
        Info = "ℹ️",
        Success = "✅",
        Warning = "⚠️",
        Error = "❌",
    }

    local notifContainer = CoreGui:FindFirstChild("CUZAO_Notifications")
    if not notifContainer then
        notifContainer = Create("ScreenGui", {
            Name = "CUZAO_Notifications",
            DisplayOrder = 999,
            ResetOnSpawn = false,
            Parent = CoreGui,
        })
    end

    local count = 0
    for _, v in ipairs(notifContainer:GetChildren()) do
        count = count + 1
    end

    local notif = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 60),
        Position = UDim2.new(1, -340, 0, 20 + (count * 70)),
        BackgroundColor3 = Theme:GetColor("NotificationBg"),
        BorderSizePixel = 0,
        Parent = notifContainer,
    })
    AddCorner(notif)
    AddStroke(notif, colors[type], 1.5)

    Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = colors[type],
        BorderSizePixel = 0,
        Parent = notif,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 25),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Text = (icons[type] or "") .. " " .. title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 16, 0, 32),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif,
    })

    -- Animate in
    notif.Position = UDim2.new(1, 350, 0, 20 + (count * 70))
    Tween(notif, {Position = UDim2.new(1, -340, 0, 20 + (count * 70))}, 0.4, Enum.EasingStyle.Back)

    -- Auto remove
    task.delay(duration, function()
        if not notif then return end
        Tween(notif, {Position = UDim2.new(1, 350, 0, notif.Position.Y.Offset)}, 0.3, Enum.EasingStyle.Quint)
        task.delay(0.35, function()
            notif:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or Library.Config.Title
    local subtitle = config.Subtitle or Library.Config.Subtitle
    local size = config.Size or UDim2.new(0, 620, 0, 420)

    -- Destroy old window
    if Library.Window then
        Library.Window:Destroy()
    end

    -- ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "CUZAO_HUB",
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    Library.Screen = screenGui

    -- Main Frame
    local mainFrame = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme:GetColor("Background"),
        BorderSizePixel = 0,
        Parent = screenGui,
        ClipsDescendants = true,
    })
    AddCorner(mainFrame)
    AddShadow(mainFrame)

    -- Glow effect
    Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    local glowStroke = Create("UIStroke", {
        Color = Theme:GetColor("Accent"),
        Thickness = 1.5,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = mainFrame,
    })

    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    AddCorner(titleBar, UDim.new(0, 8))
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    -- CUZAO Logo / Icon
    Create("TextLabel", {
        Name = "Logo",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "C",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        Parent = titleBar,
    })
    AddCorner(Create("Frame", {Parent = titleBar}), UDim.new(0, 8))

    local logoFrame = titleBar:FindFirstChild("Logo")
    -- re-do logo properly
    logoFrame:ClearAllChildren()
    AddCorner(logoFrame, UDim.new(0, 6))

    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 50, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 50, 0, 26),
        BackgroundTransparency = 1,
        Text = subtitle .. " • v" .. Library.Config.Version,
        TextColor3 = Theme:GetColor("TextMuted"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Close Button
    local closeBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -44, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Error"),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
    })
    AddCorner(closeBtn, UDim.new(0, 6))

    -- Minimize Button
    local minimizeBtn = Create("TextButton", {
        Name = "MinBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Warning"),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = titleBar,
    })
    AddCorner(minimizeBtn, UDim.new(0, 6))

    -- Content Area
    local contentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })

    -- Sidebar (Tabs)
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    AddCorner(sidebar, UDim.new(0, 8))

    -- Tab content area
    local tabContent = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -150, 1, -10),
        Position = UDim2.new(0, 145, 0, 5),
        BackgroundColor3 = Theme:GetColor("Tertiary"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    AddCorner(tabContent)
    AddPadding(tabContent, 8, 8, 8, 8)

    -- Store references
    Library.Window = mainFrame
    Library.Sidebar = sidebar
    Library.TabContent = tabContent
    Library.GlowStroke = glowStroke
    Library.TitleBar = titleBar

    -- ═══ Dragging ═══
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ═══ Close / Minimize ═══
    closeBtn.MouseButton1Click:Connect(function()
        Library:Close()
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(mainFrame, {Size = UDim2.new(0, 620, 0, 50)}, 0.3)
            minimizeBtn.Text = "+"
        else
            Tween(mainFrame, {Size = size}, 0.3)
            minimizeBtn.Text = "−"
        end
    end)

    -- ═══ Keybind Toggle ═══
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.Config.Keybind then
            Library:Toggle()
        end
    end)

    Library.IsOpen = true
    return Library
end

-- ═══════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════
function Library:CreateTab(config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or "📁"
    local tabOrder = #Library.Tabs + 1

    -- Tab Button (Sidebar)
    local tabBtn = Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, -10, 0, 36),
        Position = UDim2.new(0, 5, 0, 10 + (tabOrder * 40)),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        Parent = Library.Sidebar,
    })
    AddCorner(tabBtn, UDim.new(0, 6))

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. name,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })
    AddPadding(tabBtn, 0, 0, 10, 0)

    -- Tab Content Frame
    local tabFrame = Create("ScrollingFrame", {
        Name = "Content_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme:GetColor("ScrollBar"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Library.TabContent,
    })

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = tabFrame,
    })
    AddPadding(tabFrame, 4, 4, 4, 4)

    -- Tab data
    local tabData = {
        Name = name,
        Icon = icon,
        Button = tabBtn,
        Frame = tabFrame,
        Order = tabOrder,
        Sections = {},
    }
    Library.Tabs[name] = tabData

    -- Tab click
    tabBtn.MouseButton1Click:Connect(function()
        Library:SelectTab(name)
    end)

    -- Hover effects
    tabBtn.MouseEnter:Connect(function()
        if Library.CurrentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = Theme:GetColor("TabHover")}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if Library.CurrentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = Theme:GetColor("TabBackground")}, 0.15)
        end
    end)

    -- Auto select first tab
    if tabOrder == 1 then
        Library:SelectTab(name)
    end

    -- Section creator scoped to this tab
    local tabAPI = {}

    function tabAPI:CreateSection(sectionName)
        sectionName = sectionName or "Section"
        local sectionFrame = Create("Frame", {
            Name = "Section_" .. sectionName,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = #tabFrame:GetChildren() * 10,
            Parent = tabFrame,
        })

        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            Parent = sectionFrame,
        })

        -- Section Header
        Create("TextLabel", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = "  " .. sectionName,
            TextColor3 = Theme:GetColor("Accent"),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = sectionFrame,
        })

        local sectionAPI = {}

        function sectionAPI:AddParagraph(text, desc)
            local paraFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            local label = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 4),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                Parent = paraFrame,
            })

            if desc then
                Create("TextLabel", {
                    Size = UDim2.new(1, -16, 0, 0),
                    Position = UDim2.new(0, 8, 0, 24),
                    BackgroundTransparency = 1,
                    Text = desc,
                    TextColor3 = Theme:GetColor("TextMuted"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    Parent = paraFrame,
                })
            end

            return paraFrame
        end

        function sectionAPI:AddButton(config)
            local btnConfig = config or {}
            local text = btnConfig.Text or "Button"
            local callback = btnConfig.Callback or function() end

            local btnFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme:GetColor("Accent"),
                BorderSizePixel = 0,
                Text = text,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                Parent = btnFrame,
            })
            AddCorner(btn, Library.Config.SmallCornerRadius)

            btn.MouseButton1Click:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
                pcall(callback)
            end)

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("AccentSecondary")}, 0.1)
            end)

            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
            end)

            return btn
        end

        function sectionAPI:AddToggle(config)
            local toggleConfig = config or {}
            local text = toggleConfig.Text or "Toggle"
            local default = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end
            local flag = toggleConfig.Flag

            local toggled = default
            local toggleFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame,
            })

            local toggleBg = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -48, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = toggled and Theme:GetColor("Accent") or Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Parent = toggleFrame,
            })
            AddCorner(toggleBg, UDim.new(1, 0))

            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = toggled and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Parent = toggleBg,
            })
            AddCorner(toggleCircle, UDim.new(1, 0))

            local toggleBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = toggleFrame,
            })

            local function updateToggle()
                toggled = not toggled
                if toggled then
                    Tween(toggleBg, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.2)
                    Tween(toggleCircle, {Position = UDim2.new(1, -20, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                else
                    Tween(toggleBg, {BackgroundColor3 = Theme:GetColor("Border")}, 0.2)
                    Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                end
                pcall(callback, toggled)
            end

            toggleBtn.MouseButton1Click:Connect(updateToggle)

            local toggleAPI = {}
            function toggleAPI:Set(value)
                if value ~= toggled then
                    updateToggle()
                end
            end
            function toggleAPI:Get()
                return toggled
            end

            return toggleAPI
        end

        function sectionAPI:AddSlider(config)
            local sliderConfig = config or {}
            local text = sliderConfig.Text or "Slider"
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or 50
            local callback = sliderConfig.Callback or function() end
            local suffix = sliderConfig.Suffix or ""

            local currentValue = default
            local sliderFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame,
            })

            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -58, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(currentValue) .. suffix,
                TextColor3 = Theme:GetColor("Accent"),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame,
            })

            local track = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 6),
                Position = UDim2.new(0, 8, 0, 30),
                BackgroundColor3 = Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Parent = sliderFrame,
            })
            AddCorner(track, UDim.new(1, 0))

            local fillPercent = (currentValue - min) / (max - min)
            local fill = Create("Frame", {
                Size = UDim2.new(fillPercent, 0, 1, 0),
                BackgroundColor3 = Theme:GetColor("Accent"),
                BorderSizePixel = 0,
                Parent = track,
            })
            AddCorner(fill, UDim.new(1, 0))

            local knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(fillPercent, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Parent = track,
            })
            AddCorner(knob, UDim.new(1, 0))
            AddStroke(knob, Theme:GetColor("Accent"), 2)

            local dragging = false

            local function updateSlider(inputX)
                local trackAbsPos = track.AbsolutePosition.X
                local trackAbsSize = track.AbsoluteSize.X
                local relativeX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                currentValue = math.floor(min + (max - min) * relativeX)

                Tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1)
                Tween(knob, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, 0.1)
                valueLabel.Text = tostring(currentValue) .. suffix
                pcall(callback, currentValue)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position.X)
                end
            end)

            track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            local sliderAPI = {}
            function sliderAPI:Set(value)
                currentValue = math.clamp(value, min, max)
                local pct = (currentValue - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valueLabel.Text = tostring(currentValue) .. suffix
            end
            function sliderAPI:Get()
                return currentValue
            end

            return sliderAPI
        end

        function sectionAPI:AddDropdown(config)
            local ddConfig = config or {}
            local text = ddConfig.Text or "Dropdown"
            local options = ddConfig.Options or {}
            local default = ddConfig.Default or options[1] or ""
            local callback = ddConfig.Callback or function() end

            local isOpen = false
            local currentValue = default

            local ddFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                ClipsDescendants = false,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ddFrame,
            })

            local selectBtn = Create("TextButton", {
                Size = UDim2.new(0, 140, 0, 28),
                Position = UDim2.new(1, -148, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = "",
                Parent = ddFrame,
            })
            AddCorner(selectBtn, Library.Config.SmallCornerRadius)
            AddStroke(selectBtn, Theme:GetColor("InputBorder"))

            local selectedLabel = Create("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = currentValue,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = selectBtn,
            })

            Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme:GetColor("TextMuted"),
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = selectBtn,
            })

            -- Dropdown list (expanded below)
            local listFrame = Create("Frame", {
                Name = "List",
                Size = UDim2.new(0, 140, 0, math.min(#options, 6) * 28 + 8),
                Position = UDim2.new(1, -148, 0, 34),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                ZIndex = 10,
                ClipsDescendants = true,
                Visible = false,
                Parent = ddFrame,
            })
            AddCorner(listFrame, Library.Config.SmallCornerRadius)
            AddStroke(listFrame, Theme:GetColor("InputBorder"))

            local listLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = listFrame,
            })
            AddPadding(listFrame, 4, 4, 4, 4)

            for i, option in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme:GetColor("Hover"),
                    BackgroundTransparency = option == currentValue and 0 or 1,
                    BorderSizePixel = 0,
                    Text = "  " .. option,
                    TextColor3 = Theme:GetColor("Text"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                    Parent = listFrame,
                })
                AddCorner(optBtn, UDim.new(0, 4))

                optBtn.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    isOpen = false
                    listFrame.Visible = false

                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = child.Text == "  " .. option and 0 or 1
                        end
                    end

                    pcall(callback, option)
                end)
            end

            selectBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                listFrame.Visible = isOpen
            end)

            local ddAPI = {}
            function ddAPI:Set(value)
                currentValue = value
                selectedLabel.Text = value
            end
            function ddAPI:Get()
                return currentValue
            end
            function ddAPI:Refresh(newOptions)
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                listFrame.Size = UDim2.new(0, 140, 0, math.min(#newOptions, 6) * 28 + 8)
                for i, opt in ipairs(newOptions) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme:GetColor("Hover"),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = "  " .. opt,
                        TextColor3 = Theme:GetColor("Text"),
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11,
                        Parent = listFrame,
                    })
                    AddCorner(optBtn, UDim.new(0, 4))
                    optBtn.MouseButton1Click:Connect(function()
                        currentValue = opt
                        selectedLabel.Text = opt
                        isOpen = false
                        listFrame.Visible = false
                        pcall(callback, opt)
                    end)
                end
            end

            return ddAPI
        end

        function sectionAPI:AddKeybind(config)
            local kbConfig = config or {}
            local text = kbConfig.Text or "Keybind"
            local default = kbConfig.Default or Enum.KeyCode.Unknown
            local callback = kbConfig.Callback or function() end
            local changedCallback = kbConfig.ChangedCallback or function() end

            local currentBind = default
            local listening = false

            local kbFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = kbFrame,
            })

            local bindBtn = Create("TextButton", {
                Size = UDim2.new(0, 90, 0, 28),
                Position = UDim2.new(1, -98, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = currentBind.Name or "None",
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Parent = kbFrame,
            })
            AddCorner(bindBtn, Library.Config.SmallCornerRadius)
            AddStroke(bindBtn, Theme:GetColor("InputBorder"))

            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
                Tween(bindBtn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.15)
            end)

            local kbConnection
            kbConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentBind = input.KeyCode
                    bindBtn.Text = currentBind.Name
                    listening = false
                    Tween(bindBtn, {BackgroundColor3 = Theme:GetColor("InputBg")}, 0.15)
                    pcall(changedCallback, currentBind)
                end
            end)

            local kbAPI = {}
            function kbAPI:Set(key)
                currentBind = key
                bindBtn.Text = key.Name or "None"
            end
            function kbAPI:Get()
                return currentBind
            end

            return kbAPI
        end

        function sectionAPI:AddColorPicker(config)
            local cpConfig = config or {}
            local text = cpConfig.Text or "Color"
            local default = cpConfig.Default or Theme:GetColor("Accent")
            local callback = cpConfig.Callback or function() end

            local currentColor = default
            local isOpen = false

            local cpFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                ClipsDescendants = false,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cpFrame,
            })

            local colorPreview = Create("TextButton", {
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(1, -36, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0,
                Text = "",
                Parent = cpFrame,
            })
            AddCorner(colorPreview, UDim.new(0, 6))
            AddStroke(colorPreview, Theme:GetColor("Border"))

            local palette = Create("Frame", {
                Name = "Palette",
                Size = UDim2.new(0, 180, 0, 120),
                Position = UDim2.new(1, -188, 0, 42),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                ZIndex = 15,
                ClipsDescendants = true,
                Visible = false,
                Parent = cpFrame,
            })
            AddCorner(palette, UDim.new(0, 6))
            AddStroke(palette, Theme:GetColor("InputBorder"))

            -- Preset colors grid
            local presetColors = {
                Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0),
                Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 128, 255),
                Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128),
                Color3.fromRGB(64, 64, 64), Color3.fromRGB(0, 0, 0),
                Color3.fromRGB(255, 100, 100), Color3.fromRGB(100, 255, 100),
                Color3.fromRGB(100, 100, 255), Color3.fromRGB(255, 200, 50),
                Color3.fromRGB(200, 100, 255), Color3.fromRGB(100, 255, 200),
            }

            local grid = Create("UIGridLayout", {
                CellSize = UDim2.new(0, 26, 0, 26),
                CellPadding = UDim2.new(0, 3, 0, 3),
                Parent = palette,
            })
            AddPadding(palette, 6, 6, 6, 6)

            for _, color in ipairs(presetColors) do
                local swatch = Create("TextButton", {
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 16,
                    Parent = palette,
                })
                AddCorner(swatch, UDim.new(0, 4))

                swatch.MouseButton1Click:Connect(function()
                    currentColor = color
                    Tween(colorPreview, {BackgroundColor3 = color}, 0.15)
                    isOpen = false
                    palette.Visible = false
                    pcall(callback, color)
                end)
            end

            colorPreview.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                palette.Visible = isOpen
            end)

            local cpAPI = {}
            function cpAPI:Set(color)
                currentColor = color
                colorPreview.BackgroundColor3 = color
            end
            function cpAPI:Get()
                return currentColor
            end

            return cpAPI
        end

        function sectionAPI:AddInput(config)
            local inputConfig = config or {}
            local text = inputConfig.Text or "Input"
            local placeholder = inputConfig.Placeholder or ""
            local default = inputConfig.Default or ""
            local callback = inputConfig.Callback or function() end

            local inputFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundTransparency = 1,
                LayoutOrder = #sectionFrame:GetChildren() * 10,
                Parent = sectionFrame,
            })

            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputFrame,
            })

            local textBox = Create("TextBox", {
                Size = UDim2.new(1, -16, 0, 30),
                Position = UDim2.new(0, 8, 0, 22),
                BackgroundColor3 = Theme:GetColor("InputBg"),
                BorderSizePixel = 0,
                Text = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme:GetColor("Placeholder"),
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = inputFrame,
            })
            AddCorner(textBox, Library.Config.SmallCornerRadius)
            AddStroke(textBox, Theme:GetColor("InputBorder"))
            AddPadding(textBox, 0, 0, 8, 8)

            textBox.Focused:Connect(function()
                Tween(textBox, {BorderColor3 = Theme:GetColor("Accent")}, 0.15)
            end)

            textBox.FocusLost:Connect(function()
                Tween(textBox, {BorderColor3 = Theme:GetColor("InputBorder")}, 0.15)
                pcall(callback, textBox.Text)
            end)

            local inputAPI = {}
            function inputAPI:Set(value)
                textBox.Text = value
            end
            function inputAPI:Get()
                return textBox.Text
            end

            return inputAPI
        end

        tabData.Sections[sectionName] = sectionAPI
        return sectionAPI
    end

    return tabAPI
end

-- ═══════════════════════════════════════════
-- TAB NAVIGATION
-- ═══════════════════════════════════════════
function Library:SelectTab(name)
    local tab = Library.Tabs[name]
    if not tab then return end

    -- Deselect all
    for tabName, tabData in pairs(Library.Tabs) do
        tabData.Frame.Visible = false
        Tween(tabData.Button, {BackgroundColor3 = Theme:GetColor("TabBackground")}, 0.15)
        local label = tabData.Button:FindFirstChildWhichIsA("TextLabel")
        if label then
            Tween(label, {TextColor3 = Theme:GetColor("TextSecondary")}, 0.15)
        end
    end

    -- Select target
    tab.Frame.Visible = true
    Tween(tab.Button, {BackgroundColor3 = Theme:GetColor("TabActive")}, 0.15)
    local label = tab.Button:FindFirstChildWhichIsA("TextLabel")
    if label then
        Tween(label, {TextColor3 = Color3.new(1, 1, 1)}, 0.15)
    end

    Library.CurrentTab = name
end

-- ═══════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════
function Library:Toggle()
    if Library.IsOpen then
        Library:Close()
    else
        Library:Open()
    end
end

function Library:Open()
    if not Library.Window then return end
    Library.IsOpen = true
    Library.Window.Visible = true
    Library.Window.Size = UDim2.new(0, 0, 0, 0)
    Library.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(Library.Window, {Size = UDim2.new(0, 620, 0, 420)}, 0.4, Enum.EasingStyle.Back)
end

function Library:Close()
    if not Library.Window then return end
    Library.IsOpen = false
    Tween(Library.Window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
    task.delay(0.3, function()
        if Library.Window then
            Library.Window.Visible = false
        end
    end)
end

function Library:Destroy()
    if Library.Window then
        Library.Window:Destroy()
        Library.Window = nil
    end
    if Library.Screen then
        Library.Screen:Destroy()
        Library.Screen = nil
    end
    Theme:StopRGB()
    Library.Tabs = {}
    Library.IsOpen = false
end

function Library:UpdateTheme(themeName)
    Theme:SetTheme(themeName)
    -- In a full implementation, this would update all UI elements
    self:Notify("Theme", "Tema alterado para " .. themeName, "Info")
end

return Library