local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

if not Drawing or not Drawing.new then
	warn("EXUNYS_ESP: Drawing API unavailable in this executor.")
	return
end

local function newDrawing(class)
	local ok, obj = pcall(Drawing.new, class)
	if ok and obj then
		return obj
	end
	return nil
end

local Settings = {
	ESP = { Enabled = true, Color = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0), Size = 14, Offset = 10, Outline = true, Rainbow = false, DisplayName = true, DisplayDistance = true },
	Tracer = { Enabled = true, Color = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0), Thickness = 1, Outline = true, Rainbow = false },
	HeadDot = { Enabled = true, Color = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0), Thickness = 1, Radius = 6, Outline = true, Rainbow = false },
	Box = { Enabled = true, Type = 1, Color = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0), Thickness = 1, Outline = true, Rainbow = false, Fill = false },
	HealthBar = { Enabled = true, Color = Color3.fromRGB(0,255,0), OutlineColor = Color3.fromRGB(0,0,0), Thickness = 1, Outline = true },
	Chams = { Enabled = false, Color = Color3.fromRGB(255,255,255), Transparency = 0.3, Rainbow = false },
	Skeleton = { Enabled = false, Color = Color3.fromRGB(255,255,255), Thickness = 1, Rainbow = false },
	Highlight = { Enabled = false, Color = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0), Transparency = 0.5, Rainbow = false },
	Crosshair = { Enabled = false, Color = Color3.fromRGB(0,255,0), Size = 12, Gap = 6, Thickness = 1, Outline = true, OutlineColor = Color3.fromRGB(0,0,0) }
}

local Entries = {}
local FrameTick = tick()
local Rainbow = Color3.fromRGB(255,255,255)

local function rainbowColor()
	return Color3.fromHSV(FrameTick % 1, 1, 1)
end

local function getWorldToViewport(pos)
	return Camera:WorldToViewportPoint(pos)
end

local function getPlayerRoot(player)
	local char = player and player.Character
	if not char then return nil end
	return char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
end

local function getPlayerHead(player)
	local char = player and player.Character
	if not char then return nil end
	return char:FindFirstChild("Head")
end

local function getBoxParams(player)
	local root = getPlayerRoot(player)
	local head = getPlayerHead(player)
	if not root or not head then return nil end
	local pos = root.Position
	local up = Camera.CFrame.UpVector
	local top, topVis = getWorldToViewport(pos + Vector3.new(0, 2.5, 0) + up)
	local bottom, bottomVis = getWorldToViewport(pos - Vector3.new(0, 2.5, 0) - up)
	if not topVis and not bottomVis then return nil end
	local w = math.max(math.floor(math.abs(top.X - bottom.X)), 3)
	local h = math.max(math.floor(math.max(math.abs(bottom.Y - top.Y), w / 2)), 3)
	local size = Vector2.new(math.floor(math.max(h / 1.5, w)), h)
	local position = Vector2.new(math.floor(top.X / 2 + bottom.X / 2 - size.X / 2), math.floor(math.min(top.Y, bottom.Y)))
	return position, size, topVis and bottomVis, top, bottom
end

local function getColor(entry, defaultColor)
	if entry.Settings and entry.Settings.Rainbow then
		return Rainbow
	end
	return defaultColor
end

local function clearEntry(entry)
	for _, obj in next, entry.Visuals do
		if obj and obj.Remove then
			pcall(obj.Remove, obj)
		end
	end
	entry.Visuals = {}
end

local function createVisuals(entry)
	clearEntry(entry)
	entry.Visuals = {}

	if Settings.ESP.Enabled then
		local top = newDrawing("Text")
		local bottom = newDrawing("Text")
		if top and bottom then
			top.Center = true
			bottom.Center = true
			top.ZIndex = 4
			bottom.ZIndex = 4
			entry.Visuals.TopText = top
			entry.Visuals.BottomText = bottom
		end
	end

	if Settings.Tracer.Enabled then
		local line = newDrawing("Line")
		local outline = newDrawing("Line")
		if line and outline then
			entry.Visuals.Tracer = line
			entry.Visuals.TracerOutline = outline
		end
	end

	if Settings.HeadDot.Enabled then
		local circle = newDrawing("Circle")
		local outline = newDrawing("Circle")
		if circle and outline then
			entry.Visuals.HeadDot = circle
			entry.Visuals.HeadDotOutline = outline
		end
	end

	if Settings.Box.Enabled then
		local square = newDrawing("Square")
		local squareOutline = newDrawing("Square")
		if square and squareOutline then
			entry.Visuals.Box = square
			entry.Visuals.BoxOutline = squareOutline
		end
	end

	if Settings.HealthBar.Enabled then
		local bar = newDrawing("Line")
		local barOutline = newDrawing("Line")
		if bar and barOutline then
			entry.Visuals.HealthBar = bar
			entry.Visuals.HealthBarOutline = barOutline
		end
	end

	if Settings.Highlight.Enabled then
		local hl = Instance.new("Highlight")
		hl.Name = "EXUNYS_HIGHLIGHT"
		hl.FillColor = Settings.Highlight.Color
		hl.OutlineColor = Settings.Highlight.OutlineColor
		hl.FillTransparency = Settings.Highlight.Transparency
		hl.Parent = CoreGui
		entry.Visuals.Highlight = hl
	end
end

local function updateEntry(entry)
	local player = entry.Player
	local char = player and player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not humanoid or humanoid.Health <= 0 then
		for _, obj in next, entry.Visuals do
			if obj then
				if obj.Visible ~= nil then obj.Visible = false end
				if obj.Enabled ~= nil then obj.Enabled = false end
			end
		end
		return
	end

	local position, size, onScreen, top, bottom = getBoxParams(player)
	if not position or not size then
		for _, obj in next, entry.Visuals do
			if obj then
				if obj.Visible ~= nil then obj.Visible = false end
				if obj.Enabled ~= nil then obj.Enabled = false end
			end
		end
		return
	end

	if entry.Visuals.TopText and entry.Visuals.BottomText then
		local topText = entry.Visuals.TopText
		local bottomText = entry.Visuals.BottomText
		topText.Visible = onScreen
		bottomText.Visible = onScreen
		if onScreen then
			local fontSize = math.clamp(math.abs((top - bottom).Y) - 3, 6, Settings.ESP.Size)
			topText.Size = fontSize
			bottomText.Size = fontSize
			topText.Color = getColor(entry, Settings.ESP.Color)
			bottomText.Color = getColor(entry, Settings.ESP.Color)
			topText.OutlineColor = Settings.ESP.OutlineColor
			bottomText.OutlineColor = Settings.ESP.OutlineColor
			topText.Outline = Settings.ESP.Outline
			bottomText.Outline = Settings.ESP.Outline
			local labelsX = position.X + size.X / 2
			local name = player.DisplayName ~= "" and player.DisplayName or player.Name
			if Settings.ESP.DisplayName and player.DisplayName ~= player.Name then
				name = player.DisplayName .. " (" .. player.Name .. ")"
			end
			local distance = Settings.ESP.DisplayDistance and math.floor((player.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude) or nil
			topText.Text = name
			bottomText.Text = distance and (tostring(distance) .. " Studs") or ""
			topText.Position = Vector2.new(labelsX, top.Y - Settings.ESP.Offset * 2.05)
			bottomText.Position = Vector2.new(labelsX, bottom.Y + Settings.ESP.Offset / 2)
		end
	end

	if entry.Visuals.Tracer and entry.Visuals.TracerOutline then
		local tracer = entry.Visuals.Tracer
		local outline = entry.Visuals.TracerOutline
		tracer.Visible = onScreen
		outline.Visible = onScreen and Settings.Tracer.Outline
		if onScreen then
			tracer.Color = getColor(entry, Settings.Tracer.Color)
			tracer.Thickness = Settings.Tracer.Thickness
			tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			tracer.To = Vector2.new(position.X + size.X / 2, position.Y + size.Y)
			if Settings.Tracer.Outline then
				outline.Color = Settings.Tracer.OutlineColor
				outline.Thickness = Settings.Tracer.Thickness + 1
				outline.From = tracer.From
				outline.To = tracer.To
			end
		end
	end

	if entry.Visuals.HeadDot and entry.Visuals.HeadDotOutline then
		local dot = entry.Visuals.HeadDot
		local outline = entry.Visuals.HeadDotOutline
		local head = getPlayerHead(player)
		if head then
			local headPos, headVis = getWorldToViewport(head.Position)
			dot.Visible = headVis
			outline.Visible = headVis and Settings.HeadDot.Outline
			if headVis then
				dot.Color = getColor(entry, Settings.HeadDot.Color)
				dot.Thickness = Settings.HeadDot.Thickness
				dot.Radius = Settings.HeadDot.Radius
				dot.Position = Vector2.new(headPos.X, headPos.Y)
				if Settings.HeadDot.Outline then
					outline.Color = Settings.HeadDot.OutlineColor
					outline.Thickness = Settings.HeadDot.Thickness + 1
					outline.Radius = Settings.HeadDot.Radius
					outline.Position = dot.Position
				end
			end
		else
			dot.Visible = false
			outline.Visible = false
		end
	end

	if entry.Visuals.Box and entry.Visuals.BoxOutline then
		local box = entry.Visuals.Box
		local outline = entry.Visuals.BoxOutline
		box.Visible = onScreen
		outline.Visible = onScreen and Settings.Box.Outline
		if onScreen then
			box.Color = getColor(entry, Settings.Box.Color)
			box.Thickness = Settings.Box.Thickness
			box.Filled = Settings.Box.Fill
			box.Position = position
			box.Size = size
			if Settings.Box.Outline then
				outline.Color = Settings.Box.OutlineColor
				outline.Thickness = Settings.Box.Thickness + 1
				outline.Filled = false
				outline.Position = position
				outline.Size = size
			end
		end
	end

	if entry.Visuals.HealthBar and entry.Visuals.HealthBarOutline then
		local bar = entry.Visuals.HealthBar
		local outline = entry.Visuals.HealthBarOutline
		bar.Visible = onScreen
		outline.Visible = onScreen and Settings.HealthBar.Outline
		if onScreen then
			local maxHealth = humanoid.MaxHealth
			local health = math.clamp(humanoid.Health, 0, maxHealth)
			local ratio = health / maxHealth
			local offset = 4
			bar.Color = Settings.HealthBar.Color
			bar.Thickness = Settings.HealthBar.Thickness
			bar.From = Vector2.new(position.X - offset, position.Y + size.Y)
			bar.To = Vector2.new(position.X - offset, bar.From.Y - ratio * size.Y)
			if Settings.HealthBar.Outline then
				outline.Color = Settings.HealthBar.OutlineColor
				outline.Thickness = Settings.HealthBar.Thickness + 1
				outline.From = Vector2.new(position.X - offset, position.Y + size.Y + 1)
				outline.To = Vector2.new(position.X - offset, outline.From.Y - size.Y - 2)
			end
		end
	end

	if entry.Visuals.Highlight then
		local hl = entry.Visuals.Highlight
		if char and char.Parent then
			hl.Adornee = char
			hl.Enabled = onScreen
			hl.FillColor = getColor(entry, Settings.Highlight.Color)
			hl.OutlineColor = Settings.Highlight.OutlineColor
			hl.FillTransparency = Settings.Highlight.Transparency
		else
			hl.Enabled = false
		end
	end
end

local function wrapPlayer(player)
	if player == LocalPlayer then return end
	if Entries[player] then return end
	local entry = { Player = player, Visuals = {}, Settings = Settings }
	Entries[player] = entry
	createVisuals(entry)
end

local function unwrapPlayer(player)
	local entry = Entries[player]
	if not entry then return end
	clearEntry(entry)
	if entry.Visuals.Highlight then
		pcall(function() entry.Visuals.Highlight:Destroy() end)
	end
	Entries[player] = nil
end

local function rebuildAll()
	for player, entry in next, Entries do
		createVisuals(entry)
	end
end

local function updateAll()
	FrameTick = tick()
	Rainbow = rainbowColor()
	for _, entry in next, Entries do
		updateEntry(entry)
	end
end

for _, player in next, Players:GetPlayers() do
	wrapPlayer(player)
end
Players.PlayerAdded:Connect(wrapPlayer)
Players.PlayerRemoving:Connect(unwrapPlayer)

RunService.RenderStepped:Connect(updateAll)

local crosshair = {}
local function createCrosshair()
	if not Settings.Crosshair.Enabled then return end
	crosshair.Left = newDrawing("Line")
	crosshair.Right = newDrawing("Line")
	crosshair.Top = newDrawing("Line")
	crosshair.Bottom = newDrawing("Line")
	crosshair.LeftOutline = newDrawing("Line")
	crosshair.RightOutline = newDrawing("Line")
	crosshair.TopOutline = newDrawing("Line")
	crosshair.BottomOutline = newDrawing("Line")
end

local function updateCrosshair()
	if not Settings.Crosshair.Enabled then
		for _, obj in next, crosshair do
			if obj then obj.Visible = false end
		end
		return
	end
	local mouse = UserInputService:GetMouseLocation()
	local size = Settings.Crosshair.Size
	local gap = Settings.Crosshair.Gap
	local thickness = Settings.Crosshair.Thickness
	crosshair.Left.Visible = true
	crosshair.Right.Visible = true
	crosshair.Top.Visible = true
	crosshair.Bottom.Visible = true
	crosshair.Left.Color = Settings.Crosshair.Color
	crosshair.Right.Color = Settings.Crosshair.Color
	crosshair.Top.Color = Settings.Crosshair.Color
	crosshair.Bottom.Color = Settings.Crosshair.Color
	crosshair.Left.Thickness = thickness
	crosshair.Right.Thickness = thickness
	crosshair.Top.Thickness = thickness
	crosshair.Bottom.Thickness = thickness
	crosshair.Left.From = Vector2.new(mouse.X - gap - size, mouse.Y)
	crosshair.Left.To = Vector2.new(mouse.X - gap, mouse.Y)
	crosshair.Right.From = Vector2.new(mouse.X + gap, mouse.Y)
	crosshair.Right.To = Vector2.new(mouse.X + gap + size, mouse.Y)
	crosshair.Top.From = Vector2.new(mouse.X, mouse.Y - gap - size)
	crosshair.Top.To = Vector2.new(mouse.X, mouse.Y - gap)
	crosshair.Bottom.From = Vector2.new(mouse.X, mouse.Y + gap)
	crosshair.Bottom.To = Vector2.new(mouse.X, mouse.Y + gap + size)
	if Settings.Crosshair.Outline then
		for _, name in next, {"Left", "Right", "Top", "Bottom"} do
			local outline = crosshair[name .. "Outline"]
			local line = crosshair[name]
			if outline and line then
				outline.Visible = true
				outline.Color = Settings.Crosshair.OutlineColor
				outline.Thickness = thickness + 1
				outline.From = line.From
				outline.To = line.To
			end
		end
	else
		for _, name in next, {"Left", "Right", "Top", "Bottom"} do
			local outline = crosshair[name .. "Outline"]
			if outline then outline.Visible = false end
		end
	end
end

createCrosshair()
RunService.RenderStepped:Connect(updateCrosshair)

local function createGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "EXUNYS_ESP_GUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = CoreGui

	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.fromOffset(210, 286)
	frame.Position = UDim2.new(0, 20, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	title.BorderSizePixel = 0
	title.Text = "EXUNYS ESP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -24)
	scroll.Position = UDim2.new(0, 0, 0, 24)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 4)
	padding.Parent = scroll

	local function makeButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.Parent = scroll
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	local function makeToggle(name, get, set)
		local btn = makeButton("", function() end)
		local function refresh()
			btn.Text = name .. ": " .. (get() and "ON" or "OFF")
			btn.BackgroundColor3 = get() and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 50)
		end
		btn.MouseButton1Click:Connect(function()
			set(not get())
			refresh()
			rebuildAll()
		end)
		refresh()
		return btn
	end

	makeToggle("ESP", function() return Settings.ESP.Enabled end, function(v) Settings.ESP.Enabled = v end)
	makeToggle("Tracer", function() return Settings.Tracer.Enabled end, function(v) Settings.Tracer.Enabled = v end)
	makeToggle("Head Dot", function() return Settings.HeadDot.Enabled end, function(v) Settings.HeadDot.Enabled = v end)
	makeToggle("Box", function() return Settings.Box.Enabled end, function(v) Settings.Box.Enabled = v end)
	makeToggle("Health Bar", function() return Settings.HealthBar.Enabled end, function(v) Settings.HealthBar.Enabled = v end)
	makeToggle("Chams", function() return Settings.Chams.Enabled end, function(v) Settings.Chams.Enabled = v end)
	makeToggle("Skeleton", function() return Settings.Skeleton.Enabled end, function(v) Settings.Skeleton.Enabled = v end)
	makeToggle("Highlight", function() return Settings.Highlight.Enabled end, function(v) Settings.Highlight.Enabled = v end)
	makeToggle("Crosshair", function() return Settings.Crosshair.Enabled end, function(v) Settings.Crosshair.Enabled = v end)

	makeButton("Box: Square", function() Settings.Box.Type = 1; rebuildAll() end)
	makeButton("Box: Corner", function() Settings.Box.Type = 2; rebuildAll() end)
	makeButton("Fill Box: Toggle", function() Settings.Box.Fill = not Settings.Box.Fill; rebuildAll() end)
	makeButton("Rainbow All: Toggle", function()
		local v = not Settings.ESP.Rainbow
		Settings.ESP.Rainbow = v
		Settings.Tracer.Rainbow = v
		Settings.HeadDot.Rainbow = v
		Settings.Box.Rainbow = v
		Settings.Chams.Rainbow = v
		Settings.Skeleton.Rainbow = v
		Settings.Highlight.Rainbow = v
		rebuildAll()
	end)
	makeButton("Red Team", function()
		for _, s in next, {Settings.ESP, Settings.Tracer, Settings.HeadDot, Settings.Box} do
			s.Color = Color3.fromRGB(255, 0, 0)
		end
	end)
	makeButton("Blue Team", function()
		for _, s in next, {Settings.ESP, Settings.Tracer, Settings.HeadDot, Settings.Box} do
			s.Color = Color3.fromRGB(0, 100, 255)
		end
	end)
	makeButton("Green Crosshair", function() Settings.Crosshair.Color = Color3.fromRGB(0, 255, 0) end)
	makeButton("Unload", function()
		for player in next, Entries do
			unwrapPlayer(player)
		end
		for _, obj in next, crosshair do
			if obj and obj.Remove then pcall(obj.Remove, obj) end
		end
		gui:Destroy()
	end)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end)
end

createGui()
