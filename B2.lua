if LPH_OBFUSCATED == nil then
	LPH_NO_VIRTUALIZE = function(...)
		return ...
	end
end

local game, workspace = game, workspace
local assert, select, next, type, typeof, pcall, setmetatable, tick, warn = assert, select, next, type, typeof, pcall, setmetatable, tick, warn
local mathfloor, mathabs, mathcos, mathsin, mathrad, mathdeg, mathmin, mathmax, mathclamp, mathrandom = math.floor, math.abs, math.cos, math.sin, math.rad, math.deg, math.min, math.max, math.clamp, math.random
local stringformat, stringfind, stringchar = string.format, string.find, string.char
local unpack = table.unpack
local wait, spawn, delay = task.wait, task.spawn, task.delay
local getgenv = getgenv or function()
	return _G
end
local getrawmetatable = getrawmetatable or function()
	return nil
end
local gethiddenproperty = gethiddenproperty or function(self, Index)
	return self[Index]
end
local cloneref = cloneref or function(...)
	return ...
end
local clonefunction = clonefunction or function(...)
	return ...
end
local identifyexecutor = identifyexecutor or function()
	return "Unknown"
end
local loadstring = loadstring or function()
	return nil
end
local cleardrawcache = cleardrawcache or function() end

local HttpGet = nil
if game and game.HttpGet then
	HttpGet = function(url)
		return game:HttpGet(url)
	end
elseif syn and syn.request then
	HttpGet = function(url)
		local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
		return ok and res and res.Body or nil
	end
elseif http and http.request then
	HttpGet = function(url)
		local ok, res = pcall(http.request, {Url = url, Method = "GET"})
		return ok and res and res.Body or nil
	end
elseif request then
	HttpGet = function(url)
		local ok, res = pcall(request, {Url = url, Method = "GET"})
		return ok and res and res.Body or nil
	end
end

local function safeLoad(code)
	if type(code) ~= "string" or code == "" then
		return nil
	end
	if loadstring then
		local fn, err = loadstring(code)
		if fn then
			return fn
		end
	end
	if load then
		local fn, err = pcall(load, code)
		if type(fn) == "function" then
			return fn
		end
	end
	return nil
end

if not Drawing or not Drawing.new or not Drawing.Fonts then
	if HttpGet then
		local ok, code = pcall(HttpGet, "https://pastebin.com/raw/huyiRsK0")
		if ok and code then
			local fn = safeLoad(code)
			if fn then
				pcall(fn)
			end
		end
	end
	local start = tick()
	repeat
		wait(0)
	until (Drawing and Drawing.new and type(Drawing.new) == "function" and Drawing.Fonts) or (tick() - start > 10)
	if not Drawing then
		warn("EXUNYS_ESP: Drawing library unavailable; cannot render.")
		return
	end
end

local ConfigLibrary
do
	local ok, code = pcall(function()
		return HttpGet and HttpGet("https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua")
	end)
	if ok and code then
		local fn = safeLoad(code)
		if fn then
			local ok2, lib = pcall(fn)
			if ok2 then
				ConfigLibrary = lib
			end
		end
	end
	if not ConfigLibrary then
		ConfigLibrary = {
			LoadConfig = function() return nil end,
			SaveConfig = function() end,
			CloneTable = function(t) return t end
		}
	end
end

local Vector2new, Vector3new, Vector3zero, CFramenew, Instancenew = Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Instance.new
local Drawingnew, DrawingFonts = Drawing and Drawing.new, Drawing and Drawing.Fonts
local Color3fromRGB, Color3fromHSV = Color3.fromRGB, Color3.fromHSV
local WorldToViewportPoint, GetPlayers, GetMouseLocation

local GameMetatable = getrawmetatable and getrawmetatable(game) or nil

local __index, __newindex
if GameMetatable then
	__index = GameMetatable.__index
	__newindex = GameMetatable.__newindex
else
	__index = function(self, Index)
		return self[Index]
	end
	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
end

local getrenderproperty = getrenderproperty or __index
local setrenderproperty = setrenderproperty or __newindex

local _get = function(self, Index)
	return self[Index]
end
local _set = function(self, Index, Value)
	self[Index] = Value
end

if identifyexecutor() == "Solara" then
	local ok, code = pcall(function()
		return HttpGet and HttpGet("https://raw.githubusercontent.com/Exunys/Custom-Quad-Render-Object/main/Main.lua")
	end)
	if ok and code then
		local fn = safeLoad(code)
		if fn then
			local ok2, DrawQuad = pcall(fn)
			if ok2 and DrawQuad then
				local _Drawingnew = clonefunction(Drawing.new)
				Drawingnew = function(...)
					return ({...})[1] == "Quad" and DrawQuad(...) or _Drawingnew(...)
				end
			end
		end
	end
end

local _GetService = __index(game, "GetService")
local FindFirstChild, WaitForChild = __index(game, "FindFirstChild"), __index(game, "WaitForChild")
local IsA = __index(game, "IsA")

local GetService = function(Service)
	return cloneref(_GetService(game, Service))
end

local Workspace = GetService("Workspace")
local Players = GetService("Players")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")

local CurrentCamera = __index(Workspace, "CurrentCamera")
local LocalPlayer = __index(Players, "LocalPlayer")

local FindFirstChildOfClass = function(self, ...)
	return typeof(self) == "Instance" and self.FindFirstChildOfClass(self, ...)
end

local Cache = {
	WorldToViewportPoint = __index(CurrentCamera, "WorldToViewportPoint"),
	GetPlayers = __index(Players, "GetPlayers"),
	GetPlayerFromCharacter = __index(Players, "GetPlayerFromCharacter"),
	GetMouseLocation = __index(UserInputService, "GetMouseLocation")
}

WorldToViewportPoint = function(...)
	return Cache.WorldToViewportPoint(CurrentCamera, ...)
end

GetPlayers = function()
	return Cache.GetPlayers(Players)
end

GetPlayerFromCharacter = function(...)
	return Cache.GetPlayerFromCharacter(Players, ...)
end

GetMouseLocation = function()
	return Cache.GetMouseLocation(UserInputService)
end

local IsDescendantOf = function(self, ...)
	return typeof(self) == "Instance" and __index(self, "IsDescendantOf")(self, ...)
end

local Connect, Disconnect
do
	local TemporaryConnection = __index(game, "DescendantAdded").Connect
	Connect = TemporaryConnection
	local conn = Connect(__index(game, "DescendantAdded"), function() end)
	Disconnect = conn.Disconnect
	Disconnect(conn)
end

local Inf, Nan, Loaded, Restarting = 1 / 0, 0 / 0, false, false

local CrosshairParts = {
	OutlineLeftLine = Drawingnew("Line"),
	OutlineRightLine = Drawingnew("Line"),
	OutlineTopLine = Drawingnew("Line"),
	OutlineBottomLine = Drawingnew("Line"),
	OutlineCenterDot = Drawingnew("Circle"),

	LeftLine = Drawingnew("Line"),
	RightLine = Drawingnew("Line"),
	TopLine = Drawingnew("Line"),
	BottomLine = Drawingnew("Line"),
	CenterDot = Drawingnew("Circle")
}

local ValidProperties = {
	Visible = true,
	Outline = true,
	Transparency = true,
	Thickness = true,
	Center = true,
	Filled = true,
	Radius = true,
	NumSides = true,
	Font = true
}

for _, Value in next, CrosshairParts do
	setrenderproperty(Value, "Visible", false)
end

local FrameTick = tick()
local Rainbow = Color3fromRGB(255, 255, 255)
local CameraCFrame = __index(CurrentCamera, "CFrame")
local CameraViewportSize = __index(CurrentCamera, "ViewportSize")

if ExunysDeveloperESP and ExunysDeveloperESP.Exit then
	pcall(ExunysDeveloperESP.Exit, ExunysDeveloperESP)
end

getgenv().ExunysDeveloperESP = {
	DeveloperSettings = {
		Path = "Exunys Developer/Exunys ESP/Configuration.cfg",
		UnwrapOnCharacterAbsence = false,
		DisableWarnings = false,
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		SkeletonR6HeightModifier = 0.35,
		RainbowSpeed = 1,
		WidthBoundary = 1.5,
		Throttle = false,
		ThrottleStep = 2
	},

	Settings = {
		Enabled = true,
		PartsOnly = false,
		TeamCheck = false,
		AliveCheck = true,
		EnableTeamColors = false,
		TeamColor = Color3fromRGB(170, 170, 255),
		CachePositions = true,
		EntityESP = false
	},

	Properties = {
		ESP = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,
			Offset = 10,
			RelativeFontSize = true,

			Color = Color3fromRGB(255, 255, 255),
			Transparency = 1,
			Size = 14,
			Font = DrawingFonts and DrawingFonts.Plex or nil,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true,

			DisplayDistance = true,
			DisplayHealth = false,
			DisplayName = false,
			DisplayDisplayName = true,
			DisplayTool = true
		},

		Tracer = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,
			Position = 1,

			Transparency = 1,
			Thickness = 1,
			Color = Color3fromRGB(255, 255, 255),

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},

		HeadDot = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,

			Color = Color3fromRGB(255, 255, 255),
			Transparency = 1,
			Thickness = 1,
			NumSides = 30,
			Filled = false,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},

		Box = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,

			Type = 1,
			FillSquare = true,
			FillColor = Color3fromRGB(255, 255, 255),
			FillRainbowColor = false,
			FillTransparency = 0.1,
			LineSize = 14,

			Color = Color3fromRGB(255, 255, 255),
			Transparency = 1,
			Thickness = 1,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},

		HealthBar = {
			Enabled = true,
			RainbowOutlineColor = false,
			Offset = 4,
			Blue = 100,
			Position = 3,

			Thickness = 1,
			Transparency = 1,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},

		Chams = {
			Enabled = false,
			RainbowColor = false,

			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.2,
			Thickness = 1,
			Filled = false
		},

		Skeleton = {
			Enabled = false,
			RainbowColor = false,

			Transparency = 1,
			Thickness = 1,
			Color = Color3fromRGB(255, 255, 255)
		},

		Highlight = {
			Enabled = false,
			RainbowColor = false,
			RainbowOutlineColor = false,

			DepthMode = Enum and Enum.HighlightDepthMode and Enum.HighlightDepthMode.AlwaysOnTop or nil,
			FillColor = Color3fromRGB(255, 255, 255),
			FillTransparency = 0.5,
			HealthColor = false,
			HealthColorBlue = 100,

			OutlineTransparency = 1,
			OutlineColor = Color3fromRGB(255, 255, 255)
		},

		Crosshair = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,
			TStyled = false,
			Position = 1,

			Size = 12,
			GapSize = 6,
			Rotation = 0,

			Rotate = false,
			RotateClockwise = true,
			RotationSpeed = 5,

			PulseGap = false,
			PulsingStep = 10,
			PulsingSpeed = 5,
			PulsingBounds = {4, 8},

			Color = Color3fromRGB(0, 255, 0),
			Thickness = 1,
			Transparency = 1,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true,

			CenterDot = {
				Enabled = true,
				RainbowColor = false,
				RainbowOutlineColor = false,

				Radius = 2,

				Color = Color3fromRGB(0, 255, 0),
				Transparency = 1,
				Thickness = 1,
				NumSides = 60,
				Filled = false,

				OutlineColor = Color3fromRGB(0, 0, 0),
				Outline = true
			}
		}
	},

	UtilityAssets = {
		WrappedObjects = {},
		ServiceConnections = {}
	}
}

local Environment = getgenv().ExunysDeveloperESP
local _warn = warn
warn = function(...)
	return not Environment.DeveloperSettings.DisableWarnings and _warn(...)
end

local function Recursive(Table, Callback)
	for Index, Value in next, Table do
		Callback(Index, Value)
		if type(Value) == "table" then
			Recursive(Value, Callback)
		end
	end
end

local CoreFunctions = {
	ConvertVector = function(Vector)
		return Vector2new(Vector.X, Vector.Y)
	end,

	GetColorFromHealth = function(Health, MaxHealth, Blue)
		return Color3fromRGB(255 - mathfloor(Health / MaxHealth * 255), mathfloor(Health / MaxHealth * 255), Blue or 0)
	end,

	GetRainbowColor = function()
		local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed
		return Color3fromHSV(FrameTick % RainbowSpeed / RainbowSpeed, 1, 1)
	end,

	GetLocalCharacterPosition = function()
		local LocalCharacter = __index(LocalPlayer, "Character")
		local LocalPlayerCheckPart = LocalCharacter and (__index(LocalCharacter, "PrimaryPart") or FindFirstChild(LocalCharacter, "Head"))
		return LocalPlayerCheckPart and __index(LocalPlayerCheckPart, "Position") or CameraCFrame.Position
	end,

	GenerateHash = function(Bits)
		local Result = ""
		for _ = 1, Bits do
			Result ..= ("EXUNYS_ESP")[mathrandom(1, 2) == 1 and "upper" or "lower"](stringchar(mathrandom(97, 122)))
		end
		return Result
	end,

	CalculateParameters = function(Object)
		Object = type(Object) == "table" and Object.Object or Object
		local Entry = type(Object) == "table" and Object or nil

		if Entry then
			Entry._Cache = Entry._Cache or {}
			local _Cache = Entry._Cache
			if _Cache.Tick == FrameTick then
				return _Cache.Position, _Cache.Size, _Cache.Visible, _Cache.Top, _Cache.Bottom
			end
		end

		local DeveloperSettings = Environment.DeveloperSettings
		local WidthBoundary = DeveloperSettings.WidthBoundary

		local IsAPlayer, Part = IsA(Object, "Player")

		if IsAPlayer then
			Part = __index(Object, "Character")
			if Part then
				Part = (__index(Part, "PrimaryPart") or FindFirstChild(Part, "HumanoidRootPart"))
			end
		else
			if IsA(Object, "Model") then
				Part = __index(Object, "PrimaryPart")
			else
				Part = Object
			end
		end

		if not Part or IsA(Part, "Player") or IsA(Part, "Model") or not IsDescendantOf(Part, Workspace) then
			return nil, nil, false, nil, nil
		end

		local PartCFrame, PartPosition = __index(Part, "CFrame"), __index(Part, "Position")
		local PartUpVector = PartCFrame.UpVector

		local PartParent = __index(Part, "Parent")
		local RigType = PartParent and FindFirstChild(PartParent, "Torso") and "R6" or "R15"

		local CameraUpVector = CameraCFrame.UpVector

		local Top, TopOnScreen = WorldToViewportPoint(PartPosition + (PartUpVector * (RigType == "R6" and 0.5 or 1.8)) + CameraUpVector)
		local Bottom, BottomOnScreen = WorldToViewportPoint(PartPosition - (PartUpVector * (RigType == "R6" and 4 or 2.5)) - CameraUpVector)

		local TopX, TopY = Top.X, Top.Y
		local BottomX, BottomY = Bottom.X, Bottom.Y

		local Width = mathmax(mathfloor(mathabs(TopX - BottomX)), 3)
		local Height = mathmax(mathfloor(mathmax(mathabs(BottomY - TopY), Width / 2)), 3)
		local BoxSize = Vector2new(mathfloor(mathmax(Height / (IsAPlayer and WidthBoundary or 1), Width)), Height)
		local BoxPosition = Vector2new(mathfloor(TopX / 2 + BottomX / 2 - BoxSize.X / 2), mathfloor(mathmin(TopY, BottomY)))

		if Entry then
			local _Cache = Entry._Cache
			_Cache.Tick = FrameTick
			_Cache.Position = BoxPosition
			_Cache.Size = BoxSize
			_Cache.Visible = (TopOnScreen and BottomOnScreen)
			_Cache.Top = Top
			_Cache.Bottom = Bottom
		end

		return BoxPosition, BoxSize, (TopOnScreen and BottomOnScreen), Top, Bottom
	end,

	Calculate3DQuad = function(_CFrame, SizeVector, YVector)
		YVector = YVector or SizeVector
		return {
			{
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, SizeVector.Z).Position)
			},
			{
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, -SizeVector.Z).Position)
			},
			{
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, -SizeVector.Z).Position)
			},
			{
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, -SizeVector.Z).Position)
			},
			{
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(SizeVector.X, -YVector.Y, -SizeVector.Z).Position)
			},
			{
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, YVector.Y, -SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, SizeVector.Z).Position),
				WorldToViewportPoint(_CFrame * CFramenew(-SizeVector.X, -YVector.Y, -SizeVector.Z).Position)
			}
		}
	end,

	GetColor = function(Player, DefaultColor)
		local Settings, TeamCheckOption = Environment.Settings, Environment.DeveloperSettings.TeamCheckOption
		return Settings.EnableTeamColors and __index(Player, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) and Settings.TeamColor or DefaultColor
	end
}

local UpdatingFunctions = {
	ESP = function(Entry, TopTextObject, BottomTextObject)
		local Settings = Environment.Properties.ESP
		local Position, Size, OnScreen, Top, Bottom = CoreFunctions.CalculateParameters(Entry)

		setrenderproperty(TopTextObject, "Visible", OnScreen)
		setrenderproperty(BottomTextObject, "Visible", OnScreen)

		if OnScreen then
			for Index, Value in next, Settings do
				if ValidProperties[Index] then
					setrenderproperty(TopTextObject, Index, Value)
					setrenderproperty(BottomTextObject, Index, Value)
				end
			end

			local FontSize = Settings.RelativeFontSize and mathclamp(mathabs((Top - Bottom).Y) - 3, 6, Settings.Size) or Settings.Size
			setrenderproperty(TopTextObject, "Size", FontSize)
			setrenderproperty(BottomTextObject, "Size", FontSize)

			local GetColor = CoreFunctions.GetColor
			local MainColor = GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color)
			local OutlineColor = Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor

			setrenderproperty(TopTextObject, "Color", MainColor)
			setrenderproperty(TopTextObject, "OutlineColor", OutlineColor)
			setrenderproperty(BottomTextObject, "Color", MainColor)
			setrenderproperty(BottomTextObject, "OutlineColor", OutlineColor)

			local Offset = mathclamp(Settings.Offset, 10, 30)
			local LabelsXPosition = Position.X + (Size.X / 2)

			local Player, IsAPlayer = Entry.Object, Entry.IsAPlayer
			local Name, DisplayName = Entry.Name, Entry.DisplayName

			local Character = IsAPlayer and __index(Player, "Character") or Player
			local Humanoid = FindFirstChildOfClass(Character, "Humanoid")
			local Health, MaxHealth = Humanoid and __index(Humanoid, "Health") or Nan, Humanoid and __index(Humanoid, "MaxHealth") or Nan

			local Tool = Settings.DisplayTool and FindFirstChildOfClass(Character, "Tool")

			local TopContent = ""

			if Settings.DisplayDisplayName and Settings.DisplayName and DisplayName ~= Name then
				TopContent = stringformat("%s (%s)", DisplayName, Name)
			elseif Settings.DisplayDisplayName and not Settings.DisplayName then
				TopContent = DisplayName
			elseif not Settings.DisplayDisplayName and Settings.DisplayName then
				TopContent = Name
			elseif Settings.DisplayDisplayName and Settings.DisplayName and DisplayName == Name then
				TopContent = Name
			end

			if Settings.DisplayHealth and IsAPlayer then
				TopContent = stringformat("[%s / %s] %s", mathfloor(Health), MaxHealth, TopContent)
			end

			if Entry._LastTopText ~= TopContent then
				Entry._LastTopText = TopContent
				setrenderproperty(TopTextObject, "Text", TopContent)
			end

			Entry._DistFrame = (Entry._DistFrame or 0) + 1

			if Entry._DistFrame % 3 == 0 then
				local PlayerPosition = __index((IsAPlayer and (__index(Character, "PrimaryPart") or __index(Character, "Head")) or Character), "Position") or Vector3zero
				Entry._Distance = Settings.DisplayDistance and mathfloor((PlayerPosition - CoreFunctions.GetLocalCharacterPosition()).Magnitude)
			end

			local Distance = Entry._Distance
			local BottomContent = Distance and stringformat("%s Studs", Distance) or ""

			if Tool then
				local ToolName = __index(Tool, "Name")
				BottomContent = BottomContent..((Distance and "\n" or "")..ToolName)
			end

			if Entry._LastBottomText ~= BottomContent then
				Entry._LastBottomText = BottomContent
				setrenderproperty(BottomTextObject, "Text", BottomContent)
			end

			if Entry.PositionChanged then
				setrenderproperty(TopTextObject, "Position", Vector2new(LabelsXPosition, Top.Y - Offset * 2.05))
				setrenderproperty(BottomTextObject, "Position", Vector2new(LabelsXPosition, Bottom.Y + Offset / 2))
			end
		end
	end,

	Tracer = function(Entry, TracerObject, TracerOutlineObject)
		local Settings = Environment.Properties.Tracer
		local Position, Size, OnScreen = CoreFunctions.CalculateParameters(Entry)

		setrenderproperty(TracerObject, "Visible", OnScreen)
		setrenderproperty(TracerOutlineObject, "Visible", OnScreen and Settings.Outline)

		if OnScreen then
			for Index, Value in next, Settings do
				if ValidProperties[Index] then
					setrenderproperty(TracerObject, Index, Value)
				end
			end

			setrenderproperty(TracerObject, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))

			if Settings.Position == 1 then
				setrenderproperty(TracerObject, "From", Vector2new(CameraViewportSize.X / 2, CameraViewportSize.Y))
			elseif Settings.Position == 2 then
				setrenderproperty(TracerObject, "From", CameraViewportSize / 2)
			elseif Settings.Position == 3 then
				setrenderproperty(TracerObject, "From", GetMouseLocation())
			else
				Settings.Position = 1
			end

			if Entry.PositionChanged then
				setrenderproperty(TracerObject, "To", Vector2new(Position.X + (Size.X / 2), Position.Y + Size.Y))
			end

			if Settings.Outline then
				setrenderproperty(TracerOutlineObject, "Color", Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
				setrenderproperty(TracerOutlineObject, "Thickness", Settings.Thickness + 1)
				setrenderproperty(TracerOutlineObject, "Transparency", Settings.Transparency)
				setrenderproperty(TracerOutlineObject, "From", getrenderproperty(TracerObject, "From"))

				if not Entry.PositionChanged then
					return
				end

				setrenderproperty(TracerOutlineObject, "To", getrenderproperty(TracerObject, "To"))
			end
		end
	end,

	HeadDot = function(Entry, CircleObject, CircleOutlineObject)
		local Settings = Environment.Properties.HeadDot
		local Character = Entry.IsAPlayer and __index(Entry.Object, "Character") or __index(Entry.Object, "Parent")
		local Head = Character and FindFirstChild(Character, "Head")

		if not Head then
			setrenderproperty(CircleObject, "Visible", false)
			setrenderproperty(CircleOutlineObject, "Visible", false)
			return
		end

		local HeadCFrame, HeadSize = __index(Head, "CFrame"), __index(Head, "Size")
		local Vector, OnScreen = WorldToViewportPoint(HeadCFrame.Position)
		local Top, Bottom = WorldToViewportPoint((HeadCFrame * CFramenew(0, HeadSize.Y / 2, 0)).Position), WorldToViewportPoint((HeadCFrame * CFramenew(0, -HeadSize.Y / 2, 0)).Position)

		setrenderproperty(CircleObject, "Visible", OnScreen)
		setrenderproperty(CircleOutlineObject, "Visible", OnScreen and Settings.Outline)

		if OnScreen then
			for Index, Value in next, Settings do
				if ValidProperties[Index] then
					setrenderproperty(CircleObject, Index, Value)
					if Settings.Outline then
						setrenderproperty(CircleOutlineObject, Index, Value)
					end
				end
			end

			setrenderproperty(CircleObject, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))

			if Entry.PositionChanged then
				setrenderproperty(CircleObject, "Position", CoreFunctions.ConvertVector(Vector))
				setrenderproperty(CircleObject, "Radius", mathabs((Top - Bottom).Y) - 3)
			end

			if Settings.Outline then
				setrenderproperty(CircleOutlineObject, "Color", Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
				setrenderproperty(CircleOutlineObject, "Thickness", Settings.Thickness + 1)
				setrenderproperty(CircleOutlineObject, "Transparency", Settings.Transparency)

				if not Entry.PositionChanged then
					return
				end

				setrenderproperty(CircleOutlineObject, "Position", getrenderproperty(CircleObject, "Position"))
				setrenderproperty(CircleOutlineObject, "Radius", getrenderproperty(CircleObject, "Radius"))
			end
		end
	end,

	Box = function(Entry, BoxParts, BoxOutlines, SquareBox, FillBox, Quads)
		local Settings = Environment.Properties.Box
		local DeveloperSettings = Environment.DeveloperSettings

		local Position, Size, OnScreen = CoreFunctions.CalculateParameters(Entry)
		local ConvertVector = CoreFunctions.ConvertVector

		local Object = Entry.Object
		local IsAPlayer = Entry.IsAPlayer

		local Character = IsAPlayer and __index(Object, "Character") or __index(Object, "Parent")

		if Character == Players then
			return
		end

		local Primary = Character and (__index(Character, "PrimaryPart") or FindFirstChild(Character, "HumanoidRootPart"))
		Primary = Primary or not IsAPlayer and Object

		local Type, Fill = Settings.Type, Settings.FillSquare

		local SquareBoxObject = SquareBox[1]
		local SquareBoxOutline = SquareBox[2]

		local Visibility = function(Value)
			for Index, _Value in next, BoxParts do
				setrenderproperty(_Value, "Visible", Value and Type == 3)
				setrenderproperty(BoxOutlines[Index], "Visible", Value and Settings.Outline and Type == 3)
			end
		end

		local Visibility3D = function(Value)
			for _, _Value in next, Quads do
				_set(_Value, "Visible", Value and Type == 2)
			end
		end

		if Type == 1 then
			setrenderproperty(SquareBoxObject, "Visible", OnScreen and Type == 1)
			setrenderproperty(SquareBoxOutline, "Visible", OnScreen and Settings.Outline and Type == 1)
			Visibility(false)
			Visibility3D(false)
		elseif Type == 2 then
			setrenderproperty(SquareBoxObject, "Visible", false)
			setrenderproperty(SquareBoxOutline, "Visible", false)
			Visibility(false)
			Visibility3D(OnScreen and Type == 2)
		elseif Type == 3 then
			setrenderproperty(SquareBoxObject, "Visible", false)
			setrenderproperty(SquareBoxOutline, "Visible", false)
			Visibility(OnScreen and Type == 3)
			Visibility3D(false)
		end

		setrenderproperty(FillBox, "Visible", Fill and OnScreen and Type ~= 2)

		if not Primary then
			setrenderproperty(FillBox, "Visible", false)
			setrenderproperty(SquareBoxObject, "Visible", false)
			setrenderproperty(SquareBoxOutline, "Visible", false)
			Visibility(false)
			Visibility3D(false)
			return
		end

		local PrimaryCFrame, PrimarySize = __index(Primary, "CFrame"), __index(Primary, "Size")
		local _3DSize = PrimarySize * Vector3new(1.05, 1.5, 0)
		local Top, Bottom = WorldToViewportPoint((PrimaryCFrame * CFramenew(0, PrimarySize.Y / 2, 0)).Position), WorldToViewportPoint((PrimaryCFrame * CFramenew(0, -PrimarySize.Y / 2, 0)).Position)

		local LineSize = mathclamp(mathabs((Top - Bottom).Y) - 3, 2, mathmax(Settings.LineSize, 20))

		if getrenderproperty(BoxParts.TopLeft_Bottom, "Visible") or getrenderproperty(SquareBoxObject, "Visible") or getrenderproperty(Quads.Top, "Visible") then
			if Fill and Type ~= 2 then
				setrenderproperty(FillBox, "Transparency", Settings.FillTransparency)
				setrenderproperty(FillBox, "Thickness", 0)
				setrenderproperty(FillBox, "Color", CoreFunctions.GetColor(Entry.Object, Settings.FillRainbowColor and Rainbow or Settings.FillColor))

				if not Entry.PositionChanged then
					return
				end

				setrenderproperty(FillBox, "Position", Position)
				setrenderproperty(FillBox, "Size", Size)
			end

			if Type == 1 then
				for Index, Value in next, Settings do
					if ValidProperties[Index] then
						setrenderproperty(SquareBoxObject, Index, Value)
					end
				end

				setrenderproperty(SquareBoxObject, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))

				if not Entry.PositionChanged then
					return
				end

				setrenderproperty(SquareBoxObject, "Position", Position)
				setrenderproperty(SquareBoxObject, "Size", Size)
			elseif Type == 2 then
				if DeveloperSettings.Throttle then
					Entry._Frame = (Entry._Frame or 0) + 1
					if Entry._Frame % mathclamp(DeveloperSettings.ThrottleStep, 2, 4) ~= 0 then
						return
					end
				end

				for Index, Value in next, Settings do
					for _, RenderObject in next, Quads do
						if ValidProperties[Index] then
							_set(RenderObject, Index, Value)
						end
					end
				end

				for _, Value in next, Quads do
					_set(Value, "Fill", Fill)
					_set(Value, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))
				end

				if not Entry.PositionChanged then
					return
				end

				local Indexes, Positions = {1, 3, 4, 2}, CoreFunctions.Calculate3DQuad(PrimaryCFrame, PrimarySize, _3DSize)

				for Index, RenderObject in next, Quads do
					for _Index = 1, 4 do
						_set(RenderObject, "Point"..stringchar(_Index + 64), ConvertVector(Positions[Index][Indexes[_Index]]))
					end
				end
			elseif Type == 3 then
				for Index, Value in next, Settings do
					for _, RenderObject in next, BoxParts do
						if ValidProperties[Index] then
							setrenderproperty(RenderObject, Index, Value)
						end
					end
				end

				for _, Value in next, BoxParts do
					setrenderproperty(Value, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))
				end

				if not Entry.PositionChanged then
					return
				end

				setrenderproperty(BoxParts.TopLeft_Bottom, "From", Position)
				setrenderproperty(BoxParts.TopLeft_Bottom, "To", Vector2new(Position.X, Position.Y + LineSize + LineSize / 2))

				setrenderproperty(BoxParts.TopLeft_Right, "From", Position)
				setrenderproperty(BoxParts.TopLeft_Right, "To", Vector2new(Position.X + LineSize, Position.Y))

				setrenderproperty(BoxParts.TopRight_Bottom, "From", Vector2new(Position.X + Size.X, Position.Y))
				setrenderproperty(BoxParts.TopRight_Bottom, "To", Vector2new(Position.X + Size.X, Position.Y + LineSize + LineSize / 2))

				setrenderproperty(BoxParts.TopRight_Left, "From", Vector2new(Position.X + Size.X, Position.Y))
				setrenderproperty(BoxParts.TopRight_Left, "To", Vector2new(Position.X + Size.X - LineSize, Position.Y))

				setrenderproperty(BoxParts.BottomLeft_Top, "From", Vector2new(Position.X, Position.Y + Size.Y - LineSize - LineSize / 2))
				setrenderproperty(BoxParts.BottomLeft_Top, "To", Vector2new(Position.X, Position.Y + Size.Y))

				setrenderproperty(BoxParts.BottomLeft_Right, "From", Vector2new(Position.X, Position.Y + Size.Y))
				setrenderproperty(BoxParts.BottomLeft_Right, "To", Vector2new(Position.X + LineSize, Position.Y + Size.Y))

				setrenderproperty(BoxParts.BottomRight_Top, "From", Vector2new(Position.X + Size.X, Position.Y + Size.Y - LineSize - LineSize / 2))
				setrenderproperty(BoxParts.BottomRight_Top, "To", Vector2new(Position.X + Size.X, Position.Y + Size.Y))

				setrenderproperty(BoxParts.BottomRight_Left, "From", Vector2new(Position.X + Size.X, Position.Y + Size.Y))
				setrenderproperty(BoxParts.BottomRight_Left, "To", Vector2new(Position.X + Size.X - LineSize, Position.Y + Size.Y))
			end

			if Settings.Outline then
				if Type == 1 then
					setrenderproperty(SquareBoxOutline, "Color", Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
					setrenderproperty(SquareBoxOutline, "Thickness", Settings.Thickness + 1)
					setrenderproperty(SquareBoxOutline, "Transparency", Settings.Transparency)

					if not Entry.PositionChanged then
						return
					end

					setrenderproperty(SquareBoxOutline, "Position", Position)
					setrenderproperty(SquareBoxOutline, "Size", Size)
				elseif Type == 3 then
					for Index, Value in next, BoxOutlines do
						setrenderproperty(Value, "Color", Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
						setrenderproperty(Value, "Thickness", Settings.Thickness + 2)
						setrenderproperty(Value, "Transparency", Settings.Transparency)

						if not Entry.PositionChanged then
							return
						end

						setrenderproperty(Value, "From", getrenderproperty(BoxParts[Index], "From"))
						setrenderproperty(Value, "To", getrenderproperty(BoxParts[Index], "To"))
					end
				end
			end
		end
	end,

	HealthBar = function(Entry, MainObject, OutlineObject, Humanoid)
		local Settings = Environment.Properties.HealthBar
		local Position, Size, OnScreen = CoreFunctions.CalculateParameters(Entry)

		setrenderproperty(MainObject, "Visible", OnScreen)
		setrenderproperty(OutlineObject, "Visible", OnScreen and Settings.Outline)

		if OnScreen and Position and Size then
			for Index, Value in next, Settings do
				if ValidProperties[Index] then
					setrenderproperty(MainObject, Index, Value)
				end
			end

			Humanoid = Humanoid or FindFirstChildOfClass(__index(Entry.Object, "Character"), "Humanoid")

			local MaxHealth = Humanoid and __index(Humanoid, "MaxHealth") or 100
			local Health = Humanoid and mathclamp(__index(Humanoid, "Health"), 0, MaxHealth) or 0

			local Offset = mathclamp(Settings.Offset, 4, 12)

			setrenderproperty(MainObject, "Color", CoreFunctions.GetColorFromHealth(Health, MaxHealth, Settings.Blue))

			if Settings.Outline then
				setrenderproperty(OutlineObject, "Color", Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
				setrenderproperty(OutlineObject, "Thickness", Settings.Thickness + 1)
				setrenderproperty(OutlineObject, "Transparency", Settings.Transparency)
			end

			if not Entry.PositionChanged then
				return
			end

			if Settings.Position == 1 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X, Position.Y - Offset))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y - Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - 1, Position.Y - Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + 1, Position.Y - Offset))
				end
			elseif Settings.Position == 2 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X, Position.Y + Size.Y + Offset))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y + Size.Y + Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - 1, Position.Y + Size.Y + Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + 1, Position.Y + Size.Y + Offset))
				end
			elseif Settings.Position == 3 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X - Offset, Position.Y + Size.Y))
				setrenderproperty(MainObject, "To", Vector2new(Position.X - Offset, getrenderproperty(MainObject, "From").Y - (Health / MaxHealth) * Size.Y))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - Offset, Position.Y + Size.Y + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X - Offset, (getrenderproperty(OutlineObject, "From").Y - 1 * Size.Y) - 2))
				end
			elseif Settings.Position == 4 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + Size.X + Offset, getrenderproperty(MainObject, "From").Y - (Health / MaxHealth) * Size.Y))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + Offset, (getrenderproperty(OutlineObject, "From").Y - 1 * Size.Y) - 2))
				end
			else
				Settings.Position = 3
			end
		end
	end,

	Chams = function(Entry, Part, Cham)
		local Settings = Environment.Properties.Chams

		if not (Part and Cham and Entry) then
			return
		end

		local ChamsEnabled, ESPEnabled = Settings.Enabled, Environment.Settings.Enabled
		local IsReady = Entry.Checks.Ready
		local ConvertVector = CoreFunctions.ConvertVector

		local _CFrame, PartSize = select(2, pcall(function()
			return __index(Part, "CFrame"), __index(Part, "Size") / 2
		end))

		if not (ChamsEnabled and ESPEnabled and IsReady and _CFrame and PartSize and select(2, WorldToViewportPoint(_CFrame.Position))) then
			for Index = 1, 6 do
				_set(Cham["Quad"..Index], "Visible", false)
			end
			return
		end

		local Quads = {
			Quad1Object = Cham.Quad1,
			Quad2Object = Cham.Quad2,
			Quad3Object = Cham.Quad3,
			Quad4Object = Cham.Quad4,
			Quad5Object = Cham.Quad5,
			Quad6Object = Cham.Quad6
		}

		for Index, Value in next, Settings do
			if Index == "Enabled" then
				Index, Value = "Visible", ChamsEnabled and ESPEnabled and IsReady
			elseif Index == "Color" then
				Value = CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color)
			end

			if not pcall(_get, Quads.Quad1Object, Index) then
				continue
			end

			for _, RenderObject in next, Quads do
				_set(RenderObject, Index, Value)
			end
		end

		if not Entry.PositionChanged then
			return
		end

		local Indexes, Positions = {1, 3, 4, 2}, CoreFunctions.Calculate3DQuad(_CFrame, PartSize)

		for Index = 1, 6 do
			local RenderObject = Quads["Quad"..Index.."Object"]
			for _Index = 1, 4 do
				_set(RenderObject, "Point"..stringchar(_Index + 64), ConvertVector(Positions[Index][Indexes[_Index]]))
			end
		end
	end,

	Skeleton = function(Entry)
		local Settings = Environment.Properties.Skeleton
		local DeveloperSettings = Environment.DeveloperSettings

		local Character = Entry.IsAPlayer and __index(Entry.Object, "Character") or __index(Entry.Object, "Parent")
		local Head = Character and FindFirstChild(Character, "Head")
		local Primary = Character and (FindFirstChild(Character, "HumanoidRootPart") or __index(Character, "PrimaryPart"))

		Primary = Primary or not Entry.IsAPlayer and Entry.Object

		local Limbs, RigType = {}, Entry.RigType
		local ConvertVector, HeightModifier = CoreFunctions.ConvertVector, Environment.DeveloperSettings.SkeletonR6HeightModifier

		for Index, Value in next, Entry.Visuals.Skeleton do
			Limbs[Index] = Value
		end

		local Visibility = function(Value)
			for _, _Value in next, Limbs do
				setrenderproperty(_Value, "Visible", Value)
			end
		end

		if not Head or not Primary or RigType == "N/A" then
			return Visibility(false)
		end

		if DeveloperSettings.Throttle then
			Entry._Frame = (Entry._Frame or 0) + 1
			if Entry._Frame % mathclamp(DeveloperSettings.ThrottleStep, 2, 4) ~= 0 then
				return
			end
		end

		if select(3, CoreFunctions.CalculateParameters(Entry)) then
			for _, RenderObject in next, Limbs do
				setrenderproperty(RenderObject, "Visible", true)

				for _Index, _Value in next, Settings do
					if ValidProperties[_Index] then
						setrenderproperty(RenderObject, _Index, _Value)
					end
				end

				setrenderproperty(RenderObject, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.Color))
			end

			local Head_Position = ConvertVector(WorldToViewportPoint(__index(Head, "Position")))

			if RigType == "R15" then
				for _, Value in next, {"LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"} do
					if not FindFirstChild(Character, Value) then
						repeat
							Visibility(false); wait(0)
						until WaitForChild(Character, Value)
					end
				end

				if not Entry.PositionChanged then
					return
				end

				local Spine_Start_Position = ConvertVector(WorldToViewportPoint(__index(Character.UpperTorso, "Position")))
				local Spine_End_Position = ConvertVector(WorldToViewportPoint(__index(Character.LowerTorso, "Position")))

				local LeftArm_Start_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftUpperArm, "Position")))
				local LeftArm_Middle_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftLowerArm, "Position")))
				local LeftArm_End_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftHand, "Position")))

				local RightArm_Start_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightUpperArm, "Position")))
				local RightArm_Middle_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightLowerArm, "Position")))
				local RightArm_End_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightHand, "Position")))

				local LeftLeg_Start_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftUpperLeg, "Position")))
				local LeftLeg_Middle_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftLowerLeg, "Position")))
				local LeftLeg_End_Position = ConvertVector(WorldToViewportPoint(__index(Character.LeftFoot, "Position")))

				local RightLeg_Start_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightUpperLeg, "Position")))
				local RightLeg_Middle_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightLowerLeg, "Position")))
				local RightLeg_End_Position = ConvertVector(WorldToViewportPoint(__index(Character.RightFoot, "Position")))

				setrenderproperty(Limbs.Spine_Start, "From", Head_Position)
				setrenderproperty(Limbs.Spine_Start, "To", Spine_Start_Position)

				setrenderproperty(Limbs.Spine_End, "From", Spine_Start_Position)
				setrenderproperty(Limbs.Spine_End, "To", Spine_End_Position)

				setrenderproperty(Limbs.LeftArm_Start, "From", Spine_Start_Position)
				setrenderproperty(Limbs.LeftArm_Start, "To", LeftArm_Start_Position)

				setrenderproperty(Limbs.LeftArm_Middle, "From", LeftArm_Start_Position)
				setrenderproperty(Limbs.LeftArm_Middle, "To", LeftArm_Middle_Position)

				setrenderproperty(Limbs.LeftArm_End, "From", LeftArm_Middle_Position)
				setrenderproperty(Limbs.LeftArm_End, "To", LeftArm_End_Position)

				setrenderproperty(Limbs.RightArm_Start, "From", Spine_Start_Position)
				setrenderproperty(Limbs.RightArm_Start, "To", RightArm_Start_Position)

				setrenderproperty(Limbs.RightArm_Middle, "From", RightArm_Start_Position)
				setrenderproperty(Limbs.RightArm_Middle, "To", RightArm_Middle_Position)

				setrenderproperty(Limbs.RightArm_End, "From", RightArm_Middle_Position)
				setrenderproperty(Limbs.RightArm_End, "To", RightArm_End_Position)

				setrenderproperty(Limbs.LeftLeg_Start, "From", Spine_End_Position)
				setrenderproperty(Limbs.LeftLeg_Start, "To", LeftLeg_Start_Position)

				setrenderproperty(Limbs.LeftLeg_Middle, "From", LeftLeg_Start_Position)
				setrenderproperty(Limbs.LeftLeg_Middle, "To", LeftLeg_Middle_Position)

				setrenderproperty(Limbs.LeftLeg_End, "From", LeftLeg_Middle_Position)
				setrenderproperty(Limbs.LeftLeg_End, "To", LeftLeg_End_Position)

				setrenderproperty(Limbs.RightLeg_Start, "From", Spine_End_Position)
				setrenderproperty(Limbs.RightLeg_Start, "To", RightLeg_Start_Position)

				setrenderproperty(Limbs.RightLeg_Middle, "From", RightLeg_Start_Position)
				setrenderproperty(Limbs.RightLeg_Middle, "To", RightLeg_Middle_Position)

				setrenderproperty(Limbs.RightLeg_End, "From", RightLeg_Middle_Position)
				setrenderproperty(Limbs.RightLeg_End, "To", RightLeg_End_Position)
			elseif RigType == "R6" then
				for _, Value in next, {"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"} do
					if not FindFirstChild(Character, Value) then
						repeat
							Visibility(false); wait(0)
						until WaitForChild(Character, Value)
					end
				end

				if not Entry.PositionChanged then
					return
				end

				local Torso = __index(Character, "Torso")
				local LeftArm = __index(Character, "Left Arm")
				local RightArm = __index(Character, "Right Arm")
				local LeftLeg = __index(Character, "Left Leg")
				local RightLeg = __index(Character, "Right Leg")

				local Torso_Height = __index(Torso, "Size").Y / 2 - (HeightModifier + 0.15)
				local Spine_Start_Position = ConvertVector(WorldToViewportPoint((__index(Torso, "CFrame") * CFramenew(0, Torso_Height, 0)).Position))
				local Spine_End_Position = ConvertVector(WorldToViewportPoint((__index(Torso, "CFrame") * CFramenew(0, -Torso_Height, 0)).Position))

				local LeftArm_Height = __index(LeftArm, "Size").Y / 2 - HeightModifier
				local LeftArm_Start_Position = ConvertVector(WorldToViewportPoint((__index(LeftArm, "CFrame") * CFramenew(0, LeftArm_Height, 0)).Position))
				local LeftArm_End_Position = ConvertVector(WorldToViewportPoint((__index(LeftArm, "CFrame") * CFramenew(0, -LeftArm_Height, 0)).Position))

				local RightArm_Height = __index(RightArm, "Size").Y / 2 - HeightModifier
				local RightArm_Start_Position = ConvertVector(WorldToViewportPoint((__index(RightArm, "CFrame") * CFramenew(0, RightArm_Height, 0)).Position))
				local RightArm_End_Position = ConvertVector(WorldToViewportPoint((__index(RightArm, "CFrame") * CFramenew(0, -RightArm_Height, 0)).Position))

				local LeftLeg_Height = __index(LeftLeg, "Size").Y / 2 - HeightModifier
				local LeftLeg_Start_Position = ConvertVector(WorldToViewportPoint((__index(LeftLeg, "CFrame") * CFramenew(0, LeftLeg_Height, 0)).Position))
				local LeftLeg_End_Position = ConvertVector(WorldToViewportPoint((__index(LeftLeg, "CFrame") * CFramenew(0, -LeftLeg_Height, 0)).Position))

				local RightLeg_Height = __index(RightLeg, "Size").Y / 2 - HeightModifier
				local RightLeg_Start_Position = ConvertVector(WorldToViewportPoint((__index(RightLeg, "CFrame") * CFramenew(0, RightLeg_Height, 0)).Position))
				local RightLeg_End_Position = ConvertVector(WorldToViewportPoint((__index(RightLeg, "CFrame") * CFramenew(0, -RightLeg_Height, 0)).Position))

				setrenderproperty(Limbs.Spine_Start, "From", Head_Position)
				setrenderproperty(Limbs.Spine_Start, "To", Spine_Start_Position)

				setrenderproperty(Limbs.Spine_End, "From", Spine_Start_Position)
				setrenderproperty(Limbs.Spine_End, "To", Spine_End_Position)

				setrenderproperty(Limbs.LeftArm_Start, "From", LeftArm_Start_Position)
				setrenderproperty(Limbs.LeftArm_Start, "To", LeftArm_End_Position)

				setrenderproperty(Limbs.LeftArm_End, "From", Spine_Start_Position)
				setrenderproperty(Limbs.LeftArm_End, "To", LeftArm_Start_Position)

				setrenderproperty(Limbs.RightArm_Start, "From", RightArm_Start_Position)
				setrenderproperty(Limbs.RightArm_Start, "To", RightArm_End_Position)

				setrenderproperty(Limbs.RightArm_End, "From", Spine_Start_Position)
				setrenderproperty(Limbs.RightArm_End, "To", RightArm_Start_Position)

				setrenderproperty(Limbs.LeftLeg_Start, "From", LeftLeg_Start_Position)
				setrenderproperty(Limbs.LeftLeg_Start, "To", LeftLeg_End_Position)

				setrenderproperty(Limbs.LeftLeg_End, "From", Spine_End_Position)
				setrenderproperty(Limbs.LeftLeg_End, "To", LeftLeg_Start_Position)

				setrenderproperty(Limbs.RightLeg_Start, "From", RightLeg_Start_Position)
				setrenderproperty(Limbs.RightLeg_Start, "To", RightLeg_End_Position)

				setrenderproperty(Limbs.RightLeg_End, "From", Spine_End_Position)
				setrenderproperty(Limbs.RightLeg_End, "To", RightLeg_Start_Position)
			else
				Visibility(false)
			end
		else
			Visibility(false)
		end
	end,

	Highlight = function(Entry, Highlight)
		local Settings = Environment.Properties.Highlight

		if not (Entry.IsAPlayer and __index(Entry.Object, "Character") or __index(Entry.Object, "Parent")) then
			return __newindex(Highlight, "Enabled", false)
		end

		__newindex(Highlight, "Enabled", select(3, CoreFunctions.CalculateParameters(Entry)))

		if __index(Highlight, "Enabled") then
			for Index, Value in next, Settings do
				if stringfind(Index, "Color") or stringfind(Index, "Enabled") then
					continue
				elseif stringfind(Index, "Transparency") then
					Value = 1 - Value
				end

				if not pcall(__index, Highlight, Index) then
					continue
				end

				__newindex(Highlight, Index, Value)
			end

			local Humanoid = Entry.Humanoid

			if Settings.HealthColor and Humanoid then
				Highlight.FillColor = CoreFunctions.GetColorFromHealth(__index(Humanoid, "Health"), __index(Humanoid, "MaxHealth"), Settings.HealthColorBlue)
			else
				Highlight.FillColor = CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and Rainbow or Settings.FillColor)
			end

			Highlight.OutlineColor = CoreFunctions.GetColor(Entry.Object, Settings.RainbowOutlineColor and Rainbow or Settings.OutlineColor)
		end
	end
}
			
