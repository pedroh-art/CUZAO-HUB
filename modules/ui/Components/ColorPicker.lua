--!strict
--[[
    CUZAO HUB - ColorPicker Component
    Seletor de cor com paleta de presets e gradientes HSV
]]

local ColorPicker = {}

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

function ColorPicker.new(config)
    config = config or {}
    local text = config.Text or "Color"
    local default = config.Default or Theme:GetColor("Accent")
    local callback = config.Callback or function() end

    local currentColor = default
    local isOpen = false

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = config.Parent,
    })

    -- Label
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Color preview
    local preview = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        Text = "",
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
    local previewStroke = Create("UIStroke", {
        Color = Theme:GetColor("Border"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = preview,
    })

    -- Palette popup
    local palette = Create("Frame", {
        Size = UDim2.new(0, 190, 0, 130),
        Position = UDim2.new(1, -198, 0, 40),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        ZIndex = 15,
        Visible = false,
        ClipsDescendants = true,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = palette })
    Create("UIStroke", {
        Color = Theme:GetColor("InputBorder"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = palette,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = palette,
    })

    -- Preset colors
    local presets = {
        -- Row 1: Primary
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 128, 255),
        Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 0, 255),
        -- Row 2: Pastel / Dark
        Color3.fromRGB(255, 180, 180), Color3.fromRGB(255, 220, 150),
        Color3.fromRGB(255, 255, 180), Color3.fromRGB(180, 255, 180),
        Color3.fromRGB(180, 255, 255), Color3.fromRGB(180, 180, 255),
        Color3.fromRGB(220, 180, 255), Color3.fromRGB(255, 180, 255),
        -- Row 3: Grayscale + accent
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200),
        Color3.fromRGB(140, 140, 140), Color3.fromRGB(80, 80, 80),
        Color3.fromRGB(40, 40, 40), Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(255, 100, 50), Color3.fromRGB(50, 200, 100),
    }

    local grid = Create("UIGridLayout", {
        CellSize = UDim2.new(0, 20, 0, 20),
        CellPadding = UDim2.new(0, 3, 0, 3),
        Parent = palette,
    })

    local swatches = {}
    for i, color in ipairs(presets) do
        local swatch = Create("TextButton", {
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 16,
            LayoutOrder = i,
            Parent = palette,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = swatch })

        local swatchStroke = Create("UIStroke", {
            Color = Theme:GetColor("Border"),
            Thickness = 1,
            Transparency = color == currentColor and 0 or 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ZIndex = 17,
            Parent = swatch,
        })

        swatch.MouseButton1Click:Connect(function()
            currentColor = color
            TweenService:Create(preview, TweenInfo.new(0.15), {
                BackgroundColor3 = color
            }):Play()
            TweenService:Create(previewStroke, TweenInfo.new(0.15), {
                Color = color
            }):Play()

            -- Update selection indicators
            for _, child in ipairs(palette:GetChildren()) do
                if child:IsA("TextButton") then
                    local cs = child:FindFirstChildWhichIsA("UIStroke")
                    if cs then
                        cs.Transparency = child.BackgroundColor3 == color and 0 or 1
                    end
                end
            end

            pcall(callback, color)
        end)

        swatch.MouseEnter:Connect(function()
            TweenService:Create(swatch, TweenInfo.new(0.08), { Size = UDim2.new(0, 23, 0, 23) }):Play()
        end)
        swatch.MouseLeave:Connect(function()
            TweenService:Create(swatch, TweenInfo.new(0.08), { Size = UDim2.new(0, 20, 0, 20) }):Play()
        end)

        swatches[i] = swatch
    end

    -- RGB sliders section
    local rgbY = 88
    local function MakeRGBSlider(label, val, yPos, callbackRGB)
        Create("TextLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 8, 0, yPos),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Theme:GetColor("TextMuted"),
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            ZIndex = 16,
            Parent = palette,
        })

        local track = Create("Frame", {
            Size = UDim2.new(1, -30, 0, 4),
            Position = UDim2.new(0, 28, 0, yPos + 6),
            BackgroundColor3 = Theme:GetColor("Border"),
            BorderSizePixel = 0,
            ZIndex = 16,
            Parent = palette,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local fill = Create("Frame", {
            Size = UDim2.new(val / 255, 0, 1, 0),
            BackgroundColor3 = Theme:GetColor("Accent"),
            BorderSizePixel = 0,
            ZIndex = 17,
            Parent = track,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

        local dragging = false
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                callbackRGB(math.floor(p * 255))
            end
        end)

        return { Set = function(_, v) fill.Size = UDim2.new(math.clamp(v / 255, 0, 1), 0, 1, 0) end }
    end

    local r, g, b = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)

    MakeRGBSlider("R", r, rgbY, function(v)
        r = v
        currentColor = Color3.fromRGB(r, g, b)
        preview.BackgroundColor3 = currentColor
        pcall(callback, currentColor)
    end)

    MakeRGBSlider("G", g, rgbY + 22, function(v)
        g = v
        currentColor = Color3.fromRGB(r, g, b)
        preview.BackgroundColor3 = currentColor
        pcall(callback, currentColor)
    end)

    MakeRGBSlider("B", b, rgbY + 44, function(v)
        b = v
        currentColor = Color3.fromRGB(r, g, b)
        preview.BackgroundColor3 = currentColor
        pcall(callback, currentColor)
    end)

    -- Toggle palette
    preview.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        palette.Visible = isOpen
    end)

    local api = {}
    function api:Set(color)
        currentColor = color
        preview.BackgroundColor3 = color
        previewStroke.Color = color
        r = math.floor(color.R * 255)
        g = math.floor(color.G * 255)
        b = math.floor(color.B * 255)
    end
    function api:Get() return currentColor end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return ColorPicker