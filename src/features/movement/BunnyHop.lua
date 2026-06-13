local BunnyHop = {}
BunnyHop.__index = BunnyHop

function BunnyHop.new(context)
    local self = setmetatable({}, BunnyHop)
    self.services = context.services
    self.globals = context.globals
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.enabled = false
    self.cleaner:Give(self.errorHandler:Connect(self.services.RunService.RenderStepped, "BunnyHop", function()
        if not self.enabled or not self.globals:IsAlive() then return end
        if not self.services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local char = self.globals:GetPlayer().Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local state = hum:GetState()
        if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end))
    return self
end

function BunnyHop:SetEnabled(v) self.enabled = v == true end
function BunnyHop:Destroy() self.cleaner:Cleanup() end
return BunnyHop