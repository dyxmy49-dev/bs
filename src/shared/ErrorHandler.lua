local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

local unpackValues = unpack or table.unpack

local function sanitizeOneLine(text, maxLen)
    local line = tostring(text or ""):gsub("[\r\n]+", " ")
    if maxLen and #line > maxLen then
        line = line:sub(1, maxLen) .. "..."
    end
    return line
end

function ErrorHandler.new(source)
    return setmetatable({
        source = source or "?",
    }, ErrorHandler)
end

function ErrorHandler:handlePcall(ok, ...)
    if ok then
        return ...
    end
    local err = sanitizeOneLine(select(1, ...), 200)
    warn(string.format("[%s] Error: %s", self.source, err))
end

function ErrorHandler:wrap(fn)
    return function(...)
        local args = { ... }
        local results = { pcall(function()
            return fn(unpackValues(args, 1, args.n or #args))
        end) }
        return self:handlePcall(unpackValues(results, 1, results.n or #results))
    end
end

function ErrorHandler:try(fn, ...)
    return self:handlePcall(pcall(fn, ...))
end

return ErrorHandler