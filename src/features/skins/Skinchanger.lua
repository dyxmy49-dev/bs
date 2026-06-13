local Skinchanger = {}
Skinchanger.__index = Skinchanger

local KNIFE_MODELS = {
    "Skeleton Knife", "Butterfly Knife", "Karambit", "Bayonet",
    "M9 Bayonet", "Gut Knife", "Flip Knife", "Falchion Knife",
    "Bowie Knife", "Huntsman Knife", "Shadow Daggers", "Talon Knife",
    "Navaja Knife", "Stiletto Knife", "Ursus Knife", "Classic Knife",
    "Paracord Knife", "Survival Knife", "Nomad Knife",
}

local SKIN_TAGS = { "Skin", "Paint", "Finish", "Style", "Wear" }

function Skinchanger.new(context)
    local self = setmetatable({}, Skinchanger)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.enabled = false
    self.selectedSkin = nil
    self.selectedKnife = nil
    self.skinList = {}
    self.knifeList = table.clone and table.clone(KNIFE_MODELS) or {table.unpack(KNIFE_MODELS)}
    self.remotes = {}
    self._origIndex = nil
    self._origNamecall = nil
    return self
end

function Skinchanger:ScanRemotes()
    self.remotes = {}
    local rs = self.services.ReplicatedStorage
    for _, d in ipairs(rs:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local n = d.Name:lower()
            for _, tag in ipairs(SKIN_TAGS) do
                if n:find(tag:lower()) then
                    table.insert(self.remotes, d)
                    break
                end
            end
        end
    end
    return self.remotes
end

function Skinchanger:ApplySkin(skinName)
    if not self.enabled or not skinName then return end
    self.selectedSkin = skinName
    self:ScanRemotes()
    for _, remote in ipairs(self.remotes) do
        pcall(function()
            local payload = { Skin = skinName, Owned = true, Unlocked = true }
            if remote:IsA("RemoteEvent") then
                remote:FireServer(payload)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(payload)
            end
        end)
    end
end

function Skinchanger:HookIndex()
    if self._origIndex then return end
    pcall(function()
        self._origIndex = hookmetamethod(game, "__index", function(obj, key)
            if self.enabled and type(key) == "string" then
                local k = key:lower()
                if k == "owned" or k == "unlocked" or k == "hasskin" or k == "hascosmetic" then
                    local ok, name = pcall(function() return tostring(obj):lower() end)
                    if ok and (name:find("skin") or name:find("cosmetic")) then
                        return true
                    end
                end
            end
            return self._origIndex(obj, key)
        end)
    end)
end

function Skinchanger:SetEnabled(v)
    self.enabled = v == true
    if v then
        self:HookIndex()
        self:ScanRemotes()
    end
end

function Skinchanger:SetSkin(name)
    self.selectedSkin = name
    if self.enabled then self:ApplySkin(name) end
end

function Skinchanger:GetKnifeList()
    return self.knifeList
end

function Skinchanger:Destroy()
    self.cleaner:Cleanup()
end

return Skinchanger