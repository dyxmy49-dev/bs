-- ui_lib.lua from potanginamo373-lang/Bloxstrike
-- Full source: https://raw.githubusercontent.com/potanginamo373-lang/Bloxstrike/main/ui_lib.lua
local pl  = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local ui  = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local ts  = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")
local rs  = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local lp  = pl.LocalPlayer
local Library = {}
Library.__index = Library
function Library:CreateWindow(config)
    config = config or {}
    local window = setmetatable({tabs={}, opened=true}, {__index=Library})
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function()
        if gethui then screenGui.Parent = gethui()
        else screenGui.Parent = game:GetService("CoreGui") end
    end)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(20,20,30)
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
    local tabHolder = Instance.new("Frame")
    tabHolder.Name = "Tabs"
    tabHolder.Size = UDim2.new(0, 120, 1, 0)
    tabHolder.BackgroundColor3 = Color3.fromRGB(15,15,22)
    tabHolder.BorderSizePixel = 0
    tabHolder.Parent = main
    Instance.new("UICorner", tabHolder).CornerRadius = UDim.new(0,8)
    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0,2)
    tabList.Parent = tabHolder
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -130, 1, -10)
    content.Position = UDim2.new(0, 125, 0, 5)
    content.BackgroundTransparency = 1
    content.Parent = main
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,120)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Parent = content
    local scrollList = Instance.new("UIListLayout")
    scrollList.SortOrder = Enum.SortOrder.LayoutOrder
    scrollList.Padding = UDim.new(0,4)
    scrollList.Parent = scroll
    Instance.new("UIPadding", scroll).PaddingLeft = UDim.new(0,4)
    local activeTab = nil
    local function setActive(tab)
        if activeTab then
            activeTab._btn.BackgroundColor3 = Color3.fromRGB(25,25,38)
            activeTab._btn.TextColor3 = Color3.fromRGB(150,150,180)
            activeTab._frame.Visible = false
        end
        activeTab = tab
        tab._btn.BackgroundColor3 = Color3.fromRGB(50,50,80)
        tab._btn.TextColor3 = Color3.fromRGB(255,255,255)
        tab._frame.Visible = true
    end
    window._scroll = scroll
    window._tabHolder = tabHolder
    window._setActive = setActive
    window._tabs = {}
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(15,15,22)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,8)
    local title = Instance.new("TextLabel")
    title.Text = config.Name or "BloxStrike"
    title.Size = UDim2.new(1,-40,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = titleBar
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    ui.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    return window
end
function Library:MakeTab(config)
    config = config or {}
    local tab = setmetatable({_elements={}}, {__index=Library})
    local btn = Instance.new("TextButton")
    btn.Name = config.Name or "Tab"
    btn.Size = UDim2.new(1,-4,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,38)
    btn.BorderSizePixel = 0
    btn.Text = config.Name or "Tab"
    btn.TextColor3 = Color3.fromRGB(150,150,180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = self._tabHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local frame = Instance.new("Frame")
    frame.Name = config.Name or "Tab"
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = self._scroll
    local fl = Instance.new("UIListLayout")
    fl.SortOrder = Enum.SortOrder.LayoutOrder
    fl.Padding = UDim.new(0,4)
    fl.Parent = frame
    tab._btn = btn; tab._frame = frame; tab._window = self
    btn.MouseButton1Click:Connect(function() self._setActive(tab) end)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self._setActive(tab) end
    return tab
end
local function makeElement(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-8,0,h or 30)
    f.BackgroundColor3 = Color3.fromRGB(25,25,38)
    f.BorderSizePixel = 0
    f.Parent = parent._frame
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,5)
    return f
end
function Library:AddToggle(config)
    config = config or {}
    local state = config.Default == true
    local f = makeElement(self, 34)
    local lbl = Instance.new("TextLabel")
    lbl.Text = config.Name or "Toggle"
    lbl.Size = UDim2.new(1,-50,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Parent = f
    local tog = Instance.new("Frame")
    tog.Size = UDim2.new(0,32,0,18)
    tog.Position = UDim2.new(1,-40,0.5,-9)
    tog.BackgroundColor3 = state and Color3.fromRGB(80,140,255) or Color3.fromRGB(50,50,70)
    tog.BorderSizePixel = 0
    tog.Parent = f
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0,9)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = tog
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,7)
    local cb = config.Callback or function() end
    cb(state)
    f.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        state = not state
        ts:Create(tog,TweenInfo.new(0.15),{BackgroundColor3=state and Color3.fromRGB(80,140,255) or Color3.fromRGB(50,50,70)}):Play()
        ts:Create(knob,TweenInfo.new(0.15),{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        cb(state)
    end)
end
function Library:AddSlider(config)
    config = config or {}
    local min,max,val = config.Min or 0, config.Max or 100, config.Default or 50
    local f = makeElement(self, 48)
    local lbl = Instance.new("TextLabel")
    lbl.Text = (config.Name or "Slider").." ["..val.."]" 
    lbl.Size = UDim2.new(1,-8,0,20)
    lbl.Position = UDim2.new(0,8,0,2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Parent = f
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-16,0,6)
    track.Position = UDim2.new(0,8,0,28)
    track.BackgroundColor3 = Color3.fromRGB(40,40,60)
    track.BorderSizePixel = 0
    track.Parent = f
    Instance.new("UICorner", track).CornerRadius = UDim.new(0,3)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(80,140,255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)
    local cb = config.Callback or function() end
    cb(val)
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        val = math.floor(min + rel*(max-min))
        fill.Size = UDim2.new(rel,0,1,0)
        lbl.Text = (config.Name or "Slider").." ["..val.."]"
        cb(val)
    end
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    track.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
    ui.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
end
function Library:AddDropdown(config)
    config = config or {}
    local opts = config.Options or {}
    local sel = config.Default or opts[1] or ""
    local f = makeElement(self, 34)
    local lbl = Instance.new("TextLabel")
    lbl.Text = config.Name or "Dropdown"
    lbl.Size = UDim2.new(0.5,-4,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45,-4,0,24)
    btn.Position = UDim2.new(0.55,0,0.5,-12)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.BorderSizePixel = 0
    btn.Text = sel
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local cb = config.Callback or function() end
    local open = false
    local dropFrame = nil
    btn.MouseButton1Click:Connect(function()
        open = not open
        if dropFrame then dropFrame:Destroy(); dropFrame = nil end
        if not open then return end
        dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #opts*26+4)
        dropFrame.Position = UDim2.new(0, btn.AbsolutePosition.X - f.AbsolutePosition.X, 0, 38)
        dropFrame.BackgroundColor3 = Color3.fromRGB(30,30,48)
        dropFrame.BorderSizePixel = 0
        dropFrame.ZIndex = 10
        dropFrame.Parent = f
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,4)
        for i,opt in ipairs(opts) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1,-4,0,22)
            ob.Position = UDim2.new(0,2,0,(i-1)*26+2)
            ob.BackgroundTransparency = 1
            ob.Text = opt; ob.TextColor3 = Color3.fromRGB(200,200,220)
            ob.Font = Enum.Font.Gotham; ob.TextSize = 11; ob.ZIndex = 11
            ob.Parent = dropFrame
            ob.MouseButton1Click:Connect(function()
                sel = opt; btn.Text = opt; open = false
                if dropFrame then dropFrame:Destroy(); dropFrame = nil end
                cb(sel)
            end)
        end
    end)
end
function Library:AddTextbox(config)
    config = config or {}
    local f = makeElement(self, 34)
    local lbl = Instance.new("TextLabel")
    lbl.Text = config.Name or "Input"
    lbl.Size = UDim2.new(0.45,-4,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5,-4,0,24)
    box.Position = UDim2.new(0.5,0,0.5,-12)
    box.BackgroundColor3 = Color3.fromRGB(35,35,55)
    box.BorderSizePixel = 0
    box.Text = config.Default or ""
    box.PlaceholderText = config.PlaceholderText or "..."
    box.TextColor3 = Color3.fromRGB(200,200,220)
    box.Font = Enum.Font.Gotham; box.TextSize = 11
    box.ClearTextOnFocus = false
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
    local cb = config.Callback or function() end
    box.FocusLost:Connect(function(enter) if enter then cb(box.Text) end end)
end
function Library:AddButton(config)
    config = config or {}
    local f = makeElement(self, 30)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,1,-4)
    btn.Position = UDim2.new(0,4,0,2)
    btn.BackgroundColor3 = Color3.fromRGB(50,80,180)
    btn.BorderSizePixel = 0
    btn.Text = config.Name or "Button"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    local cb = config.Callback or function() end
    btn.MouseButton1Click:Connect(cb)
end
function Library:notify(title, text, duration, sound)
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = gethui and gethui() or game:GetService("CoreGui") end)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,280,0,60)
    f.Position = UDim2.new(1,-290,1,-70)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.BorderSizePixel = 0
    f.Parent = gui
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
    local t1 = Instance.new("TextLabel")
    t1.Text = title; t1.Size = UDim2.new(1,-8,0,20)
    t1.Position = UDim2.new(0,8,0,4)
    t1.BackgroundTransparency = 1; t1.TextColor3 = Color3.fromRGB(80,140,255)
    t1.TextXAlignment = Enum.TextXAlignment.Left; t1.Font = Enum.Font.GothamBold; t1.TextSize = 12; t1.Parent = f
    local t2 = Instance.new("TextLabel")
    t2.Text = text; t2.Size = UDim2.new(1,-8,0,20)
    t2.Position = UDim2.new(0,8,0,24)
    t2.BackgroundTransparency = 1; t2.TextColor3 = Color3.fromRGB(180,180,200)
    t2.TextXAlignment = Enum.TextXAlignment.Left; t2.Font = Enum.Font.Gotham; t2.TextSize = 11; t2.Parent = f
    task.delay(duration or 3, function() if gui.Parent then gui:Destroy() end end)
end
function Library:loadConfig() end
return Library