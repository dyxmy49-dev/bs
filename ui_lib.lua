local pl  = cloneref(game:GetService("Players"))
local ui  = cloneref(game:GetService("UserInputService"))
local ts  = cloneref(game:GetService("TweenService"))
local rs  = cloneref(game:GetService("RunService"))
local lp  = pl.LocalPlayer

local function Create(instanceType, properties, children)
	local instance = Instance.new(instanceType)
	if properties then
		for prop, value in pairs(properties) do
			instance[prop] = value
		end
	end
	if children then
		for _, child in pairs(children) do
			child.Parent = instance
		end
	end
	return instance
end

local LibClass = {}
LibClass.__index = LibClass

function LibClass:CreateWindow(options)
	options = options or {}
	local window = {}
	window.Tabs = {}
	window.ActiveTab = nil

	local guiParent = game:GetService("CoreGui")
	pcall(function()
		if gethui then guiParent = gethui() end
	end)

	local MainGui = Create("ScreenGui", {
		Name = options.Name or "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = guiParent,
	})

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 550, 0, 400),
		Position = UDim2.new(0.5, -275, 0.5, -200),
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		BorderSizePixel = 0,
		Parent = MainGui,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })

	local TopBar = Create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Color3.fromRGB(12, 12, 20),
		BorderSizePixel = 0,
		Parent = MainFrame,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TopBar })

	local TopBarFill = Create("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(12, 12, 20),
		BorderSizePixel = 0,
		Parent = TopBar,
	})

	local Title = Create("TextLabel", {
		Text = options.Name or "Library",
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = TopBar,
	})

	local CloseBtn = Create("TextButton", {
		Text = "X",
		Size = UDim2.new(0, 28, 0, 20),
		Position = UDim2.new(1, -34, 0.5, -10),
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		BorderSizePixel = 0,
		Parent = TopBar,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseBtn })

	local visible = true
	CloseBtn.MouseButton1Click:Connect(function()
		visible = not visible
		MainFrame.Visible = visible
	end)

	local TabContainer = Create("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 130, 1, -36),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Color3.fromRGB(15, 15, 24),
		BorderSizePixel = 0,
		Parent = MainFrame,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabContainer })

	local TabFill = Create("Frame", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 24),
		BorderSizePixel = 0,
		Parent = TabContainer,
	})

	local TabList = Create("Frame", {
		Name = "TabList",
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.new(0, 4, 0, 4),
		BackgroundTransparency = 1,
		Parent = TabContainer,
	})
	local TabListLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = TabList,
	})

	local ContentArea = Create("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -138, 1, -44),
		Position = UDim2.new(0, 134, 0, 40),
		BackgroundTransparency = 1,
		Parent = MainFrame,
	})

	-- Dragging
	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	ui.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	local tabApi = {}

	function tabApi:MakeTab(tabOptions)
		tabOptions = tabOptions or {}
		local tab = {}

		local TabBtn = Create("TextButton", {
			Text = tabOptions.Name or "Tab",
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(25, 25, 38),
			TextColor3 = Color3.fromRGB(140, 140, 170),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			BorderSizePixel = 0,
			Parent = TabList,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })

		local TabContent = Create("ScrollingFrame", {
			Name = tabOptions.Name or "Tab",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			Parent = ContentArea,
		})
		local ContentLayout = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
			Parent = TabContent,
		})
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
			Parent = TabContent,
		})

		TabBtn.MouseButton1Click:Connect(function()
			if window.ActiveTab then
				window.ActiveTab.Content.Visible = false
				ts:Create(window.ActiveTab.Btn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(25, 25, 38),
					TextColor3 = Color3.fromRGB(140, 140, 170),
				}):Play()
			end
			window.ActiveTab = { Btn = TabBtn, Content = TabContent }
			TabContent.Visible = true
			ts:Create(TabBtn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(50, 80, 200),
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
		end)

		if #window.Tabs == 0 then
			window.ActiveTab = { Btn = TabBtn, Content = TabContent }
			TabContent.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
			TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		table.insert(window.Tabs, { Btn = TabBtn, Content = TabContent })

		local tabContentApi = {}

		local function makeSection(name)
			local sec = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(22, 22, 34),
				BorderSizePixel = 0,
				Parent = TabContent,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sec })
			local secList = Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
				Parent = sec,
			})
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				Parent = sec,
			})
			if name then
				Create("TextLabel", {
					Text = name,
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(100, 100, 150),
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.GothamBold,
					TextSize = 11,
					Parent = sec,
				})
			end
			return sec
		end

		local function makeRow(parent, h)
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, h or 30),
				BackgroundColor3 = Color3.fromRGB(28, 28, 42),
				BorderSizePixel = 0,
				Parent = parent,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = row })
			return row
		end

		function tabContentApi:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default == true
			local cb = opts.Callback or function() end
			local row = makeRow(TabContent, 34)
			Create("TextLabel", {
				Text = opts.Name or "Toggle",
				Size = UDim2.new(1, -52, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = row,
			})
			local track = Create("Frame", {
				Size = UDim2.new(0, 34, 0, 18),
				Position = UDim2.new(1, -42, 0.5, -9),
				BackgroundColor3 = state and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(45, 45, 65),
				BorderSizePixel = 0,
				Parent = row,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = track })
			local knob = Create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = track,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = knob })
			pcall(cb, state)
			row.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				state = not state
				ts:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(45, 45, 65)}):Play()
				ts:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
				cb(state)
			end)
		end

		function tabContentApi:AddSlider(opts)
			opts = opts or {}
			local min, max, val = opts.Min or 0, opts.Max or 100, opts.Default or 50
			local cb = opts.Callback or function() end
			local row = makeRow(TabContent, 52)
			local lbl = Create("TextLabel", {
				Text = (opts.Name or "Slider") .. " [" .. val .. "]",
				Size = UDim2.new(1, -8, 0, 20),
				Position = UDim2.new(0, 8, 0, 2),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = row,
			})
			local track = Create("Frame", {
				Size = UDim2.new(1, -16, 0, 6),
				Position = UDim2.new(0, 8, 0, 32),
				BackgroundColor3 = Color3.fromRGB(35, 35, 55),
				BorderSizePixel = 0,
				Parent = row,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = track })
			local fill = Create("Frame", {
				Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(60, 120, 255),
				BorderSizePixel = 0,
				Parent = track,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = fill })
			pcall(cb, val)
			local dragging = false
			local function update(x)
				local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + rel * (max - min))
				fill.Size = UDim2.new(rel, 0, 1, 0)
				lbl.Text = (opts.Name or "Slider") .. " [" .. val .. "]"
				cb(val)
			end
			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i.Position.X) end
			end)
			track.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			ui.InputChanged:Connect(function(i)
				if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
			end)
		end

		function tabContentApi:AddDropdown(opts)
			opts = opts or {}
			local options_list = opts.Options or {}
			local sel = opts.Default or (options_list[1] or "")
			local cb = opts.Callback or function() end
			local row = makeRow(TabContent, 34)
			Create("TextLabel", {
				Text = opts.Name or "Dropdown",
				Size = UDim2.new(0.45, -4, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = row,
			})
			local btn = Create("TextButton", {
				Text = sel,
				Size = UDim2.new(0.5, -4, 0, 24),
				Position = UDim2.new(0.5, 0, 0.5, -12),
				BackgroundColor3 = Color3.fromRGB(35, 35, 55),
				TextColor3 = Color3.fromRGB(200, 200, 220),
				Font = Enum.Font.Gotham,
				TextSize = 11,
				BorderSizePixel = 0,
				Parent = row,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
			local open, dropFrame = false, nil
			btn.MouseButton1Click:Connect(function()
				open = not open
				if dropFrame then dropFrame:Destroy(); dropFrame = nil end
				if not open then return end
				dropFrame = Create("Frame", {
					Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options_list * 26 + 4),
					Position = UDim2.new(0, btn.AbsolutePosition.X - row.AbsolutePosition.X, 0, 36),
					BackgroundColor3 = Color3.fromRGB(28, 28, 44),
					BorderSizePixel = 0,
					ZIndex = 10,
					Parent = row,
				})
				Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropFrame })
				for i, opt in ipairs(options_list) do
					local ob = Create("TextButton", {
						Text = opt,
						Size = UDim2.new(1, -4, 0, 22),
						Position = UDim2.new(0, 2, 0, (i - 1) * 26 + 2),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(200, 200, 220),
						Font = Enum.Font.Gotham,
						TextSize = 11,
						ZIndex = 11,
						Parent = dropFrame,
					})
					ob.MouseButton1Click:Connect(function()
						sel = opt; btn.Text = opt; open = false
						if dropFrame then dropFrame:Destroy(); dropFrame = nil end
						cb(sel)
					end)
				end
			end)
		end

		function tabContentApi:AddTextbox(opts)
			opts = opts or {}
			local cb = opts.Callback or function() end
			local row = makeRow(TabContent, 34)
			Create("TextLabel", {
				Text = opts.Name or "Input",
				Size = UDim2.new(0.4, -4, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 220),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = row,
			})
			local box = Create("TextBox", {
				Text = opts.Default or "",
				PlaceholderText = opts.PlaceholderText or "...",
				Size = UDim2.new(0.55, -4, 0, 24),
				Position = UDim2.new(0.45, 0, 0.5, -12),
				BackgroundColor3 = Color3.fromRGB(35, 35, 55),
				TextColor3 = Color3.fromRGB(200, 200, 220),
				Font = Enum.Font.Gotham,
				TextSize = 11,
				ClearTextOnFocus = false,
				BorderSizePixel = 0,
				Parent = row,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
			box.FocusLost:Connect(function(enter) if enter then cb(box.Text) end end)
		end

		function tabContentApi:AddButton(opts)
			opts = opts or {}
			local cb = opts.Callback or function() end
			local row = makeRow(TabContent, 30)
			local btn = Create("TextButton", {
				Text = opts.Name or "Button",
				Size = UDim2.new(1, -8, 1, -4),
				Position = UDim2.new(0, 4, 0, 2),
				BackgroundColor3 = Color3.fromRGB(50, 80, 200),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				BorderSizePixel = 0,
				Parent = row,
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })
			btn.MouseButton1Click:Connect(cb)
		end

		function tabContentApi:AddLabel(opts)
			opts = opts or {}
			Create("TextLabel", {
				Text = opts.Name or "",
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				TextColor3 = opts.Color or Color3.fromRGB(150, 150, 180),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				Parent = TabContent,
			})
		end

		return tabContentApi
	end

	function tabApi:notify(title, text, duration)
		local guiP = game:GetService("CoreGui")
		pcall(function() if gethui then guiP = gethui() end end)
		local notifGui = Create("ScreenGui", { ResetOnSpawn = false, Parent = guiP })
		local f = Create("Frame", {
			Size = UDim2.new(0, 280, 0, 64),
			Position = UDim2.new(1, -290, 1, -74),
			BackgroundColor3 = Color3.fromRGB(18, 18, 28),
			BorderSizePixel = 0,
			Parent = notifGui,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = f })
		Create("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Color3.fromRGB(60, 120, 255), BorderSizePixel = 0, Parent = f })
		Create("TextLabel", {
			Text = title or "Notification",
			Size = UDim2.new(1, -16, 0, 22),
			Position = UDim2.new(0, 12, 0, 4),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			Parent = f,
		})
		Create("TextLabel", {
			Text = text or "",
			Size = UDim2.new(1, -16, 0, 20),
			Position = UDim2.new(0, 12, 0, 28),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(170, 170, 200),
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			Parent = f,
		})
		task.delay(duration or 3, function()
			if notifGui and notifGui.Parent then
				ts:Create(f, TweenInfo.new(0.3), { Position = UDim2.new(1, 10, 1, -74) }):Play()
				task.wait(0.35)
				notifGui:Destroy()
			end
		end)
	end

	function tabApi:loadConfig() end

	return tabApi
end

local showLoadingOverlay = function() end
LibClass.showLoadingOverlay = showLoadingOverlay

return LibClass