local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function Create(t, p)
    local i = Instance.new(t)
    for k,v in pairs(p or {}) do i[k]=v end
    return i
end

local LibClass = {}
LibClass.__index = LibClass

function LibClass:CreateWindow(opts)
    opts = opts or {}
    local window = {Tabs={}, ActiveTab=nil}
    local guiParent = game:GetService("CoreGui")
    pcall(function() if gethui then guiParent=gethui() end end)
    local MainGui = Create("ScreenGui",{Name=opts.Name or "UI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Global,Parent=guiParent})
    local MainFrame = Create("Frame",{Name="Main",Size=UDim2.new(0,550,0,400),Position=UDim2.new(0.5,-275,0.5,-200),BackgroundColor3=Color3.fromRGB(18,18,28),BorderSizePixel=0,Parent=MainGui})
    Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=MainFrame})
    local TopBar = Create("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(12,12,20),BorderSizePixel=0,Parent=MainFrame})
    Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=TopBar})
    Create("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.fromRGB(12,12,20),BorderSizePixel=0,Parent=TopBar})
    Create("TextLabel",{Text=opts.Name or "BloxStrike",Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=14,Parent=TopBar})
    local visible=true
    local xBtn=Create("TextButton",{Text="X",Size=UDim2.new(0,26,0,20),Position=UDim2.new(1,-32,0.5,-10),BackgroundColor3=Color3.fromRGB(180,40,40),TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0,Parent=TopBar})
    Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=xBtn})
    xBtn.MouseButton1Click:Connect(function() visible=not visible; MainFrame.Visible=visible end)
    local TabContainer=Create("Frame",{Size=UDim2.new(0,128,1,-36),Position=UDim2.new(0,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,Parent=MainFrame})
    Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=TabContainer})
    Create("Frame",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,Parent=TabContainer})
    local TabList=Create("Frame",{Size=UDim2.new(1,-8,1,-8),Position=UDim2.new(0,4,0,4),BackgroundTransparency=1,Parent=TabContainer})
    Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),Parent=TabList})
    local ContentArea=Create("Frame",{Size=UDim2.new(1,-136,1,-44),Position=UDim2.new(0,132,0,40),BackgroundTransparency=1,Parent=MainFrame})
    local dragging,dragStart,startPos
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=MainFrame.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dragStart
            MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    local api={}
    function api:MakeTab(tabOpts)
        tabOpts=tabOpts or {}
        local Btn=Create("TextButton",{Text=tabOpts.Name or "Tab",Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(24,24,36),TextColor3=Color3.fromRGB(130,130,165),Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0,Parent=TabList})
        Create("UICorner",{CornerRadius=UDim.new(0,6),Parent=Btn})
        local Scroll=Create("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(70,70,110),AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),Visible=false,Parent=ContentArea})
        Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),Parent=Scroll})
        Create("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingTop=UDim.new(0,4),Parent=Scroll})
        Btn.MouseButton1Click:Connect(function()
            if window.ActiveTab then
                window.ActiveTab.S.Visible=false
                TweenService:Create(window.ActiveTab.B,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(24,24,36),TextColor3=Color3.fromRGB(130,130,165)}):Play()
            end
            window.ActiveTab={B=Btn,S=Scroll}
            Scroll.Visible=true
            TweenService:Create(Btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(45,75,195),TextColor3=Color3.fromRGB(255,255,255)}):Play()
        end)
        if #window.Tabs==0 then
            window.ActiveTab={B=Btn,S=Scroll}; Scroll.Visible=true
            Btn.BackgroundColor3=Color3.fromRGB(45,75,195); Btn.TextColor3=Color3.fromRGB(255,255,255)
        end
        table.insert(window.Tabs,{B=Btn,S=Scroll})
        local tApi={}
        local function row(h)
            local f=Create("Frame",{Size=UDim2.new(1,0,0,h or 32),BackgroundColor3=Color3.fromRGB(24,24,36),BorderSizePixel=0,Parent=Scroll})
            Create("UICorner",{CornerRadius=UDim.new(0,5),Parent=f})
            return f
        end
        function tApi:AddToggle(o)
            o=o or {}; local s=o.Default==true; local cb=o.Callback or function()end
            local f=row(34)
            Create("TextLabel",{Text=o.Name or "Toggle",Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(195,195,215),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=12,Parent=f})
            local tr=Create("Frame",{Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-42,0.5,-9),BackgroundColor3=s and Color3.fromRGB(55,115,255) or Color3.fromRGB(42,42,62),BorderSizePixel=0,Parent=f})
            Create("UICorner",{CornerRadius=UDim.new(0,9),Parent=tr})
            local kn=Create("Frame",{Size=UDim2.new(0,14,0,14),Position=s and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Parent=tr})
            Create("UICorner",{CornerRadius=UDim.new(0,7),Parent=kn})
            pcall(cb,s)
            f.InputBegan:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                s=not s
                TweenService:Create(tr,TweenInfo.new(0.12),{BackgroundColor3=s and Color3.fromRGB(55,115,255) or Color3.fromRGB(42,42,62)}):Play()
                TweenService:Create(kn,TweenInfo.new(0.12),{Position=s and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
                cb(s)
            end)
        end
        function tApi:AddSlider(o)
            o=o or {}; local mn,mx,v=o.Min or 0,o.Max or 100,o.Default or 50; local cb=o.Callback or function()end
            local f=row(50)
            local lbl=Create("TextLabel",{Text=(o.Name or "Slider").." ["..v.."]",Size=UDim2.new(1,-8,0,20),Position=UDim2.new(0,8,0,2),BackgroundTransparency=1,TextColor3=Color3.fromRGB(195,195,215),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=12,Parent=f})
            local tr=Create("Frame",{Size=UDim2.new(1,-16,0,6),Position=UDim2.new(0,8,0,30),BackgroundColor3=Color3.fromRGB(34,34,52),BorderSizePixel=0,Parent=f})
            Create("UICorner",{CornerRadius=UDim.new(0,3),Parent=tr})
            local fl=Create("Frame",{Size=UDim2.new((v-mn)/(mx-mn),0,1,0),BackgroundColor3=Color3.fromRGB(55,115,255),BorderSizePixel=0,Parent=tr})
            Create("UICorner",{CornerRadius=UDim.new(0,3),Parent=fl})
            pcall(cb,v)
            local drag=false
            local function upd(x) local r=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); v=math.floor(mn+r*(mx-mn)); fl.Size=UDim2.new(r,0,1,0); lbl.Text=(o.Name or "Slider").." ["..v.."]"; cb(v) end
            tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end end)
            tr.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
        end
        function tApi:AddDropdown(o)
            o=o or {}; local opts=o.Options or {}; local sel=o.Default or opts[1] or ""; local cb=o.Callback or function()end
            local f=row(34)
            Create("TextLabel",{Text=o.Name or "Dropdown",Size=UDim2.new(0.45,-4,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(195,195,215),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=12,Parent=f})
            local btn=Create("TextButton",{Text=sel,Size=UDim2.new(0.5,-4,0,24),Position=UDim2.new(0.5,0,0.5,-12),BackgroundColor3=Color3.fromRGB(32,32,50),TextColor3=Color3.fromRGB(195,195,215),Font=Enum.Font.Gotham,TextSize=11,BorderSizePixel=0,Parent=f})
            Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=btn})
            local open,df=false,nil
            btn.MouseButton1Click:Connect(function()
                open=not open; if df then df:Destroy(); df=nil end
                if not open then return end
                df=Create("Frame",{Size=UDim2.new(0,btn.AbsoluteSize.X,0,#opts*26+4),Position=UDim2.new(0,btn.AbsolutePosition.X-f.AbsolutePosition.X,0,36),BackgroundColor3=Color3.fromRGB(26,26,42),BorderSizePixel=0,ZIndex=10,Parent=f})
                Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=df})
                for i,opt in ipairs(opts) do
                    local ob=Create("TextButton",{Text=opt,Size=UDim2.new(1,-4,0,22),Position=UDim2.new(0,2,0,(i-1)*26+2),BackgroundTransparency=1,TextColor3=Color3.fromRGB(195,195,215),Font=Enum.Font.Gotham,TextSize=11,ZIndex=11,Parent=df})
                    ob.MouseButton1Click:Connect(function() sel=opt; btn.Text=opt; open=false; if df then df:Destroy(); df=nil end; cb(sel) end)
                end
            end)
        end
        function tApi:AddTextbox(o)
            o=o or {}; local cb=o.Callback or function()end
            local f=row(34)
            Create("TextLabel",{Text=o.Name or "Input",Size=UDim2.new(0.4,-4,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(195,195,215),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=12,Parent=f})
            local box=Create("TextBox",{Text=o.Default or "",PlaceholderText=o.PlaceholderText or "...",Size=UDim2.new(0.55,-4,0,24),Position=UDim2.new(0.45,0,0.5,-12),BackgroundColor3=Color3.fromRGB(32,32,50),TextColor3=Color3.fromRGB(195,195,215),Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,BorderSizePixel=0,Parent=f})
            Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=box})
            box.FocusLost:Connect(function(enter) if enter then cb(box.Text) end end)
        end
        function tApi:AddButton(o)
            o=o or {}; local cb=o.Callback or function()end
            local f=row(30)
            local btn=Create("TextButton",{Text=o.Name or "Button",Size=UDim2.new(1,-8,1,-4),Position=UDim2.new(0,4,0,2),BackgroundColor3=Color3.fromRGB(45,75,195),TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,Parent=f})
            Create("UICorner",{CornerRadius=UDim.new(0,5),Parent=btn})
            btn.MouseButton1Click:Connect(cb)
        end
        return tApi
    end
    function api:notify(title,text,duration)
        local gp=game:GetService("CoreGui")
        pcall(function() if gethui then gp=gethui() end end)
        local ng=Create("ScreenGui",{ResetOnSpawn=false,Parent=gp})
        local f=Create("Frame",{Size=UDim2.new(0,280,0,60),Position=UDim2.new(1,-290,1,-70),BackgroundColor3=Color3.fromRGB(18,18,28),BorderSizePixel=0,Parent=ng})
        Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=f})
        Create("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=Color3.fromRGB(55,115,255),BorderSizePixel=0,Parent=f})
        Create("TextLabel",{Text=title or "",Size=UDim2.new(1,-14,0,22),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=13,Parent=f})
        Create("TextLabel",{Text=text or "",Size=UDim2.new(1,-14,0,20),Position=UDim2.new(0,10,0,28),BackgroundTransparency=1,TextColor3=Color3.fromRGB(160,160,195),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,Parent=f})
        task.delay(duration or 3,function() if ng.Parent then ng:Destroy() end end)
    end
    function api:loadConfig() end
    return api
end

return LibClass