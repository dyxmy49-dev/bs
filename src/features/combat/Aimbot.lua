local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new(context)
    local self = setmetatable({}, Aimbot)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.settings = {
        enabled = false,
        fov = 100,
        smoothing = 0.1,
        hitpart = "Head",
        teamCheck = true,
    }
    self.running = true
    self.holding = false
    self.cleaner:Give(function() self.running = false end)
    self.cleaner:Give(self.services.UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.LeftAlt
        or input.KeyCode == Enum.KeyCode.RightAlt
        or input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.holding = true
        end
    end))
    self.cleaner:Give(self.services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt
        or input.KeyCode == Enum.KeyCode.RightAlt
        or input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.holding = false
        end
    end))
    self.errorHandler:Spawn("Aimbot Loop", function()
        while self.running do
            task.wait()
            if not self.settings.enabled or not self.holding then continue end
            if not self.globals:IsAlive() then continue end
            local camera = self.globals:GetCamera()
            if not camera then continue end
            local bestTarget = nil
            local bestDist = math.huge
            local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            for _, p in ipairs(self.services.Players:GetPlayers()) do
                if p == self.globals:GetPlayer() then continue end
                if self.settings.teamCheck and not self.globals:IsEnemyPlayer(p) then continue end
                local char = p.Character
                if not char then continue end
                local part = char:FindFirstChild(self.settings.hitpart) or char:FindFirstChild("HumanoidRootPart")
                if not part then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                if not onScreen then continue end
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist > self.settings.fov then continue end
                if dist < bestDist then bestDist = dist; bestTarget = part end
            end
            if bestTarget then
                local pos, onScreen = camera:WorldToViewportPoint(bestTarget.Position)
                if onScreen then
                    local target2D = Vector2.new(pos.X, pos.Y)
                    local delta = target2D - center
                    local smooth = math.clamp(self.settings.smoothing, 0.01, 1)
                    if mousemoverel then
                        pcall(mousemoverel, delta.X * smooth, delta.Y * smooth)
                    end
                end
            end
        end
    end)
    return self
end

function Aimbot:SetEnabled(v) self.settings.enabled = v == true end
function Aimbot:SetFOV(v) self.settings.fov = tonumber(v) or 100 end
function Aimbot:SetSmoothing(v) self.settings.smoothing = math.clamp(tonumber(v) or 0.1, 0.01, 1) end
function Aimbot:SetHitpart(v) self.settings.hitpart = tostring(v) end
function Aimbot:SetTeamCheck(v) self.settings.teamCheck = v == true end
function Aimbot:Destroy() self.cleaner:Cleanup() end
return Aimbot