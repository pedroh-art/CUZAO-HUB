--!strict
--[[
    CUZAO HUB - Keybind Component
    Configurador de tecla de atalho
]]

local Keybind = {}

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

function Keybind.new(config)
    config = config or {}
    local text = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local changedCallback = config.ChangedCallback or function() end

    local currentBind = default
    local listening = false

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = config.Parent,
    })

    -- Label
    Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Bind button
    local bindBtn = Create("TextButton", {
        Size = UDim2.new(0, 88, 0, 28),
        Position = UDim2.new(1, -96, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = currentBind.Name or "None",
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = bindBtn })
    local bindStroke = Create("UIStroke", {
        Color = Theme:GetColor("InputBorder"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = bindBtn,
    })

    local scale = Create("UIScale", { Scale = 1, Parent = bindBtn })

    -- Click to listen
    bindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "..."
        TweenService:Create(bindBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme:GetColor("Accent"),
        }):Play()
        TweenService:Create(bindStroke, TweenInfo.new(0.15), {
            Color = Theme:GetColor("Accent"),
        }):Play()
    end)

    bindBtn.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1), { Scale = 1.04 }):Play()
    end)
    bindBtn.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1), { Scale = 1 }):Play()
    end)

    -- Input listener
    local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentBind = input.KeyCode
            bindBtn.Text = currentBind.Name
            listening = false
            TweenService:Create(bindBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme:GetColor("InputBg"),
            }):Play()
            TweenService:Create(bindStroke, TweenInfo.new(0.15), {
                Color = Theme:GetColor("InputBorder"),
            }):Play()
            pcall(changedCallback, currentBind)
        elseif listening and input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Allow mouse button binding
            currentBind = input.UserInputType
            bindBtn.Text = "Mouse" .. tostring(input.UserInputType.Value)
            listening = false
            TweenService:Create(bindBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme:GetColor("InputBg"),
            }):Play()
            TweenService:Create(bindStroke, TweenInfo.new(0.15), {
                Color = Theme:GetColor("InputBorder"),
            }):Play()
            pcall(changedCallback, currentBind)
        end
    end)

    local api = {}
    function api:Set(key)
        currentBind = key
        bindBtn.Text = key.Name or tostring(key)
    end
    function api:Get() return currentBind end
    function api:SetText(t) frame:FindFirstChildWhichIsA("TextLabel").Text = t end
    function api:Destroy()
        inputConn:Disconnect()
        frame:Destroy()
    end
    function api:GetFrame() return frame end

    return api
end

return Keybind