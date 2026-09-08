--!strict
--[[
    CUZAO HUB - Dropdown Component
    Menu suspenso com lista de opções
]]

local Dropdown = {}

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

function Dropdown.new(config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or options[1] or ""
    local callback = config.Callback or function() end
    local multiSelect = config.MultiSelect or false

    local value = default
    local selected = multiSelect and { default } or nil
    local isOpen = false

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = config.Parent,
    })

    -- Title
    Create("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Select button
    local selectBtn = Create("TextButton", {
        Size = UDim2.new(0, 135, 0, 28),
        Position = UDim2.new(1, -143, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        Text = "",
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = selectBtn })
    local selStroke = Create("UIStroke", {
        Color = Theme:GetColor("InputBorder"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = selectBtn,
    })

    local selLabel = Create("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = selectBtn,
    })

    local arrow = Create("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme:GetColor("TextMuted"),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        Parent = selectBtn,
    })

    -- Dropdown list
    local maxVisible = math.min(#options, 6)
    local listFrame = Create("ScrollingFrame", {
        Size = UDim2.new(0, 135, 0, maxVisible * 28 + 8),
        Position = UDim2.new(1, -143, 0, 32),
        BackgroundColor3 = Theme:GetColor("InputBg"),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme:GetColor("ScrollBar"),
        CanvasSize = UDim2.new(0, 0, 0, #options * 28 + 8),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 12,
        Visible = false,
        ClipsDescendants = true,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = listFrame })
    Create("UIStroke", {
        Color = Theme:GetColor("InputBorder"),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = listFrame,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = listFrame,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = listFrame,
    })

    local optionBtns = {}

    for i, opt in ipairs(options) do
        local ob = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "  " .. opt,
            TextColor3 = Theme:GetColor("Text"),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
            LayoutOrder = i,
            Parent = listFrame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ob })

        ob.MouseEnter:Connect(function()
            TweenService:Create(ob, TweenInfo.new(0.1), {
                BackgroundTransparency = 0,
                BackgroundColor3 = Theme:GetColor("Hover"),
            }):Play()
        end)
        ob.MouseLeave:Connect(function()
            if opt ~= value then
                TweenService:Create(ob, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            end
        end)

        ob.MouseButton1Click:Connect(function()
            value = opt
            selLabel.Text = opt
            isOpen = false
            listFrame.Visible = false
            TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = 0 }):Play()

            -- Highlight selected
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    local isSelected = child.Text:gsub("^%s+", "") == opt
                    TweenService:Create(child, TweenInfo.new(0.1), {
                        BackgroundTransparency = isSelected and 0 or 1,
                        BackgroundColor3 = Theme:GetColor("Accent"),
                    }):Play()
                end
            end

            pcall(callback, opt)
        end)

        optionBtns[opt] = ob
    end

    selectBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        TweenService:Create(arrow, TweenInfo.new(0.15), {
            Rotation = isOpen and 180 or 0
        }):Play()

        if isOpen then
            selStroke.Color = Theme:GetColor("Accent")
        else
            selStroke.Color = Theme:GetColor("InputBorder")
        end
    end)

    local api = {}
    function api:Set(v)
        value = v
        selLabel.Text = v
    end
    function api:Get() return value end
    function api:Refresh(newOptions)
        options = newOptions
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        maxVisible = math.min(#options, 6)
        listFrame.Size = UDim2.new(0, 135, 0, maxVisible * 28 + 8)
        for i, opt in ipairs(options) do
            local ob = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "  " .. opt,
                TextColor3 = Theme:GetColor("Text"),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
                LayoutOrder = i,
                Parent = listFrame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ob })
            ob.MouseButton1Click:Connect(function()
                value = opt
                selLabel.Text = opt
                isOpen = false
                listFrame.Visible = false
                pcall(callback, opt)
            end)
        end
    end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Dropdown