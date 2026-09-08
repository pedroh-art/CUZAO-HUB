--!strict
--[[
    CUZAO HUB - Input Component
    Campo de texto com placeholder e validação
]]

local Input = {}

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

function Input.new(config)
    config = config or {}
    local text = config.Text or "Input"
    local placeholder = config.Placeholder or ""
    local default = config.Default or ""
    local callback = config.Callback or function() end
    local order = config.Order or 0
    local clearOnFocus = config.ClearOnFocus or false
    local multiLine = config.MultiLine or false

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = config.Parent,
    })

    -- Label
    Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 2),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- TextBox container
    local container = Create("Frame", {
        Size = UDim2.new(1, -16, 0, multiLine and 60 or 30),
        Position = UDim2.new(0, 8, 0, 22),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = container })
    local containerStroke = Create("UIStroke", {
        Color = Theme:GetColor("InputBorder"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = container,
    })

    local textBox = Create("TextBox", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme:GetColor("Placeholder"),
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = multiLine and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        TextWrapped = multiLine,
        MultiLine = multiLine,
        ClearTextOnFocus = clearOnFocus,
        Parent = container,
    })

    -- Character count (optional)
    local charCount = nil
    if config.ShowCharCount then
        charCount = Create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 14),
            Position = UDim2.new(0, 6, 1, -14),
            BackgroundTransparency = 1,
            Text = tostring(#textBox.Text) .. "/" .. tostring(config.MaxLength or 100),
            TextColor3 = Theme:GetColor("TextMuted"),
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container,
        })
    end

    -- Focus effects
    textBox.Focused:Connect(function()
        TweenService:Create(containerStroke, TweenInfo.new(0.15), {
            Color = Theme:GetColor("Accent"),
        }):Play()
    end)

    textBox.FocusLost:Connect(function()
        TweenService:Create(containerStroke, TweenInfo.new(0.15), {
            Color = Theme:GetColor("InputBorder"),
        }):Play()
        pcall(callback, textBox.Text)
    end)

    if charCount then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local maxLen = config.MaxLength or 100
            local len = #textBox.Text
            charCount.Text = tostring(len) .. "/" .. tostring(maxLen)
            if len > maxLen then
                charCount.TextColor3 = Theme:GetColor("Error")
            else
                charCount.TextColor3 = Theme:GetColor("TextMuted")
            end
        end)
    end

    local api = {}
    function api:Set(v) textBox.Text = v end
    function api:Get() return textBox.Text end
    function api:SetPlaceholder(p) textBox.PlaceholderText = p end
    function api:SetText(t) frame:FindFirstChildWhichIsA("TextLabel").Text = t end
    function api:Focus() textBox:CaptureFocus() end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Input