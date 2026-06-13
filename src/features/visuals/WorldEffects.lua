local WorldEffects = {}
WorldEffects.__index = WorldEffects

function WorldEffects.new(context)
    local self = setmetatable({}, WorldEffects)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.settings = { antiFlash = false, antiSmoke = false }
    self.running = true
    self.cleaner:Give(function() self.running = false end)
    self.errorHandler:Spawn("WorldEffects AntiFlash", function()
        while self.running do
            task.wait(0.2)
            if self.settings.antiFlash then
                local pg = self.globals:GetPlayer():FindFirstChild("PlayerGui")
                local gui = pg and pg:FindFirstChild("FlashbangEffect")
                local fx = self.services.Lighting:FindFirstChild("FlashbangColorCorrection")
                if gui then gui:Destroy() end
                if fx then fx:Destroy() end
            end
        end
    end)
    self.errorHandler:Spawn("WorldEffects AntiSmoke", function()
        while self.running do
            task.wait(0.5)
            if self.settings.antiSmoke then
                local debris = self.services.Workspace:FindFirstChild("Debris")
                if debris then
                    for _, f in ipairs(debris:GetChildren()) do
                        if string.match(f.Name, "Voxel") then f:ClearAllChildren(); f:Destroy() end
                    end
                end
            end
        end
    end)
    return self
end

function WorldEffects:SetSetting(k, v) if self.settings[k] ~= nil then self.settings[k] = v end end
function WorldEffects:Destroy() self.cleaner:Cleanup() end
return WorldEffects