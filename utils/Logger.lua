--[[
    CUZAO HUB - Logger
    Sistema de logs coloridos e estruturados
]]

local Logger = {}

Logger.Config = {
    Enabled = true,
    Level = "INFO", -- DEBUG, INFO, WARN, ERROR
    ShowTimestamp = true,
    ShowModule = true,
    MaxHistory = 100,
}

Logger.History = {}

-- ANSI color codes for console
local Colors = {
    DEBUG = "\27[36m",   -- Cyan
    INFO = "\27[37m",    -- White
    WARN = "\27[33m",    -- Yellow
    ERROR = "\27[31m",   -- Red
    SUCCESS = "\27[32m", -- Green
    RESET = "\27[0m",
}

local Icons = {
    DEBUG = "🔍",
    INFO = "ℹ️ ",
    WARN = "⚠️ ",
    ERROR = "❌",
    SUCCESS = "✅",
}

local LevelPriority = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    SUCCESS = 2,
}

function Logger:ShouldLog(level)
    if not self.Config.Enabled then return false end
    local current = LevelPriority[self.Config.Level] or 2
    local target = LevelPriority[level] or 2
    return target >= current
end

function Logger:Log(level, module, message, data)
    if not self:ShouldLog(level) then return end

    local timestamp = os.date("%H:%M:%S")
    local prefix = Icons[level] or "•"

    local parts = {}
    if self.Config.ShowTimestamp then
        table.insert(parts, string.format("[%s]", timestamp))
    end
    table.insert(parts, string.format("[%s %s]", prefix, level))
    if self.Config.ShowModule and module then
        table.insert(parts, string.format("[%s]", module))
    end
    table.insert(parts, message)

    local logLine = table.concat(parts, " ")

    -- Console output
    local color = Colors[level] or ""
    print(color .. logLine .. Colors.RESET)

    -- Data dump
    if data then
        print("  Data: " .. tostring(data))
    end

    -- History
    table.insert(self.History, {
        Time = os.time(),
        Level = level,
        Module = module,
        Message = message,
        Data = data,
    })

    -- Trim history
    while #self.History > self.Config.MaxHistory do
        table.remove(self.History, 1)
    end
end

-- Shorthand methods
function Logger:Debug(module, message, data)
    self:Log("DEBUG", module, message, data)
end

function Logger:Info(module, message, data)
    self:Log("INFO", module, message, data)
end

function Logger:Warn(module, message, data)
    self:Log("WARN", module, message, data)
end

function Logger:Error(module, message, data)
    self:Log("ERROR", module, message, data)
end

function Logger:Success(module, message, data)
    self:Log("SUCCESS", module, message, data)
end

function Logger:SetLevel(level)
    self.Config.Level = level
end

function Logger:SetEnabled(enabled)
    self.Config.Enabled = enabled
end

function Logger:GetHistory(level)
    if level then
        local filtered = {}
        for _, entry in ipairs(self.History) do
            if entry.Level == level then
                table.insert(filtered, entry)
            end
        end
        return filtered
    end
    return self.History
end

function Logger:ClearHistory()
    self.History = {}
end

function Logger:ExportHistory()
    local lines = {}
    for _, entry in ipairs(self.History) do
        local line = string.format("[%s] [%s] [%s] %s",
            os.date("%Y-%m-%d %H:%M:%S", entry.Time),
            entry.Level,
            entry.Module or "Global",
            entry.Message
        )
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

return Logger