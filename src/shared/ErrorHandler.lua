local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

function ErrorHandler.new(source)
    return setmetatable({ source = source or "?" }, ErrorHandler)
end

function ErrorHandler:Spawn(name, fn)
    task.spawn(function()
        local ok, err = pcall(fn)
        if not ok then
            warn(string.format("[%s] %s: %s", self.source, name, tostring(err)))
        end
    end)
end

function ErrorHandler:Connect(signal, name, fn)
    return signal:Connect(function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn(string.format("[%s] %s: %s", self.source, name, tostring(err)))
        end
    end)
end

function ErrorHandler:wrap(fn)
    return function(...)
        local args = {...}
        local ok, err = pcall(function() fn(table.unpack(args)) end)
        if not ok then
            warn(string.format("[%s] Error: %s", self.source, tostring(err)))
        end
    end
end

function ErrorHandler:try(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn(string.format("[%s] Error: %s", self.source, tostring(err)))
    end
    return ok
end

return ErrorHandler