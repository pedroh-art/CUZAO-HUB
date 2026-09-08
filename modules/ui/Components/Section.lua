--!strict
--[[
    CUZAO HUB - Section Component
    Seção agrupadora com header e container de componentes
]]

local Section = {}

local Theme = require(script.Parent.Parent.Theme)

local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Section.new(config)
    config = config or {}
    local title = config.Title or "Section"
    local order = config.Order or 0

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = config.Parent,
    })

    local layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = frame,
    })

    -- Section header
    local header = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "  " .. string.upper(title),
        TextColor3 = Theme:GetColor("Accent"),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Parent = frame,
    })

    -- Separator line
    Create("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = Theme:GetColor("Divider"),
        BorderSizePixel = 0,
        LayoutOrder = 0,
        Parent = frame,
    })

    local componentOrder = 1
    local api = {}

    function api:GetNextOrder()
        componentOrder = componentOrder + 1
        return componentOrder
    end

    function api:AddParagraph(titleText, desc)
        local pf = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = api:GetNextOrder(),
            Parent = frame,
        })

        Create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 0),
            Position = UDim2.new(0, 8, 0, 4),
            BackgroundTransparency = 1,
            Text = titleText,
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
                Position = UDim2.new(0, 8, 0, 22),
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

    function api:AddDivider()
        Create("Frame", {
            Size = UDim2.new(1, -16, 0, 1),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundColor3 = Theme:GetColor("Divider"),
            BorderSizePixel = 0,
            LayoutOrder = api:GetNextOrder(),
            Parent = frame,
        })
    end

    function api:AddComponent(componentFrame, layoutOrder)
        if componentFrame then
            if componentFrame:IsA("GuiObject") then
                componentFrame.LayoutOrder = layoutOrder or api:GetNextOrder()
                componentFrame.Parent = frame
            end
        end
        return componentFrame
    end

    function api:SetTitle(t)
        header.Text = "  " .. string.upper(t)
    end

    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end
    function api:GetLayout() return layout end

    return api
end

return Section