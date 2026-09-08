--!strict
--[[
    CUZAO HUB - Window Component
    Janela principal reutilizável com tabs, drag, resize
    Pode ser usada como extensão da Library ou standalone
]]

local Window = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme carregado do CUZAO global (require() não funciona com loadstring/HttpGet)
local Theme = getgenv().CUZAO.Modules["Theme"]

-- ═══════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════
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

local function Tween(instance, props, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 8),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme:GetColor("Border"),
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function AddPadding(parent, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft = UDim.new(0, l or 8),
        PaddingRight = UDim.new(0, r or 8),
        Parent = parent,
    })
end

-- ═══════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════
function Window.new(config)
    config = config or {}

    local self = setmetatable({}, {__index = Window})

    self.Title = config.Title or "CUZAO HUB"
    self.Subtitle = config.Subtitle or ""
    self.Size = config.Size or UDim2.new(0, 620, 0, 420)
    self.Resizable = config.Resizable ~= false
    self.Keybind = config.Keybind or Enum.KeyCode.RightControl
    self.Parent = config.Parent or game:GetService("CoreGui")

    self.Tabs = {}
    self.CurrentTab = nil
    self.IsOpen = false
    self.IsDragging = false
    self.IsMinimized = false
    self.IsFocused = false
    self.Connections = {}

    self:_Create()
    self:_SetupDrag()
    self:_SetupKeybind()

    return self
end

function Window:_Create()
    -- ScreenGui
    self.Gui = Create("ScreenGui", {
        Name = "CUZAO_Window_" .. self.Title:gsub("%s+", "_"),
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = self.Parent,
    })

    -- Main Container
    self.Container = Create("Frame", {
        Name = "Container",
        Size = self.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme:GetColor("Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
    })
    AddCorner(self.Container)
    self:_AddShadow()

    -- Glow border
    self.BorderGlow = AddStroke(self.Container, Theme:GetColor("Accent"), 1.5)
    self.BorderGlow.Transparency = 0.4

    -- Title Bar
    self:_CreateTitleBar()

    -- Content area
    self:_CreateContentArea()

    self.IsOpen = true
end

function Window:_CreateTitleBar()
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = self.Container,
    })
    AddCorner(self.TitleBar, UDim.new(0, 8))
    -- Fill bottom corners
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme:GetColor("Secondary"),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = self.TitleBar,
    })

    -- Logo
    local logo = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = self.TitleBar,
    })
    AddCorner(logo, UDim.new(0, 6))
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "C",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBlack,
        ZIndex = 7,
        Parent = logo,
    })

    -- Title text
    Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 18),
        Position = UDim2.new(0, 50, 0, 5),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = self.TitleBar,
    })

    if self.Subtitle ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(0, 300, 0, 14),
            Position = UDim2.new(0, 50, 0, 25),
            BackgroundTransparency = 1,
            Text = self.Subtitle,
            TextColor3 = Theme:GetColor("TextMuted"),
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = self.TitleBar,
        })
    end

    -- Window control buttons
    local function MakeBtn(name, color, text, pos)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = pos,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 6,
            Parent = self.TitleBar,
        })
        AddCorner(btn, UDim.new(0, 6))
        return btn
    end

    self.CloseBtn = MakeBtn("Close", Theme:GetColor("Error"), "×", UDim2.new(1, -40, 0.5, 0))
    self.MinBtn = MakeBtn("Min", Theme:GetColor("Warning"), "−", UDim2.new(1, -72, 0.5, 0))

    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    self.MinBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Hover effects
    for _, btn in ipairs({self.CloseBtn, self.MinBtn}) do
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0}, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.1}, 0.1)
        end)
    end
end

function Window:_CreateContentArea()
    self.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Container,
    })

    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 135, 1, 0),
        BackgroundColor3 = Theme:GetColor("TabBackground"),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.Content,
    })
    AddCorner(self.Sidebar)

    -- Tab content wrapper
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -145, 1, -8),
        Position = UDim2.new(0, 140, 0, 4),
        BackgroundColor3 = Theme:GetColor("Tertiary"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Content,
    })
    AddCorner(self.TabContainer)
end

function Window:_AddShadow()
    Create("ImageLabel", {
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        ZIndex = self.Container.ZIndex - 1,
        Parent = self.Container,
    })
end

-- ═══════════════════════════════════════════
-- DRAGGING
-- ═══════════════════════════════════════════
function Window:_SetupDrag()
    local dragStart, startPos

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            dragStart = input.Position
            startPos = self.Container.Position
        end
    end)

    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end)

    local conn = UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    table.insert(self.Connections, conn)
end

-- ═══════════════════════════════════════════
-- KEYBIND
-- ═══════════════════════════════════════════
function Window:_SetupKeybind()
    local conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.Keybind then
            self:Toggle()
        end
    end)
    table.insert(self.Connections, conn)
end

-- ═══════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════
function Window:CreateTab(config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or "📁"
    local order = #self.Tabs + 1

    -- Tab Button
    local tabBtn = Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, -8, 0, 34),
        Position = UDim2.new(0, 4, 0, 8 + (order * 38)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 4,
        Parent = self.Sidebar,
    })
    AddCorner(tabBtn, UDim.new(0, 6))

    Create("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. name,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = tabBtn,
    })

    -- Tab scroll frame
    local tabFrame = Create("ScrollingFrame", {
        Name = "Content_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme:GetColor("ScrollBar"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 2,
        Parent = self.TabContainer,
    })
    AddPadding(tabFrame, 6, 6, 6, 6)

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabFrame,
    })

    -- Tab data
    local tabData = {
        Name = name,
        Icon = icon,
        Button = tabBtn,
        Frame = tabFrame,
        Order = order,
        Sections = {},
    }
    self.Tabs[name] = tabData

    -- Click handler
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = Theme:GetColor("TabHover")
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            tabBtn.BackgroundTransparency = 1
        end
    end)

    -- Auto-select first
    if order == 1 then
        self:SelectTab(name)
    end

    -- Return section factory
    return self:_CreateTabAPI(tabData)
end

function Window:_CreateTabAPI(tabData)
    local api = {}

    function api:CreateSection(name)
        name = name or "Section"
        local sf = Create("Frame", {
            Name = "Section_" .. name,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #tabData.Frame:GetChildren() * 10,
            Parent = tabData.Frame,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
            Parent = sf,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "  " .. string.upper(name),
            TextColor3 = Theme:GetColor("Accent"),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = sf,
        })

        local secAPI = {}

        function secAPI:AddLabel(config)
            local cfg = config or {}
            cfg.Type = "Label"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddButton(config)
            local cfg = config or {}
            cfg.Type = "Button"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddToggle(config)
            local cfg = config or {}
            cfg.Type = "Toggle"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddSlider(config)
            local cfg = config or {}
            cfg.Type = "Slider"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddDropdown(config)
            local cfg = config or {}
            cfg.Type = "Dropdown"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddKeybind(config)
            local cfg = config or {}
            cfg.Type = "Keybind"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddColorPicker(config)
            local cfg = config or {}
            cfg.Type = "ColorPicker"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddInput(config)
            local cfg = config or {}
            cfg.Type = "Input"
            return self:_AddComponent(sf, cfg)
        end

        function secAPI:AddParagraph(title, desc)
            local pf = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #sf:GetChildren() * 10,
                Parent = sf,
            })
            Create("TextLabel", {
                Size = UDim2.new(1, -12, 0, 0),
                Position = UDim2.new(0, 6, 0, 4),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                Parent = pf,
            })
            if desc then
                Create("TextLabel", {
                    Size = UDim2.new(1, -12, 0, 0),
                    Position = UDim2.new(0, 6, 0, 22),
                    BackgroundTransparency = 1,
                    Text = desc,
                    TextColor3 = Theme:GetColor("TextMuted"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    Parent = pf,
                })
            end
            return pf
        end

        function secAPI:AddDivider()
            local d = Create("Frame", {
                Size = UDim2.new(1, -12, 0, 1),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundColor3 = Theme:GetColor("Divider"),
                BorderSizePixel = 0,
                LayoutOrder = #sf:GetChildren() * 10,
                Parent = sf,
            })
            return d
        end

        tabData.Sections[name] = secAPI
        return secAPI
    end

    return api
end

function Window:_AddComponent(parent, config)
    -- Delegate to Library component system or build inline
    -- This is a lightweight inline builder
    local layoutOrder = #parent:GetChildren() * 10

    if config.Type == "Button" then
        local bf = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme:GetColor("Accent"),
            BorderSizePixel = 0,
            Text = config.Text or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Parent = bf,
        })
        AddCorner(btn, UDim.new(0, 6))
        btn.MouseButton1Click:Connect(function()
            pcall(config.Callback or function() end)
        end)
        return { Set = function() end, Get = function() end }
    end

    if config.Type == "Toggle" then
        local tf = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        local state = config.Default or false
        Create("TextLabel", {
            Size = UDim2.new(1, -55, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Toggle",
            TextColor3 = Theme:GetColor("Text"),
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tf,
        })
        local bg = Create("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -44, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border"),
            BorderSizePixel = 0,
            Parent = tf,
        })
        AddCorner(bg, UDim.new(1, 0))
        local circle = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = bg,
        })
        AddCorner(circle, UDim.new(1, 0))

        local toggleBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = tf,
        })

        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            Tween(bg, {BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border")}, 0.15)
            Tween(circle, {Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.15)
            pcall(config.Callback or function() end, state)
        end)

        return {
            Set = function(_, v)
                state = v
                Tween(bg, {BackgroundColor3 = v and Theme:GetColor("Accent") or Theme:GetColor("Border")}, 0.15)
                Tween(circle, {Position = v and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.15)
            end,
            Get = function() return state end,
        }
    end

    if config.Type == "Slider" then
        return Window._BuildSlider(parent, config, layoutOrder)
    end

    if config.Type == "Dropdown" then
        return Window._BuildDropdown(parent, config, layoutOrder)
    end

    if config.Type == "Keybind" then
        return Window._BuildKeybind(parent, config, layoutOrder)
    end

    if config.Type == "Input" then
        return Window._BuildInput(parent, config, layoutOrder)
    end

    return {}
end

-- ═══════════════════════════════════════════
-- COMPONENT BUILDERS (Static)
-- ═══════════════════════════════════════════
function Window._BuildSlider(parent, config, layoutOrder)
    local min = config.Min or 0
    local max = config.Max or 100
    local val = config.Default or 50
    local suffix = config.Suffix or ""

    local sf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 18),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Slider",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sf,
    })

    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0.3, -6, 0, 18),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(val) .. suffix,
        TextColor3 = Theme:GetColor("Accent"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sf,
    })

    local track = Create("Frame", {
        Size = UDim2.new(1, -12, 0, 6),
        Position = UDim2.new(0, 6, 0, 30),
        BackgroundColor3 = Theme:GetColor("Border"),
        BorderSizePixel = 0,
        Parent = sf,
    })
    AddCorner(track, UDim.new(1, 0))

    local pct = (val - min) / (max - min)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(fill, UDim.new(1, 0))

    local knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(pct, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(knob, UDim.new(1, 0))
    AddStroke(knob, Theme:GetColor("Accent"), 1.5)

    local dragging = false
    local function update(x)
        local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valLabel.Text = tostring(val) .. suffix
        pcall(config.Callback or function() end, val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
            i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
            i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)

    return {
        Set = function(_, v)
            val = math.clamp(v, min, max)
            local p = (val - min) / (max - min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valLabel.Text = tostring(val) .. suffix
        end,
        Get = function() return val end,
    }
end

function Window._BuildDropdown(parent, config, layoutOrder)
    local options = config.Options or {}
    local val = config.Default or options[1] or ""
    local isOpen = false

    local df = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        ClipsDescendants = false,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Dropdown",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = df,
    })

    local selBtn = Create("TextButton", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(1, -136, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = "",
        Parent = df,
    })
    AddCorner(selBtn, UDim.new(0, 4))
    AddStroke(selBtn, Theme:GetColor("InputBorder"))

    local selLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = val,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = selBtn,
    })

    Create("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme:GetColor("TextMuted"),
        TextSize = 9,
        Parent = selBtn,
    })

    local listF = Create("Frame", {
        Size = UDim2.new(0, 130, 0, math.min(#options, 5) * 26 + 8),
        Position = UDim2.new(1, -136, 0, 30),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        ZIndex = 10,
        Visible = false,
        ClipsDescendants = true,
        Parent = df,
    })
    AddCorner(listF, UDim.new(0, 4))
    AddStroke(listF, Theme:GetColor("InputBorder"))
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = listF })
    AddPadding(listF, 4, 4, 4, 4)

    for _, opt in ipairs(options) do
        local ob = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = opt == val and 0 or 1,
            BackgroundColor3 = Theme:GetColor("Hover"),
            BorderSizePixel = 0,
            Text = "  " .. opt,
            TextColor3 = Theme:GetColor("Text"),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = listF,
        })
        AddCorner(ob, UDim.new(0, 4))
        ob.MouseButton1Click:Connect(function()
            val = opt
            selLabel.Text = opt
            isOpen = false
            listF.Visible = false
            pcall(config.Callback or function() end, opt)
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listF.Visible = isOpen
    end)

    return {
        Set = function(_, v) val = v; selLabel.Text = v end,
        Get = function() return val end,
    }
end

function Window._BuildKeybind(parent, config, layoutOrder)
    local bind = config.Default or Enum.KeyCode.Unknown
    local listening = false

    local kf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Keybind",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = kf,
    })

    local kBtn = Create("TextButton", {
        Size = UDim2.new(0, 88, 0, 26),
        Position = UDim2.new(1, -94, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = bind.Name or "None",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = kf,
    })
    AddCorner(kBtn, UDim.new(0, 4))
    AddStroke(kBtn, Theme:GetColor("InputBorder"))

    kBtn.MouseButton1Click:Connect(function()
        listening = true
        kBtn.Text = "..."
        Tween(kBtn, {BackgroundColor3 = Theme:GetColor("Accent")}, 0.1)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            bind = input.KeyCode
            kBtn.Text = bind.Name
            listening = false
            Tween(kBtn, {BackgroundColor3 = Theme:GetColor("InputBg")}, 0.1)
            pcall(config.ChangedCallback or config.Callback or function() end, bind)
        end
    end)

    return {
        Set = function(_, v) bind = v; kBtn.Text = v.Name or "None" end,
        Get = function() return bind end,
    }
end

function Window._BuildInput(parent, config, layoutOrder)
    local inf = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Input",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inf,
    })

    local tb = Create("TextBox", {
        Size = UDim2.new(1, -12, 0, 28),
        Position = UDim2.new(0, 6, 0, 20),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "",
        PlaceholderColor3 = Theme:GetColor("Placeholder"),
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inf,
    })
    AddCorner(tb, UDim.new(0, 4))
    AddStroke(tb, Theme:GetColor("InputBorder"))
    AddPadding(tb, 0, 0, 8, 8)

    tb.FocusLost:Connect(function()
        pcall(config.Callback or function() end, tb.Text)
    end)

    return {
        Set = function(_, v) tb.Text = v end,
        Get = function() return tb.Text end,
    }
end

-- ═══════════════════════════════════════════
-- TAB NAVIGATION
-- ═══════════════════════════════════════════
function Window:SelectTab(name)
    local tab = self.Tabs[name]
    if not tab then return end

    for _, t in pairs(self.Tabs) do
        t.Frame.Visible = false
        t.Button.BackgroundTransparency = 1
        local lbl = t.Button:FindFirstChildWhichIsA("TextLabel")
        if lbl then lbl.TextColor3 = Theme:GetColor("TextSecondary") end
    end

    tab.Frame.Visible = true
    tab.Button.BackgroundTransparency = 0
    tab.Button.BackgroundColor3 = Theme:GetColor("TabActive")
    local lbl = tab.Button:FindFirstChildWhichIsA("TextLabel")
    if lbl then lbl.TextColor3 = Color3.new(1, 1, 1) end
    self.CurrentTab = name
end

-- ═══════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════
function Window:Toggle()
    if self.IsOpen then self:Close() else self:Open() end
end

function Window:Open()
    self.IsOpen = true
    self.Container.Visible = true
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Container, {Size = self.Size}, 0.35, Enum.EasingStyle.Back)
end

function Window:Close()
    self.IsOpen = false
    Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
    task.delay(0.25, function()
        self.Container.Visible = false
    end)
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then
        Tween(self.Container, {Size = UDim2.new(0, 620, 0, 48)}, 0.25)
        self.MinBtn.Text = "+"
    else
        Tween(self.Container, {Size = self.Size}, 0.25)
        self.MinBtn.Text = "−"
    end
end

function Window:Destroy()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.Gui then self.Gui:Destroy() end
end

function Window:Notify(title, message, notifType, duration)
    -- Delegate to Library notify or build inline
    notifType = notifType or "Info"
    duration = duration or 4

    local colors = {
        Info = Theme:GetColor("Accent"),
        Success = Theme:GetColor("Success"),
        Warning = Theme:GetColor("Warning"),
        Error = Theme:GetColor("Error"),
    }

    local container = self.Gui:FindFirstChild("Notifications")
    if not container then
        container = Create("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -310, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.Gui,
        })
    end

    local count = #container:GetChildren()
    local n = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, count * 58),
        BackgroundColor3 = Theme:GetColor("NotificationBg"),
        BorderSizePixel = 0,
        Parent = container,
    })
    AddCorner(n, UDim.new(0, 6))
    AddStroke(n, colors[notifType] or Theme:GetColor("Border"), 1)

    Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = colors[notifType] or Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        Parent = n,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 18),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = n,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 14),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme:GetColor("TextSecondary"),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = n,
    })

    n.Position = UDim2.new(0, 310, 0, count * 58)
    Tween(n, {Position = UDim2.new(0, 0, 0, count * 58)}, 0.3, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(n, {Position = UDim2.new(0, 310, 0, n.Position.Y.Offset)}, 0.25)
        task.delay(0.3, function() n:Destroy() end)
    end)
end

return Window