--!strict
--[[
    CUZAO HUB - Slider Component
    Slider numérico com arrasto e clique na track
]]

local Slider = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Theme)

local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Slider.new(config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or math.floor((min + max) / 2)
    local callback = config.Callback or function() end
    local suffix = config.Suffix or ""

    local value = default

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = config.Parent,
    })

    -- Title
    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 18),
        Position = UDim2.new(0, 8, 0, 2),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Value label
    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0.3, -8, 0, 18),
        Position = UDim2.new(0.7, 0, 0, 2),
        BackgroundTransparency = 1,
        Text = tostring(value) .. suffix,
        TextColor3 = Theme:GetColor("Accent"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })

    -- Track background
    local track = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 6),
        Position = UDim2.new(0, 8, 0, 30),
        BackgroundColor3 = Theme:GetColor("Border"),
        BorderSizePixel = 0,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

    -- Fill
    local pct = math.clamp((value - min) / (max - min), 0, 1)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme:GetColor("Accent"),
        BorderSizePixel = 0,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

    -- Knob
    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(pct, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local knobStroke = Create("UIStroke", {
        Color = Theme:GetColor("Accent"),
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = knob,
    })

    local dragging = false

    local function updateValue(inputX)
        local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        local newPct = (value - min) / (max - min)

        local t = TweenInfo.new(0.08, Enum.EasingStyle.Linear)
        TweenService:Create(fill, t, { Size = UDim2.new(newPct, 0, 1, 0) }):Play()
        TweenService:Create(knob, t, { Position = UDim2.new(newPct, 0, 0.5, 0) }):Play()
        valLabel.Text = tostring(value) .. suffix
        pcall(callback, value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input.Position.X)
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
            updateValue(input.Position.X)
        end
    end)

    local api = {}
    function api:Set(v)
        value = math.clamp(v, min, max)
        local p = (value - min) / (max - min)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valLabel.Text = tostring(value) .. suffix
    end
    function api:Get() return value end
    function api:SetText(t) frame:FindFirstChildWhichIsA("TextLabel", true).Text = t end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Slider