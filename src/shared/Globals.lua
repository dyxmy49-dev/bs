local Services = require("src/shared/Services.lua")

local LocalPlayer = Services.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

return {
    LocalPlayer = LocalPlayer,
    Character = function() return Character end,
    Humanoid = function() return Humanoid end,
    RootPart = function() return RootPart end,
    Camera = Camera,
}