local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.new(context)
    local self = setmetatable({}, Hitbox)
    self.services = context.services
    self.globals = context.globals
    self.settings = { enabled = false, size = 5 }
    return self
end

function Hitbox:SetEnabled(v) self.settings.enabled = v == true end
function Hitbox:SetSize(v) self.settings.size = math.clamp(tonumber(v) or 5, 1, 50) end

function Hitbox:GetTarget(enemies)
    if not self.settings.enabled then return nil end
    local camera = self.globals:GetCamera()
    if not camera then return nil end
    local center = camera.ViewportSize / 2
    local closest, closestDist = nil, math.huge
    for _, enemy in ipairs(enemies or {}) do
        local char = enemy.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < self.settings.size * 20 and dist < closestDist then
                        closest = enemy
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

return Hitbox