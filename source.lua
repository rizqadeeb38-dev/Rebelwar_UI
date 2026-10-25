--[[
    RebelUI v1.0.0  ·  made by prorizz196  ·  MIT license
    The panel library behind Rebelwar. Mobile friendly. Made for Roblox executors.
    Same look as the Rebelwar Hub: spinning ring, embers, glowing tabs, shiny buttons,
    pill toggles, a top bar you can fill with FPS / Timer / Logo and more, and a loading screen.

    local UI  = loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"))()

    local Load = UI:Loading({ Title = "Rebelwar", Logo = 114659273298746 })   -- optional loading screen
    Load:Status("Starting..."); Load:Progress(0.6)
    Load:Finish()

    local Win  = UI:CreateWindow({ Title = "Rebelwar", Subtitle = "my panel", Icon = 114659273298746 })
    local Bar  = Win:CreateBar({ Items = { "FPS", "Logo", "Timer" } })
    local Tab  = Win:CreateTab({ Name = "Main", Icon = 78400891408621, Title = "Main hub", Description = "Hello!" })
    Tab:Toggle({ Name = "Speed", Description = "Run faster", Callback = function(on) print(on) end })
    Win:CreateSettingsTab({ Bar = Bar })

    Elements: Section, Label, Divider, Button, Toggle, Slider, Dropdown, Input, Keybind,
              Color, Header, Image, Progress, Paragraph, Choice, Cycle
    Window:   CreateTab, CreateBar, CreateSettingsTab, Notify, SetTheme, SetAccent, SetScale,
              SetTransparency, Toggle, Save, Load, Destroy
    Every element returns an object with :Get() and :Set(value).
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local RebelUI = { Version = "1.0.0" }
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

-- ============================================================ themes
-- A theme is built from one accent color. "Red" is the exact Rebelwar Hub look.
local rgb = Color3.fromRGB

local function makeTheme(accent, over)
	local h, s = accent:ToHSV()
	local function d(sv, v)
		return Color3.fromHSV(h, math.clamp(s * sv, 0, 1), v)
	end
	local t = {
		Accent = accent,
		Glow = accent:Lerp(Color3.new(1, 1, 1), 0.15),
		Dark = accent:Lerp(Color3.new(0, 0, 0), 0.6),
		BG0 = d(0.9, 0.09),
		BG1 = d(0.85, 0.2),
		S0 = d(0.9, 0.12),
		S1 = d(0.85, 0.24),
		B0 = d(0.9, 0.1),
		B1 = d(0.85, 0.26),
		Item = d(0.8, 0.17),
		ItemOn = d(0.85, 0.24),
		Off = d(0.35, 0.3),
		Inset = d(0.9, 0.07),
	}
	for k, v in pairs(over or {}) do
		t[k] = v
	end
	return t
end

local THEMES = {
	Red = makeTheme(rgb(235, 40, 50), {
		Glow = rgb(255, 60, 70),
		Dark = rgb(110, 12, 20),
		BG0 = rgb(22, 10, 12),
		BG1 = rgb(40, 14, 19),
		S0 = rgb(30, 13, 16),
		S1 = rgb(48, 16, 23),
		B0 = rgb(26, 12, 14),
		B1 = rgb(58, 16, 24),
		Item = rgb(42, 18, 22),
		ItemOn = rgb(58, 20, 27),
		Off = rgb(78, 44, 48),
		Inset = rgb(26, 11, 14),
	}),
	Crimson = makeTheme(rgb(200, 20, 45)),
	Blue = makeTheme(rgb(64, 140, 255)),
	Green = makeTheme(rgb(60, 205, 110)),
	Purple = makeTheme(rgb(160, 90, 255)),
	Orange = makeTheme(rgb(255, 140, 40)),
	Pink = makeTheme(rgb(255, 80, 170)),
	Gold = makeTheme(rgb(245, 190, 40)),
	Cyber = makeTheme(rgb(0, 235, 230)),
	Blood = makeTheme(rgb(150, 10, 20)),
	Ice = makeTheme(rgb(150, 210, 255)),
	Mono = makeTheme(rgb(190, 190, 205)),
}
RebelUI.Themes = { "Red", "Crimson", "Blue", "Green", "Purple", "Orange", "Pink", "Gold", "Cyber", "Blood", "Ice", "Mono" }

local C = {
	Text = rgb(240, 235, 235),
	Dim = rgb(150, 125, 128),
	White = Color3.new(1, 1, 1),
	Green = rgb(70, 220, 110),
	Yellow = rgb(255, 200, 70),
	Bad = rgb(235, 70, 70),
}

-- ============================================================ helpers
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		o[k] = v
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local function corner(o, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(
		o,
		TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function safe(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[RebelUI] callback error: " .. tostring(err))
	end
end

local function asset(x)
	-- accepts 123456, "123456" or "rbxassetid://123456"
	if type(x) == "number" then
		return "rbxassetid://" .. tostring(math.floor(x))
	end
	x = tostring(x or "")
	if x:match("^%d+$") then
		return "rbxassetid://" .. x
	end
	return x
end

local function label(parent, str, size, color, bold)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Text = str,
		TextSize = size or 11,
		TextColor3 = color or C.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function fitText(l, maxSize)
	l.TextScaled = true
	new("UITextSizeConstraint", { MaxTextSize = maxSize }, l)
end

local function gradient(obj, c0, c1, rot)
	return new("UIGradient", { Color = ColorSequence.new(c0, c1), Rotation = rot or 0 }, obj)
end

local function ringSeq(t)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, t.Glow),
		ColorSequenceKeypoint.new(0.5, t.Dark),
		ColorSequenceKeypoint.new(1, t.Glow),
	})
end

local function pulse(obj)
	local sc = new("UIScale", {}, obj)
	TweenService:Create(
		sc,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Scale = 1.12 }
	):Play()
	return sc
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- Mouse or finger drag on a bar. onRel gets a number from 0 to 1.
local function bindBar(win, bar, onRel, onState)
	local dragging = false
	local function fromInput(i)
		local w = bar.AbsoluteSize.X
		if w <= 0 then
			return
		end
		onRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1))
	end
	bar.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			if onState then
				onState(true)
			end
			fromInput(i)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			fromInput(i)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			if onState then
				onState(false)
			end
		end
	end)
end

local function pickParent()
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and h then
		return h
	end
	ok, h = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and h then
		return h
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function clearOld(name)
	local lp = Players.LocalPlayer
	local places = { pickParent() }
	local pg = lp and lp:FindFirstChildOfClass("PlayerGui")
	if pg then
		table.insert(places, pg)
	end
	for _, place in ipairs(places) do
		for _, g in ipairs(place:GetChildren()) do
			if g.Name == name then
				g:Destroy()
			end
		end
	end
end

local function toHex(c)
	return string.format(
		"#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5)
	)
end

local function fromHex(s)
	s = tostring(s):gsub("#", "")
	if #s ~= 6 then
		return nil
	end
	local r, g, b = tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16)
	if not (r and g and b) then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

function Window:_onTheme(fn)
	fn(self.Theme)
	table.insert(self._fns, fn)
end

-- a stroke whose gradient spins around the object and follows the theme
function Window:_ring(stroke)
	stroke.Color = Color3.new(1, 1, 1)
	local g = new("UIGradient", { Color = ringSeq(self.Theme) }, stroke)
	table.insert(self._spin, g)
	return g
end

-- ============================================================ loading screen
local function fadeOut(root, dur)
	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local function tw(obj, props)
		pcall(function()
			TweenService:Create(obj, info, props):Play()
		end)
	end
	tw(root, { BackgroundTransparency = 1 })
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("UIStroke") then
			tw(d, { Transparency = 1 })
		elseif d:IsA("ImageLabel") then
			tw(d, { ImageTransparency = 1, BackgroundTransparency = 1 })
		elseif d:IsA("TextLabel") or d:IsA("TextButton") then
			tw(d, { TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1 })
		elseif d:IsA("Frame") then
			tw(d, { BackgroundTransparency = 1 })
		end
	end
end

function RebelUI:Loading(o)
	-- Title, Subtitle, Logo, Banner, Badge, Footer, Theme, Name
	-- Returns L with :Progress(0-1) :Status(text) :Badge(text) :Preload({ids}) :Run(steps) :Fail(text) :Finish()
	o = o or {}
	local theme = THEMES[o.Theme or "Red"] or THEMES.Red
	local name = o.Name or "RebelUI_Loading"
	clearOld(name)
	local L = {}
	local sg = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		sg.ScreenInsets = Enum.ScreenInsets.None
	end)
	sg.Parent = pickParent()

	local root = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 3, 5),
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
		ZIndex = 1,
	}, sg)

	if o.Banner then
		local banner = new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = asset(o.Banner),
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 1,
		}, root)
		local bs = new("UIScale", {}, banner)
		TweenService:Create(bs, TweenInfo.new(14, Enum.EasingStyle.Linear), { Scale = 1.12 }):Play()
	end
	-- dark shade (heavier at the bottom) and an accent glow at the bottom
	local shade = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2 }, root)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.75),
			NumberSequenceKeypoint.new(0.45, 0.6),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
	}, shade)
	local tint = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Accent:Lerp(Color3.new(0, 0, 0), 0.35),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, root)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.55, 1),
			NumberSequenceKeypoint.new(1, 0.72),
		}),
	}, tint)

	-- rising embers
	local embers = {}
	for i = 1, 24 do
		local s = math.random(2, 5)
		local e = new("Frame", {
			Size = UDim2.fromOffset(s, s),
			BackgroundColor3 = (math.random() < 0.5) and theme.Glow or theme.Accent:Lerp(Color3.new(1, 0.7, 0.2), 0.5),
			BackgroundTransparency = 0.25 + math.random() * 0.5,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, root)
		corner(e, s)
		embers[i] = { f = e, x = math.random(), y = math.random(), sp = 0.04 + math.random() * 0.09, ph = math.random() * 6.28, fr = 0.6 + math.random() }
	end

	-- badge (top center)
	local badge = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.08, 0),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Text = "",
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = C.Text,
		Visible = false,
		ZIndex = 6,
	}, root)
	corner(badge, 13)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, badge)
	local badgeStroke = new("UIStroke", {
		Color = theme.Glow,
		Thickness = 1,
		Transparency = 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, badge)

	-- logo with a spinning ring
	local spin = {}
	if o.Logo then
		local logoL = new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.27, 0),
			Size = UDim2.fromOffset(84, 84),
			BackgroundTransparency = 1,
			Image = asset(o.Logo),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 5,
		}, root)
		corner(logoL, 18)
		local logoRing = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1), Thickness = 2 }, logoL)
		table.insert(spin, new("UIGradient", { Color = ringSeq(theme) }, logoRing))
		pulse(logoL)
	end

	-- title: accent text with a white shine sweeping across
	local titleL = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 0),
		Size = UDim2.fromOffset(340, 62),
		BackgroundTransparency = 1,
		Text = o.Title or "RebelUI",
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		ZIndex = 5,
	}, root)
	new("UITextSizeConstraint", { MaxTextSize = 50 }, titleL)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2.5 }, titleL)
	local base = theme.Accent:Lerp(Color3.new(1, 1, 1), 0.05)
	local titleGrad = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, base),
			ColorSequenceKeypoint.new(0.42, base),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.58, base),
			ColorSequenceKeypoint.new(1, base),
		}),
	}, titleL)
	local titleScale = new("UIScale", { Scale = 0.7 }, titleL)
	if o.Subtitle then
		new("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.42, 46),
			Size = UDim2.fromOffset(320, 16),
			BackgroundTransparency = 1,
			Text = string.upper(o.Subtitle),
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(235, 215, 218),
			TextTransparency = 0.15,
			ZIndex = 5,
		}, root)
	end

	-- loading bar block
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.8, 0),
		Size = UDim2.new(0.6, 0, 0, 44),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, root)
	new("UISizeConstraint", { MaxSize = Vector2.new(400, 44), MinSize = Vector2.new(220, 44) }, holder)
	local statusL = label(holder, "", 13, C.Text, false)
	statusL.Size = UDim2.new(1, -60, 0, 18)
	statusL.Position = UDim2.fromOffset(2, 0)
	statusL.Font = Enum.Font.GothamMedium
	statusL.ZIndex = 6
	local pctL = label(holder, "0%", 13, C.Text, true)
	pctL.Size = UDim2.fromOffset(56, 18)
	pctL.Position = UDim2.new(1, -56, 0, 0)
	pctL.TextXAlignment = Enum.TextXAlignment.Right
	pctL.ZIndex = 6
	local outer = new("Frame", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 24), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 6 }, holder)
	corner(outer, 8)
	local redRing = new("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = theme.Glow, BorderSizePixel = 0, ZIndex = 6 }, outer)
	corner(redRing, 7)
	local inner = new("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundColor3 = Color3.fromRGB(18, 7, 9),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 7,
	}, redRing)
	corner(inner, 6)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 8 }, inner)
	corner(fill, 6)
	gradient(fill, theme.Accent, theme.Accent:Lerp(Color3.new(1, 0.7, 0.3), 0.55), 0)
	local shimmer = new("Frame", { Size = UDim2.fromScale(0.4, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 9 }, fill)
	new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, shimmer)

	if o.Footer ~= false then
		new("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.94, 0),
			Size = UDim2.fromOffset(320, 16),
			BackgroundTransparency = 1,
			Text = o.Footer or ("RebelUI v" .. RebelUI.Version),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(210, 180, 182),
			TextTransparency = 0.25,
			ZIndex = 5,
		}, root)
	end

	local target, displayed, alive = 0, 0, true
	local conn = RunService.RenderStepped:Connect(function(dt)
		local now = os.clock()
		displayed += (target - displayed) * math.min(1, dt * 5)
		fill.Size = UDim2.fromScale(math.clamp(displayed, 0, 1), 1)
		pctL.Text = math.floor(displayed * 100 + 0.5) .. "%"
		shimmer.Position = UDim2.fromScale(((now * 0.9) % 1.6) - 0.5, 0)
		titleGrad.Offset = Vector2.new(((now * 0.55) % 2) - 1, 0)
		local rot = (now * 90) % 360
		for _, g in ipairs(spin) do
			g.Rotation = rot
		end
		for _, e in ipairs(embers) do
			e.y -= e.sp * dt
			if e.y < -0.05 then
				e.y = 1.05
				e.x = math.random()
			end
			e.f.Position = UDim2.new(e.x, math.sin(now * e.fr + e.ph) * 14, e.y, 0)
		end
	end)
	tween(titleScale, 0.7, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	function L:Progress(p)
		target = math.clamp(tonumber(p) or 0, 0, 1)
	end
	function L:Status(text, color)
		statusL.Text = tostring(text or "")
		statusL.TextColor3 = color or C.Text
		statusL.TextTransparency = 1
		statusL.Position = UDim2.fromOffset(2, 6)
		tween(statusL, 0.25, { TextTransparency = 0, Position = UDim2.fromOffset(2, 0) })
	end
	function L:Badge(text, color)
		badge.Text = tostring(text or "")
		badge.TextColor3 = color or C.Text
		badgeStroke.Color = color or theme.Glow
		badge.Visible = true
		badge.BackgroundTransparency = 1
		tween(badge, 0.3, { BackgroundTransparency = 0.35 })
	end
	function L:Fail(text)
		fill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		L:Status(text or "Something went wrong", Color3.fromRGB(255, 90, 90))
	end
	-- loads images / sounds ahead of time and moves the bar from `from` to `to` while it works
	function L:Preload(list, from, to)
		list = list or {}
		from, to = from or target, to or 1
		local ids = {}
		for _, x in ipairs(list) do
			table.insert(ids, asset(x))
		end
		if #ids == 0 then
			return
		end
		local done, finished = 0, false
		task.spawn(function()
			pcall(function()
				game:GetService("ContentProvider"):PreloadAsync(ids, function()
					done += 1
					L:Progress(from + (to - from) * math.min(done / #ids, 1))
				end)
			end)
			finished = true
		end)
		local t0 = os.clock()
		while not finished and os.clock() - t0 < 5 do
			task.wait(0.05)
		end
	end
	-- Run({ {"Loading assets", function() ... end}, {"Building panel", fn} }): shows each step and fills the bar
	function L:Run(steps)
		steps = steps or {}
		for i, step in ipairs(steps) do
			L:Status(step[1])
			if type(step[2]) == "function" then
				local ok, err = pcall(step[2])
				if not ok then
					warn("[RebelUI] loading step failed: " .. tostring(err))
				end
			end
			L:Progress(i / #steps)
			task.wait(0.18)
		end
	end
	function L:Finish()
		if not alive then
			return
		end
		alive = false
		target = 1
		local t0 = os.clock()
		while displayed < 0.985 and os.clock() - t0 < 1.2 do
			task.wait()
		end
		task.wait(0.25)
		tween(titleScale, 0.55, { Scale = 1.15 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		fadeOut(root, 0.55)
		task.wait(0.65)
		conn:Disconnect()
		sg:Destroy()
	end
	function L:Destroy()
		alive = false
		conn:Disconnect()
		sg:Destroy()
	end
	L.Gui = sg
	return L
end

-- ============================================================ window
function RebelUI:CreateWindow(o)
	o = o or {}
	local win = setmetatable({
		_conns = {},
		_fns = {},
		_tabs = {},
		_spin = {},
		_frame = {},
		Flags = {},
		Open = false,
		Sound = o.Sound == true,
		Toasts = o.Toasts ~= false,
		NotifyTime = 4,
		ConfirmClose = o.ConfirmClose == true,
		Scale = 1,
	}, Window)
	local themeName = THEMES[o.Theme or "Red"] and (o.Theme or "Red") or "Red"
	win.Theme = THEMES[themeName]
	win.ThemeName = themeName
	win.TitleText = o.Title or "RebelUI"
	local lp = Players.LocalPlayer

	local name = o.Name or "RebelUI"
	clearOld(name)

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	local width = math.floor(math.min(o.Width or 420, math.max(300, vp.X * 0.9)))
	local height = math.floor(math.min(o.Height or 340, math.max(200, vp.Y * 0.85)))
	win._baseSize = { width, height }

	local gui = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	win.Gui = gui

	win._click = new("Sound", { SoundId = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.6 }, gui)

	-- ---------- the panel: spinning ring + thin black outer ring
	local main = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = o.Position or UDim2.new(0.5, 0, 0.5, 22),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		Visible = false,
		ClipsDescendants = false,
	}, gui)
	corner(main, 10)
	local mainG = new("UIGradient", { Rotation = 90 }, main)
	local panelScale = new("UIScale", { Scale = 0.6 }, main)
	local ringStroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1 }, main)
	win:_ring(ringStroke)
	local blackRing = new("Frame", {
		Size = UDim2.new(1, 2, 1, 2),
		Position = UDim2.fromOffset(-1, -1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
	}, main)
	corner(blackRing, 11)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, blackRing)
	win.Main, win._mainG, win._scaleObj = main, mainG, panelScale

	-- embers drifting up behind the content
	local fx = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Active = false }, main)
	corner(fx, 10)
	local embers = {}
	for i = 1, 14 do
		local s = math.random(2, 4)
		local e = new("Frame", {
			Size = UDim2.fromOffset(s, s),
			BackgroundTransparency = 0.45 + math.random() * 0.4,
			BorderSizePixel = 0,
		}, fx)
		corner(e, s)
		embers[i] = { f = e, x = math.random(), y = math.random(), sp = 0.03 + math.random() * 0.06, ph = math.random() * 6.28, fr = 0.5 + math.random(), odd = i % 2 == 0 }
	end

	-- ---------- side column: logo, title, tabs, player card
	local side = new("Frame", {
		Size = UDim2.new(0, 110, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, main)
	corner(side, 12)
	local sideG = new("UIGradient", { Rotation = 90 }, side)
	local titleX = o.Icon and 29 or 8
	local titleL = label(side, win.TitleText, 11, C.Text, true)
	titleL.Size = UDim2.new(1, -(titleX + 3), 0, 14)
	titleL.Position = UDim2.fromOffset(titleX, 11)
	fitText(titleL, 11)
	if o.Subtitle then
		local sub = label(side, o.Subtitle, 8, C.Dim, false)
		sub.Size = UDim2.new(1, -10, 0, 10)
		sub.Position = UDim2.fromOffset(6, 27)
		fitText(sub, 8)
	end
	if o.Icon then
		local logo = new("ImageLabel", {
			Size = UDim2.fromOffset(20, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(15, 16),
			BackgroundTransparency = 1,
			Image = asset(o.Icon),
			ScaleType = Enum.ScaleType.Fit,
		}, side)
		corner(logo, 10)
		pulse(logo)
	end
	local showProfile = o.Profile ~= false and lp ~= nil
	local tabList = new("ScrollingFrame", {
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -10, 1, showProfile and -96 or -46),
		Position = UDim2.fromOffset(5, 40),
		BackgroundTransparency = 1,
	}, side)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
	local profile
	if showProfile then
		profile = new("Frame", { Size = UDim2.new(1, -10, 0, 46), Position = UDim2.new(0, 5, 1, -51) }, side)
		corner(profile, 10)
		local avatar = new("ImageLabel", {
			Size = UDim2.fromOffset(32, 32),
			Position = UDim2.fromOffset(6, 7),
			BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150",
		}, profile)
		corner(avatar, 16)
		local u = label(profile, "@" .. lp.Name, 11, C.Text, true)
		u.Size = UDim2.new(1, -46, 0, 16)
		u.Position = UDim2.fromOffset(42, 9)
		local n = label(profile, lp.DisplayName, 8, C.Dim, false)
		n.Size = UDim2.new(1, -46, 0, 11)
		n.Position = UDim2.fromOffset(42, 26)
	end

	-- ---------- content column: page title, glowing line, - and X
	local content = new("Frame", {
		Size = UDim2.new(1, -126, 1, -10),
		Position = UDim2.fromOffset(121, 5),
		BackgroundTransparency = 1,
	}, main)
	local pageTitle = label(content, "", 12, C.Text, true)
	pageTitle.Size = UDim2.new(1, -54, 0, 22)
	pageTitle.Position = UDim2.fromOffset(4, 4)
	local underline = new("Frame", {
		Size = UDim2.new(1, -58, 0, 2),
		Position = UDim2.fromOffset(4, 26),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, content)
	corner(underline, 1)
	local ulG = new("UIGradient", {}, underline)
	win._pageTitle, win._content, win._side, win._tabList = pageTitle, content, side, tabList

	local function smallButton(txt, x, size, color)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, x, 0, 0),
			BackgroundTransparency = 1,
			Text = txt,
			TextColor3 = color,
			TextSize = size,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, content)
		new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.2 }, b)
		return b
	end
	local miniBtn = smallButton("-", -52, 16, Color3.fromRGB(120, 120, 120))
	local closeBtn = smallButton("X", -26, 12, Color3.fromRGB(235, 40, 50))
	win._closeBtn = closeBtn

	-- ---------- notifications (slide up from the bottom, stack)
	local notes = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.new(0, 260, 1, -40),
		BackgroundTransparency = 1,
		ZIndex = 50,
	}, gui)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, notes)
	win._notes = notes

	-- ---------- round button that opens the panel (only shown when there is no top bar)
	local fab = new("TextButton", {
		Position = UDim2.new(0, 12, 0.5, -22),
		Size = UDim2.fromOffset(44, 44),
		Text = o.Icon and "" or "R",
		TextSize = 20,
		Font = Enum.Font.GothamBlack,
		TextColor3 = C.Text,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 20,
	}, gui)
	corner(fab, 22)
	local fabG = new("UIGradient", { Rotation = 90 }, fab)
	local fabRing = new("UIStroke", { Thickness = 2 }, fab)
	win:_ring(fabRing)
	if o.Icon then
		local fi = new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			Image = asset(o.Icon),
			ZIndex = 21,
		}, fab)
		corner(fi, 14)
	end
	do
		local down, moved, startPos, startMouse = false, 0, nil, nil
		fab.InputBegan:Connect(function(i)
			if isPress(i) then
				down, moved = true, 0
				startMouse, startPos = i.Position, fab.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if down and isMove(i) then
				local d = i.Position - startMouse
				moved = math.max(moved, d.Magnitude)
				if moved > 6 then
					fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if down and isPress(i) then
				down = false
				if moved <= 6 then
					win:Toggle(true)
				end
			end
		end)
	end
	win._fab = fab

	-- ---------- dragging the panel by the title strips
	local function makeDraggable(handle)
		local dragging, startMouse, startPos = false, nil, nil
		handle.InputBegan:Connect(function(i)
			if isPress(i) then
				dragging = true
				startMouse = i.Position
				startPos = main.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - startMouse
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if isPress(i) then
				dragging = false
			end
		end)
	end
	local function strip(p, size, pos)
		local f = new("Frame", { Size = size, Position = pos, BackgroundTransparency = 1, ZIndex = 5 }, p)
		makeDraggable(f)
	end
	strip(content, UDim2.new(1, -54, 0, 26), UDim2.fromOffset(0, 0))
	strip(side, UDim2.new(1, 0, 0, 36), UDim2.fromOffset(0, 0))

	-- ---------- theme painting
	win:_onTheme(function(t)
		mainG.Color = ColorSequence.new(t.BG0, t.BG1)
		sideG.Color = ColorSequence.new(t.S0, t.S1)
		fabG.Color = ColorSequence.new(t.S1, t.B1)
		ulG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, t.Dark),
			ColorSequenceKeypoint.new(0.5, t.Glow),
			ColorSequenceKeypoint.new(1, t.Dark),
		})
		if profile then
			profile.BackgroundColor3 = t.Item
		end
		for _, g in ipairs(win._spin) do
			g.Color = ringSeq(t)
		end
		for _, e in ipairs(embers) do
			e.f.BackgroundColor3 = e.odd and t.Glow or t.Accent:Lerp(Color3.new(1, 0.7, 0.3), 0.5)
		end
	end)

	-- ---------- one render loop: spinning rings, moving gradients, embers
	win._conns[#win._conns + 1] = RunService.RenderStepped:Connect(function(dt)
		local now = os.clock()
		local rot = (now * 80) % 360
		for _, g in ipairs(win._spin) do
			g.Rotation = rot
		end
		if win.Open then
			mainG.Offset = Vector2.new(0, math.sin(now * 0.6) * 0.12)
			ulG.Offset = Vector2.new(((now * 0.5) % 2) - 1, 0)
			for _, e in ipairs(embers) do
				e.y -= e.sp * dt
				if e.y < -0.05 then
					e.y = 1.05
					e.x = math.random()
				end
				e.f.Position = UDim2.new(e.x, math.sin(now * e.fr + e.ph) * 8, e.y, 0)
			end
		end
		for _, fn in ipairs(win._frame or {}) do
			fn(now, dt)
		end
	end)

	-- ---------- buttons and keys
	local armed = false
	closeBtn.MouseButton1Click:Connect(function()
		if win.ConfirmClose and not armed then
			armed = true
			win:Notify({ Title = "Close the panel?", Text = "Tap X again to confirm", Duration = 2.5 })
			task.delay(2.5, function()
				armed = false
			end)
			return
		end
		win:Destroy()
	end)
	miniBtn.MouseButton1Click:Connect(function()
		win:Toggle(false)
	end)
	local key = o.ToggleKey or Enum.KeyCode.RightShift
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
		if not processed and i.KeyCode == key then
			win:Toggle()
		end
	end)

	win._orderTabs = 0
	if o.Open ~= false then
		win:Toggle(true)
	else
		fab.Visible = true
	end
	return win
end

function Window:_playClick()
	if self.Sound and self._click then
		pcall(function()
			self._click:Play()
		end)
	end
end

function Window:Toggle(state)
	if state == nil then
		state = not self.Open
	end
	self.Open = state
	local main = self.Main
	if state then
		main.Visible = true
		tween(self._scaleObj, 0.35, { Scale = self.Scale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	else
		local t = tween(self._scaleObj, 0.2, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		t.Completed:Connect(function()
			if not self.Open then
				main.Visible = false
			end
		end)
	end
	self._fab.Visible = not state and not self._hasBar
end

function Window:SetTheme(name)
	local t = THEMES[name]
	if not t then
		return
	end
	self.Theme = t
	self.ThemeName = name
	for _, fn in ipairs(self._fns) do
		fn(t)
	end
end

function Window:SetAccent(color)
	-- any Color3 becomes the accent; the rest of the theme is made from it
	local t = makeTheme(color)
	self.Theme = t
	self.ThemeName = "Custom"
	for _, fn in ipairs(self._fns) do
		fn(t)
	end
end

function RebelUI:AddTheme(name, accent, dark)
	THEMES[name] = makeTheme(accent, dark and { Dark = dark } or nil)
	if not table.find(self.Themes, name) then
		table.insert(self.Themes, name)
	end
end

function Window:SetScale(s)
	-- 0.8 to 1.3: makes the whole panel smaller or bigger
	self.Scale = math.clamp(tonumber(s) or 1, 0.5, 1.6)
	if self.Open then
		tween(self._scaleObj, 0.2, { Scale = self.Scale })
	end
end

function Window:SetTransparency(t)
	-- 0 to 0.6: see-through panel
	t = math.clamp(tonumber(t) or 0, 0, 0.9)
	self.Main.BackgroundTransparency = t
	self._side.BackgroundTransparency = t
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self._conns = {}
	if self.OnDestroy then
		safe(self.OnDestroy)
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

function Window:Notify(o)
	if type(o) == "string" then
		o = { Text = o }
	end
	o = o or {}
	if self.Toasts == false then
		return
	end
	self._noteN = (self._noteN or 0) + 1
	local dur = o.Duration or self.NotifyTime or 4
	local kinds = { success = C.Green, warn = C.Yellow, error = C.Bad }
	self:_playClick()
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self._noteN,
	}, self._notes)
	local card = new("Frame", {
		Position = UDim2.new(0, -290, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 30,
	}, wrap)
	corner(card, 10)
	local cg = new("UIGradient", {}, card)
	local st = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Transparency = 0.2 }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	local h = label(card, o.Title or "Rebelwar", 11, C.Text, true)
	h.Size = UDim2.new(1, 0, 0, 14)
	h.ZIndex = 31
	h.LayoutOrder = 1
	if o.Text then
		local b = label(card, o.Text, 9, C.Dim, false)
		b.TextWrapped = true
		b.TextTruncate = Enum.TextTruncate.None
		b.Size = UDim2.new(1, 0, 0, 0)
		b.AutomaticSize = Enum.AutomaticSize.Y
		b.ZIndex = 31
		b.LayoutOrder = 2
	end
	local line = new("Frame", { Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, ZIndex = 31, LayoutOrder = 3 }, card)
	corner(line, 1)
	local function paint(t)
		cg.Color = ColorSequence.new(t.BG0, t.B1)
		local c = kinds[o.Type or ""] or t.Accent
		st.Color = kinds[o.Type or ""] or t.Glow
		line.BackgroundColor3 = c
	end
	paint(self.Theme)
	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(line, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	task.delay(dur, function()
		if card.Parent then
			local o2 = tween(card, 0.25, { Position = UDim2.new(0, -290, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			o2.Completed:Connect(function()
				wrap:Destroy()
			end)
		end
	end)
end

function Window:_bind(obj, prop, key)
	self:_onTheme(function(t)
		obj[prop] = t[key]
	end)
end

-- ============================================================ tabs
function Window:CreateTab(name, icon)
	-- CreateTab("Main", 123456)  or  CreateTab({ Name=, Icon=, Title=, Description= })
	local opts = type(name) == "table" and name or { Name = name, Icon = icon }
	local win = self
	local tab = setmetatable({ Win = win, Name = opts.Name or "Tab", Icon = opts.Icon, _n = 0 }, Tab)
	local active = false

	-- ---------- the tab button: icon far left, name next to it, marker when selected
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = C.White,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #win._tabs + 1,
	}, win._tabList)
	corner(btn, 8)
	local bg = new("UIGradient", {}, btn)
	local ind = new("Frame", {
		Size = UDim2.fromOffset(3, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 1, 0.5, 0),
		BackgroundColor3 = C.White,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, btn)
	corner(ind, 2)
	local pad = 10
	local img
	if opts.Icon then
		img = new("ImageLabel", {
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			BackgroundTransparency = 1,
			Image = asset(opts.Icon),
			ImageColor3 = C.Dim,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 4,
		}, btn)
		pad = 28
	end
	local txt = label(btn, tab.Name, 11, C.Dim, false)
	txt.Font = Enum.Font.GothamMedium
	txt.Position = UDim2.new(0, pad, 0, 0)
	txt.Size = UDim2.new(1, -pad - 4, 1, 0)
	txt.ZIndex = 4

	-- ---------- the page
	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -32),
		Position = UDim2.fromOffset(0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, win._content)
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 6) }, page)
	tab.Page = page
	tab.TabButton = btn

	local function paint()
		local t = win.Theme
		bg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.4))
		page.ScrollBarImageColor3 = t.Accent
		tween(btn, 0.15, { BackgroundTransparency = active and 0.1 or 1 })
		tween(ind, 0.2, { Size = UDim2.fromOffset(3, active and 14 or 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		txt.TextColor3 = active and C.Text or C.Dim
		if img then
			img.ImageColor3 = active and C.Text or C.Dim
		end
	end
	tab._set = function(a)
		active = a
		paint()
	end
	function tab:Select()
		for _, other in ipairs(win._tabs) do
			if other ~= tab then
				other.Page.Visible = false
				other._set(false)
			end
		end
		page.Position = UDim2.fromOffset(0, 40)
		page.Visible = true
		tween(page, 0.22, { Position = UDim2.fromOffset(0, 32) })
		tab._set(true)
		win._pageTitle.Text = tab.Name
		win.CurrentTab = tab
	end
	function tab:SetName(n)
		tab.Name = n
		txt.Text = n
		if win.CurrentTab == tab then
			win._pageTitle.Text = n
		end
	end
	function tab:SetIcon(i)
		if img then
			img.Image = asset(i)
		end
	end
	win:_onTheme(paint)
	btn.MouseButton1Click:Connect(function()
		win:_playClick()
		tab:Select()
	end)
	btn.MouseEnter:Connect(function()
		if not active then
			tween(btn, 0.12, { BackgroundTransparency = 0.8 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not active then
			tween(btn, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	table.insert(win._tabs, tab)
	if #win._tabs == 1 then
		tab:Select()
	end
	-- the tab's own header ("text hub") at the top of its page
	if opts.Title or opts.Description then
		tab.HeaderObj = tab:Header({
			Title = opts.Title or tab.Name,
			Text = opts.Description,
			Icon = opts.HeaderIcon or opts.Icon,
		})
	end
	return tab
end

-- ============================================================ elements
function Tab:_next()
	self._n += 1
	return self._n
end

function Tab:_row(h)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 36),
		BorderSizePixel = 0,
		LayoutOrder = self:_next(),
	}, self.Page)
	corner(f, 8)
	self.Win:_bind(f, "BackgroundColor3", "Item")
	return f
end

local function register(self, o, obj)
	if o.Flag then
		self.Win.Flags[o.Flag] = obj
	end
	obj.Flag = o.Flag
	return obj
end

function Tab:Section(text)
	local l = label(self.Page, text or "Section", 11, C.Text, true)
	l.Size = UDim2.new(1, 0, 0, 18)
	l.LayoutOrder = self:_next()
	self.Win:_bind(l, "TextColor3", "Glow")
	local obj = {}
	function obj:Set(v)
		l.Text = tostring(v)
	end
	return obj
end

function Tab:Divider()
	local d = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		LayoutOrder = self:_next(),
	}, self.Page)
	self.Win:_bind(d, "BackgroundColor3", "Off")
	return d
end

function Tab:Label(text)
	local l = label(self.Page, text or "", 10, C.Dim, false)
	l.TextWrapped = true
	l.TextTruncate = Enum.TextTruncate.None
	l.Size = UDim2.new(1, 0, 0, 14)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.LayoutOrder = self:_next()
	local obj = {}
	function obj:Set(v)
		l.Text = tostring(v)
	end
	function obj:Get()
		return l.Text
	end
	return obj
end

function Tab:Button(o)
	-- Name, Description, Callback: a shiny gradient button with a spinning ring and a click ripple
	o = o or {}
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local H = o.Height or (hasDesc and 40 or 32)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, H),
		BackgroundColor3 = C.White,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
		LayoutOrder = self:_next(),
	}, self.Page)
	corner(b, 8)
	local bg = new("UIGradient", {}, b)
	local st = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1.5 }, b)
	win:_ring(st)
	win:_onTheme(function(t)
		bg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
	end)
	local shine = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.28, 0, 1.8, 0),
		Position = UDim2.new(-0.3, 0, 0.5, 0),
		Rotation = 20,
		BackgroundColor3 = C.White,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, b)
	TweenService:Create(
		shine,
		TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 0.9),
		{ Position = UDim2.new(1.3, 0, 0.5, 0) }
	):Play()
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, hasDesc and 22 or H),
		Position = UDim2.fromOffset(0, hasDesc and 4 or 0),
		Text = o.Name or "Button",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.White,
		ZIndex = 4,
	}, b)
	local dl
	if hasDesc then
		dl = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.fromOffset(0, 22),
			Text = o.Description,
			Font = Enum.Font.Gotham,
			TextSize = 8,
			TextColor3 = Color3.fromRGB(235, 220, 222),
			ZIndex = 4,
		}, b)
	end
	local sc = new("UIScale", {}, b)
	b.MouseButton1Down:Connect(function()
		tween(sc, 0.08, { Scale = 0.95 })
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	b.MouseButton1Click:Connect(function()
		win:_playClick()
		local r = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = C.White,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, b)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, r)
		local tw = tween(r, 0.5, { Size = UDim2.fromOffset(340, 340), BackgroundTransparency = 1 })
		tw.Completed:Connect(function()
			r:Destroy()
		end)
		safe(o.Callback)
	end)
	local obj = {}
	function obj:Fire()
		safe(o.Callback)
	end
	function obj:SetName(n)
		lbl.Text = n
	end
	function obj:SetDescription(d)
		if dl then
			dl.Text = d
		end
	end
	return obj
end

function Tab:Toggle(o)
	-- Name, Description, Icon, Default, Style ("Switch"|"Checkbox"), Color, Locked, Key, Flag, Callback
	o = o or {}
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local H = hasDesc and 40 or 32
	local row = self:_row(H)
	local rowStroke = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Transparency = 1 }, row)
	local left = 10
	if o.Icon then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			Image = asset(o.Icon),
			ScaleType = Enum.ScaleType.Fit,
		}, row)
		left = 34
	end
	local right = 62 + (o.Key and 36 or 0)
	local name = label(row, o.Name or "Toggle", 11, C.Text, true)
	name.Position = UDim2.new(0, left, 0, hasDesc and 6 or 0)
	name.Size = UDim2.new(1, -(left + right), 0, hasDesc and 14 or H)
	local desc
	if hasDesc then
		desc = label(row, o.Description, 8, C.Dim, false)
		desc.Position = UDim2.new(0, left, 0, 22)
		desc.Size = UDim2.new(1, -(left + right), 0, 11)
	end
	local tag
	if o.Key then
		tag = label(row, "[" .. o.Key.Name .. "]", 9, C.Dim, true)
		tag.TextXAlignment = Enum.TextXAlignment.Right
		tag.AnchorPoint = Vector2.new(1, 0.5)
		tag.Position = UDim2.new(1, -58, 0.5, 0)
		tag.Size = UDim2.fromOffset(34, 16)
	end

	local checkbox = o.Style == "Checkbox"
	local switch, swScale, swGlow, stateLabel, knob, dot, box, tick
	if checkbox then
		box = new("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -24, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(box, 6)
		swGlow = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Transparency = 1 }, box)
		tick = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = C.White,
			BorderSizePixel = 0,
		}, box)
		corner(tick, 3)
		switch = box
	else
		switch = new("TextButton", {
			Size = UDim2.fromOffset(42, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -31, 0.5, 0),
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(switch, 10)
		swScale = new("UIScale", {}, switch)
		swGlow = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Transparency = 1 }, switch)
		stateLabel = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 20),
			Position = UDim2.fromOffset(19, 0),
			Text = "OFF",
			TextSize = 8,
			Font = Enum.Font.GothamBold,
			TextColor3 = C.Dim,
		}, switch)
		knob = new("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = Color3.fromRGB(215, 205, 205),
			BorderSizePixel = 0,
			ZIndex = 3,
		}, switch)
		corner(knob, 8)
		dot = new("Frame", {
			Size = UDim2.fromOffset(6, 6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, knob)
		corner(dot, 3)
	end

	local obj = { Value = o.Default == true, Locked = o.Locked == true, Color = o.Color }
	local fast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local pop = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local function play(inst, info, props)
		TweenService:Create(inst, info, props):Play()
	end
	local function render(pulseIt)
		local on = obj.Value
		local t = win.Theme
		local accent = obj.Color or t.Accent
		local glow = obj.Color and obj.Color:Lerp(C.White, 0.15) or t.Glow
		swGlow.Color = glow
		rowStroke.Color = glow
		local lockT = obj.Locked and 0.5 or 0
		play(row, fast, { BackgroundColor3 = on and t.ItemOn or t.Item })
		play(rowStroke, fast, { Transparency = on and 0.55 or 1 })
		play(swGlow, fast, { Transparency = on and 0.4 or 1 })
		name.TextTransparency = obj.Locked and 0.55 or 0
		if checkbox then
			play(box, fast, { BackgroundColor3 = on and accent or t.Off, BackgroundTransparency = lockT })
			play(tick, pop, { Size = on and UDim2.fromOffset(10, 10) or UDim2.fromOffset(0, 0) })
		else
			if pulseIt then
				swScale.Scale = 0.88
				play(swScale, pop, { Scale = 1 })
				knob.Size = UDim2.fromOffset(22, 16)
				if not on then
					knob.Position = UDim2.fromOffset(20, 2)
				end
			end
			play(knob, pop, {
				Position = on and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = on and C.White or Color3.fromRGB(215, 205, 205),
			})
			play(switch, fast, { BackgroundColor3 = on and accent or t.Off, BackgroundTransparency = lockT })
			dot.BackgroundColor3 = accent
			play(dot, fast, { BackgroundTransparency = on and 0 or 1 })
			stateLabel.Text = on and "ON" or "OFF"
			stateLabel.Position = on and UDim2.fromOffset(3, 0) or UDim2.fromOffset(19, 0)
			stateLabel.TextColor3 = on and C.White or C.Dim
		end
	end
	function obj:Set(v, silent)
		v = v and true or false
		local changed = v ~= self.Value
		self.Value = v
		render(changed)
		if not silent then
			if changed and win.ToggleToasts then
				win:Notify({ Title = o.Name or "Toggle", Text = v and "Enabled" or "Disabled", Duration = 1.6 })
			end
			safe(o.Callback, v)
		end
	end
	function obj:Get()
		return self.Value
	end
	function obj:Toggle()
		if self.Locked then
			win:Notify({ Title = o.Name or "Toggle", Text = "This toggle is locked", Type = "warn", Duration = 1.6 })
			return
		end
		win:_playClick()
		self:Set(not self.Value)
	end
	function obj:Lock(state)
		self.Locked = state ~= false
		render(false)
	end
	function obj:SetName(n)
		name.Text = n
	end
	function obj:SetDescription(d)
		if desc then
			desc.Text = d
		end
	end
	function obj:SetColor(c)
		self.Color = c
		render(false)
	end
	switch.MouseButton1Click:Connect(function()
		obj:Toggle()
	end)
	local hit = new("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, -62, 1, 0),
		ZIndex = 2,
	}, row)
	hit.MouseButton1Click:Connect(function()
		obj:Toggle()
	end)
	if o.Key then
		win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
			if not processed and i.KeyCode == o.Key then
				obj:Toggle()
			end
		end)
	end
	win:_onTheme(function()
		render(false)
	end)
	if obj.Value and o.Callback then
		task.defer(safe, o.Callback, true) -- a toggle that starts ON tells your code once
	end
	return register(self, o, obj)
end

function Tab:Slider(o)
	-- Name, Min, Max, Default, Step, Suffix, Flag, Callback(value)
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local suffix = o.Suffix or ""
	local row = self:_row(44)
	local name = label(row, o.Name or "Slider", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -66, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -58, 0, 6)
	val.Size = UDim2.fromOffset(48, 14)
	local bar = new("Frame", {
		Position = UDim2.fromOffset(12, 31),
		Size = UDim2.new(1, -24, 0, 4),
		BorderSizePixel = 0,
	}, row)
	corner(bar, 2)
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 2)
	win:_bind(fill, "BackgroundColor3", "Accent")
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.Text,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, bar)
	corner(knob, 6)
	local hit = new("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Position = UDim2.fromOffset(6, 22),
		Size = UDim2.new(1, -12, 0, 22),
		ZIndex = 3,
	}, row)

	local obj = { Value = min }
	local function render()
		local rel = (obj.Value - min) / math.max(max - min, 1e-9)
		fill.Size = UDim2.fromScale(rel, 1)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		val.Text = tostring(obj.Value) .. suffix
	end
	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / step + 0.5) * step
		v = math.clamp(v, min, max)
		return math.floor(v * 10000 + 0.5) / 10000
	end
	function obj:Set(v, silent)
		v = snap(tonumber(v) or min)
		local changed = v ~= self.Value
		self.Value = v
		render()
		if changed and not silent then
			safe(o.Callback, v)
		end
	end
	function obj:Get()
		return self.Value
	end
	local page = self.Page
	-- the touch area is a little bigger than the thin bar
	local dragging = false
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			local w = bar.AbsoluteSize.X
			if w > 0 then
				obj:Set(min + math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1) * (max - min))
			end
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local w = bar.AbsoluteSize.X
			if w > 0 then
				obj:Set(min + math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1) * (max - min))
			end
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj.Value = snap(o.Default or min)
	render()
	return register(self, o, obj)
end

function Tab:Dropdown(o)
	-- Name, Options, Default, Multi, Flag, Callback(choice) (Multi gives { Speed = true, ... })
	o = o or {}
	local win = self.Win
	local options = o.Options or {}
	local multi = o.Multi == true
	local HEAD, ITEM = 34, 24
	local row = self:_row(HEAD)
	row.ClipsDescendants = true
	local name = label(row, o.Name or "Dropdown", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(0.5, -10, 0, HEAD)
	local cur = label(row, "", 10, C.Dim, true)
	cur.TextXAlignment = Enum.TextXAlignment.Right
	cur.Position = UDim2.new(0.5, 0, 0, 0)
	cur.Size = UDim2.new(0.5, -28, 0, HEAD)
	local arrow = label(row, "v", 10, C.Dim, true)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.Position = UDim2.new(1, -22, 0, 0)
	arrow.Size = UDim2.fromOffset(14, HEAD)
	local head = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, HEAD) }, row)
	local list = new("ScrollingFrame", {
		Position = UDim2.new(0, 6, 0, HEAD),
		Size = UDim2.new(1, -12, 1, -HEAD - 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

	local obj = { Value = multi and {} or nil, Open = false }
	local items = {}
	local function selected(v)
		if multi then
			return obj.Value[v] == true
		end
		return obj.Value == v
	end
	local function text()
		if multi then
			local t = {}
			for _, v in ipairs(options) do
				if obj.Value[v] then
					table.insert(t, tostring(v))
				end
			end
			return #t > 0 and table.concat(t, ", ") or "None"
		end
		return obj.Value ~= nil and tostring(obj.Value) or "Select"
	end
	local function render()
		cur.Text = text()
		for v, b in pairs(items) do
			b.TextColor3 = selected(v) and win.Theme.Glow or C.Text
			b.Font = selected(v) and Enum.Font.GothamBold or Enum.Font.Gotham
		end
	end
	local function build(v)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, ITEM),
			Text = tostring(v),
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextColor3 = C.Text,
			AutoButtonColor = false,
		}, list)
		corner(b, 6)
		win:_bind(b, "BackgroundColor3", "Inset")
		items[v] = b
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			if multi then
				obj.Value[v] = not obj.Value[v] or nil
			else
				obj.Value = v
				obj:Close()
			end
			render()
			safe(o.Callback, obj.Value)
		end)
	end
	for _, v in ipairs(options) do
		build(v)
	end
	local function setOpen(open)
		obj.Open = open
		local shown = math.min(#options, 5)
		tween(row, 0.18, { Size = UDim2.new(1, 0, 0, open and (HEAD + shown * (ITEM + 2) + 8) or HEAD) })
		arrow.Text = open and "^" or "v"
	end
	function obj:Close()
		setOpen(false)
	end
	head.MouseButton1Click:Connect(function()
		win:_playClick()
		setOpen(not obj.Open)
	end)
	function obj:Set(v, silent)
		if multi then
			obj.Value = {}
			if type(v) == "table" then
				for k, x in pairs(v) do
					if type(k) == "number" then
						obj.Value[x] = true
					elseif x then
						obj.Value[k] = true
					end
				end
			end
		else
			obj.Value = v
		end
		render()
		if not silent then
			safe(o.Callback, obj.Value)
		end
	end
	function obj:Get()
		return obj.Value
	end
	function obj:Refresh(newOptions)
		for _, b in pairs(items) do
			b:Destroy()
		end
		items, options = {}, newOptions or {}
		for _, v in ipairs(options) do
			build(v)
		end
		render()
	end
	if o.Default ~= nil then
		obj:Set(o.Default, true)
	else
		render()
	end
	win:_onTheme(render)
	return register(self, o, obj)
end

function Tab:Input(o)
	-- Name, Default, Placeholder, Clear, Flag, Callback(text)
	o = o or {}
	local win = self.Win
	local row = self:_row(36)
	local name = label(row, o.Name or "Input", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(0.42, -10, 1, 0)
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.58, -16, 0, 24),
		BorderSizePixel = 0,
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "type here",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 6)
	win:_bind(box, "BackgroundColor3", "Inset")
	local obj = {}
	function obj:Set(v, silent)
		box.Text = tostring(v)
		if not silent then
			safe(o.Callback, box.Text)
		end
	end
	function obj:Get()
		return box.Text
	end
	box.FocusLost:Connect(function()
		safe(o.Callback, box.Text)
		if o.Clear then
			box.Text = ""
		end
	end)
	return register(self, o, obj)
end

function Tab:Keybind(o)
	-- Name, Default (Enum.KeyCode), Flag, Callback() when the key is pressed, Changed(key) when rebound
	o = o or {}
	local win = self.Win
	local row = self:_row(36)
	local name = label(row, o.Name or "Keybind", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(1, -100, 1, 0)
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(78, 22),
		BorderSizePixel = 0,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	corner(b, 6)
	win:_bind(b, "BackgroundColor3", "Inset")
	local obj = { Value = o.Default or Enum.KeyCode.F, Listening = false }
	local function render()
		b.Text = obj.Listening and "press a key..." or obj.Value.Name
	end
	function obj:Set(k, silent)
		self.Value = k
		self.Listening = false
		render()
		if not silent then
			safe(o.Changed, k)
		end
	end
	function obj:Get()
		return self.Value
	end
	b.MouseButton1Click:Connect(function()
		obj.Listening = true
		render()
	end)
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if obj.Listening then
			obj:Set(i.KeyCode == Enum.KeyCode.Escape and obj.Value or i.KeyCode)
		elseif not processed and i.KeyCode == obj.Value then
			safe(o.Callback)
		end
	end)
	render()
	return register(self, o, obj)
end

local PRESETS = {
	Color3.fromRGB(235, 40, 50),
	Color3.fromRGB(255, 150, 50),
	Color3.fromRGB(250, 210, 60),
	Color3.fromRGB(60, 205, 110),
	Color3.fromRGB(60, 200, 220),
	Color3.fromRGB(64, 140, 255),
	Color3.fromRGB(160, 90, 255),
	Color3.fromRGB(255, 90, 170),
	Color3.fromRGB(240, 240, 245),
}

function Tab:Color(o)
	-- Name, Default (Color3), Flag, Callback(Color3). Tap the swatch: hue / saturation / brightness bars, hex box, presets.
	o = o or {}
	local win = self.Win
	local HEAD, FULL = 40, 168
	local row = self:_row(HEAD)
	row.ClipsDescendants = true
	local name = label(row, o.Name or "Color", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -130, 0, 14)
	local hint = label(row, "Tap the color to change it", 8, C.Dim, false)
	hint.Position = UDim2.fromOffset(10, 22)
	hint.Size = UDim2.new(1, -130, 0, 11)
	local swatch = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0, HEAD / 2),
		Size = UDim2.fromOffset(34, 18),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	corner(swatch, 9)
	new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.Text, Thickness = 1.5, Transparency = 0.4 }, swatch)
	local hex = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0, HEAD / 2),
		Size = UDim2.fromOffset(62, 20),
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
	}, row)
	corner(hex, 6)
	win:_bind(hex, "BackgroundColor3", "Inset")

	local function makeBar(y)
		local bar = new("Frame", {
			Position = UDim2.fromOffset(12, y),
			Size = UDim2.new(1, -24, 0, 12),
			BackgroundColor3 = C.White,
			BorderSizePixel = 0,
		}, row)
		corner(bar, 6)
		local g = new("UIGradient", {}, bar)
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(8, 18),
			BackgroundColor3 = C.Text,
			BorderSizePixel = 0,
		}, bar)
		corner(knob, 3)
		return bar, g, knob
	end
	local hueBar, hueG, hueKnob = makeBar(50)
	local satBar, satG, satKnob = makeBar(76)
	local valBar, valG, valKnob = makeBar(102)
	hueG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})

	local def = o.Default or Color3.fromRGB(235, 40, 50)
	local h, s, v = def:ToHSV()
	local obj = { Value = def, Open = false }
	local function render()
		obj.Value = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = obj.Value
		hex.Text = toHex(obj.Value)
		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		satKnob.Position = UDim2.new(s, 0, 0.5, 0)
		valKnob.Position = UDim2.new(v, 0, 0.5, 0)
		satG.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
		valG.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
	end
	local page = self.Page
	local function lock(down)
		page.ScrollingEnabled = not down
	end
	local function changed()
		render()
		safe(o.Callback, obj.Value)
	end
	bindBar(win, hueBar, function(rel)
		h = rel
		changed()
	end, lock)
	bindBar(win, satBar, function(rel)
		s = rel
		changed()
	end, lock)
	bindBar(win, valBar, function(rel)
		v = rel
		changed()
	end, lock)

	local sw = new("Frame", { Position = UDim2.fromOffset(12, 134), Size = UDim2.new(1, -24, 0, 22), BackgroundTransparency = 1 }, row)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, sw)
	for i, c in ipairs(PRESETS) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = c,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
		}, sw)
		corner(b, 11)
		b.MouseButton1Click:Connect(function()
			h, s, v = c:ToHSV()
			changed()
		end)
	end
	hex.FocusLost:Connect(function()
		local c = fromHex(hex.Text)
		if c then
			h, s, v = c:ToHSV()
			changed()
		else
			render()
		end
	end)
	swatch.MouseButton1Click:Connect(function()
		win:_playClick()
		obj.Open = not obj.Open
		hint.Text = obj.Open and "Drag the bars, type a hex, or pick a preset" or "Tap the color to change it"
		tween(row, 0.2, { Size = UDim2.new(1, 0, 0, obj.Open and FULL or HEAD) })
	end)

	function obj:Set(c, silent)
		h, s, v = c:ToHSV()
		render()
		if not silent then
			safe(o.Callback, obj.Value)
		end
	end
	function obj:Get()
		return obj.Value
	end
	function obj:GetHex()
		return toHex(obj.Value)
	end
	function obj:SetHex(str, silent)
		local c = fromHex(str)
		if c then
			obj:Set(c, silent)
		end
	end
	render()
	return register(self, o, obj)
end

function Tab:Header(o)
	-- Title, Text, Icon: a banner card, the "text hub" of a tab
	o = o or {}
	local win = self.Win
	local hasText = o.Text ~= nil and o.Text ~= ""
	local row = self:_row(hasText and 58 or 40)
	row.ClipsDescendants = true
	local mark = new("Frame", { Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0 }, row)
	win:_bind(mark, "BackgroundColor3", "Accent")
	local left = 14
	if o.Icon then
		local holder = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(34, 34),
			BorderSizePixel = 0,
		}, row)
		corner(holder, 9)
		win:_bind(holder, "BackgroundColor3", "Inset")
		new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(24, 24),
			Image = asset(o.Icon),
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		left = 54
	end
	local title = label(row, o.Title or "Header", 13, C.Text, true)
	title.Position = UDim2.new(0, left, 0, hasText and 7 or 0)
	title.Size = UDim2.new(1, -(left + 8), 0, hasText and 18 or 40)
	local body
	if hasText then
		body = label(row, o.Text, 9, C.Dim, false)
		body.TextWrapped = true
		body.TextTruncate = Enum.TextTruncate.None
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.Position = UDim2.new(0, left, 0, 26)
		body.Size = UDim2.new(1, -(left + 8), 0, 28)
	end
	local obj = {}
	function obj:SetTitle(t)
		title.Text = t
	end
	function obj:SetText(t)
		if body then
			body.Text = t
		end
	end
	return obj
end

function Tab:Image(o)
	-- Image (123456 or "rbxassetid://123456"), Height, Caption, Crop (true = fill and crop)
	o = o or {}
	local h = o.Height or 110
	local row = self:_row(h + (o.Caption and 22 or 0))
	row.ClipsDescendants = true
	local img = new("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 0, h - 12),
		Image = asset(o.Image),
		ScaleType = o.Crop and Enum.ScaleType.Crop or Enum.ScaleType.Fit,
	}, row)
	corner(img, 6)
	local cap
	if o.Caption then
		cap = label(row, o.Caption, 9, C.Dim, false)
		cap.TextXAlignment = Enum.TextXAlignment.Center
		cap.Position = UDim2.fromOffset(6, h - 4)
		cap.Size = UDim2.new(1, -12, 0, 16)
	end
	local obj = {}
	function obj:Set(i)
		img.Image = asset(i)
	end
	function obj:Get()
		return img.Image
	end
	function obj:SetCaption(t)
		if cap then
			cap.Text = t
		end
	end
	return obj
end

function Tab:Progress(o)
	-- Name, Min, Max, Default, Suffix. A read-only bar: use :Set(value) from your own code.
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local suffix = o.Suffix or "%"
	local row = self:_row(40)
	local name = label(row, o.Name or "Progress", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -66, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -58, 0, 5)
	val.Size = UDim2.fromOffset(48, 14)
	local bar = new("Frame", { Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -24, 0, 6), BorderSizePixel = 0 }, row)
	corner(bar, 3)
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 3)
	local fg = new("UIGradient", {}, fill)
	win:_onTheme(function(t)
		fill.BackgroundColor3 = C.White
		fg.Color = ColorSequence.new(t.Accent, t.Glow:Lerp(Color3.new(1, 0.8, 0.5), 0.4))
	end)
	local obj = { Value = min }
	function obj:Set(v)
		v = math.clamp(tonumber(v) or min, min, max)
		self.Value = v
		local rel = (v - min) / math.max(max - min, 1e-9)
		tween(fill, 0.2, { Size = UDim2.fromScale(rel, 1) })
		val.Text = tostring(math.floor(v * 100 + 0.5) / 100) .. suffix
	end
	function obj:Get()
		return self.Value
	end
	obj:Set(o.Default or min)
	return register(self, o, obj)
end

function Tab:Paragraph(o)
	-- Title, Text: a titled block of text
	o = o or {}
	local row = self:_row(30)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 0)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local t = label(row, o.Title or "", 11, C.Text, true)
	t.Size = UDim2.new(1, 0, 0, 14)
	t.LayoutOrder = 1
	local b = label(row, o.Text or "", 9, C.Dim, false)
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.LayoutOrder = 2
	local obj = {}
	function obj:Set(title, text)
		t.Text = title or t.Text
		b.Text = text or b.Text
	end
	return obj
end

function Tab:Choice(o)
	-- Name, Options, Default (false = none chosen), Flag, Callback(choice): a bar of buttons where one is chosen
	o = o or {}
	local win = self.Win
	local options = o.Options or {}
	local n = math.max(#options, 1)
	local row = self:_row(58)
	local name = label(row, o.Name or "Choice", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -20, 0, 14)
	local bar = new("Frame", {
		Position = UDim2.fromOffset(10, 24),
		Size = UDim2.new(1, -20, 0, 26),
		BorderSizePixel = 0,
	}, row)
	corner(bar, 8)
	win:_bind(bar, "BackgroundColor3", "Inset")
	local obj = { Value = nil }
	local buttons = {}
	local function render()
		local t = win.Theme
		for choice, b in pairs(buttons) do
			local on = choice == obj.Value
			b.BackgroundColor3 = t.Accent
			tween(b, 0.15, {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and C.White or C.Dim,
			})
		end
	end
	for i, choice in ipairs(options) do
		local b = new("TextButton", {
			Position = UDim2.new((i - 1) / n, 2, 0, 2),
			Size = UDim2.new(1 / n, -4, 1, -4),
			BackgroundTransparency = 1,
			Text = tostring(choice),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextColor3 = C.Dim,
			AutoButtonColor = false,
		}, bar)
		corner(b, 6)
		buttons[choice] = b
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			obj:Set(choice)
		end)
	end
	function obj:Set(choice, silent)
		if buttons[choice] == nil then
			return
		end
		local changed = self.Value ~= choice
		self.Value = choice
		render()
		if changed and not silent then
			safe(o.Callback, choice)
		end
	end
	function obj:Get()
		return self.Value
	end
	if o.Default == false then
		obj.Value = nil -- nothing chosen yet
	else
		obj.Value = o.Default ~= nil and buttons[o.Default] and o.Default or options[1]
	end
	win:_onTheme(render)
	return register(self, o, obj)
end

function Tab:Cycle(o)
	-- Name, Description, Options, Default (name or number), Flag, Callback(choice, index): the "<  option  >" picker
	o = o or {}
	local win = self.Win
	local options = o.Options or { "-" }
	local hasDesc = o.Description ~= nil
	local row = self:_row(hasDesc and 40 or 34)
	local name = label(row, o.Name or "Cycle", 11, C.Text, true)
	name.Position = UDim2.new(0, 10, 0, hasDesc and 6 or 0)
	name.Size = UDim2.new(1, -150, 0, hasDesc and 14 or 34)
	if hasDesc then
		local d = label(row, o.Description, 8, C.Dim, false)
		d.Position = UDim2.fromOffset(10, 22)
		d.Size = UDim2.new(1, -150, 0, 11)
	end
	local valueL = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(64, 20),
		Position = UDim2.new(1, -102, 0.5, -10),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = C.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local obj = { Index = 1 }
	local function render()
		valueL.Text = tostring(options[obj.Index])
	end
	function obj:Set(v, silent)
		local idx = type(v) == "number" and v or table.find(options, v)
		if not idx then
			return
		end
		obj.Index = ((idx - 1) % #options) + 1
		render()
		if not silent then
			win:_playClick()
			safe(o.Callback, options[obj.Index], obj.Index)
		end
	end
	function obj:Get()
		return options[obj.Index]
	end
	local function arrow(txt, x, dir)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, x, 0.5, -12),
			BackgroundColor3 = C.White,
			Text = txt,
			TextColor3 = C.White,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			AutoButtonColor = false,
		}, row)
		corner(b, 7)
		local g = new("UIGradient", { Rotation = 90 }, b)
		win:_onTheme(function(t)
			g.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
		end)
		b.MouseButton1Click:Connect(function()
			obj:Set(obj.Index + dir)
		end)
	end
	arrow("<", -134, -1)
	arrow(">", -34, 1)
	if o.Default ~= nil then
		local idx = type(o.Default) == "number" and o.Default or table.find(options, o.Default)
		obj.Index = idx or 1
	end
	render()
	return register(self, o, obj)
end

-- ============================================================ top bar (FPS, logo, timer and more)
local BAR_ORDER = { "FPS", "Ping", "Logo", "Title", "Timer", "Clock", "Players", "Memory", "Executor", "Game" }
local BAR_PRESETS = {
	Classic = { "FPS", "Logo", "Timer" },
	Minimal = { "Logo" },
	Gamer = { "FPS", "Ping", "Clock" },
	Info = { "Logo", "Title", "Players", "Executor" },
	Full = { "FPS", "Ping", "Logo", "Title", "Timer", "Clock", "Players", "Memory", "Executor", "Game" },
}
RebelUI.BarItems = BAR_ORDER
RebelUI.BarPresets = { "Classic", "Minimal", "Gamer", "Info", "Full" }

local function readPing()
	local ok, v = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return ok and tonumber(v) and math.floor(v + 0.5) or 0
end

local function readMemory()
	local ok, v = pcall(function()
		return game:GetService("Stats"):GetTotalMemoryUsageMb()
	end)
	return ok and tonumber(v) and math.floor(v + 0.5) or 0
end

local function readExecutor()
	local ok, v = pcall(function()
		return identifyexecutor()
	end)
	return ok and tostring(v) or "Unknown"
end

function Window:CreateBar(o)
	-- Items = { "FPS", "Logo", "Timer" } (any of RebelUI.BarItems), Preset = "Classic", Logo = asset id,
	-- Visible, Position (UDim2). Tap the bar to open or close the panel; drag it to move it.
	o = o or {}
	local win = self
	local bar = { Visible = o.Visible ~= false }
	local items = {}
	local logo = o.Logo or o.Icon
	local started = os.clock()
	local fps, frames, acc = 60, 0, 0
	local gameName = tostring(game.Name or "Game")
	local defaultPos = o.Position or UDim2.new(0.5, 0, 0, 12)

	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if ok and info and info.Name then
			gameName = info.Name
		end
	end)

	-- thin black ring around the bar, then the bar with its own spinning ring
	local outer = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = defaultPos,
		Size = UDim2.new(0, 0, 0, 36),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = bar.Visible,
		ZIndex = 9,
	}, win.Gui)
	corner(outer, 19)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, outer)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 1),
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 1),
	}, outer)
	local frame = new("Frame", {
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 10,
	}, outer)
	corner(frame, 17)
	local barG = new("UIGradient", {}, frame)
	local ring = new("UIStroke", { Thickness = 1 }, frame)
	win:_ring(ring)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, frame)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, frame)
	local intro = new("UIScale", { Scale = 0.7 }, outer)
	tween(intro, 0.5, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	win._hasBar = true
	win._fab.Visible = false
	win._bar = bar

	local texts = {} -- item name -> TextLabel whose text is refreshed
	local seps = {}
	local function accentHex()
		return toHex(win.Theme.Glow)
	end
	local function line(name, value)
		return string.format('<font color="#A58C90">%s</font> <font color="%s">%s</font>', name, accentHex(), tostring(value))
	end
	local function timer()
		local s = math.floor(os.clock() - started)
		return string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
	end
	local function players()
		local ok, v = pcall(function()
			return #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		end)
		return ok and v or "1/1"
	end
	local function valueOf(name)
		if name == "FPS" then
			return line("FPS", math.floor(fps + 0.5))
		elseif name == "Ping" then
			return line("Ping", readPing() .. "ms")
		elseif name == "Timer" then
			return line("Time", timer())
		elseif name == "Clock" then
			return line("Clock", os.date("%H:%M"))
		elseif name == "Players" then
			return line("Players", players())
		elseif name == "Memory" then
			return line("Mem", readMemory() .. "MB")
		elseif name == "Executor" then
			return line("Exec", readExecutor())
		elseif name == "Game" then
			local g = gameName
			if #g > 18 then
				g = g:sub(1, 17) .. "..."
			end
			return string.format('<font color="%s">%s</font>', accentHex(), g)
		elseif name == "Title" then
			return string.format('<font color="#F0EBEB"><b>%s</b></font>', tostring(o.Title or win.TitleText or "Rebelwar"))
		end
		return ""
	end
	local function refresh()
		for name, l in pairs(texts) do
			l.Text = valueOf(name)
		end
		for _, s in ipairs(seps) do
			s.BackgroundColor3 = win.Theme.Glow
		end
	end

	local function rebuild()
		for _, c in ipairs(frame:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		texts, seps = {}, {}
		local order = 0
		for _, name in ipairs(BAR_ORDER) do
			if items[name] then
				order += 1
				if order > 1 then
					table.insert(seps, new("Frame", {
						Size = UDim2.fromOffset(2, 16),
						BackgroundTransparency = 0.35,
						BorderSizePixel = 0,
						LayoutOrder = order * 2 - 1,
					}, frame))
				end
				if name == "Logo" then
					if logo then
						local img = new("ImageLabel", {
							Size = UDim2.fromOffset(24, 24),
							BackgroundTransparency = 1,
							Image = asset(logo),
							ScaleType = Enum.ScaleType.Fit,
							LayoutOrder = order * 2,
						}, frame)
						corner(img, 12)
						pulse(img)
					else
						local r = label(frame, "R", 17, C.Text, true)
						r.TextXAlignment = Enum.TextXAlignment.Center
						r.Size = UDim2.fromOffset(16, 22)
						r.LayoutOrder = order * 2
						win:_bind(r, "TextColor3", "Glow")
					end
				else
					local l = new("TextLabel", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 22),
						RichText = true,
						Text = "",
						TextSize = 13,
						Font = Enum.Font.GothamBold,
						TextColor3 = C.Text,
						LayoutOrder = order * 2,
					}, frame)
					texts[name] = l
				end
			end
		end
		refresh()
	end

	function bar:SetItems(list)
		items = {}
		for _, n in ipairs(list or {}) do
			items[n] = true
		end
		rebuild()
		if bar.OnChange then
			safe(bar.OnChange, bar:GetItems())
		end
	end
	function bar:GetItems()
		local out = {}
		for _, n in ipairs(BAR_ORDER) do
			if items[n] then
				table.insert(out, n)
			end
		end
		return out
	end
	function bar:SetPreset(name)
		if BAR_PRESETS[name] then
			bar:SetItems(BAR_PRESETS[name])
		end
	end
	function bar:Add(name)
		items[name] = true
		rebuild()
	end
	function bar:Remove(name)
		items[name] = nil
		rebuild()
	end
	function bar:SetLogo(l)
		logo = l
		rebuild()
	end
	function bar:Show(v)
		bar.Visible = v and true or false
		outer.Visible = bar.Visible
	end
	function bar:ResetPosition()
		outer.Position = defaultPos
	end
	function bar:Destroy()
		outer:Destroy()
		win._hasBar = false
		win._bar = nil
		if not win.Open then
			win._fab.Visible = true
		end
	end
	bar.Frame = outer

	-- drag, and a tap opens or closes the panel
	do
		local down, moved, startPos, startMouse = false, 0, nil, nil
		frame.InputBegan:Connect(function(i)
			if isPress(i) then
				down, moved = true, 0
				startMouse, startPos = i.Position, outer.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if down and isMove(i) then
				local d = i.Position - startMouse
				moved = math.max(moved, d.Magnitude)
				if moved > 6 then
					outer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if down and isPress(i) then
				down = false
				if moved <= 6 then
					win:_playClick()
					win:Toggle()
				end
			end
		end)
	end

	-- live numbers: FPS from Heartbeat, text refreshed twice a second, gradient drifting
	local since = 0
	win._conns[#win._conns + 1] = RunService.Heartbeat:Connect(function(dt)
		frames += 1
		acc += dt
		since += dt
		if acc >= 0.5 then
			fps = frames / acc
			frames, acc = 0, 0
		end
		if since >= 0.5 then
			since = 0
			refresh()
		end
		barG.Offset = Vector2.new(math.sin(os.clock() * 0.8) * 0.25, 0)
	end)

	win:_onTheme(function(t)
		barG.Color = ColorSequence.new(t.B0, t.B1)
		refresh()
	end)

	if o.Items then
		bar:SetItems(o.Items)
	else
		bar:SetPreset(o.Preset or "Classic")
	end
	return bar
end

function Tab:BarSettings(bar, o)
	-- one call adds the controls that let a player choose what the bar shows
	o = o or {}
	self:Section(o.Section or "Top bar")
	self:Toggle({
		Name = "Show top bar",
		Description = "Tap the bar to open or close the panel",
		Default = bar.Visible,
		Callback = function(on)
			bar:Show(on)
		end,
	})
	if o.Preset then
		bar:SetPreset(o.Preset)
	end
	-- show the preset that matches what the bar shows now (none if it is a custom mix)
	local nowItems = table.concat(bar:GetItems(), ",")
	local current = false
	for _, name in ipairs(RebelUI.BarPresets) do
		local want = {}
		for _, n in ipairs(BAR_ORDER) do
			for _, p in ipairs(BAR_PRESETS[name]) do
				if p == n then
					table.insert(want, n)
				end
			end
		end
		if table.concat(want, ",") == nowItems then
			current = name
			break
		end
	end
	local dd
	self:Choice({
		Name = "Bar style",
		Options = RebelUI.BarPresets,
		Default = current,
		Callback = function(name)
			bar:SetPreset(name)
			if dd then
				dd:Set(bar:GetItems(), true)
			end
		end,
	})
	dd = self:Dropdown({
		Name = "Bar items",
		Options = BAR_ORDER,
		Multi = true,
		Default = bar:GetItems(),
		Callback = function(set)
			local list = {}
			for name in pairs(set) do
				table.insert(list, name)
			end
			bar:SetItems(list)
		end,
	})
	return dd
end

-- ============================================================ saving
local function encode(v)
	local t = typeof(v)
	if t == "Color3" then
		return { _t = "c", v = toHex(v) }
	elseif t == "EnumItem" then
		return { _t = "k", v = v.Name }
	elseif t == "table" then
		local list = {}
		for k, x in pairs(v) do
			if x then
				table.insert(list, k)
			end
		end
		table.sort(list, function(a, b)
			return tostring(a) < tostring(b)
		end)
		return { _t = "m", v = list }
	end
	return v
end

local function decode(v)
	if type(v) == "table" then
		if v._t == "c" then
			return fromHex(v.v)
		elseif v._t == "k" then
			return Enum.KeyCode[v.v]
		elseif v._t == "m" then
			return v.v
		end
	end
	return v
end

function Window:_file(file)
	if file then
		return file
	end
	local clean = tostring(self.TitleText):gsub("[^%w]", "")
	return (clean == "" and "RebelUI" or clean) .. "_settings.json"
end

function Window:Save(file)
	-- saves every element that has a Flag. Needs an executor with writefile. Returns true on success.
	if type(writefile) ~= "function" then
		return false
	end
	local data = {}
	for flag, obj in pairs(self.Flags) do
		local ok, v = pcall(function()
			return obj:Get()
		end)
		if ok and v ~= nil then
			data[flag] = encode(v)
		end
	end
	data["__theme"] = self.ThemeName
	local ok = pcall(function()
		writefile(self:_file(file), game:GetService("HttpService"):JSONEncode(data))
	end)
	return ok
end

function Window:Load(file)
	-- loads what Save wrote and applies it (your Callbacks run). Returns true if a file was found.
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		return false
	end
	local path = self:_file(file)
	local okExists, exists = pcall(isfile, path)
	if not (okExists and exists) then
		return false
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	if data["__theme"] and THEMES[data["__theme"]] then
		self:SetTheme(data["__theme"])
	end
	for flag, v in pairs(data) do
		local obj = self.Flags[flag]
		if obj then
			local val = decode(v)
			if val ~= nil then
				pcall(function()
					obj:Set(val)
				end)
			end
		end
	end
	return true
end

-- ============================================================ ready-made Settings tab
function Window:CreateSettingsTab(o)
	-- Bar = the bar from CreateBar, Icon, Name, File. One call: themes, accent color, size, see-through,
	-- top bar choices, notifications, sound, save / load, reset position and unload.
	o = o or {}
	local win = self
	local tab = win:CreateTab({
		Name = o.Name or "Settings",
		Icon = o.Icon,
		Title = o.Title or "Settings",
		Description = o.Description or "Themes, top bar, notifications and the panel itself.",
	})
	local startPos = win.Main.Position
	tab:Section("Appearance")
	tab:Cycle({
		Name = "Theme",
		Description = #RebelUI.Themes .. " themes - tap the arrows",
		Options = RebelUI.Themes,
		Default = win.ThemeName,
		Callback = function(n)
			win:SetTheme(n)
		end,
	})
	tab:Color({
		Name = "Accent color",
		Default = win.Theme.Accent,
		Callback = function(c)
			win:SetAccent(c)
		end,
	})
	tab:Slider({
		Name = "Panel size",
		Min = 70,
		Max = 130,
		Default = 100,
		Suffix = "%",
		Callback = function(v)
			win:SetScale(v / 100)
		end,
	})
	tab:Slider({
		Name = "See-through",
		Min = 0,
		Max = 60,
		Default = 0,
		Suffix = "%",
		Callback = function(v)
			win:SetTransparency(v / 100)
		end,
	})
	if o.Bar then
		tab:BarSettings(o.Bar)
	end
	tab:Section("Notifications and sound")
	tab:Toggle({
		Name = "Notifications",
		Description = "Pop-up cards at the bottom",
		Default = win.Toasts,
		Callback = function(on)
			win.Toasts = on
		end,
	})
	tab:Toggle({
		Name = "Toggle pop-ups",
		Description = "A card each time a toggle flips",
		Default = win.ToggleToasts == true,
		Callback = function(on)
			win.ToggleToasts = on
		end,
	})
	tab:Toggle({
		Name = "Sound effects",
		Description = "A soft click on buttons and tabs",
		Default = win.Sound,
		Callback = function(on)
			win.Sound = on
		end,
	})
	tab:Slider({
		Name = "Notification time",
		Min = 1,
		Max = 8,
		Default = win.NotifyTime,
		Suffix = "s",
		Callback = function(v)
			win.NotifyTime = v
		end,
	})
	tab:Section("Panel")
	tab:Toggle({
		Name = "Confirm on close",
		Description = "Tap X twice to close",
		Default = win.ConfirmClose,
		Callback = function(on)
			win.ConfirmClose = on
		end,
	})
	tab:Button({
		Name = "Reset position",
		Callback = function()
			win.Main.Position = startPos
			if win._bar then
				win._bar:ResetPosition()
			end
			win:Notify({ Title = "Position", Text = "The panel is back in the middle." })
		end,
	})
	tab:Button({
		Name = "Save settings",
		Description = "Keeps every element that has a Flag",
		Callback = function()
			local ok = win:Save(o.File)
			win:Notify({
				Title = ok and "Saved" or "Could not save",
				Text = ok and "Your settings are saved." or "This executor can't write files.",
				Type = ok and "success" or "error",
			})
		end,
	})
	tab:Button({
		Name = "Load settings",
		Callback = function()
			local ok = win:Load(o.File)
			win:Notify({
				Title = ok and "Loaded" or "Nothing to load",
				Text = ok and "Your saved settings are back." or "No saved file was found.",
				Type = ok and "success" or "warn",
			})
		end,
	})
	tab:Button({
		Name = "Unload panel",
		Callback = function()
			win:Destroy()
		end,
	})
	return tab
end

return RebelUI
