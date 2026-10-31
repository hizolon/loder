local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

if not Drawing or not Drawing.new then
	warn("EXUNYS_ESP: Drawing API unavailable.")
	return
end

local function newDrawing(class)
	local ok, obj = pcall(Drawing.new, class)
	if ok and obj then return obj end
	return nil
end

local Settings = {
	ESP = {
		Enabled = false,
		Box = true, Tracer = true, HeadDot = true, HealthBar = true, Skeleton = false, Highlight = false,
		Color = Color3.fromRGB(255,255,255),
		OutlineColor = Color3.fromRGB(0,0,0),
		BoxColor = Color3.fromRGB(255,255,255),
		BoxOutlineColor = Color3.fromRGB(0,0,0),
		SkeletonColor = Color3.fromRGB(255,255,255),
		SkeletonOutlineColor = Color3.fromRGB(0,0,0),
		Size = 14, Offset = 10, Outline = true, Rainbow = false, DisplayName = true, DisplayDistance = true
	},
	Crosshair = { Enabled = false, Color = Color3.fromRGB(0,255,0), Size = 12, Gap = 6, Thickness = 1, Outline = true, OutlineColor = Color3.fromRGB(0,0,0) }
}

local Entries = {}
local FrameTick = tick()
local Rainbow = Color3.fromRGB(255,255,255)

local function rainbowColor()
	return Color3.fromHSV(FrameTick % 1, 1, 1)
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
	local center, centerVis = Camera:WorldToViewportPoint(pos)
	if not centerVis then return nil end
	local top, topVis = Camera:WorldToViewportPoint(pos + Vector3.new(0, 2.5, 0) + up)
	local bottom, bottomVis = Camera:WorldToViewportPoint(pos - Vector3.new(0, 2.5, 0) - up)
	local topX = topVis and top.X or center.X
	local topY = topVis and top.Y or (center.Y - 100)
	local bottomX = bottomVis and bottom.X or center.X
	local bottomY = bottomVis and bottom.Y or (center.Y + 100)
	local w = math.max(math.floor(math.abs(topX - bottomX)), 3)
	local h = math.max(math.floor(math.max(math.abs(bottomY - topY), w / 2)), 3)
	local size = Vector2.new(math.floor(math.max(h / 1.5, w)), h)
	local position = Vector2.new(math.floor(topX / 2 + bottomX / 2 - size.X / 2), math.floor(math.min(topY, bottomY)))
	return position, size, true, top, bottom, center
end

local function getColor(entry, defaultColor)
	if Settings.ESP.Rainbow then return Rainbow end
	return defaultColor
end

local function clearEntry(entry)
	for _, obj in next, entry.Visuals do
		if obj and obj.Remove then pcall(obj.Remove, obj) end
	end
	entry.Visuals = {}
end

local function createVisuals(entry)
	clearEntry(entry)
	entry.Visuals = {}

	local top = newDrawing("Text")
	local bottom = newDrawing("Text")
	if top and bottom then
		top.Center = true; bottom.Center = true
		top.ZIndex = 4; bottom.ZIndex = 4
		top.Visible = false; bottom.Visible = false
		entry.Visuals.TopText = top; entry.Visuals.BottomText = bottom
	end

	local line = newDrawing("Line"); local outline = newDrawing("Line")
	if line and outline then
		line.Visible = false; outline.Visible = false
		entry.Visuals.Tracer = line; entry.Visuals.TracerOutline = outline
	end

	local circle = newDrawing("Circle"); local circleOutline = newDrawing("Circle")
	if circle and circleOutline then
		circle.Visible = false; circleOutline.Visible = false
		entry.Visuals.HeadDot = circle; entry.Visuals.HeadDotOutline = circleOutline
	end

	local square = newDrawing("Square"); local squareOutline = newDrawing("Square")
	if square and squareOutline then
		square.Visible = false; squareOutline.Visible = false
		entry.Visuals.Box = square; entry.Visuals.BoxOutline = squareOutline
	end

	local bar = newDrawing("Line"); local barOutline = newDrawing("Line")
	if bar and barOutline then
		bar.Visible = false; barOutline.Visible = false
		entry.Visuals.HealthBar = bar; entry.Visuals.HealthBarOutline = barOutline
	end

	entry.Visuals.SkeletonLines = {}
	local skeletonDefs = {
		{"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
		{"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
		{"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
		{"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
		{"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"}
	}
	local r6Defs = {
		{"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
		{"Torso","Left Leg"}, {"Torso","Right Leg"}
	}
	for _, def in next, skeletonDefs do
		local line = newDrawing("Line"); local outline = newDrawing("Line")
		if line and outline then
			line.Visible = false; outline.Visible = false
			table.insert(entry.Visuals.SkeletonLines, {line, outline, def[1], def[2], "R15"})
		end
	end
	for _, def in next, r6Defs do
		local line = newDrawing("Line"); local outline = newDrawing("Line")
		if line and outline then
			line.Visible = false; outline.Visible = false
			table.insert(entry.Visuals.SkeletonLines, {line, outline, def[1], def[2], "R6"})
		end
	end

	local hl = Instance.new("Highlight")
	hl.Name = "EXUNYS_HIGHLIGHT"
	hl.FillColor = Settings.ESP.Color
	hl.OutlineColor = Settings.ESP.OutlineColor
	hl.FillTransparency = 0.5
	hl.Enabled = false
	hl.Parent = CoreGui
	entry.Visuals.Highlight = hl
end

local function updateEntry(entry)
	local player = entry.Player
	local char = player and player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	local function hideAll()
		for _, obj in next, entry.Visuals do
			if type(obj) == "table" then
				for _, sub in next, obj do
					if sub then
						if sub.Visible ~= nil then sub.Visible = false end
						if sub.Enabled ~= nil then sub.Enabled = false end
					end
				end
			elseif obj then
				if obj.Visible ~= nil then obj.Visible = false end
				if obj.Enabled ~= nil then obj.Enabled = false end
			end
		end
	end

	if not Settings.ESP.Enabled or not char or not humanoid or humanoid.Health <= 0 then
		hideAll(); return
	end

	local position, size, onScreen, top, bottom, center = getBoxParams(player)
	if not position or not size then
		hideAll(); return
	end

	if entry.Visuals.TopText and entry.Visuals.BottomText then
		local topText = entry.Visuals.TopText; local bottomText = entry.Visuals.BottomText
		if Settings.ESP.Enabled then
			topText.Visible = true; bottomText.Visible = true
			local fontSize = math.clamp(math.abs((top - bottom).Y) - 3, 6, Settings.ESP.Size)
			topText.Size = fontSize; bottomText.Size = fontSize
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
			local distance = nil
			if Settings.ESP.DisplayDistance and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
				distance = math.floor((char.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude)
			end
			topText.Text = name
			bottomText.Text = distance and (tostring(distance) .. " Studs") or ""
			topText.Position = Vector2.new(labelsX, top.Y - Settings.ESP.Offset * 2.05)
			bottomText.Position = Vector2.new(labelsX, bottom.Y + Settings.ESP.Offset / 2)
		else
			topText.Visible = false; bottomText.Visible = false
		end
	end

	if entry.Visuals.Tracer and entry.Visuals.TracerOutline then
		local tracer = entry.Visuals.Tracer; local outline = entry.Visuals.TracerOutline
		if Settings.ESP.Enabled and Settings.ESP.Tracer then
			tracer.Visible = true
			tracer.Color = getColor(entry, Settings.ESP.Color)
			tracer.Thickness = 1
			tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			tracer.To = Vector2.new(position.X + size.X / 2, position.Y + size.Y)
			if Settings.ESP.Outline then
				outline.Visible = true
				outline.Color = Settings.ESP.OutlineColor
				outline.Thickness = 2
				outline.From = tracer.From; outline.To = tracer.To
			else
				outline.Visible = false
			end
		else
			tracer.Visible = false; outline.Visible = false
		end
	end

	if entry.Visuals.HeadDot and entry.Visuals.HeadDotOutline then
		local dot = entry.Visuals.HeadDot; local outline = entry.Visuals.HeadDotOutline
		local head = getPlayerHead(player)
		if Settings.ESP.Enabled and Settings.ESP.HeadDot and head then
			local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
			if headVis then
				dot.Visible = true
				dot.Color = getColor(entry, Settings.ESP.Color)
				dot.Thickness = 1; dot.Radius = 6
				dot.Position = Vector2.new(headPos.X, headPos.Y)
				if Settings.ESP.Outline then
					outline.Visible = true
					outline.Color = Settings.ESP.OutlineColor
					outline.Thickness = 2; outline.Radius = 6
					outline.Position = dot.Position
				else
					outline.Visible = false
				end
			else
				dot.Visible = false; outline.Visible = false
			end
		else
			dot.Visible = false; outline.Visible = false
		end
	end

	if entry.Visuals.Box and entry.Visuals.BoxOutline then
		local box = entry.Visuals.Box; local outline = entry.Visuals.BoxOutline
		if Settings.ESP.Enabled and Settings.ESP.Box then
			box.Visible = true
			box.Color = getColor(entry, Settings.ESP.BoxColor)
			box.Thickness = 1
			box.Position = position; box.Size = size
			if Settings.ESP.Outline then
				outline.Visible = true
				outline.Color = Settings.ESP.BoxOutlineColor
				outline.Thickness = 2
				outline.Position = position; outline.Size = size
			else
				outline.Visible = false
			end
		else
			box.Visible = false; outline.Visible = false
		end
	end

	if entry.Visuals.HealthBar and entry.Visuals.HealthBarOutline then
		local bar = entry.Visuals.HealthBar; local outline = entry.Visuals.HealthBarOutline
		if Settings.ESP.Enabled and Settings.ESP.HealthBar then
			bar.Visible = true
			local maxHealth = humanoid.MaxHealth
			local health = math.clamp(humanoid.Health, 0, maxHealth)
			local ratio = health / maxHealth
			local offset = 4
			bar.Color = Color3.fromRGB(255 - math.floor(ratio * 255), math.floor(ratio * 255), 0)
			bar.Thickness = 1
			bar.From = Vector2.new(position.X - offset, position.Y + size.Y)
			bar.To = Vector2.new(position.X - offset, bar.From.Y - ratio * size.Y)
			if Settings.ESP.Outline then
				outline.Visible = true
				outline.Color = Settings.ESP.OutlineColor
				outline.Thickness = 2
				outline.From = Vector2.new(position.X - offset, position.Y + size.Y + 1)
				outline.To = Vector2.new(position.X - offset, outline.From.Y - size.Y - 2)
			else
				outline.Visible = false
			end
		else
			bar.Visible = false; outline.Visible = false
		end
	end

	if entry.Visuals.SkeletonLines then
		local rigType = "R15"
		if char:FindFirstChild("Torso") then rigType = "R6" end
		for _, item in next, entry.Visuals.SkeletonLines do
			local line, outline, partA, partB, rig = item[1], item[2], item[3], item[4], item[5]
			if Settings.ESP.Enabled and Settings.ESP.Skeleton and rig == rigType then
				local a = char:FindFirstChild(partA)
				local b = char:FindFirstChild(partB)
				if a and b then
					local aPos, aVis = Camera:WorldToViewportPoint(a.Position)
					local bPos, bVis = Camera:WorldToViewportPoint(b.Position)
					if aVis or bVis then
						line.Visible = true
						line.Color = getColor(entry, Settings.ESP.SkeletonColor)
						line.Thickness = 1
						line.From = Vector2.new(aPos.X, aPos.Y)
						line.To = Vector2.new(bPos.X, bPos.Y)
						if Settings.ESP.Outline then
							outline.Visible = true
							outline.Color = Settings.ESP.SkeletonOutlineColor
							outline.Thickness = 2
							outline.From = line.From; outline.To = line.To
						else
							outline.Visible = false
						end
					else
						line.Visible = false; outline.Visible = false
					end
				else
					line.Visible = false; outline.Visible = false
				end
			else
				line.Visible = false; outline.Visible = false
			end
		end
	end

	if entry.Visuals.Highlight then
		local hl = entry.Visuals.Highlight
		if Settings.ESP.Enabled and Settings.ESP.Highlight and char and char.Parent then
			hl.Adornee = char
			hl.Enabled = true
			hl.FillColor = getColor(entry, Settings.ESP.Color)
			hl.OutlineColor = Settings.ESP.OutlineColor
		else
			hl.Enabled = false
		end
	end
end

local function wrapPlayer(player)
	if player == LocalPlayer then return end
	if Entries[player] then return end
	local entry = { Player = player, Visuals = {} }
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
	crosshair.Left = newDrawing("Line"); crosshair.Right = newDrawing("Line")
	crosshair.Top = newDrawing("Line"); crosshair.Bottom = newDrawing("Line")
	crosshair.LeftOutline = newDrawing("Line"); crosshair.RightOutline = newDrawing("Line")
	crosshair.TopOutline = newDrawing("Line"); crosshair.BottomOutline = newDrawing("Line")
	for _, obj in next, crosshair do
		if obj then obj.Visible = false end
	end
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
	crosshair.Left.Visible = true; crosshair.Right.Visible = true
	crosshair.Top.Visible = true; crosshair.Bottom.Visible = true
	crosshair.Left.Color = Settings.Crosshair.Color; crosshair.Right.Color = Settings.Crosshair.Color
	crosshair.Top.Color = Settings.Crosshair.Color; crosshair.Bottom.Color = Settings.Crosshair.Color
	crosshair.Left.Thickness = thickness; crosshair.Right.Thickness = thickness
	crosshair.Top.Thickness = thickness; crosshair.Bottom.Thickness = thickness
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
				outline.From = line.From; outline.To = line.To
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

	local espBtn = makeButton("", function() end)
	local function refreshEsp()
		espBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
		espBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 50)
	end
	espBtn.MouseButton1Click:Connect(function()
		Settings.ESP.Enabled = not Settings.ESP.Enabled
		refreshEsp()
	end)
	refreshEsp()

	local subToggles = {
		{name = "Box", key = "Box"},
		{name = "Tracer", key = "Tracer"},
		{name = "Head Dot", key = "HeadDot"},
		{name = "Health Bar", key = "HealthBar"},
		{name = "Skeleton", key = "Skeleton"},
		{name = "Highlight", key = "Highlight"},
	}
	for _, item in next, subToggles do
		local btn = makeButton("", function() end)
		local function refresh()
			btn.Text = item.name .. ": " .. (Settings.ESP[item.key] and "ON" or "OFF")
			btn.BackgroundColor3 = Settings.ESP[item.key] and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 50)
		end
		btn.MouseButton1Click:Connect(function()
			Settings.ESP[item.key] = not Settings.ESP[item.key]
			refresh()
		end)
		refresh()
	end

	makeButton("Box Color: White", function() Settings.ESP.BoxColor = Color3.fromRGB(255,255,255); Settings.ESP.BoxOutlineColor = Color3.fromRGB(0,0,0) end)
	makeButton("Box Color: Red", function() Settings.ESP.BoxColor = Color3.fromRGB(255,0,0); Settings.ESP.BoxOutlineColor = Color3.fromRGB(0,0,0) end)
	makeButton("Box Color: Black", function() Settings.ESP.BoxColor = Color3.fromRGB(0,0,0); Settings.ESP.BoxOutlineColor = Color3.fromRGB(255,255,255) end)
	makeButton("Box Color: Yellow", function() Settings.ESP.BoxColor = Color3.fromRGB(255,255,0); Settings.ESP.BoxOutlineColor = Color3.fromRGB(0,0,0) end)

	makeButton("Rainbow: Toggle", function()
		Settings.ESP.Rainbow = not Settings.ESP.Rainbow
	end)
	makeButton("Skeleton: Toggle", function()
		Settings.ESP.Skeleton = not Settings.ESP.Skeleton
	end)
	makeButton("Crosshair: Toggle", function()
		Settings.Crosshair.Enabled = not Settings.Crosshair.Enabled
	end)
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
