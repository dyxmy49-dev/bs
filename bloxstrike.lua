-- BloxStrike | 100% self-contained | No external URLs

local _M = {}  -- module sources

_M['main.lua'] = [[
local bootstrap = ...
if type(bootstrap) ~= "table" then
    bootstrap = {}
end
local function normalizePath(path)
    return tostring(path or ""):gsub("\\", "/")
end
local function joinPath(...)
    local parts = { ... }
    local out = {}
    for _, part in ipairs(parts) do
        local text = normalizePath(part):gsub("^/+", ""):gsub("/+$", "")
        if text ~= "" then
            out[#out + 1] = text
        end
    end
    return table.concat(out, "/")
end
local moduleCache = {}
local function loadLocal(relativePath)
    if moduleCache[relativePath] ~= nil then
        return moduleCache[relativePath]
    end
    local preloadedSources = bootstrap.moduleSources
    local chunk, err = nil, nil
    if type(preloadedSources) == "table" and type(preloadedSources[relativePath]) == "string" then
        local source = preloadedSources[relativePath]
        chunk, err = loadstring(source, "@" .. relativePath)
    end
    assert(chunk, err or ("Failed to load module: " .. tostring(relativePath)))
    local result = chunk()
    moduleCache[relativePath] = result
    return result
end
local Cleaner = loadLocal("src/shared/Cleaner.lua")
local ErrorHandler = loadLocal("src/shared/ErrorHandler.lua")
local Services = loadLocal("src/shared/Services.lua")
local Globals = loadLocal("src/shared/Globals.lua")
local UILib = loadLocal("ui_lib.lua")
local Aimbot = loadLocal("src/features/combat/Aimbot.lua")
local TriggerBot = loadLocal("src/features/combat/TriggerBot.lua")
local Hitbox = loadLocal("src/features/combat/Hitbox.lua")
local BunnyHop = loadLocal("src/features/movement/BunnyHop.lua")
local Skinchanger = loadLocal("src/features/skins/Skinchanger.lua")
local ESP = loadLocal("src/features/visuals/ESP.lua")
local Chams = loadLocal("src/features/visuals/Chams.lua")
local KillEffects = loadLocal("src/features/visuals/KillEffects.lua")
local WorldEffects = loadLocal("src/features/visuals/WorldEffects.lua")
]]

_M['ui_lib.lua'] = 'return {}'

local _cache = {}
local function req(p)
    if _cache[p] then return _cache[p] end
    local src = _M[p]
    if not src then error('Module not found: ' .. p) end
    local r = assert(loadstring(src, '@'..p))()
    _cache[p] = r
    return r
end

local bootstrap = {
    DEFAULT_BASE_URL = 'dropbox',
    baseUrl = '',
    moduleSources = _M,
}
assert(loadstring(_M['main.lua'], '@main.lua'))(bootstrap)