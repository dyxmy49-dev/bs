local Chams = {}
Chams.__index = Chams

function Chams.new(context)
    local self = setmetatable({}, Chams)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.highlights = {}
    self.enabled = false
    self.enemyColor = Color3.fromRGB(255, 50, 50)
    self.teamColor = Color3.fromRGB(50, 255, 50)
    return self
end

function Chams:SetEnabled(v)
    self.enabled = v == true
    if not v then self:ClearAll() end
end

function Chams:ClearAll()
    for _, h in pairs(self.highlights) do
        if h and h.Parent then h:Destroy() end
    end
    self.highlights = {}
end

function Chams:Update(enemies)
    if not self.enabled then self:ClearAll() return end
    local seen = {}
    for _, player in ipairs(enemies or {}) do
        seen[player] = true
        if not self.highlights[player] then
            local char = player.Character
            if char then
                local h = Instance.new("Highlight")
                h.Adornee = char
                local isEnemy = self.globals:IsEnemyPlayer(player)
                h.FillColor = isEnemy and self.enemyColor or self.teamColor
                h.OutlineColor = h.FillColor
                h.FillTransparency = 0.5
                h.Parent = self.globals:GetGui()
                self.highlights[player] = h
            end
        end
    end
    for p, h in pairs(self.highlights) do
        if not seen[p] then
            if h and h.Parent then h:Destroy() end
            self.highlights[p] = nil
        end
    end
end

function Chams:Destroy()
    self:ClearAll()
    self.cleaner:Cleanup()
end

return Chams