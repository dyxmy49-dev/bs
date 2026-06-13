local TriggerBot = {}
TriggerBot.__index = TriggerBot

function TriggerBot.new(context)
    local self = setmetatable({}, TriggerBot)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.settings = { enabled = false, delayMs = 0 }
    self.running = true
    self.cleaner:Give(function() self.running = false end)
    self.errorHandler:Spawn("TriggerBot Loop", function()
        while self.running do
            task.wait(0.01)
            if self.settings.enabled and self.globals:IsAlive() then
                local camera = self.globals:GetCamera()
                if camera then
                    local vs = camera.ViewportSize
                    local ray = camera:ViewportPointToRay(vs.X * 0.5, vs.Y * 0.5)
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local ignore = { camera }
                    local char = self.globals:GetPlayer().Character
                    if char then ignore[#ignore+1] = char end
                    params.FilterDescendantsInstances = ignore
                    local result = self.services.Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
                    if result and result.Instance then
                        local model = result.Instance:FindFirstAncestorOfClass("Model")
                        local hum = model and model:FindFirstChildOfClass("Humanoid")
                        if model and self.globals:IsEnemyModel(model) and hum and hum.Health > 0 then
                            if self.settings.delayMs > 0 then task.wait(self.settings.delayMs / 1000) end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end)
    return self
end

function TriggerBot:SetEnabled(v) self.settings.enabled = v == true end
function TriggerBot:SetDelayMs(v) self.settings.delayMs = math.max(0, tonumber(v) or 0) end
function TriggerBot:Destroy() self.cleaner:Cleanup() end
return TriggerBot