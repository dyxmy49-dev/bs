local KillEffects = {}
KillEffects.__index = KillEffects

function KillEffects.new(context)
    local self = setmetatable({}, KillEffects)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.settings = { enabled = false, color = Color3.fromRGB(255,0,100), duration = 0.8, intensity = 0.6 }
    self.running = true
    self.lastHealth = {}
    self.flashGui = nil
    self.cleaner:Give(function()
        self.running = false
        if self.flashGui and self.flashGui.Parent then self.flashGui:Destroy() end
    end)
    self.errorHandler:Spawn("KillEffects Loop", function()
        while self.running do
            task.wait(0.1)
            if not self.settings.enabled then continue end
            for _, p in ipairs(self.services.Players:GetPlayers()) do
                if p ~= self.globals:GetPlayer() then
                    local char = p.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local prev = self.lastHealth[p]
                        local curr = hum.Health
                        if prev and curr < prev and curr <= 0 then
                            self:Flash()
                        end
                        self.lastHealth[p] = curr
                    end
                end
            end
        end
    end)
    return self
end

function KillEffects:Flash()
    local gui = self.globals:GetGui()
    if not gui then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = self.settings.color
    frame.BackgroundTransparency = 1 - self.settings.intensity
    frame.BorderSizePixel = 0
    frame.ZIndex = 100
    frame.Parent = gui
    self.flashGui = frame
    game:GetService("TweenService"):Create(frame, TweenInfo.new(self.settings.duration), {BackgroundTransparency=1}):Play()
    task.delay(self.settings.duration + 0.1, function() if frame.Parent then frame:Destroy() end end)
end

function KillEffects:SetEnabled(v) self.settings.enabled = v == true end
function KillEffects:Destroy() self.cleaner:Cleanup() end
return KillEffects