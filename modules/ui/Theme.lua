local Theme = {}

Theme.Presets = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(24, 24, 24),
        Tertiary = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentSecondary = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        TextMuted = Color3.fromRGB(120, 120, 120),
        Border = Color3.fromRGB(40, 40, 40),
        BorderActive = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Hover = Color3.fromRGB(36, 36, 36),
        Pressed = Color3.fromRGB(42, 42, 42),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.5),
        TabBackground = Color3.fromRGB(22, 22, 22),
        TabHover = Color3.fromRGB(30, 30, 30),
        TabActive = Color3.fromRGB(88, 101, 242),
        ScrollBar = Color3.fromRGB(60, 60, 60),
        ScrollBarHover = Color3.fromRGB(80, 80, 80),
        NotificationBg = Color3.fromRGB(24, 24, 24),
        NotificationBorder = Color3.fromRGB(40, 40, 40),
        TooltipBg = Color3.fromRGB(30, 30, 30),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(24, 24, 24),
        InputBorder = Color3.fromRGB(40, 40, 40),
        InputFocused = Color3.fromRGB(88, 101, 242),
        Placeholder = Color3.fromRGB(100, 100, 100),
        Divider = Color3.fromRGB(40, 40, 40),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(250, 250, 250),
        Secondary = Color3.fromRGB(240, 240, 240),
        Tertiary = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentSecondary = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(20, 20, 20),
        TextSecondary = Color3.fromRGB(80, 80, 80),
        TextMuted = Color3.fromRGB(140, 140, 140),
        Border = Color3.fromRGB(220, 220, 220),
        BorderActive = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Hover = Color3.fromRGB(235, 235, 235),
        Pressed = Color3.fromRGB(225, 225, 225),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.3),
        TabBackground = Color3.fromRGB(245, 245, 245),
        TabHover = Color3.fromRGB(235, 235, 235),
        TabActive = Color3.fromRGB(88, 101, 242),
        ScrollBar = Color3.fromRGB(180, 180, 180),
        ScrollBarHover = Color3.fromRGB(160, 160, 160),
        NotificationBg = Color3.fromRGB(245, 245, 245),
        NotificationBorder = Color3.fromRGB(220, 220, 220),
        TooltipBg = Color3.fromRGB(30, 30, 30),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(255, 255, 255),
        InputBorder = Color3.fromRGB(200, 200, 200),
        InputFocused = Color3.fromRGB(88, 101, 242),
        Placeholder = Color3.fromRGB(150, 150, 150),
        Divider = Color3.fromRGB(220, 220, 220),
    },
    RGB = {
        Name = "RGB",
        Background = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(20, 20, 28),
        Tertiary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 0, 128),
        AccentSecondary = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        TextMuted = Color3.fromRGB(140, 140, 160),
        Border = Color3.fromRGB(40, 40, 60),
        BorderActive = Color3.fromRGB(255, 0, 128),
        Success = Color3.fromRGB(0, 255, 128),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 64, 64),
        Hover = Color3.fromRGB(30, 30, 45),
        Pressed = Color3.fromRGB(35, 35, 50),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0, 0.6),
        TabBackground = Color3.fromRGB(18, 18, 25),
        TabHover = Color3.fromRGB(25, 25, 35),
        TabActive = Color3.fromRGB(255, 0, 128),
        ScrollBar = Color3.fromRGB(50, 50, 70),
        ScrollBarHover = Color3.fromRGB(70, 70, 90),
        NotificationBg = Color3.fromRGB(20, 20, 28),
        NotificationBorder = Color3.fromRGB(40, 40, 60),
        TooltipBg = Color3.fromRGB(25, 25, 35),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(20, 20, 28),
        InputBorder = Color3.fromRGB(40, 40, 60),
        InputFocused = Color3.fromRGB(255, 0, 128),
        Placeholder = Color3.fromRGB(100, 100, 120),
        Divider = Color3.fromRGB(40, 40, 60),
        RGBEnabled = true,
        RGBSpeed = 2,
    },
    CUZAO = {
        Name = "CUZAO",
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 15, 15),
        Tertiary = Color3.fromRGB(28, 18, 18),
        Accent = Color3.fromRGB(255, 0, 0),
        AccentSecondary = Color3.fromRGB(200, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(220, 200, 200),
        TextMuted = Color3.fromRGB(160, 140, 140),
        Border = Color3.fromRGB(60, 30, 30),
        BorderActive = Color3.fromRGB(255, 0, 0),
        Success = Color3.fromRGB(200, 255, 100),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(255, 60, 60),
        Hover = Color3.fromRGB(35, 25, 25),
        Pressed = Color3.fromRGB(45, 30, 30),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(20, 0, 0, 0.7),
        TabBackground = Color3.fromRGB(18, 12, 12),
        TabHover = Color3.fromRGB(28, 18, 18),
        TabActive = Color3.fromRGB(255, 0, 0),
        ScrollBar = Color3.fromRGB(70, 35, 35),
        ScrollBarHover = Color3.fromRGB(100, 50, 50),
        NotificationBg = Color3.fromRGB(20, 15, 15),
        NotificationBorder = Color3.fromRGB(60, 30, 30),
        TooltipBg = Color3.fromRGB(28, 18, 18),
        TooltipText = Color3.fromRGB(255, 255, 255),
        InputBg = Color3.fromRGB(20, 15, 15),
        InputBorder = Color3.fromRGB(60, 30, 30),
        InputFocused = Color3.fromRGB(255, 0, 0),
        Placeholder = Color3.fromRGB(140, 100, 100),
        Divider = Color3.fromRGB(60, 30, 30),
    },
}

Theme.Current = "Dark"
Theme.Active = Theme.Presets.Dark
Theme.RGBTime = 0
Theme.RGBConnection = nil

function Theme:SetTheme(name)
    local preset = self.Presets[name]
    if not preset then
        warn("[Theme] Tema não encontrado: " .. tostring(name))
        return false
    end

    self.Current = name
    self.Active = preset

    if self.RGBConnection then
        self.RGBConnection:Disconnect()
        self.RGBConnection = nil
    end

    if preset.RGBEnabled then
        self:StartRGB()
    end

    return true
end

function Theme:GetColor(key)
    return self.Active[key]
end

function Theme:GetCurrentThemeName()
    return self.Current
end

function Theme:StartRGB()
    local RunService = game:GetService("RunService")
    self.RGBTime = 0

    self.RGBConnection = RunService.RenderStepped:Connect(function(deltaTime)
        self.RGBTime = self.RGBTime + deltaTime * (self.Active.RGBSpeed or 2)

        local hue = (self.RGBTime * 50) % 360
        local saturation = 1
        local value = 1

        local function hsvToRgb(h, s, v)
            local c = v * s
            local x = c * (1 - math.abs((h / 60) % 2 - 1))
            local m = v - c
            local r, g, b

            if h < 60 then r, g, b = c, x, 0
            elseif h < 120 then r, g, b = x, c, 0
            elseif h < 180 then r, g, b = 0, c, x
            elseif h < 240 then r, g, b = 0, x, c
            elseif h < 300 then r, g, b = x, 0, c
            else r, g, b = c, 0, x end

            return Color3.new(r + m, g + m, b + m)
        end

        local rgbColor = hsvToRgb(hue, saturation, value)
        local rgbColor2 = hsvToRgb((hue + 180) % 360, saturation, value)

        self.Active.Accent = rgbColor
        self.Active.AccentSecondary = rgbColor2
        self.Active.BorderActive = rgbColor
        self.Active.TabActive = rgbColor
        self.Active.InputFocused = rgbColor
        self.Active.ScrollBarHover = rgbColor:Lerp(Color3.new(1, 1, 1), 0.3)
    end)
end

function Theme:StopRGB()
    if self.RGBConnection then
        self.RGBConnection:Disconnect()
        self.RGBConnection = nil
    end
end

function Theme:LerpColor(color1, color2, alpha)
    return color1:Lerp(color2, alpha)
end

function Theme:CreateGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    return gradient
end

function Theme:GetRGBColor(offset)
    if not self.Active.RGBEnabled then return self.Active.Accent end

    local hue = ((self.RGBTime * 50) + (offset or 0)) % 360
    local c = 1 * 1
    local x = c * (1 - math.abs((hue / 60) % 2 - 1))
    local m = 1 - c
    local r, g, b

    if hue < 60 then r, g, b = c, x, 0
    elseif hue < 120 then r, g, b = x, c, 0
    elseif hue < 180 then r, g, b = 0, c, x
    elseif hue < 240 then r, g, b = 0, x, c
    elseif hue < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end

    return Color3.new(r + m, g + m, b + m)
end

return Theme