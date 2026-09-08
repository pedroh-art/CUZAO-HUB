--!strict
--[[
    CUZAO HUB - Button Component
    Botão com efeitos hover/press
]]

local Button = {}

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

function Button.new(config)
    config = config or {}
    local text = config.Text or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or Theme:GetColor("Accent")
    local style = config.Style or "Filled" -- Filled, Outline, Ghost

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = config.Parent,
    })

    local btnColor = color
    local btnBgTransparency = style == "Ghost" and 1 or (style == "Outline" and 1 or 0)

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = btnColor,
        BackgroundTransparency = btnBgTransparency,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

    local stroke = nil
    if style == "Outline" then
        stroke = Create("UIStroke", {
            Color = btnColor,
            Thickness = 1.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = btn,
        })
    end

    -- Scale effect
    local scale = Create("UIScale", { Scale = 1, Parent = btn })

    local hoverT = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(scale, hoverT, { Scale = 1.02 }):Play()
        if style == "Filled" then
            TweenService:Create(btn, hoverT, {
                BackgroundColor3 = btnColor:Lerp(Color3.new(1, 1, 1), 0.15),
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(scale, hoverT, { Scale = 1 }):Play()
        if style == "Filled" then
            TweenService:Create(btn, hoverT, { BackgroundColor3 = btnColor }):Play()
        end
    end)

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.05), { Scale = 0.97 }):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1), { Scale = 1.02 }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        -- Ripple flash
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = btnBgTransparency + 0.3,
        }):Play()
        task.delay(0.15, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = btnBgTransparency,
            }):Play()
        end)
        pcall(callback)
    end)

    local api = {}
    function api:SetText(t) btn.Text = t end
    function api:SetColor(c)
        btnColor = c
        btn.BackgroundColor3 = c
        if stroke then stroke.Color = c end
    end
    function api:SetCallback(cb) callback = cb end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Button