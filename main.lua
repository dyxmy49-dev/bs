local bootstrap = ...
if type(bootstrap) ~= "table" then bootstrap = {} end

local function normalizePath(path)
    return tostring(path or ""):gsub("\\", "/")
end
local function joinPath(...)
    local parts = {...}; local out = {}
    for _, part in ipairs(parts) do
        local text = normalizePath(part):gsub("^/+", ""):gsub("/+$", "")
        if text ~= "" then out[#out+1] = text end
    end
    return table.concat(out, "/")
end

local moduleCache = {}
local httpGet = (syn and syn.request and function(url)
    local r = syn.request({Url=url,Method="GET"}); return r and r.Body
end) or (http and http.request and function(url)
    local r = http.request({Url=url,Method="GET"}); return r and r.Body
end)
if not httpGet and game and game.HttpGet then
    httpGet = function(url) return game:HttpGet(url) end
end

local function loadLocal(path)
    if moduleCache[path] ~= nil then return moduleCache[path] end
    local preloaded = bootstrap.moduleSources
    local baseUrl = bootstrap.baseUrl
    local chunk, err
    if type(preloaded) == "table" and type(preloaded[path]) == "string" then
        chunk, err = loadstring(preloaded[path], "@"..path)
    end
    if not chunk and type(baseUrl) == "string" and baseUrl ~= "" and httpGet then
        local url = joinPath(baseUrl, path)
        local ok, body = pcall(httpGet, url)
        if ok and type(body) == "string" and body ~= "" then
            chunk, err = loadstring(body, "@"..url)
        end
    end
    assert(chunk, err or ("Failed to load: "..path))
    local result = chunk()
    moduleCache[path] = result
    return result
end

assert((bootstrap.DEFAULT_BASE_URL or "") ~= "", "DEFAULT_BASE_URL must not be empty")

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

local eh = ErrorHandler.new("BloxStrike")
local context = {
    services = Services,
    globals = Globals,
    Cleaner = Cleaner,
    errorHandler = eh,
}

local features = {
    aimbot = Aimbot.new(context),
    triggerbot = TriggerBot.new(context),
    hitbox = Hitbox.new(context),
    bunnyhop = BunnyHop.new(context),
    skinchanger = Skinchanger.new(context),
    esp = ESP.new(context),
    chams = Chams.new(context),
    killeffects = KillEffects.new(context),
    worldeffects = WorldEffects.new(context),
}

local gui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
local window = UILib:CreateWindow({
    Name = "BloxStrike",
    LoadingTitle = "BloxStrike",
    LoadingSubtitle = "by Ashly Hub",
    ConfigurationSaving = { Enabled = true, FolderName = "BloxStrike", FileName = "config" },
})

local combatTab = window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998" })
local visualsTab = window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })
local movementTab = window:MakeTab({ Name = "Movement", Icon = "rbxassetid://4483345998" })
local skinsTab = window:MakeTab({ Name = "Skins", Icon = "rbxassetid://4483345998" })
local miscTab = window:MakeTab({ Name = "Misc", Icon = "rbxassetid://4483345998" })

combatTab:AddToggle({ Name = "Aimbot", Default = false, Callback = function(v) features.aimbot:SetEnabled(v) end })
combatTab:AddSlider({ Name = "FOV", Min = 10, Max = 500, Default = 100, Callback = function(v) features.aimbot:SetFOV(v) end })
combatTab:AddSlider({ Name = "Smoothing", Min = 0, Max = 100, Default = 10, Callback = function(v) features.aimbot:SetSmoothing(v/100) end })
combatTab:AddDropdown({ Name = "Hitbox", Default = "Head", Options = {"Head","Torso","HumanoidRootPart"}, Callback = function(v) features.aimbot:SetHitpart(v) end })
combatTab:AddToggle({ Name = "Team Check", Default = true, Callback = function(v) features.aimbot:SetTeamCheck(v) end })
combatTab:AddToggle({ Name = "TriggerBot", Default = false, Callback = function(v) features.triggerbot:SetEnabled(v) end })
combatTab:AddSlider({ Name = "TriggerBot Delay (ms)", Min = 0, Max = 500, Default = 0, Callback = function(v) features.triggerbot:SetDelayMs(v) end })

visualsTabs:AddToggle({ Name = "ESP", Default = false, Callback = function(v) features.esp:SetEnabled(v) end })
visualsTab:AddToggle({ Name = "Box ESP", Default = true, Callback = function(v) features.esp:SetShowBox(v) end })
visualsTab:AddToggle({ Name = "Name ESP", Default = true, Callback = function(v) features.esp:SetShowName(v) end })
visualsTab:AddToggle({ Name = "Health Bar", Default = true, Callback = function(v) features.esp:SetShowHealth(v) end })
visualsTab:AddToggle({ Name = "Chams", Default = false, Callback = function(v) features.chams:SetEnabled(v) end })
visualsTab:AddToggle({ Name = "Kill Effects", Default = false, Callback = function(v) features.killeffects:SetEnabled(v) end })
visualsTab:AddToggle({ Name = "Anti Flash", Default = false, Callback = function(v) features.worldeffects:SetSetting("antiFlash", v) end })
visualsTab:AddToggle({ Name = "Anti Smoke", Default = false, Callback = function(v) features.worldeffects:SetSetting("antiSmoke", v) end })

movementTab:AddToggle({ Name = "Bunny Hop", Default = false, Callback = function(v) features.bunnyhop:SetEnabled(v) end })

skinsTab:AddToggle({ Name = "Skin Unlock", Default = false, Callback = function(v) features.skinchanger:SetEnabled(v) end })
skinsTab:AddTextbox({ Name = "Skin Name", Default = "", TextDisappear = false, Callback = function(v) features.skinchanger:SetSkin(v) end })

window:notify("BloxStrike", "Loaded successfully!", nil, false)

return { window = window, features = features }