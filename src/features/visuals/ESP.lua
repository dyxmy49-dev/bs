local ESP = {}
ESP.__index = ESP

local function safeRemove(d)
    if d then pcall(function() d:Remove() end) end
end

function ESP.new(context)
    local self = setmetatable({}, ESP)
    self.globals = context.globals
    self.services = context.services
    self.cleaner = context.Cleaner.new()
    self.errorHandler = context.errorHandler
    self.drawings = {}
    self.enabled = false
    self.teamCheck = true
    self.showBox = true
    self.showName = true
    self.showHealth = true
    self.showDistance = false
    self.boxColor = Color3.fromRGB(255, 50, 50)
    self.teamColor = Color3.fromRGB(50, 255, 50)
    self.running = true
    self.cleaner:Give(function()
        self.running = false
        for _, d in pairs(self.drawings) do
            if d.box then safeRemove(d.box) end
            if d.name then safeRemove(d.name) end
            if d.health then safeRemove(d.health) end
            if d.dist then safeRemove(d.dist) end
        end
        self.drawings = {}
    end)
    self.errorHandler:Spawn("ESP Loop", function()
        while self.running do
            task.wait(0)
            self:Update()
        end
    end)
    return self
end

function ESP:GetOrCreate(player)
    if not self.drawings[player] then
        local function newDraw(type, props)
            local d = Drawing.new(type)
            for k,v in pairs(props) do d[k]=v end
            return d
        end
        self.drawings[player] = {
            box = newDraw("Square", {Visible=false,Thickness=1,Filled=false,Color=self.boxColor}),
            name = newDraw("Text", {Visible=false,Size=14,Center=true,Outline=true,Color=Color3.fromRGB(255,255,255)}),
            health = newDraw("Square", {Visible=false,Thickness=1,Filled=true,Color=Color3.fromRGB(0,255,0)}),
            dist = newDraw("Text", {Visible=false,Size=12,Center=true,Outline=true,Color=Color3.fromRGB(200,200,200)}),
        }
    end
    return self.drawings[player]
end

function ESP:Update()
    if not self.enabled then
        for _, d in pairs(self.drawings) do
            if d.box then d.box.Visible = false end
            if d.name then d.name.Visible = false end
            if d.health then d.health.Visible = false end
            if d.dist then d.dist.Visible = false end
        end
        return
    end
    local camera = self.globals:GetCamera()
    if not camera then return end
    local localPlayer = self.globals:GetPlayer()
    for _, player in ipairs(self.services.Players:GetPlayers()) do
        if player == localPlayer then continue end
        if self.teamCheck and not self.globals:IsEnemyPlayer(player) then
            local d = self.drawings[player]
            if d then
                if d.box then d.box.Visible = false end
                if d.name then d.name.Visible = false end
            end
            continue
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local pos, onScreen = camera:WorldToViewportPoint(root.Position)
        local d = self:GetOrCreate(player)
        if not onScreen then
            d.box.Visible = false; d.name.Visible = false
            d.health.Visible = false; d.dist.Visible = false
            continue
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local scale = 1 / pos.Z
        local w, h = 40 * scale * 40, 60 * scale * 40
        local x, y = pos.X - w/2, pos.Y - h/2
        local color = self.globals:IsEnemyPlayer(player) and self.boxColor or self.teamColor
        if self.showBox then
            d.box.Size = Vector2.new(w, h)
            d.box.Position = Vector2.new(x, y)
            d.box.Color = color
            d.box.Visible = true
        else d.box.Visible = false end
        if self.showName then
            d.name.Text = player.DisplayName
            d.name.Position = Vector2.new(pos.X, y - 18)
            d.name.Color = color
            d.name.Visible = true
        else d.name.Visible = false end
        if self.showHealth and hum then
            local pct = math.clamp(hum.Health/math.max(hum.MaxHealth,1), 0, 1)
            d.health.Size = Vector2.new(3, h * pct)
            d.health.Position = Vector2.new(x - 6, y + h * (1-pct))
            d.health.Color = Color3.fromRGB(255*(1-pct), 255*pct, 0)
            d.health.Visible = true
        else d.health.Visible = false end
        if self.showDistance then
            local dist = math.floor((root.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude)
            d.dist.Text = dist.."m"
            d.dist.Position = Vector2.new(pos.X, y + h + 4)
            d.dist.Visible = true
        else d.dist.Visible = false end
    end
end

function ESP:SetEnabled(v) self.enabled = v == true end
function ESP:SetTeamCheck(v) self.teamCheck = v == true end
function ESP:SetShowBox(v) self.showBox = v == true end
function ESP:SetShowName(v) self.showName = v == true end
function ESP:SetShowHealth(v) self.showHealth = v == true end
function ESP:Destroy() self.cleaner:Cleanup() end
return ESP