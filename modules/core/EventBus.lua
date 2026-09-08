--[[
    CUZAO HUB - Event Bus Module
    Sistema de eventos para comunicação desacoplada entre módulos
]]

local EventBus = {}
EventBus._events = {}
EventBus._onceEvents = {}
EventBus._wildcardListeners = {}

-- Conectar a um evento
function EventBus:On(eventName, callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    self._events[eventName] = self._events[eventName] or {}
    table.insert(self._events[eventName], callback)

    -- Retornar função para desconectar
    return function()
        self:Off(eventName, callback)
    end
end

-- Conectar a um evento apenas uma vez
function EventBus:Once(eventName, callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    self._onceEvents[eventName] = self._onceEvents[eventName] or {}
    table.insert(self._onceEvents[eventName], callback)

    return function()
        self:OffOnce(eventName, callback)
    end
end

-- Conectar a todos os eventos (wildcard)
function EventBus:OnAny(callback)
    if type(callback) ~= "function" then
        warn("[EventBus] Callback deve ser uma função")
        return function() end
    end

    table.insert(self._wildcardListeners, callback)

    return function()
        self:OffAny(callback)
    end
end

-- Desconectar de um evento
function EventBus:Off(eventName, callback)
    if not self._events[eventName] then return false end

    for i, cb in ipairs(self._events[eventName]) do
        if cb == callback then
            table.remove(self._events[eventName], i)
            return true
        end
    end
    return false
end

-- Desconectar de um evento once
function EventBus:OffOnce(eventName, callback)
    if not self._onceEvents[eventName] then return false end

    for i, cb in ipairs(self._onceEvents[eventName]) do
        if cb == callback then
            table.remove(self._onceEvents[eventName], i)
            return true
        end
    end
    return false
end

-- Desconectar de wildcard
function EventBus:OffAny(callback)
    for i, cb in ipairs(self._wildcardListeners) do
        if cb == callback then
            table.remove(self._wildcardListeners, i)
            return true
        end
    end
    return false
end

-- Emitir evento
function EventBus:Emit(eventName, ...)
    local args = {...}

    -- Listeners normais
    if self._events[eventName] then
        for _, callback in ipairs(self._events[eventName]) do
            task.spawn(function()
                local success, err = pcall(callback, unpack(args))
                if not success then
                    warn("[EventBus] Erro no listener '" .. eventName .. "': " .. tostring(err))
                end
            end)
        end
    end

    -- Listeners once (executam e removem)
    if self._onceEvents[eventName] then
        for _, callback in ipairs(self._onceEvents[eventName]) do
            task.spawn(function()
                local success, err = pcall(callback, unpack(args))
                if not success then
                    warn("[EventBus] Erro no listener once '" .. eventName .. "': " .. tostring(err))
                end
            end)
        end
        self._onceEvents[eventName] = nil
    end

    -- Wildcard listeners
    for _, callback in ipairs(self._wildcardListeners) do
        task.spawn(function()
            local success, err = pcall(callback, eventName, unpack(args))
            if not success then
                warn("[EventBus] Erro no wildcard listener: " .. tostring(err))
            end
        end)
    end
end

-- Emitir evento de forma síncrona (bloqueante)
function EventBus:EmitSync(eventName, ...)
    local args = {...}
    local results = {}

    if self._events[eventName] then
        for _, callback in ipairs(self._events[eventName]) do
            local success, result = pcall(callback, unpack(args))
            if success then
                table.insert(results, result)
            else
                warn("[EventBus] Erro no listener sync '" .. eventName .. "': " .. tostring(result))
            end
        end
    end

    if self._onceEvents[eventName] then
        for _, callback in ipairs(self._onceEvents[eventName]) do
            local success, result = pcall(callback, unpack(args))
            if success then
                table.insert(results, result)
            else
                warn("[EventBus] Erro no listener once sync '" .. eventName .. "': " .. tostring(result))
            end
        end
        self._onceEvents[eventName] = nil
    end

    return results
end

-- Aguardar evento (promise-like)
function EventBus:WaitFor(eventName, timeout)
    timeout = timeout or 5
    local thread = coroutine.running()
    local connection

    connection = self:Once(eventName, function(...)
        if connection then connection() end
        task.spawn(thread, ...)
    end)

    task.delay(timeout, function()
        if connection then
            connection()
            task.spawn(thread, nil, "timeout")
        end
    end)

    return coroutine.yield()
end

-- Limpar todos os listeners de um evento
function EventBus:Clear(eventName)
    self._events[eventName] = nil
    self._onceEvents[eventName] = nil
end

-- Limpar todos os eventos
function EventBus:ClearAll()
    self._events = {}
    self._onceEvents = {}
    self._wildcardListeners = {}
end

-- Obter contagem de listeners
function EventBus:GetListenerCount(eventName)
    local count = 0
    if self._events[eventName] then
        count = count + #self._events[eventName]
    end
    if self._onceEvents[eventName] then
        count = count + #self._onceEvents[eventName]
    end
    return count
end

-- Listar todos os eventos registrados
function EventBus:GetRegisteredEvents()
    local events = {}
    for name, _ in pairs(self._events) do
        table.insert(events, name)
    end
    for name, _ in pairs(self._onceEvents) do
        if not self._events[name] then
            table.insert(events, name .. " (once)")
        end
    end
    return events
end

-- Debug: imprimir todos os listeners
function EventBus:DebugPrint()
    print("=== EventBus Debug ===")
    for name, listeners in pairs(self._events) do
        print("  " .. name .. ": " .. #listeners .. " listeners")
    end
    for name, listeners in pairs(self._onceEvents) do
        print("  " .. name .. " (once): " .. #listeners .. " listeners")
    end
    print("  Wildcard: " .. #self._wildcardListeners .. " listeners")
    print("=====================")
end

return EventBus