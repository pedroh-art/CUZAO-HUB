--!strict
--[[
    CUZAO HUB - Toggle Component
    Componente de alternância (on/off) reutilizável
]]

local Toggle = {}

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Theme)

local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function AddCorner(parent, r)
    return Create("UICorner", { CornerRadius = r or UDim.new(0, 8), Parent = parent })
end

function Toggle.new(config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local state = default
    local conn = nil

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = config.Parent,
    })

    -- Label
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Track
    local track = Create("Frame", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border"),
        BorderSizePixel = 0,
        Parent = frame,
    })
    AddCorner(track, UDim.new(1, 0))

    -- Circle
    local circle = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(circle, UDim.new(1, 0))

    -- Click target
    local clickBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame,
    })

    local function update()
        state = not state
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(track, tInfo, {
            BackgroundColor3 = state and Theme:GetColor("Accent") or Theme:GetColor("Border")
        }):Play()
        TweenService:Create(circle, tInfo, {
            Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }):Play()
        pcall(callback, state)
    end

    clickBtn.MouseButton1Click:Connect(update)

    local api = {}
    function api:Set(v)
        if v ~= state then update() end
    end
    function api:Get() return state end
    function api:SetText(t) label.Text = t end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Toggle