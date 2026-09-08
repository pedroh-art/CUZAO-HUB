--!strict
--[[
    CUZAO HUB - Paragraph Component
    Texto informativo com título e descrição
]]

local Paragraph = {}

local Theme = require(script.Parent.Parent.Theme)

local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Paragraph.new(config)
    config = config or {}
    local title = config.Title or config.Text or "Paragraph"
    local description = config.Description or config.Desc
    local order = config.Order or 0

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = config.Parent,
    })

    -- Padding container
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = frame,
    })

    -- Title
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:GetColor("Text"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        Parent = frame,
    })

    -- Description (optional)
    local descLabel = nil
    local yOffset = 4

    if description and description ~= "" then
        yOffset = 4
        titleLabel.Position = UDim2.new(0, 0, 0, 0)

        descLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = Theme:GetColor("TextMuted"),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            Parent = frame,
        })
    else
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
    end

    local api = {}
    function api:SetTitle(t)
        titleLabel.Text = t
    end
    function api:SetDescription(d)
        if descLabel then
            descLabel.Text = d
        end
    end
    function api:SetText(t) titleLabel.Text = t end
    function api:Destroy() frame:Destroy() end
    function api:GetFrame() return frame end

    return api
end

return Paragraph