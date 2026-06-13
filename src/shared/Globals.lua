local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

local Globals = {}

function Globals:GetPlayer() return LocalPlayer end
function Globals:GetCharacter() return Character end
function Globals:GetHumanoid() return Humanoid end
function Globals:GetRootPart() return RootPart end
function Globals:GetCamera() return workspace.CurrentCamera end

function Globals:IsAlive()
    local char = Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

function Globals:IsEnemyPlayer(player)
    if not player or player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

function Globals:IsEnemyModel(model)
    if not model then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return self:IsEnemyPlayer(player)
        end
    end
    return false
end

function Globals:GetGui()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    return pg
end

return Globals