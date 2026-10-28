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

    Elements: Section, Label, Divider, Button, Toggle, Slider, RangeSlider, Pad, Dropdown, Input,
              Keybind, Color, Header, Image, Progress, Paragraph, Notice, Choice, Cycle,
              Console, Graph, CodeBox, Feed
    Window:   CreateTab, CreateBar, CreateSettingsTab, Notify, SetTheme, SetAccent, SetScale,
              SetOpacity, SetSize, SetToggleKey, Toggle, Save, Load, Destroy,
              SaveProfile, LoadProfile, DeleteProfile, ListProfiles, SetAutoLoad, AutoLoad
    Library:  Loading, CreateWindow, KeyGate, AddTheme, SetLanguage, Spring, State
    Also: search box, drag-to-resize, named profiles, key gate, notification buttons and icons,
          dialogs, collapsible sections, keybind modes, number boxes, tab dividers,
          settings export / import, panel opacity (100% by default).
    More Window methods: Dialog, CreateTabDivider, CreateKeybindList, Export, Import
    Game assistant: Window:GameAssistant (full-screen HUD), Window:SetTrigger (Circle / Square / Bar), Loading({ Video = ... })
    Effects: SetOpenAnimation, SetAnimSpeed, SetReduceMotion, SetFx, SetRainbow, Confetti, Shake, ScreenShake, Button { Danger = true }
    Extras: CreateToolsTab (command bar, notes, badges, randomizer, performance, accessibility), AddCommand, RunCommand, CreateAITab (optional)
    More elements: Notice (warning box). Every element: tooltip, :SetVisible, :Destroy, :DependsOn
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
	-- made for easy reading: pure black, bright yellow
	Contrast = makeTheme(rgb(255, 230, 0), {
		Glow = rgb(255, 255, 120),
		Dark = rgb(130, 115, 0),
		BG0 = rgb(0, 0, 0),
		BG1 = rgb(12, 12, 12),
		S0 = rgb(0, 0, 0),
		S1 = rgb(20, 20, 20),
		B0 = rgb(0, 0, 0),
		B1 = rgb(28, 28, 28),
		Item = rgb(26, 26, 26),
		ItemOn = rgb(52, 48, 0),
		Off = rgb(120, 120, 120),
		Inset = rgb(0, 0, 0),
	}),
	-- blue and orange are easy to tell apart for most kinds of color blindness
	Colorblind = makeTheme(rgb(0, 114, 178), { Glow = rgb(86, 180, 233), Dark = rgb(0, 50, 80) }),
}
RebelUI.Themes = { "Red", "Crimson", "Blue", "Green", "Purple", "Orange", "Pink", "Gold", "Cyber", "Blood", "Ice", "Mono", "Contrast", "Colorblind" }
RebelUI.SourceUrl = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"
RebelUI.Lang = {} -- text translations, see RebelUI:SetLanguage

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
	if props and type(props.Text) == "string" and RebelUI.Lang[props.Text] then
		props.Text = RebelUI.Lang[props.Text] -- translations (RebelUI:SetLanguage)
	end
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
		Text = RebelUI.Lang[str] or str,
		TextSize = size or 11,
		TextColor3 = color or C.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

-- ============================================================ small tools you can use too
-- Translate the panel: RebelUI:SetLanguage({ ["Settings"] = "Tetapan", ["Save settings"] = "Simpan" }) before CreateWindow.
function RebelUI:SetLanguage(dict)
	RebelUI.Lang = type(dict) == "table" and dict or {}
end

-- A spring: smooth, bouncy movement. local s = UI.Spring.new(0, 12, 0.6); s.Target = 1; s:Update(dt) each frame.
local Spring = {}
Spring.__index = Spring
function Spring.new(value, speed, damping)
	return setmetatable({ Value = value or 0, Target = value or 0, Velocity = 0, Speed = speed or 10, Damping = damping or 0.7 }, Spring)
end
function Spring:Update(dt)
	dt = math.min(dt or 1 / 60, 0.25)
	local steps = math.max(1, math.ceil(dt * 120))
	local h = dt / steps
	local k, c = self.Speed * self.Speed, 2 * self.Damping * self.Speed
	for _ = 1, steps do
		self.Velocity += (k * (self.Target - self.Value) - c * self.Velocity) * h
		self.Value += self.Velocity * h
	end
	return self.Value
end
RebelUI.Spring = Spring

-- A value that tells everyone who is listening when it changes.
--   local score = UI.State(0); score:Bind(labelObj, "Score: %d"); score:Set(5)
local State = {}
State.__index = State
function RebelUI.State(initial)
	return setmetatable({ Value = initial, _fns = {} }, State)
end
function State:Get()
	return self.Value
end
function State:Set(v)
	if v == self.Value then
		return
	end
	self.Value = v
	for _, fn in ipairs(self._fns) do
		safe(fn, v)
	end
end
function State:OnChange(fn)
	table.insert(self._fns, fn)
	return fn
end
function State:Bind(obj, fmt)
	-- obj is any element with :Set (a Label, Paragraph, Slider, Toggle...). fmt is a string.format pattern.
	local function push(v)
		obj:Set(fmt and string.format(fmt, v) or v)
	end
	push(self.Value)
	return self:OnChange(push)
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

local RAINBOW = (function()
	local k = {}
	for i = 0, 6 do
		k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.85, 1))
	end
	return ColorSequence.new(k)
end)()

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
	local g = new("UIGradient", { Color = self._rainbow and RAINBOW or ringSeq(self.Theme) }, stroke)
	table.insert(self._spin, g)
	return g
end

-- turns a link, a file name or an asset id into something an ImageLabel / VideoFrame can show (nil if it can't)
local function resolveMedia(src, file)
	src = tostring(src or "")
	if src:match("^%d+$") or src:match("^rbxasset") then
		return asset(src)
	end
	local gca = getcustomasset or get_custom_asset
	if src:match("^https?://") then
		if not file then
			local h = 0
			for i = 1, #src do
				h = (h * 31 + src:byte(i)) % 1000000007
			end
			file = "RebelUI_media_" .. h .. ".mp4"
		end
		if type(isfile) == "function" and isfile(file) and gca then
			local okC, size = pcall(function()
				return #readfile(file)
			end)
			if okC and size > 1000 and size < 30000000 then
				local okA, a = pcall(gca, file)
				if okA then
					return a
				end
			end
		end
		local req = (syn and syn.request) or request or http_request
		local function fetch(u)
			if req then
				local ok, res = pcall(req, { Url = u, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36", Referer = u } })
				if ok and res and type(res.Body) == "string" then
					return res.Body
				end
			end
			local ok, b = pcall(function()
				return game:HttpGet(u)
			end)
			return ok and type(b) == "string" and b or nil
		end
		local function isVideo(b)
			return type(b) == "string" and #b > 20000 and not b:sub(1, 600):lower():find("<html", 1, true)
		end
		local body = fetch(src)
		if body and not isVideo(body) then
			-- it was a web page (a video host's player). Look for the real video file inside it.
			local page = body:gsub("\\/", "/"):gsub("&amp;", "&")
			local found
			for _, pat in ipairs({ '<source[^>]-src=["\']([^"\']+)["\']', '<video[^>]-src=["\']([^"\']+)["\']', '["\']file["\']%s*:%s*["\']([^"\']+)["\']', '["\']src["\']%s*:%s*["\']([^"\']+)["\']', '(https?://[^%s"\'<>\\]+%.mp4[^%s"\'<>\\]*)', '(https?://[^%s"\'<>\\]+%.webm[^%s"\'<>\\]*)' }) do
				for u in page:gmatch(pat) do
					if u:lower():find("%.mp4") or u:lower():find("%.webm") or u:lower():find("/video") or u:lower():find("/download") then
						found = u
						break
					end
				end
				if found then
					break
				end
			end
			if found then
				if found:sub(1, 2) == "//" then
					found = "https:" .. found
				elseif found:sub(1, 1) == "/" then
					found = src:match("^(https?://[^/]+)") .. found
				end
				body = fetch(found)
			else
				body = nil
			end
		end
		if not isVideo(body) or #body > 30000000 then
			if body and #body > 30000000 then
				warn("[RebelUI] that video is over 30 MB, so it was skipped (make it smaller)")
			end
			body = nil
		end
		if body and writefile and gca then
			pcall(writefile, file, body)
			local ok, a = pcall(gca, file)
			if ok then
				return a
			end
		end
		return nil
	end
	if gca and type(isfile) == "function" and isfile(src) then
		local ok, a = pcall(gca, src)
		if ok then
			return a
		end
	end
	return nil
end
RebelUI.ResolveMedia = resolveMedia

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
	-- Title, Subtitle, Logo, Banner, Footer, Theme, Name, Timeout
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
	-- a loading video (optional). Video = link / file name / asset id. L:SetVideo(x) can add it later.
	local function attachVideo(src)
		if not src or L.Dead then
			return
		end
		pcall(function()
			if L.VideoFrame then
				L.VideoFrame:Destroy()
			end
			local vf = new("VideoFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Looped = o.VideoLoop ~= false,
				Volume = o.VideoVolume or 0,
				Video = src,
				ZIndex = 1,
			}, root)
			vf.Playing = true
			pcall(function()
				vf:Play()
			end)
			L.VideoFrame = vf
			-- if the video never loads (some executors can't play them) remove it so the banner stays
			task.delay(8, function()
				pcall(function()
					if vf.Parent and not vf.IsLoaded then
						vf:Destroy()
					end
				end)
			end)
		end)
	end
	function L:SetVideo(v)
		task.spawn(function()
			local okR, src = pcall(resolveMedia, v, o.VideoFile)
			if okR then
				attachVideo(src)
			end
		end)
	end
	if o.Video then
		L:SetVideo(o.Video)
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
		L.Dead = true
		alive = false
		conn:Disconnect()
		sg:Destroy()
	end
	L.Gui = sg
	-- tap anywhere to skip (after 2.5 seconds), so a loading screen can never trap you
	if o.Skippable ~= false then
		local born = os.clock()
		local hint = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -14, 1, -10),
			Size = UDim2.fromOffset(120, 16),
			BackgroundTransparency = 1,
			Text = "Tap to skip",
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.35,
			TextXAlignment = Enum.TextXAlignment.Right,
			Visible = false,
			ZIndex = 20,
		}, root)
		task.delay(2.5, function()
			if alive then
				hint.Visible = true
			end
		end)
		root.InputBegan:Connect(function(i)
			if alive and os.clock() - born > 2.5 and isPress(i) then
				L:Destroy()
			end
		end)
	end
	-- safety net: if your script never calls Finish, the screen removes itself so it can never trap the player
	local limit = o.Timeout or 40
	task.delay(limit, function()
		if alive and sg.Parent then
			warn("[RebelUI] the loading screen was still open after " .. limit .. "s and was closed. Call Load:Finish().")
			L:Destroy()
		end
	end)
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
		_keybinds = {},
		Flags = {},
		Open = false,
		Sound = o.Sound == true,
		Toasts = o.Toasts ~= false,
		NotifyTime = 4,
		ConfirmClose = o.ConfirmClose == true,
		Scale = 1,
		Inertia = o.Inertia ~= false,
		Scramble = o.Scramble ~= false,
		Opacity = 100,
		ToggleKey = o.ToggleKey or Enum.KeyCode.RightShift,
		AnimSpeed = o.AnimSpeed or 1,
		OpenAnim = o.OpenAnimation or "Pop",
		ReduceMotion = o.ReduceMotion == true,
	}, Window)
	local themeName = THEMES[o.Theme or "Red"] and (o.Theme or "Red") or "Red"
	win.Theme = THEMES[themeName]
	win.ThemeName = themeName
	win.TitleText = o.Title or "RebelUI"
	win._icon = o.Icon
	local lp = Players.LocalPlayer

	local name = o.Name or "RebelUI"
	clearOld(name)

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	if vp.X < 200 or vp.Y < 150 then
		vp = Vector2.new(800, 450) -- some executors report 0 right after joining
	end
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
	win._ringStroke = ringStroke

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
	local hasSearch = o.Search ~= false
	pageTitle.Size = UDim2.new(1, hasSearch and -166 or -54, 0, 22)
	pageTitle.Position = UDim2.fromOffset(4, 4)
	if hasSearch then
		local sb = new("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -56, 0, 6),
			Size = UDim2.fromOffset(104, 18),
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = C.Dim,
			TextColor3 = C.Text,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			ZIndex = 8,
		}, content)
		corner(sb, 9)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6) }, sb)
		win:_bind(sb, "BackgroundColor3", "Inset")
		win._search = sb
		sb:GetPropertyChangedSignal("Text"):Connect(function()
			win:_filter(sb.Text)
		end)
	end
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
		Text = "",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 20,
	}, gui)
	win._fabCorner = corner(fab, 22)
	local fabG = new("UIGradient", { Rotation = 90 }, fab)
	local fabRing = new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, fab)
	win:_ring(fabRing)
	if not o.Icon then
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "R",
			TextSize = 20,
			Font = Enum.Font.GothamBlack,
			TextColor3 = C.Text,
			ZIndex = 21,
		}, fab)
	end
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
		local lx, ly, lt, vx, vy = 0, 0, 0, 0, 0
		handle.InputBegan:Connect(function(i)
			if isPress(i) then
				dragging = true
				startMouse = i.Position
				startPos = main.Position
				win._glide = nil
				lx, ly, lt, vx, vy = i.Position.X, i.Position.Y, os.clock(), 0, 0
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - startMouse
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				local now = os.clock()
				local dt = now - lt
				if dt > 0.001 then
					vx = vx * 0.5 + ((i.Position.X - lx) / dt) * 0.5
					vy = vy * 0.5 + ((i.Position.Y - ly) / dt) * 0.5
					lx, ly, lt = i.Position.X, i.Position.Y, now
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if dragging and isPress(i) then
				dragging = false
				-- let go while moving: the panel keeps gliding and slows down (Inertia = false turns it off)
				if win.Inertia and os.clock() - lt < 0.08 and math.abs(vx) + math.abs(vy) > 150 then
					win._glide = { x = math.clamp(vx, -1500, 1500), y = math.clamp(vy, -1500, 1500) }
				end
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
			g.Color = win._rainbow and RAINBOW or ringSeq(t)
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
		local g = win._glide
		if g then
			local P = main.Position
			main.Position = UDim2.new(P.X.Scale, P.X.Offset + g.x * dt, P.Y.Scale, P.Y.Offset + g.y * dt)
			local f = 0.88 ^ (dt * 60)
			g.x *= f
			g.y *= f
			if math.abs(g.x) + math.abs(g.y) < 20 then
				win._glide = nil
			end
		end
		local fns = win._frame
		if fns and #fns > 0 then
			for _, fn in ipairs(table.clone(fns)) do -- a copy, so a function can remove itself safely
				local ok, err = pcall(fn, now, dt)
				if not ok then
					local at = table.find(fns, fn)
					if at then
						table.remove(fns, at) -- a broken per-frame function is dropped instead of erroring every frame
					end
					warn("[RebelUI] a per-frame function failed and was removed: " .. tostring(err))
				end
			end
		end
	end)

	-- ---------- drag the corner to resize the panel
	if o.Resizable ~= false then
		local grip = new("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 12,
		}, main)
		local lines = {}
		for k = 1, 2 do
			local ln = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(15 - (k - 1) * 4, 15 - (k - 1) * 4),
				Size = UDim2.fromOffset(k == 1 and 10 or 6, 2),
				Rotation = -45,
				BorderSizePixel = 0,
				BackgroundTransparency = 0.25,
				ZIndex = 13,
			}, grip)
			corner(ln, 1)
			lines[k] = ln
		end
		win:_onTheme(function(t)
			for _, ln in ipairs(lines) do
				ln.BackgroundColor3 = t.Glow
			end
		end)
		local rs, sm, ss = false, nil, nil
		grip.InputBegan:Connect(function(i)
			if isPress(i) then
				rs, sm, ss = true, i.Position, main.AbsoluteSize / math.max(panelScale.Scale, 0.01)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if rs and isMove(i) then
				local d = (i.Position - sm) / math.max(panelScale.Scale, 0.01)
				win:SetSize(ss.X + d.X, ss.Y + d.Y)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if rs and isPress(i) then
				rs = false
			end
		end)
	end

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
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
		if not processed and i.KeyCode == win.ToggleKey then
			win:Toggle()
		end
	end)

	win._orderTabs = 0
	win:_initFx()
	win:SetOpacity(o.Opacity or 100)
	if o.AutoSave then
		win:AutoSave(o.AutoSave)
	end
	if o.Open ~= false then
		win:Toggle(true)
	else
		fab.Visible = not win._hasBar
	end
	if o.Trigger then
		win:SetTrigger(o.Trigger)
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
	local sp = self.AnimSpeed or 1
	local style = self.OpenAnim or "Pop"
	local sc = self._scaleObj
	if not self._restPos then
		self._restPos = main.Position
	end
	if state then
		self._token = (self._token or 0) + 1
		main.Visible = true
		if self.ReduceMotion then
			sc.Scale = self.Scale
			main.Rotation = 0
		elseif style == "Slide" then
			sc.Scale = self.Scale
			local base = main.Position
			main.Position = base + UDim2.fromOffset(0, 90)
			tween(main, 0.4 / sp, { Position = base }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		elseif style == "Fade" then
			sc.Scale = self.Scale * 0.94
			tween(sc, 0.3 / sp, { Scale = self.Scale }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		elseif style == "Bounce" then
			sc.Scale = self.Scale * 0.3
			tween(sc, 0.7 / sp, { Scale = self.Scale }, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		elseif style == "Drop" then
			sc.Scale = self.Scale
			local base = main.Position
			main.Position = base + UDim2.fromOffset(0, -140)
			tween(main, 0.6 / sp, { Position = base }, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		elseif style == "Spin" then
			sc.Scale = self.Scale * 0.5
			main.Rotation = -14
			tween(sc, 0.45 / sp, { Scale = self.Scale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			tween(main, 0.45 / sp, { Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else -- Pop
			tween(sc, 0.35 / sp, { Scale = self.Scale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	else
		local my = (self._token or 0) + 1
		self._token = my
		local t = tween(sc, (self.ReduceMotion and 0.01 or 0.2 / sp), { Scale = self.Scale * 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		t.Completed:Connect(function()
			if not self.Open and self._token == my then
				main.Visible = false
				main.Rotation = 0
			end
		end)
	end
	if self._scan then
		self._scan.Visible = state and self.Fx and self.Fx.Scan or false
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

-- rainbow rings around everything (cheap: no per-frame recoloring of the whole panel)
function Window:SetRainbow(on)
	self._rainbow = on == true
	for _, g in ipairs(self._spin) do
		g.Color = self._rainbow and RAINBOW or ringSeq(self.Theme)
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
	-- 0 to 0.9: see-through panel (SetOpacity is the same thing as a percent)
	t = math.clamp(tonumber(t) or 0, 0, 0.9)
	self.Main.BackgroundTransparency = t
	self._side.BackgroundTransparency = t
end

function Window:SetOpacity(pct)
	-- 10 to 100. 100 = solid panel (the default)
	pct = math.clamp(tonumber(pct) or 100, 10, 100)
	self.Opacity = pct
	self:SetTransparency(1 - pct / 100)
end

function Window:SetSize(w, h)
	-- the size of the panel in pixels (before UI size scaling). It stays inside the screen.
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	if vp.X < 200 or vp.Y < 150 then
		vp = Vector2.new(800, 450)
	end
	local s = math.max(self.Scale, 0.01)
	w = math.clamp(tonumber(w) or self._baseSize[1], 320, math.max(320, vp.X * 0.96 / s))
	h = math.clamp(tonumber(h) or self._baseSize[2], 240, math.max(240, vp.Y * 0.96 / s))
	self.Main.Size = UDim2.fromOffset(math.floor(w), math.floor(h))
end

function Window:SetToggleKey(k)
	if typeof(k) == "EnumItem" then
		self.ToggleKey = k
	end
end

function Window:_scramble(lbl, text)
	-- the title "decodes" into the new name (Scramble = false turns it off)
	self._scrTok = (self._scrTok or 0) + 1
	local mine = self._scrTok
	text = tostring(text)
	if not self.Scramble or #text == 0 then
		lbl.Text = text
		return
	end
	local chars = "01#@$%&*+=?"
	task.spawn(function()
		local steps = 7
		for s = 1, steps do
			if self._scrTok ~= mine or self._dead then
				return
			end
			local out = {}
			for k = 1, #text do
				local ch = text:sub(k, k)
				if ch == " " or k <= (#text * (s - 1) / steps) then
					out[k] = ch
				else
					local r = math.random(1, #chars)
					out[k] = chars:sub(r, r)
				end
			end
			lbl.Text = table.concat(out)
			task.wait(0.035)
		end
		if self._scrTok == mine then
			lbl.Text = text
		end
	end)
end

function Window:Destroy()
	self._dead = true
	if self.HUD then
		pcall(function()
			self.HUD:Destroy()
		end)
	end
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
		local nop = function() end
		return { SetTitle = nop, SetText = nop, Progress = nop, Close = nop }
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
	local hparent = card
	if o.Icon then
		hparent = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, ZIndex = 31, LayoutOrder = 1 }, card)
		new("ImageLabel", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(0, 1),
			BackgroundTransparency = 1,
			Image = asset(o.Icon),
			ZIndex = 32,
		}, hparent)
	end
	local h = label(hparent, o.Title or "Rebelwar", 11, C.Text, true)
	h.Size = UDim2.new(1, 0, 0, 14)
	h.ZIndex = 31
	h.LayoutOrder = 1
	if o.Icon then
		h.Size = UDim2.new(1, -22, 0, 18)
		h.Position = UDim2.fromOffset(22, 0)
	end
	local b = label(card, o.Text or "", 9, C.Dim, false)
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.ZIndex = 31
	b.LayoutOrder = 2
	b.Visible = o.Text ~= nil
	local dismiss
	local btns = {}
	if type(o.Actions) == "table" and #o.Actions > 0 then
		local arow = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, ZIndex = 31, LayoutOrder = 3 }, card)
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 5),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, arow)
		for n, a in ipairs(o.Actions) do
			if n > 3 then
				break
			end
			local b = new("TextButton", {
				Size = UDim2.new(1 / math.min(#o.Actions, 3), -4, 0, 20),
				BorderSizePixel = 0,
				Text = tostring(a.Name or "OK"),
				TextColor3 = C.Text,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 32,
				LayoutOrder = n,
			}, arow)
			corner(b, 6)
			btns[#btns + 1] = b
			b.MouseButton1Click:Connect(function()
				safe(a.Callback)
				if dismiss then
					dismiss()
				end
			end)
		end
	end
	local line = new("Frame", { Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, ZIndex = 31, LayoutOrder = 4 }, card)
	corner(line, 1)
	local function paint(t)
		cg.Color = ColorSequence.new(t.BG0, t.B1)
		local c = kinds[o.Type or ""] or t.Accent
		st.Color = kinds[o.Type or ""] or t.Glow
		line.BackgroundColor3 = c
		for _, b in ipairs(btns) do
			b.BackgroundColor3 = c:Lerp(Color3.new(0, 0, 0), 0.45)
		end
	end
	paint(self.Theme)
	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local persistent = dur <= 0 or dur == math.huge -- Duration = 0 stays until Close()
	if persistent then
		line.Size = UDim2.new(0, 0, 0, 2)
	else
		tween(line, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	end
	local closing = false
	dismiss = function()
		if closing or not card.Parent then
			return
		end
		closing = true
		local o2 = tween(card, 0.25, { Position = UDim2.new(0, -290, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		o2.Completed:Connect(function()
			wrap:Destroy()
		end)
	end
	if not persistent then
		task.delay(dur, dismiss)
	end
	-- the card can be changed while it is on screen: n:SetTitle, n:SetText, n:Progress(0 to 1), n:Close()
	return {
		SetTitle = function(_, t)
			h.Text = tostring(t)
		end,
		SetText = function(_, t)
			b.Text = tostring(t)
			b.Visible = true
		end,
		Progress = function(_, v)
			line.Size = UDim2.new(math.clamp(tonumber(v) or 0, 0, 1), 0, 0, 2)
		end,
		Close = function()
			dismiss()
		end,
	}
end

-- ============================================================ dialog (a pop-up question with buttons)
function Window:Dialog(o)
	-- Title, Text, Buttons = { { Name = "Yes", Callback = fn }, { Name = "No" } }  (up to 3, tapping one closes it)
	o = o or {}
	if self._dialog and self._dialog.Parent then
		self._dialog:Destroy()
	end
	local t = self.Theme
	local back = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 60,
	}, self.Gui)
	self._dialog = back
	tween(back, 0.2, { BackgroundTransparency = 0.45 })
	local card = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(280, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		ZIndex = 61,
	}, back)
	corner(card, 12)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(t.BG0, t.BG1) }, card)
	new("UIStroke", { Color = t.Glow, Thickness = 1.5 }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	local sc = new("UIScale", { Scale = 0.75 }, card)
	tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local h = label(card, o.Title or "Are you sure?", 14, t.Glow, true)
	h.Font = Enum.Font.GothamBlack
	h.Size = UDim2.new(1, 0, 0, 20)
	h.ZIndex = 62
	h.LayoutOrder = 1
	if o.Text then
		local b = label(card, o.Text, 10, C.Dim, false)
		b.TextWrapped = true
		b.TextTruncate = Enum.TextTruncate.None
		b.Size = UDim2.new(1, 0, 0, 0)
		b.AutomaticSize = Enum.AutomaticSize.Y
		b.ZIndex = 62
		b.LayoutOrder = 2
	end
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 62, LayoutOrder = 3 }, card)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	}, row)
	local list = o.Buttons
	if type(list) ~= "table" or #list == 0 then
		list = { { Name = "OK" } }
	end
	local n = math.min(#list, 3)
	local function close()
		if back.Parent then
			tween(back, 0.15, { BackgroundTransparency = 1 })
			tween(sc, 0.15, { Scale = 0.8 })
			task.delay(0.16, function()
				back:Destroy()
			end)
		end
	end
	for i = 1, n do
		local a = list[i]
		local first = i == 1
		local btn = new("TextButton", {
			Size = UDim2.new(1 / n, -6 * (n - 1) / n, 0, 30),
			BackgroundColor3 = first and t.Accent or t.Item,
			BorderSizePixel = 0,
			Text = tostring(a.Name or "OK"),
			TextColor3 = C.Text,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			ZIndex = 63,
			LayoutOrder = i,
		}, row)
		corner(btn, 8)
		if first then
			new("UIStroke", { Color = t.Glow, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
		end
		btn.MouseButton1Click:Connect(function()
			self:_playClick()
			close()
			safe(a.Callback)
		end)
	end
	return { Close = close }
end

function Window:_bind(obj, prop, key)
	self:_onTheme(function(t)
		obj[prop] = t[key]
	end)
end

-- ============================================================ tooltips
-- Hover (PC) or press and hold (phone) on an element that has Tooltip = "text".
function Window:_tip(row, text)
	local win = self
	local token = 0
	local function hide()
		token += 1
		if win._tipFrame then
			win._tipFrame.Visible = false
		end
	end
	local function show()
		if not win.Gui then
			return
		end
		if not win._tipFrame then
			local f = new("Frame", {
				Size = UDim2.fromOffset(190, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 70,
			}, win.Gui)
			corner(f, 8)
			local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
			new("UIPadding", {
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}, f)
			local l = label(f, "", 9, C.Text, false)
			l.TextWrapped = true
			l.TextTruncate = Enum.TextTruncate.None
			l.Size = UDim2.new(1, 0, 0, 0)
			l.AutomaticSize = Enum.AutomaticSize.Y
			l.ZIndex = 71
			win:_onTheme(function(t)
				f.BackgroundColor3 = t.S0
				st.Color = t.Glow
			end)
			win._tipFrame, win._tipLabel = f, l
		end
		win._tipLabel.Text = tostring(text)
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
		local pos, size = row.AbsolutePosition, row.AbsoluteSize
		local x = math.clamp(pos.X, 6, math.max(6, vp.X - 200))
		local y = pos.Y - 40
		if y < 6 then
			y = pos.Y + size.Y + 6
		end
		win._tipFrame.Position = UDim2.fromOffset(x, y)
		win._tipFrame.Visible = true
	end
	row.MouseEnter:Connect(function()
		token += 1
		local mine = token
		task.delay(0.4, function()
			if token == mine then
				show()
			end
		end)
	end)
	row.MouseLeave:Connect(hide)
	row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			token += 1
			local mine = token
			task.delay(0.6, function()
				if token == mine then
					show()
				end
			end)
		end
	end)
	row.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			local mine = token
			task.delay(1.6, function()
				if token == mine then
					hide()
				end
			end)
			token += 1
		end
	end)
end

-- ============================================================ keybind list (the keys that are set, on screen)
function Window:CreateKeybindList(o)
	-- Position (UDim2), Title, Visible. Lists every Keybind and every Toggle that has a Key.
	o = o or {}
	local win = self
	local f = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = o.Position or UDim2.new(1, -12, 0, 56),
		Size = UDim2.fromOffset(150, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		ZIndex = 40,
		Visible = o.Visible ~= false,
	}, win.Gui)
	corner(f, 8)
	local fg = new("UIGradient", { Rotation = 90 }, f)
	local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 9),
		PaddingRight = UDim.new(0, 9),
	}, f)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, f)
	local title = label(f, o.Title or "Keybinds", 10, C.Text, true)
	title.Size = UDim2.new(1, 0, 0, 16)
	title.ZIndex = 41
	title.LayoutOrder = 0
	win:_onTheme(function(t)
		fg.Color = ColorSequence.new(t.BG0, t.B1)
		st.Color = t.Glow
		title.TextColor3 = t.Glow
	end)
	-- drag it by the title
	local dragging, sm, sp
	local grab = new("TextButton", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", ZIndex = 42, LayoutOrder = 0 }, title)
	grab.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, sm, sp = true, i.Position, f.Position
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - sm
			f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if isPress(i) then
			dragging = false
		end
	end)
	local rows, acc = {}, 1
	local obj = {}
	local function refresh()
		for n, kb in ipairs(win._keybinds) do
			local l = rows[kb]
			if not l then
				l = label(f, "", 9, C.Dim, false)
				l.Size = UDim2.new(1, 0, 0, 14)
				l.ZIndex = 41
				rows[kb] = l
			end
			l.LayoutOrder = n
			local on = kb.active and kb.active() or false
			local okk, k = pcall(kb.key)
			l.Text = tostring(kb.name) .. "   [" .. ((okk and k and k.Name) or "?") .. "]" .. (on and "  ON" or "")
			l.TextColor3 = on and win.Theme.Glow or C.Dim
		end
	end
	table.insert(win._frame, function(_, dt)
		acc += dt or 0
		if acc >= 0.25 and f.Visible then
			acc = 0
			refresh()
		end
	end)
	refresh()
	function obj:Show(v)
		f.Visible = v ~= false
	end
	function obj:Destroy()
		f:Destroy()
	end
	win._kbList = obj
	return obj
end

-- ============================================================ search
-- Types in the search box: rows on the current tab whose text matches stay, the rest hide.
function Window:_filter(q)
	q = tostring(q or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	local tab = self.CurrentTab
	if not tab then
		return
	end
	local hidden = tab._hidden or {}
	tab._hidden = hidden
	for _, obj in ipairs(hidden) do
		if obj.Parent then
			obj.Visible = true
		end
	end
	table.clear(hidden)
	for _, s in ipairs(tab._secs or {}) do
		if s.apply and s.collapsed then
			s.apply()
		end
	end
	if q == "" then
		return
	end
	local found = 0
	for _, row in ipairs(tab.Page:GetChildren()) do
		if row:IsA("GuiObject") then
			local match = false
			if row:IsA("Frame") or row:IsA("TextButton") then
				for _, d in ipairs(row:GetDescendants()) do
					if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and d.Text:lower():find(q, 1, true) then
						match = true
						break
					end
				end
			end
			if match then
				found += 1
			else
				row.Visible = false
				table.insert(hidden, row)
			end
		end
	end
	return found
end

-- ============================================================ tabs
function Window:CreateTabDivider(text)
	-- a small caption between tabs in the side list, like "GAMES" or "SETTINGS"
	local l = label(self._tabList, string.upper(tostring(text or "")), 8, C.Dim, true)
	l.Size = UDim2.new(1, 0, 0, 16)
	l.TextXAlignment = Enum.TextXAlignment.Left
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }, l)
	l.LayoutOrder = #self._tabs * 10 + 5
	self:_bind(l, "TextColor3", "Glow")
	return l
end

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
		LayoutOrder = (#win._tabs + 1) * 10,
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
		if win._search and win._search.Text ~= "" then
			win._search.Text = ""
		end
		page.Position = UDim2.fromOffset(0, 40)
		page.Visible = true
		tween(page, 0.22, { Position = UDim2.fromOffset(0, 32) })
		tab._set(true)
		win:_scramble(win._pageTitle, tab.Name)
		win.CurrentTab = tab
		if opts.Build and not tab._built then
			-- Build = function(tab) ... end : the tab fills itself the first time it is opened
			tab._built = true
			safe(opts.Build, tab)
		end
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
	-- the tab's own header ("text hub") at the top of its page
	if opts.Title or opts.Description then
		tab.HeaderObj = tab:Header({
			Title = opts.Title or tab.Name,
			Text = opts.Description,
			Icon = opts.HeaderIcon or opts.Icon,
		})
	end
	if #win._tabs == 1 then
		tab:Select()
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

local function register(self, o, obj, kind)
	if o.Flag then
		self.Win.Flags[o.Flag] = obj
	end
	obj.Flag = o.Flag
	local row
	for _, c in ipairs(self.Page:GetChildren()) do
		if c:IsA("GuiObject") and c.LayoutOrder == self._n then
			row = c
			break
		end
	end
	obj.Row = row
	if kind then
		self._items = self._items or {}
		table.insert(self._items, { kind = kind, o = o, obj = obj })
	end
	if o.Tooltip and row then
		self.Win:_tip(row, o.Tooltip)
	end
	local winRef = self.Win
	function obj:DependsOn(other, value)
		-- shows this element only while `other:Get() == value` (default true). Example: speed:DependsOn(toggle)
		if value == nil then
			value = true
		end
		local acc, last = 0, nil
		local function check(_, dt)
			acc += dt or 0
			if last ~= nil and acc < 0.1 then
				return
			end
			acc = 0
			local ok, v = pcall(function()
				return other:Get()
			end)
			local show = ok and v == value
			if show ~= last then
				last = show
				if row and row.Parent then
					row.Visible = show
				end
			end
		end
		table.insert(winRef._frame, check)
		check(0, 1)
		return self
	end
	if not obj.SetVisible then
		function obj:SetVisible(v)
			if row then
				row.Visible = v ~= false
			end
		end
	end
	if not obj.Destroy then
		local win = self.Win
		function obj:Destroy()
			if row then
				row:Destroy()
			end
			if o.Flag and win.Flags[o.Flag] == self then
				win.Flags[o.Flag] = nil
			end
		end
	end
	return obj
end

function Tab:Section(text)
	-- Section("Name")  or  Section({ Name = "Name", Collapsible = true, Collapsed = false })
	local o = type(text) == "table" and text or { Name = text }
	local name = tostring(o.Name or "Section")
	self._secs = self._secs or {}
	if not o.Collapsible then
		local l = label(self.Page, name, 11, C.Text, true)
		l.Size = UDim2.new(1, 0, 0, 18)
		l.LayoutOrder = self:_next()
		self.Win:_bind(l, "TextColor3", "Glow")
		table.insert(self._secs, { order = l.LayoutOrder })
		local obj = {}
		function obj:Set(v)
			l.Text = tostring(v)
		end
		return register(self, { Name = name }, obj, "Section")
	end
	local tab = self
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:_next(),
	}, self.Page)
	local l = label(b, "", 11, C.Text, true)
	l.Size = UDim2.fromScale(1, 1)
	self.Win:_bind(l, "TextColor3", "Glow")
	local sec = { order = b.LayoutOrder, collapsed = o.Collapsed == true }
	table.insert(self._secs, sec)
	local obj = {}
	local function render()
		l.Text = (sec.collapsed and ">  " or "v  ") .. name
	end
	function sec.apply()
		local to = math.huge
		for _, s in ipairs(tab._secs) do
			if s.order > sec.order and s.order < to then
				to = s.order
			end
		end
		for _, c in ipairs(tab.Page:GetChildren()) do
			if c:IsA("GuiObject") and c.LayoutOrder > sec.order and c.LayoutOrder < to then
				c.Visible = not sec.collapsed
			end
		end
	end
	function obj:Set(v)
		name = tostring(v)
		render()
	end
	function obj:Collapse(state)
		if state == nil then
			state = not sec.collapsed
		end
		sec.collapsed = state
		render()
		sec.apply()
	end
	function obj:IsCollapsed()
		return sec.collapsed
	end
	b.MouseButton1Click:Connect(function()
		tab.Win:_playClick()
		obj:Collapse()
	end)
	render()
	task.defer(sec.apply) -- rows you add after the section are hidden too when it starts collapsed
	return register(self, { Name = name }, obj, "Section")
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
	return register(self, { Text = text }, obj, "Label")
end

function Tab:Button(o)
	-- Name, Description, Callback: a shiny gradient button with a spinning ring and a click ripple
	-- Risky = true (red), DoubleClick = true (asks "Tap again"), Disabled = true, Tooltip = "text"
	o = o or {}
	if o.Danger then
		o.Risky = true
	end
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
		if o.Risky then
			bg.Color = ColorSequence.new(C.Bad, C.Bad:Lerp(Color3.new(0, 0, 0), 0.5))
		else
			bg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
		end
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
	local disabled = o.Disabled == true
	local armed = false
	local nameText = o.Name or "Button"
	local function look()
		b.BackgroundTransparency = disabled and 0.55 or 0
		lbl.TextTransparency = disabled and 0.5 or 0
	end
	look()
	b.MouseButton1Down:Connect(function()
		tween(sc, 0.08, { Scale = 0.95 })
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	b.MouseButton1Click:Connect(function()
		if disabled then
			return
		end
		if win.SafeMode and (o.Risky or o.Danger) then
			win:Notify({ Title = "Safe mode is on", Text = "Turn it off in Tools to use this button.", Type = "warn" })
			return
		end
		if o.DoubleClick and not armed then
			armed = true
			lbl.Text = "Tap again to confirm"
			task.delay(2, function()
				if armed then
					armed = false
					lbl.Text = nameText
				end
			end)
			return
		end
		armed = false
		lbl.Text = nameText
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
		if o.Danger then -- Danger = true: the screen shakes (Power = 0.2 to 4)
			win:ScreenShake(o.Power or 1.6, o.ShakeTime or 0.8)
		end
		safe(o.Callback)
	end)
	local obj = {}
	function obj:Fire()
		safe(o.Callback)
	end
	function obj:SetName(n)
		nameText = n
		lbl.Text = n
	end
	function obj:SetDescription(d)
		if dl then
			dl.Text = d
		end
	end
	function obj:SetDisabled(v)
		disabled = v == true
		look()
	end
	return register(self, o, obj, "Button")
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
		table.insert(win._keybinds, {
			name = o.Name or "Toggle",
			key = function()
				return o.Key
			end,
			active = function()
				return obj.Value
			end,
		})
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
	return register(self, o, obj, "Toggle")
end

function Tab:Slider(o)
	-- Name, Min, Max, Default, Step, Suffix, Prefix, Flag, Callback(value)
	-- Arrows = true (< > buttons), Log = true (fine steps for small numbers, Min must be above 0)
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
	-- Log = true: the left part of the bar covers small numbers in fine steps (needs Min above 0)
	local useLog = o.Log == true and min > 0 and max > min
	local function toRel(v)
		if useLog then
			return math.log(math.max(v, min) / min) / math.log(max / min)
		end
		return (v - min) / math.max(max - min, 1e-9)
	end
	local function fromRel(r)
		if useLog then
			return min * (max / min) ^ r
		end
		return min + r * (max - min)
	end
	local function render()
		local rel = toRel(obj.Value)
		fill.Size = UDim2.fromScale(rel, 1)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		val.Text = (o.Prefix or "") .. tostring(obj.Value) .. suffix
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
				obj:Set(fromRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1)))
			end
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local w = bar.AbsoluteSize.X
			if w > 0 then
				obj:Set(fromRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1)))
			end
		end
	end)
	if o.Arrows then
		-- small < > buttons for exact one-step changes
		val.Position = UDim2.new(1, -104, 0, 6)
		local function arrow(txt, x, dir)
			local a = new("TextButton", {
				Position = UDim2.new(1, x, 0, 5),
				Size = UDim2.fromOffset(20, 16),
				BorderSizePixel = 0,
				Text = txt,
				TextSize = 11,
				TextColor3 = C.Text,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 4,
			}, row)
			corner(a, 5)
			win:_bind(a, "BackgroundColor3", "Inset")
			a.MouseButton1Click:Connect(function()
				obj:Set(obj.Value + dir * step)
			end)
		end
		arrow("<", -50, -1)
		arrow(">", -28, 1)
	end
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj.Value = snap(o.Default or min)
	render()
	return register(self, o, obj, "Slider")
end

function Tab:Dropdown(o)
	-- Name, Options (a list, or "Players" for everyone in the server), Default, Multi, Flag, Callback(choice) (Multi gives { Speed = true, ... })
	-- Searchable: a search box inside the list (automatic when there are more than 7 options)
	o = o or {}
	local win = self.Win
	local function playerNames()
		local out = {}
		for _, pl in ipairs(Players:GetPlayers()) do
			table.insert(out, pl.Name)
		end
		table.sort(out)
		return out
	end
	local isPlayers = o.Options == "Players"
	local options = isPlayers and playerNames() or o.Options or {}
	local multi = o.Multi == true
	local searchable = o.Searchable == true or (o.Searchable ~= false and #options > 7)
	local HEAD, ITEM = 34, 24
	local SH = searchable and 26 or 0
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
	local items = {}
	local sbox
	if searchable then
		sbox = new("TextBox", {
			Position = UDim2.new(0, 6, 0, HEAD),
			Size = UDim2.new(1, -12, 0, 22),
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = C.Dim,
			TextColor3 = C.Text,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
		}, row)
		corner(sbox, 6)
		win:_bind(sbox, "BackgroundColor3", "Item")
		sbox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = sbox.Text:lower()
			for v, b in pairs(items) do
				b.Visible = q == "" or tostring(v):lower():find(q, 1, true) ~= nil
			end
		end)
	end
	local list = new("ScrollingFrame", {
		Position = UDim2.new(0, 6, 0, HEAD + SH),
		Size = UDim2.new(1, -12, 1, -HEAD - SH - 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

	local obj = { Value = multi and {} or nil, Open = false }
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
		tween(row, 0.18, { Size = UDim2.new(1, 0, 0, open and (HEAD + SH + shown * (ITEM + 2) + 8) or HEAD) })
		arrow.Text = open and "^" or "v"
		if not open and sbox then
			sbox.Text = ""
		end
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
	if isPlayers then
		-- Options = "Players": the list follows who is in the server
		local function again()
			local keep = obj.Value
			obj:Refresh(playerNames())
			if not multi and keep ~= nil and items[keep] then
				obj.Value = keep
				render()
			end
		end
		win._conns[#win._conns + 1] = Players.PlayerAdded:Connect(again)
		win._conns[#win._conns + 1] = Players.PlayerRemoving:Connect(function()
			task.delay(0.1, again)
		end)
	end
	return register(self, o, obj, "Dropdown")
end

function Tab:Input(o)
	-- Name, Default, Placeholder, Clear, Flag, Callback(text)
	-- Numeric = true: only numbers, Callback(number). Min / Max clamp it. Math = true also solves things like 16 * 4.
	o = o or {}
	if o.Math then
		o.Numeric = true
	end
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
	-- Math = true lets you type 16 * 4 or (2 + 3) ^ 2 and get the answer. Plain recursive parser, no loadstring.
	local function evaluate(src)
		local pos, s = 1, tostring(src):gsub("%s+", "")
		local expr
		local function atom()
			local c = s:sub(pos, pos)
			if c == "(" then
				pos += 1
				local v = expr()
				if s:sub(pos, pos) == ")" then
					pos += 1
				end
				return v
			elseif c == "-" then
				pos += 1
				return -(atom() or 0)
			end
			local num = s:match("^%d*%.?%d+", pos) or s:match("^%d+", pos)
			if not num then
				return nil
			end
			pos += #num
			return tonumber(num)
		end
		local function power()
			local a = atom()
			while a and s:sub(pos, pos) == "^" do
				pos += 1
				local b = atom()
				a = b and a ^ b or nil
			end
			return a
		end
		local function term()
			local a = power()
			while a do
				local c = s:sub(pos, pos)
				if c ~= "*" and c ~= "/" and c ~= "%" then
					break
				end
				pos += 1
				local b = power()
				if not b then
					return nil
				end
				a = c == "*" and a * b or (c == "/" and b ~= 0 and a / b) or (c == "%" and b ~= 0 and a % b) or nil
			end
			return a
		end
		function expr()
			local a = term()
			while a do
				local c = s:sub(pos, pos)
				if c ~= "+" and c ~= "-" then
					break
				end
				pos += 1
				local b = term()
				if not b then
					return nil
				end
				a = c == "+" and a + b or a - b
			end
			return a
		end
		local r = expr()
		if pos <= #s then
			return nil
		end
		return r
	end
	local function value()
		if not o.Numeric then
			return box.Text
		end
		local n = (o.Math and evaluate(box.Text)) or tonumber(box.Text) or tonumber(o.Default) or 0
		return math.clamp(n, o.Min or -math.huge, o.Max or math.huge)
	end
	if o.Numeric or o.MaxLength then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = box.Text
			if o.Numeric then
				clean = (clean:gsub(o.Math and "[^%d%.%-%+%*/%^%%%(%)%s]" or "[^%d%.%-]", ""))
			end
			if o.MaxLength and #clean > o.MaxLength then
				clean = clean:sub(1, o.MaxLength)
			end
			if clean ~= box.Text then
				box.Text = clean
			end
		end)
	end
	function obj:Set(v, silent)
		box.Text = tostring(v)
		if not silent then
			safe(o.Callback, value())
		end
	end
	function obj:Get()
		return value()
	end
	box.FocusLost:Connect(function()
		if o.Numeric then
			box.Text = tostring(value())
		end
		safe(o.Callback, value())
		if o.Clear then
			box.Text = ""
		end
	end)
	return register(self, o, obj, "Input")
end

function Tab:Keybind(o)
	-- Name, Default (Enum.KeyCode), Flag, Callback() when the key is pressed, Changed(key) when rebound
	-- Modifier = Enum.KeyCode.LeftShift: the key only counts while that key is held (a combo, like Shift + F)
	-- Mode: "Press" (default, Callback()), "Toggle" (Callback(true/false) each press), "Hold" (Callback(true) down, Callback(false) up)
	o = o or {}
	local mode = o.Mode or "Press"
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
	local obj = { Value = o.Default or Enum.KeyCode.F, Listening = false, State = false }
	table.insert(win._keybinds, {
		name = o.Name or "Keybind",
		key = function()
			return obj.Value
		end,
		active = function()
			return obj.State
		end,
	})
	local function render()
		b.Text = obj.Listening and "press a key..." or ((o.Modifier and (o.Modifier.Name:gsub("^Left", "") .. "+") or "") .. obj.Value.Name)
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
		elseif not processed and i.KeyCode == obj.Value and (not o.Modifier or UIS:IsKeyDown(o.Modifier)) then
			if mode == "Toggle" then
				obj.State = not obj.State
				safe(o.Callback, obj.State)
			elseif mode == "Hold" then
				obj.State = true
				safe(o.Callback, true)
			else
				safe(o.Callback)
			end
		end
	end)
	if mode == "Hold" then
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if obj.State and i.KeyCode == obj.Value then
				obj.State = false
				safe(o.Callback, false)
			end
		end)
	end
	render()
	return register(self, o, obj, "Keybind")
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
	return register(self, o, obj, "Color")
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
	return register(self, o, obj, "Header")
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
	return register(self, o, obj, "Image")
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
	return register(self, o, obj, "Progress")
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
	return register(self, o, obj, "Paragraph")
end

function Tab:Notice(o)
	-- a colored box for warnings and tips. Type = "warn" (yellow), "error" (red), "success" (green) or none. Title, Text
	o = o or {}
	local kinds = { warn = C.Yellow, error = C.Bad, success = C.Green }
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
	local st = new("UIStroke", { Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, row)
	local t = label(row, o.Title or "Note", 11, C.Text, true)
	t.Size = UDim2.new(1, 0, 0, 14)
	t.LayoutOrder = 1
	local b = label(row, o.Text or "", 9, C.Dim, false)
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.LayoutOrder = 2
	local kind = o.Type
	local function paint()
		local c = kinds[kind or ""] or self.Win.Theme.Glow
		st.Color = c
		t.TextColor3 = c
	end
	self.Win:_onTheme(paint)
	local obj = {}
	function obj:Set(title, text)
		t.Text = title or t.Text
		b.Text = text or b.Text
	end
	function obj:SetType(k)
		kind = k
		paint()
	end
	return register(self, o, obj, "Notice")
end

-- ============================================================ range slider (two knobs)
function Tab:RangeSlider(o)
	-- Name, Min, Max, Default = { Low, High }, Step, Suffix, Flag, Callback(low, high). Get() gives { Low =, High = }
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local suffix = o.Suffix or ""
	local row = self:_row(44)
	local name = label(row, o.Name or "Range", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -110, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -108, 0, 6)
	val.Size = UDim2.fromOffset(98, 14)
	local bar = new("Frame", { Position = UDim2.fromOffset(12, 31), Size = UDim2.new(1, -24, 0, 4), BorderSizePixel = 0 }, row)
	corner(bar, 2)
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 2)
	win:_bind(fill, "BackgroundColor3", "Accent")
	local knobs = {}
	for k = 1, 2 do
		local kn = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Text,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, bar)
		corner(kn, 6)
		knobs[k] = kn
	end
	local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(6, 22), Size = UDim2.new(1, -12, 0, 22), ZIndex = 3 }, row)
	local obj = { Low = min, High = max }
	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / step + 0.5) * step
		return math.floor(math.clamp(v, min, max) * 10000 + 0.5) / 10000
	end
	local function render()
		local a = (obj.Low - min) / math.max(max - min, 1e-9)
		local b = (obj.High - min) / math.max(max - min, 1e-9)
		knobs[1].Position = UDim2.new(a, 0, 0.5, 0)
		knobs[2].Position = UDim2.new(b, 0, 0.5, 0)
		fill.Position = UDim2.fromScale(a, 0)
		fill.Size = UDim2.fromScale(math.max(b - a, 0), 1)
		val.Text = tostring(obj.Low) .. suffix .. " - " .. tostring(obj.High) .. suffix
	end
	function obj:Set(v, silent)
		local lo, hi
		if type(v) == "table" then
			lo, hi = v.Low or v[1], v.High or v[2]
		end
		lo, hi = snap(tonumber(lo) or min), snap(tonumber(hi) or max)
		if lo > hi then
			lo, hi = hi, lo
		end
		local changed = lo ~= self.Low or hi ~= self.High
		self.Low, self.High = lo, hi
		render()
		if changed and not silent then
			safe(o.Callback, lo, hi)
		end
	end
	function obj:Get()
		return { Low = self.Low, High = self.High }
	end
	local page = self.Page
	local dragging, which = false, 1
	local function move(x)
		local w = bar.AbsoluteSize.X
		if w <= 0 then
			return
		end
		local v = min + math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1) * (max - min)
		if which == 1 then
			obj:Set({ Low = math.min(v, obj.High), High = obj.High })
		else
			obj:Set({ Low = obj.Low, High = math.max(v, obj.Low) })
		end
	end
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			local w = bar.AbsoluteSize.X
			local v = min + math.clamp((i.Position.X - bar.AbsolutePosition.X) / math.max(w, 1), 0, 1) * (max - min)
			which = math.abs(v - obj.Low) <= math.abs(v - obj.High) and 1 or 2
			move(i.Position.X)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			move(i.Position.X)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj:Set(o.Default or { min, max }, true)
	return register(self, o, obj, "RangeSlider")
end

-- ============================================================ 2D pad (two values with one finger)
function Tab:Pad(o)
	-- Name, Default = { X = 0.5, Y = 0.5 } (0 to 1), Height, Flag, Callback(x, y). Get() gives { X =, Y = }
	o = o or {}
	local win = self.Win
	local H = o.Height or 110
	local row = self:_row(H + 26)
	local name = label(row, o.Name or "Pad", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.5, -10, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(0.5, 0, 0, 5)
	val.Size = UDim2.new(0.5, -10, 0, 14)
	local box = new("TextButton", {
		Position = UDim2.fromOffset(10, 24),
		Size = UDim2.new(1, -20, 0, H),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
	}, row)
	corner(box, 8)
	win:_bind(box, "BackgroundColor3", "Inset")
	local vline = new("Frame", { Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 0.6 }, box)
	local hline = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.6 }, box)
	local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BorderSizePixel = 0, ZIndex = 3 }, box)
	corner(dot, 7)
	win:_bind(dot, "BackgroundColor3", "Glow")
	win:_bind(vline, "BackgroundColor3", "Glow")
	win:_bind(hline, "BackgroundColor3", "Glow")
	local obj = { X = 0.5, Y = 0.5 }
	local function render()
		dot.Position = UDim2.fromScale(obj.X, obj.Y)
		vline.Position = UDim2.new(obj.X, 0, 0, 0)
		hline.Position = UDim2.new(0, 0, obj.Y, 0)
		val.Text = string.format("%.2f , %.2f", obj.X, obj.Y)
	end
	function obj:Set(v, silent)
		v = type(v) == "table" and v or {}
		self.X = math.clamp(tonumber(v.X or v[1]) or 0.5, 0, 1)
		self.Y = math.clamp(tonumber(v.Y or v[2]) or 0.5, 0, 1)
		render()
		if not silent then
			safe(o.Callback, self.X, self.Y)
		end
	end
	function obj:Get()
		return { X = self.X, Y = self.Y }
	end
	local page = self.Page
	local dragging = false
	local function move(p)
		local s = box.AbsoluteSize
		if s.X > 0 and s.Y > 0 then
			obj:Set({ X = (p.X - box.AbsolutePosition.X) / s.X, Y = (p.Y - box.AbsolutePosition.Y) / s.Y })
		end
	end
	box.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			move(i.Position)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			move(i.Position)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj:Set(o.Default or { X = 0.5, Y = 0.5 }, true)
	return register(self, o, obj, "Pad")
end

-- ============================================================ console (a log you can read inside the panel)
local LOG_COLORS = { warn = C.Yellow, error = C.Bad, success = C.Green }
function Tab:Console(o)
	-- Name, Height (120), MaxLines (200). obj:Log(text, "info"|"warn"|"error"|"success"), obj:Clear(), obj:GetText(), obj:Copy()
	o = o or {}
	local win = self.Win
	local H = o.Height or 120
	local row = self:_row(H + 30)
	local name = label(row, o.Name or "Console", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -120, 0, 16)
	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 25),
		Size = UDim2.new(1, -16, 0, H),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	corner(list, 6)
	win:_bind(list, "BackgroundColor3", "Inset")
	new("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, list)
	local obj = { Lines = {}, _n = 0 }
	local function small(txt, x, fn)
		local b = new("TextButton", {
			Position = UDim2.new(1, x, 0, 5),
			Size = UDim2.fromOffset(48, 16),
			BorderSizePixel = 0,
			Text = txt,
			TextSize = 9,
			TextColor3 = C.Text,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, row)
		corner(b, 5)
		win:_bind(b, "BackgroundColor3", "Inset")
		b.MouseButton1Click:Connect(fn)
	end
	function obj:Log(text, kind)
		self._n += 1
		local stamp = os.date("%H:%M:%S")
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = "[" .. stamp .. "] " .. tostring(text),
			TextSize = 9,
			Font = Enum.Font.Code,
			TextColor3 = LOG_COLORS[kind or ""] or C.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = self._n,
		}, list)
		table.insert(self.Lines, { l = l, t = l.Text })
		while #self.Lines > (o.MaxLines or 200) do
			local first = table.remove(self.Lines, 1)
			first.l:Destroy()
		end
		list.CanvasPosition = Vector2.new(0, 1e6)
	end
	function obj:Clear()
		for _, e in ipairs(self.Lines) do
			e.l:Destroy()
		end
		self.Lines = {}
	end
	function obj:GetText()
		local out = {}
		for _, e in ipairs(self.Lines) do
			table.insert(out, e.t)
		end
		return table.concat(out, "\n")
	end
	function obj:Copy()
		return type(setclipboard) == "function" and pcall(setclipboard, self:GetText())
	end
	function obj:Get()
		return self:GetText()
	end
	function obj:Set() end
	small("Clear", -56, function()
		obj:Clear()
	end)
	small("Copy", -108, function()
		local ok = obj:Copy()
		win:Notify({ Title = ok and "Copied" or "Can't copy", Type = ok and "success" or "warn" })
	end)
	win._console = win._console or obj
	return register(self, o, obj, "Console")
end

function Window:Log(text, kind)
	-- writes to the first Console you made. Returns false if there is none.
	if self._console then
		self._console:Log(text, kind)
		return true
	end
	return false
end

-- ============================================================ live graph (FPS, Ping, Memory, frame time or your own number)
function Tab:Graph(o)
	-- Name, Source = "FPS" | "Ping" | "Memory" | "Frame" | function() return number end, Height (60), Samples (30), Interval (0.25), Max, Suffix
	o = o or {}
	local win = self.Win
	local H = o.Height or 60
	local N = math.clamp(o.Samples or 30, 8, 60)
	local source = o.Source or "FPS"
	local row = self:_row(H + 30)
	local name = label(row, o.Name or tostring(type(source) == "string" and source or "Graph"), 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.6, -10, 0, 16)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(0.6, 0, 0, 5)
	val.Size = UDim2.new(0.4, -10, 0, 16)
	local area = new("Frame", { Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -20, 0, H), BorderSizePixel = 0, ClipsDescendants = true }, row)
	corner(area, 6)
	win:_bind(area, "BackgroundColor3", "Inset")
	local bars = {}
	for k = 1, N do
		local b = new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new((k - 1) / N, 1, 1, -1),
			Size = UDim2.new(1 / N, -2, 0, 1),
			BorderSizePixel = 0,
		}, area)
		win:_bind(b, "BackgroundColor3", "Accent")
		bars[k] = b
	end
	local defaults = { FPS = { 120, " fps" }, Ping = { 300, " ms" }, Memory = { 1500, " MB" }, Frame = { 40, " ms" } }
	local top = o.Max or (defaults[source] and defaults[source][1]) or 100
	local suffix = o.Suffix or (defaults[source] and defaults[source][2]) or ""
	local samples = {}
	for k = 1, N do
		samples[k] = 0
	end
	local fpsAvg = 60
	local function read(dt)
		if type(source) == "function" then
			local ok, v = pcall(source)
			return ok and tonumber(v) or 0
		elseif source == "FPS" then
			fpsAvg = fpsAvg * 0.7 + (1 / math.max(dt, 1e-3)) * 0.3
			return math.floor(fpsAvg + 0.5)
		elseif source == "Frame" then
			return math.floor(dt * 10000 + 0.5) / 10
		elseif source == "Ping" then
			local ok, v = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return ok and math.floor((tonumber(v) or 0) + 0.5) or 0
		elseif source == "Memory" then
			local ok, v = pcall(function()
				return game:GetService("Stats"):GetTotalMemoryUsageMb()
			end)
			return ok and math.floor((tonumber(v) or 0) + 0.5) or 0
		end
		return 0
	end
	local acc, dtSum, cnt = 0, 0, 0
	local function draw()
		local peak = top
		for _, v in ipairs(samples) do
			if v > peak then
				peak = v
			end
		end
		for k = 1, N do
			bars[k].Size = UDim2.new(1 / N, -2, math.clamp(samples[k] / peak, 0.02, 1), 0)
		end
		val.Text = tostring(samples[N]) .. suffix
	end
	local obj = {}
	function obj:Push(v)
		table.remove(samples, 1)
		table.insert(samples, tonumber(v) or 0)
		draw()
	end
	function obj:Get()
		return samples[N]
	end
	function obj:Set() end
	table.insert(win._frame, function(_, dt)
		acc += dt
		dtSum += dt
		cnt += 1
		if acc >= (o.Interval or 0.25) then
			local avg = dtSum / math.max(cnt, 1)
			acc, dtSum, cnt = 0, 0, 0
			if win.Open and self.Page.Visible and row.Visible then
				obj:Push(read(avg))
			end
		end
	end)
	draw()
	return register(self, o, obj, "Graph")
end

-- ============================================================ code box (type or paste a script and run it)
function Tab:CodeBox(o)
	-- Name, Height (110), Default, Placeholder, RunText ("Run"), Callback(code). Without a Callback it runs the code with loadstring.
	o = o or {}
	local win = self.Win
	local H = o.Height or 110
	local row = self:_row(H + 66)
	local name = label(row, o.Name or "Code", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.6, -10, 0, 16)
	local count = label(row, "1 line", 9, C.Dim, false)
	count.TextXAlignment = Enum.TextXAlignment.Right
	count.Position = UDim2.new(0.6, 0, 0, 5)
	count.Size = UDim2.new(0.4, -10, 0, 16)
	local box = new("TextBox", {
		Position = UDim2.fromOffset(8, 25),
		Size = UDim2.new(1, -16, 0, H),
		BorderSizePixel = 0,
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "-- type or paste Lua here",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = false,
		MultiLine = true,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
	}, row)
	corner(box, 6)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) }, box)
	win:_bind(box, "BackgroundColor3", "Inset")
	local function lines()
		local _, n = box.Text:gsub("\n", "")
		count.Text = (n + 1) .. (n == 0 and " line" or " lines")
	end
	box:GetPropertyChangedSignal("Text"):Connect(lines)
	lines()
	local obj = {}
	function obj:Get()
		return box.Text
	end
	function obj:Set(v)
		box.Text = tostring(v)
	end
	function obj:Run()
		local code = box.Text
		if o.Callback then
			safe(o.Callback, code)
			return
		end
		if type(loadstring) ~= "function" then
			win:Notify({ Title = "Can't run", Text = "This executor has no loadstring.", Type = "error" })
			return
		end
		local fn, err = loadstring(code)
		if not fn then
			win:Notify({ Title = "Syntax error", Text = tostring(err), Type = "error" })
			win:Log(tostring(err), "error")
			return
		end
		local ok, e = pcall(fn)
		win:Notify({ Title = ok and "Ran" or "Error", Text = ok and "The code ran without errors." or tostring(e), Type = ok and "success" or "error" })
		win:Log(ok and "ran ok" or tostring(e), ok and "success" or "error")
	end
	local function btn(txt, x, w, accent, fn)
		local b = new("TextButton", {
			Position = UDim2.new(x, accent and 8 or 4, 0, H + 31),
			Size = UDim2.new(w, -12, 0, 26),
			BorderSizePixel = 0,
			Text = txt,
			TextSize = 11,
			TextColor3 = C.Text,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, row)
		corner(b, 7)
		win:_bind(b, "BackgroundColor3", accent and "Accent" or "Inset")
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			fn()
		end)
	end
	btn(o.RunText or "Run", 0, 0.5, true, function()
		obj:Run()
	end)
	btn("Clear", 0.5, 0.5, false, function()
		box.Text = ""
	end)
	return register(self, o, obj, "CodeBox")
end

-- ============================================================ feed (text that is loaded from a web page, like announcements)
function Tab:Feed(o)
	-- Title, Url (a plain text page, like a raw GitHub file), Text (shown while loading or if it fails), MaxChars (800). obj:Refresh()
	o = o or {}
	local obj = self:Paragraph({ Title = o.Title or "News", Text = o.Text or "Loading..." })
	function obj:Refresh()
		if not o.Url then
			return
		end
		task.spawn(function()
			local ok, body = pcall(function()
				return game:HttpGet(o.Url)
			end)
			if ok and type(body) == "string" and body ~= "" then
				body = body:gsub("\r", "")
				if #body > (o.MaxChars or 800) then
					body = body:sub(1, o.MaxChars or 800) .. "..."
				end
				obj:Set(nil, body)
			else
				obj:Set(nil, o.Text or "Could not load the news.")
			end
		end)
	end
	obj:Refresh()
	return obj
end

-- ============================================================ chat (messages, typing text, quick replies, input box)
local function chatRich(s)
	-- a little markdown: **bold**, `code`, "- " bullets, "# " headings. Everything else is escaped.
	s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>")
	s = s:gsub("`([^`\n]+)`", '<font face="Code" color="#ffb59e">%1</font>')
	s = s:gsub("^%- ", "• "):gsub("\n%- ", "\n• "):gsub("\n%* ", "\n• ")
	s = s:gsub("\n#+ ([^\n]+)", "\n<b>%1</b>"):gsub("^#+ ([^\n]+)", "<b>%1</b>")
	return s
end

local function chatSegments(text)
	local out, pos = {}, 1
	while true do
		local a, b, _, code = text:find("```(%w*)\n?(.-)```", pos)
		if not a then
			break
		end
		if a > pos then
			table.insert(out, { false, text:sub(pos, a - 1) })
		end
		table.insert(out, { true, (code:gsub("\n+$", "")) })
		pos = b + 1
	end
	if pos <= #text then
		table.insert(out, { false, text:sub(pos) })
	end
	local clean = {}
	for _, seg in ipairs(out) do
		local t = seg[2]
		if not seg[1] then
			t = t:gsub("^%s+", ""):gsub("%s+$", "")
		end
		if t ~= "" then
			table.insert(clean, { seg[1], t })
		end
	end
	return clean
end

function Tab:Chat(o)
	-- Name (the bot's name), Height (260), Placeholder, MaxMessages (60), Chips = true,
	-- OnSend(text, chat) when the player sends something, Actions = { { Name = "Speak", Callback = function(text) end } }
	-- chat:Add("user" | "bot" | "system", text, { Instant = true }) -> message, chat:SetStatus(text), chat:SetChips({...}),
	-- chat:SetBusy(bool), chat:Submit(text), chat:Clear(), chat:GetMessages()
	o = o or {}
	local win = self.Win
	local H = o.Height or 260
	local botName = o.Name or "Bot"
	local row = self:_row(H)
	local INPUT, CHIPS, STATUS = 34, 26, 16
	local reserve = 6 + INPUT + 6 + CHIPS + 2 + STATUS + 4
	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -reserve - 6),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	corner(list, 8)
	win:_bind(list, "BackgroundColor3", "Inset")
	win:_bind(list, "ScrollBarImageColor3", "Accent")
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, list)

	local statusL = label(row, "", 10, C.Dim, true)
	statusL.Position = UDim2.new(0, 10, 1, -(6 + INPUT + 6 + CHIPS + 2 + STATUS))
	statusL.Size = UDim2.new(1, -20, 0, STATUS)
	win:_bind(statusL, "TextColor3", "Glow")

	local chipBox = new("ScrollingFrame", {
		Position = UDim2.new(0, 6, 1, -(6 + INPUT + 6 + CHIPS)),
		Size = UDim2.new(1, -12, 0, CHIPS),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
	}, row)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, chipBox)

	local box = new("TextBox", {
		Position = UDim2.new(0, 6, 1, -(6 + INPUT)),
		Size = UDim2.new(1, -78, 0, INPUT),
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = o.Placeholder or "Type a message...",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 9)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, box)
	win:_bind(box, "BackgroundColor3", "Inset")
	local send = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 1, -(6 + INPUT)),
		Size = UDim2.fromOffset(64, INPUT),
		BorderSizePixel = 0,
		Text = "Send",
		TextColor3 = C.White,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	corner(send, 9)
	local sg = new("UIGradient", {}, send)
	win:_onTheme(function(t)
		sg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
	end)

	local obj = { Messages = {}, Busy = false }
	local n = 0
	local function toBottom()
		list.CanvasPosition = Vector2.new(0, 1e7)
	end

	-- one message bubble. role: "user" (right), "bot" (left), "system" (centered, small)
	function obj:Add(role, text, opt)
		opt = opt or {}
		text = tostring(text or "")
		n += 1
		local isUser, isSys = role == "user", role == "system"
		local wrap = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = n,
		}, list)
		new("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = isUser and Enum.HorizontalAlignment.Right or (isSys and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left),
		}, wrap)
		if not isSys then
			local who = label(wrap, isUser and (opt.Name or "You") or (opt.Name or botName), 8, C.Dim, true)
			who.Size = UDim2.new(1, 0, 0, 11)
			who.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
			who.LayoutOrder = 1
		end
		local bub = new("Frame", {
			Size = UDim2.new(isSys and 1 or 0.9, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			BackgroundTransparency = isSys and 1 or 0,
			LayoutOrder = 2,
		}, wrap)
		corner(bub, 10)
		if isUser then
			win:_bind(bub, "BackgroundColor3", "Accent")
		else
			win:_bind(bub, "BackgroundColor3", "Item")
		end
		new("UIPadding", {
			PaddingTop = UDim.new(0, isSys and 0 or 6),
			PaddingBottom = UDim.new(0, isSys and 0 or 7),
			PaddingLeft = UDim.new(0, isSys and 0 or 9),
			PaddingRight = UDim.new(0, isSys and 0 or 9),
		}, bub)
		new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, bub)

		local msg = { Role = role, Text = text, Frame = wrap }
		local reveal = {}
		local function build(t)
			for _, c in ipairs(bub:GetChildren()) do
				if c:IsA("GuiObject") then
					c:Destroy()
				end
			end
			table.clear(reveal)
			local k = 0
			for _, seg in ipairs(isUser and { { false, t } } or chatSegments(t)) do
				k += 1
				if seg[1] then
					local cf = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = k }, bub)
					corner(cf, 7)
					win:_bind(cf, "BackgroundColor3", "Inset")
					new("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, cf)
					new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, cf)
					local top = new("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1 }, cf)
					local tag = label(top, "lua", 8, C.Dim, true)
					tag.Size = UDim2.new(0.5, 0, 1, 0)
					local cp = new("TextButton", {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.fromOffset(46, 16),
						BorderSizePixel = 0,
						Text = "Copy",
						TextSize = 9,
						TextColor3 = C.Text,
						Font = Enum.Font.GothamBold,
						AutoButtonColor = false,
					}, top)
					corner(cp, 5)
					win:_bind(cp, "BackgroundColor3", "Item")
					cp.MouseButton1Click:Connect(function()
						local ok = type(setclipboard) == "function" and pcall(setclipboard, seg[2])
						cp.Text = ok and "Copied" or "No clip"
						task.delay(1.4, function()
							if cp.Parent then
								cp.Text = "Copy"
							end
						end)
					end)
					local cl = new("TextLabel", {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Text = seg[2],
						TextSize = 9,
						Font = Enum.Font.Code,
						TextColor3 = C.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextWrapped = true,
						LayoutOrder = 2,
					}, cf)
					table.insert(reveal, { obj = cf, code = true, len = #seg[2] })
				else
					local tl = new("TextLabel", {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						RichText = true,
						Text = isUser and (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) or chatRich(seg[2]),
						TextSize = isSys and 9 or 11,
						Font = Enum.Font.Gotham,
						TextColor3 = isSys and C.Dim or (isUser and C.White or C.Text),
						TextXAlignment = isSys and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
						TextWrapped = true,
						LayoutOrder = k,
					}, bub)
					table.insert(reveal, { obj = tl, code = false, len = #(seg[2]:gsub("[%*`#]", "")) })
				end
			end
		end
		build(text)
		function msg:Set(t)
			self.Text = tostring(t)
			build(self.Text)
			toBottom()
		end
		-- the typing effect: the text appears quickly, a few seconds at most
		function msg:Type(speed)
			local total = 0
			for _, r in ipairs(reveal) do
				total += r.len
			end
			if total == 0 then
				return
			end
			local cps = math.max(speed or 70, total / 2.4)
			local shown, done = 0, false
			local labels = {}
			for _, r in ipairs(reveal) do
				if r.code then
					r.obj.Visible = false
				else
					r.obj.MaxVisibleGraphemes = 0
				end
				table.insert(labels, r)
			end
			local fn
			fn = function(_, dt)
				shown += cps * dt
				local left = shown
				for _, r in ipairs(labels) do
					if r.code then
						r.obj.Visible = left > 0
						left -= r.len
					else
						local take = math.clamp(left, 0, r.len)
						r.obj.MaxVisibleGraphemes = take >= r.len and -1 or math.floor(take)
						left -= r.len
					end
				end
				toBottom()
				if shown >= total or not wrap.Parent then
					for _, r in ipairs(labels) do
						if r.code then
							r.obj.Visible = true
						else
							r.obj.MaxVisibleGraphemes = -1
						end
					end
					local at = table.find(win._frame, fn)
					if at then
						table.remove(win._frame, at)
					end
				end
			end
			table.insert(win._frame, fn)
		end
		-- small buttons under a bot message: Copy + your own (Speak ...)
		if role == "bot" and opt.Actions ~= false then
			local acts = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 3 }, wrap)
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, acts)
			local function mini(txt, order, fn)
				local b = new("TextButton", {
					Size = UDim2.fromOffset(#txt * 5.4 + 16, 16),
					BorderSizePixel = 0,
					Text = txt,
					TextSize = 8,
					TextColor3 = C.Dim,
					Font = Enum.Font.GothamBold,
					AutoButtonColor = false,
					LayoutOrder = order,
				}, acts)
				corner(b, 8)
				win:_bind(b, "BackgroundColor3", "Item")
				b.MouseButton1Click:Connect(function()
					fn(b)
				end)
			end
			mini("Copy", 1, function(b)
				local ok = type(setclipboard) == "function" and pcall(setclipboard, msg.Text)
				b.Text = ok and "Copied" or "No clip"
				task.delay(1.4, function()
					if b.Parent then
						b.Text = "Copy"
					end
				end)
			end)
			for i, a in ipairs(o.Actions or {}) do
				mini(tostring(a.Name), 1 + i, function()
					safe(a.Callback, msg.Text, msg)
				end)
			end
		end
		table.insert(obj.Messages, msg)
		while #obj.Messages > (o.MaxMessages or 60) do
			local old = table.remove(obj.Messages, 1)
			old.Frame:Destroy()
		end
		toBottom()
		if role == "bot" and not opt.Instant and opt.Type ~= false then
			msg:Type(opt.Speed)
		end
		return msg
	end

	-- the line above the chips: "Thinking..." with moving dots (SetStatus(nil) hides it)
	local statusText, statusT0 = nil, 0
	function obj:SetStatus(text)
		statusText = text
		statusT0 = os.clock()
		statusL.Text = text and tostring(text) or ""
	end
	table.insert(win._frame, function(now)
		if statusText then
			local dots = string.rep(".", math.floor((now - statusT0) * 3) % 4)
			statusL.Text = statusText .. dots
			statusL.TextTransparency = 0.15 + 0.25 * (0.5 + 0.5 * math.sin(now * 5))
		elseif statusL.TextTransparency ~= 0 then
			statusL.TextTransparency = 0
		end
	end)

	function obj:SetChips(chips)
		for _, c in ipairs(chipBox:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		for i, text in ipairs(chips or {}) do
			if i > 8 then
				break
			end
			local b = new("TextButton", {
				Size = UDim2.fromOffset(0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				BorderSizePixel = 0,
				Text = tostring(text),
				TextSize = 10,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				LayoutOrder = i,
			}, chipBox)
			corner(b, 11)
			new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, b)
			win:_bind(b, "BackgroundColor3", "Item")
			win:_bind(b, "TextColor3", "Glow")
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				obj:Submit(tostring(text))
			end)
		end
		chipBox.CanvasPosition = Vector2.new(0, 0)
	end

	function obj:SetBusy(v)
		self.Busy = v == true
		send.Text = self.Busy and "..." or "Send"
		send.BackgroundTransparency = self.Busy and 0.5 or 0
	end

	function obj:Submit(text)
		text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return false
		end
		if self.Busy and not o.AllowWhileBusy then
			win:Notify({ Title = botName, Text = "One moment, I'm still on your last message.", Type = "warn", Duration = 2 })
			return false
		end
		self:Add("user", text)
		safe(o.OnSend, text, self)
		return true
	end

	function obj:Clear()
		for _, m in ipairs(self.Messages) do
			m.Frame:Destroy()
		end
		self.Messages = {}
	end
	function obj:GetMessages()
		return self.Messages
	end
	function obj:Get()
		return #self.Messages
	end
	function obj:Set() end
	function obj:Focus()
		box:CaptureFocus()
	end

	local function fromBox()
		local t = box.Text
		if t:gsub("%s", "") ~= "" and obj:Submit(t) then
			box.Text = ""
		end
	end
	send.MouseButton1Click:Connect(function()
		win:_playClick()
		fromBox()
	end)
	box.FocusLost:Connect(function(enter)
		if enter then
			fromBox()
		end
	end)
	return register(self, o, obj, "Chat")
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
	return register(self, o, obj, "Choice")
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
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(b, 7)
		local g = new("UIGradient", { Rotation = 90 }, b)
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = txt,
			TextColor3 = C.White,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 2,
		}, b)
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
	return register(self, o, obj, "Cycle")
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
	win._barOpts = o

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
		if v.Low ~= nil and v.High ~= nil then
			return { _t = "r", lo = v.Low, hi = v.High }
		elseif v.X ~= nil and v.Y ~= nil then
			return { _t = "p", x = v.X, y = v.Y }
		end
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
		elseif v._t == "r" then
			return { Low = v.lo, High = v.hi }
		elseif v._t == "p" then
			return { X = v.x, Y = v.y }
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

function Window:_collect()
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
	return data
end

function Window:Save(file)
	-- saves every element that has a Flag. Needs an executor with writefile. Returns true on success.
	if type(writefile) ~= "function" then
		return false
	end
	local data = self:_collect()
	local ok = pcall(function()
		writefile(self:_file(file), game:GetService("HttpService"):JSONEncode(data))
	end)
	return ok
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64encode(s)
	local out = {}
	for i = 1, #s, 3 do
		local a, b, c = s:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1, c2, c3, c4 = math.floor(n / 262144) % 64, math.floor(n / 4096) % 64, math.floor(n / 64) % 64, n % 64
		out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1) .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
	end
	return table.concat(out)
end
local function b64decode(s)
	s = s:gsub("[^%w%+/=]", "")
	local out = {}
	for i = 1, #s, 4 do
		local n, pad = 0, 0
		for k = 0, 3 do
			local ch = s:sub(i + k, i + k)
			if ch == "=" or ch == "" then
				n = n * 64
				pad += 1
			else
				local at = B64:find(ch, 1, true)
				if not at then
					return nil
				end
				n = n * 64 + (at - 1)
			end
		end
		local b1, b2, b3 = math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
		out[#out + 1] = string.char(b1) .. (pad < 2 and string.char(b2) or "") .. (pad < 1 and string.char(b3) or "")
	end
	return table.concat(out)
end

function Window:Export()
	-- every Flag as one short line of text you can share ("RBL1:..."). Window:Import(text) puts it back.
	return "RBL1:" .. b64encode(game:GetService("HttpService"):JSONEncode(self:_collect()))
end

function Window:ExportTheme()
	-- just the look: "RBLT:#RRGGBB"
	return "RBLT:" .. toHex(self.Theme.Accent)
end

function Window:Import(text)
	text = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
	if text:sub(1, 5) == "RBLT:" then
		local c = fromHex(text:sub(6))
		if c then
			self:SetAccent(c)
			return true
		end
		return false
	end
	if text:sub(1, 5) == "RBL1:" then
		text = b64decode(text:sub(6)) or ""
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(text)
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	self:_apply(data)
	return true
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
	self:_apply(data)
	return true
end

function Window:_apply(data)
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

-- ============================================================ auto-save, avatar colors, update check, code export
function Window:AutoSave(seconds)
	-- keeps a backup file of all your settings every N seconds. AutoSave(nil) or AutoSave(0) stops it.
	self._autoTok = (self._autoTok or 0) + 1
	local mine = self._autoTok
	seconds = tonumber(seconds)
	self._autoOn = seconds ~= nil and seconds > 0
	if not self._autoOn then
		return
	end
	task.spawn(function()
		while not self._dead and self._autoTok == mine do
			task.wait(math.max(seconds, 5))
			if self._dead or self._autoTok ~= mine then
				return
			end
			self:Save(self:_base() .. "_autosave.json")
		end
	end)
end

function Window:RestoreSnapshot()
	-- brings back the last auto-saved settings
	return self:Load(self:_base() .. "_autosave.json")
end

function Window:ThemeFromAvatar()
	-- makes the accent color from the colors of your avatar. Returns the color, or nil if it can't tell.
	local lp = Players.LocalPlayer
	local ch = lp and lp.Character
	local bc = ch and ch:FindFirstChildOfClass("BodyColors")
	if not bc then
		return nil
	end
	local best, bestS = nil, -1
	for _, prop in ipairs({ "TorsoColor3", "HeadColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3" }) do
		local c = bc[prop]
		if typeof(c) == "Color3" then
			local _, s = c:ToHSV()
			if s > bestS then
				best, bestS = c, s
			end
		end
	end
	if not best then
		return nil
	end
	local h, s, v = best:ToHSV()
	best = Color3.fromHSV(h, math.max(s, 0.45), math.max(v, 0.75))
	self:SetAccent(best)
	return best
end

local function newer(remote, current)
	local function parts(v)
		local t = {}
		for n in tostring(v):gmatch("%d+") do
			table.insert(t, tonumber(n))
		end
		return t
	end
	local a, b = parts(remote), parts(current)
	for i = 1, math.max(#a, #b) do
		local x, y = a[i] or 0, b[i] or 0
		if x ~= y then
			return x > y
		end
	end
	return false
end

function Window:CheckUpdate(o)
	-- Url (a raw page with  Version = "1.2.3"  in it), Current (your version), Silent = true to skip the notification.
	-- Returns isNewer, remoteVersion (or nil, nil if it could not check).
	o = o or {}
	local ok, body = pcall(function()
		return game:HttpGet(o.Url or RebelUI.SourceUrl)
	end)
	if not ok or type(body) ~= "string" then
		if not o.Silent then
			self:Notify({ Title = "Update check", Text = "Could not reach the server.", Type = "warn" })
		end
		return nil, nil
	end
	local remote = body:match('Version%s*=%s*"([%d%.]+)"')
	if not remote then
		return nil, nil
	end
	local isNew = newer(remote, o.Current or RebelUI.Version)
	if not o.Silent then
		self:Notify({
			Title = isNew and "Update available" or "Up to date",
			Text = isNew and ("Version " .. remote .. " is out.") or ("You have the newest version (" .. remote .. ")."),
			Type = isNew and "warn" or "success",
		})
	end
	return isNew, remote
end

local function lit(v)
	local t = typeof(v)
	if t == "string" then
		return string.format("%q", v)
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Color3" then
		return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
	elseif t == "EnumItem" then
		local s = tostring(v)
		return s:find("^Enum%.") and s or ("Enum.KeyCode." .. tostring(v.Name))
	elseif t == "table" then
		local parts = {}
		for _, x in ipairs(v) do
			local s = lit(x)
			if not s then
				return nil
			end
			table.insert(parts, s)
		end
		if #parts == 0 then
			return nil
		end
		return "{ " .. table.concat(parts, ", ") .. " }"
	end
	return nil
end

local STATEFUL = { Toggle = true, Slider = true, Dropdown = true, Input = true, Keybind = true, Color = true, Choice = true, Cycle = true }

function Window:GenerateCode()
	-- writes the Lua that builds this panel as it is now (names, options, current values). Callbacks are left empty.
	local lines = {
		'local UI = loadstring(game:HttpGet("' .. RebelUI.SourceUrl .. '"))()',
		"",
		"local Win = UI:CreateWindow({",
		"\tTitle = " .. lit(self.TitleText) .. ",",
	}
	if THEMES[self.ThemeName] then
		table.insert(lines, "\tTheme = " .. lit(self.ThemeName) .. ",")
	end
	table.insert(lines, "})")
	local skip = { Callback = true, Changed = true, Flag = false }
	for ti, tab in ipairs(self._tabs) do
		table.insert(lines, "")
		table.insert(lines, "local Tab" .. ti .. " = Win:CreateTab({ Name = " .. lit(tab.Name) .. " })")
		for _, it in ipairs(tab._items or {}) do
			local o, kind = it.o, it.kind
			if kind == "Section" and not o.Collapsible then
				table.insert(lines, "Tab" .. ti .. ":Section(" .. lit(o.Name or "Section") .. ")")
			elseif kind == "Label" then
				table.insert(lines, "Tab" .. ti .. ":Label(" .. lit(o.Text or "") .. ")")
			else
				local keys = {}
				for k, v in pairs(o) do
					if not skip[k] and type(v) ~= "function" and lit(v) and not (k == "Default" and STATEFUL[kind]) then
						table.insert(keys, k)
					end
				end
				if STATEFUL[kind] and it.obj.Get then
					local okg, cur = pcall(function()
						return it.obj:Get()
					end)
					if okg and cur ~= nil then
						if typeof(cur) == "table" and next(cur) ~= nil and type(next(cur)) ~= "number" then
							local pick = {}
							for k, on in pairs(cur) do
								if on == true then
									table.insert(pick, k)
								end
							end
							table.sort(pick)
							cur = pick
						end
						if lit(cur) then
							o = setmetatable({ Default = cur }, { __index = o })
							table.insert(keys, "Default")
						end
					end
				end
				table.sort(keys)
				local parts = {}
				for _, k in ipairs(keys) do
					table.insert(parts, k .. " = " .. lit(o[k]))
				end
				if type(it.o.Callback) == "function" then
					table.insert(parts, "Callback = function() end")
				end
				table.insert(lines, "Tab" .. ti .. ":" .. kind .. "({ " .. table.concat(parts, ", ") .. " })")
			end
		end
	end
	return table.concat(lines, "\n")
end

-- ============================================================ named profiles
-- Several saved setups per script ("Legit", "Rage", ...). Plain files, no folders needed.
local function cleanName(s)
	s = tostring(s or ""):gsub("[^%w _%-]", ""):gsub("^%s+", ""):gsub("%s+$", "")
	return s
end

function Window:_base()
	local clean = tostring(self.TitleText):gsub("[^%w]", "")
	return "RebelUI_" .. (clean == "" and "Script" or clean)
end

function Window:_readIndex()
	local idx = { names = {} }
	if type(readfile) == "function" and type(isfile) == "function" then
		local path = self:_base() .. "_profiles.json"
		local ok, data = pcall(function()
			if isfile(path) then
				return game:GetService("HttpService"):JSONDecode(readfile(path))
			end
		end)
		if ok and type(data) == "table" then
			idx.auto = type(data.auto) == "string" and data.auto or nil
			if type(data.names) == "table" then
				for _, n in ipairs(data.names) do
					if type(n) == "string" then
						table.insert(idx.names, n)
					end
				end
			end
		end
	end
	return idx
end

function Window:_writeIndex(idx)
	if type(writefile) ~= "function" then
		return false
	end
	return (pcall(function()
		writefile(self:_base() .. "_profiles.json", game:GetService("HttpService"):JSONEncode(idx))
	end))
end

function Window:_pfile(name)
	return self:_base() .. "_profile_" .. name .. ".json"
end

function Window:ListProfiles()
	local names = self:_readIndex().names
	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)
	return names
end

function Window:SaveProfile(name)
	name = cleanName(name)
	if name == "" then
		return false, "Type a name first."
	end
	if not self:Save(self:_pfile(name)) then
		return false, "This executor can't write files."
	end
	local idx = self:_readIndex()
	if not table.find(idx.names, name) then
		table.insert(idx.names, name)
	end
	self:_writeIndex(idx)
	return true
end

function Window:LoadProfile(name)
	name = cleanName(name)
	if name == "" then
		return false, "Pick a profile first."
	end
	if not self:Load(self:_pfile(name)) then
		return false, "That profile was not found."
	end
	return true
end

function Window:DeleteProfile(name)
	name = cleanName(name)
	local idx = self:_readIndex()
	local at = table.find(idx.names, name)
	if not at then
		return false, "That profile was not found."
	end
	table.remove(idx.names, at)
	if idx.auto == name then
		idx.auto = nil
	end
	pcall(function()
		if type(delfile) == "function" then
			delfile(self:_pfile(name))
		end
	end)
	self:_writeIndex(idx)
	return true
end

function Window:SetAutoLoad(name)
	-- the profile that AutoLoad() applies. nil turns it off.
	local idx = self:_readIndex()
	idx.auto = name and cleanName(name) or nil
	if idx.auto == "" then
		idx.auto = nil
	end
	self:_writeIndex(idx)
	return idx.auto
end

function Window:AutoLoad()
	-- call once after your tabs exist. Applies the auto-load profile (or the plain saved file) if there is one.
	local idx = self:_readIndex()
	if idx.auto and self:Load(self:_pfile(idx.auto)) then
		return idx.auto
	end
	return nil
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
	tab:Button({
		Name = "Match my avatar colors",
		Description = "Makes the accent from your character",
		Callback = function()
			local c = win:ThemeFromAvatar()
			win:Notify({
				Title = c and "Theme changed" or "Can't tell",
				Text = c and "The panel now matches your avatar." or "Your character has no body colors yet.",
				Type = c and "success" or "warn",
			})
		end,
	})
	tab:Toggle({
		Name = "Rainbow rings",
		Description = "Every glowing edge turns rainbow",
		Default = win._rainbow == true,
		Flag = "__rainbow",
		Callback = function(on)
			win:SetRainbow(on)
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
		Name = "Opacity",
		Description = "100% = solid panel",
		Min = 30,
		Max = 100,
		Default = win.Opacity,
		Suffix = "%",
		Flag = "__opacity",
		Callback = function(v)
			win:SetOpacity(v)
		end,
	})
	if o.Bar then
		tab:BarSettings(o.Bar)
	end
	tab:Section("Open button and game assistant")
	tab:Cycle({
		Name = "Open button",
		Description = "Round logo, square logo or the top bar",
		Options = { "Circle", "Square", "Bar" },
		Default = win.TriggerStyle or (win._hasBar and "Bar" or "Circle"),
		Flag = "__trigger",
		Callback = function(v)
			win:SetTrigger(v)
		end,
	})
	local function hud()
		return win.HUD or win:GameAssistant(o.Assistant or { Logo = o.Icon or win._icon })
	end
	tab:Button({
		Name = "Open full game assistance",
		Description = "Full-screen HUD: players, health, stats, crosshair, your profile",
		Callback = function()
			local h = hud()
			win:Toggle(false)
			h:Open()
		end,
	})
	tab:Cycle({
		Name = "HUD colors",
		Description = "Rainbow glow, your theme or one color",
		Options = RebelUI.HudColors,
		Default = "Rainbow",
		Flag = "__hudcolor",
		Callback = function(v)
			hud():SetColor(v)
		end,
	})
	tab:Cycle({
		Name = "Crosshair",
		Options = RebelUI.Crosshairs,
		Default = "Cross",
		Flag = "__hudcross",
		Callback = function(v)
			hud():SetCrosshair(v)
		end,
	})
	tab:Toggle({
		Name = "Crosshair on screen",
		Description = "Keep the crosshair in the middle of your game view",
		Flag = "__hudingame",
		Callback = function(on)
			hud():CrosshairInGame(on)
		end,
	})
	tab:Section("Animations and effects")
	tab:Cycle({
		Name = "Open animation",
		Description = "How the panel appears",
		Options = RebelUI.OpenAnimations,
		Default = win.OpenAnim,
		Flag = "__openanim",
		Callback = function(v)
			win:SetOpenAnimation(v)
			win:Toggle(false)
			task.delay(0.35, function()
				win:Toggle(true)
			end)
		end,
	})
	tab:Slider({
		Name = "Animation speed",
		Min = 0.5,
		Max = 2.5,
		Default = win.AnimSpeed,
		Step = 0.1,
		Suffix = "x",
		Flag = "__animspeed",
		Callback = function(v)
			win:SetAnimSpeed(v)
		end,
	})
	tab:Toggle({ Name = "Click ripples", Description = "A glow ring where you tap", Default = true, Flag = "__fxripple", Callback = function(on)
		win:SetFx({ Ripple = on })
	end })
	tab:Toggle({ Name = "Finger glow", Description = "A soft light follows your finger or mouse", Default = false, Flag = "__fxglow", Callback = function(on)
		win:SetFx({ Glow = on })
	end })
	tab:Toggle({ Name = "Scan lines", Description = "A slow sweep over the panel", Default = false, Flag = "__fxscan", Callback = function(on)
		win:SetFx({ Scan = on })
	end })
	tab:Toggle({ Name = "Breathing border", Description = "The edge glows in and out", Default = true, Flag = "__fxbreathe", Callback = function(on)
		win:SetFx({ Breathe = on })
	end })
	tab:Toggle({ Name = "Reduce motion", Description = "Turns the extra animations off (easier on weak phones)", Default = win.ReduceMotion, Flag = "__reduce", Callback = function(on)
		win:SetReduceMotion(on)
	end })
	tab:Button({ Name = "Test confetti", Callback = function()
		win:Confetti(40)
	end })
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
	tab:Keybind({
		Name = "Open / close key",
		Default = win.ToggleKey,
		Flag = "__togglekey",
		Changed = function(k)
			win:SetToggleKey(k)
			win:Notify({ Title = "Key set", Text = "Press " .. k.Name .. " to open or close the panel." })
		end,
	})
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
	tab:Section("Profiles")
	local nameBox, picker
	nameBox = tab:Input({
		Name = "Profile name",
		Placeholder = "e.g. Legit",
	})
	picker = tab:Dropdown({
		Name = "Saved profiles",
		Options = win:ListProfiles(),
		Callback = function(n)
			if type(n) == "string" then
				nameBox:Set(n, true)
			end
		end,
	})
	local function result(ok, why, okText, okTitle)
		win:Notify({
			Title = ok and okTitle or "Profile",
			Text = ok and okText or why,
			Type = ok and "success" or "warn",
		})
		picker:Refresh(win:ListProfiles())
	end
	tab:Button({
		Name = "Save profile",
		Description = "Saves everything under that name",
		Callback = function()
			local ok, why = win:SaveProfile(nameBox:Get())
			result(ok, why, "Saved as " .. cleanName(nameBox:Get()) .. ".", "Saved")
		end,
	})
	tab:Button({
		Name = "Load profile",
		Callback = function()
			local ok, why = win:LoadProfile(nameBox:Get())
			result(ok, why, "Profile " .. cleanName(nameBox:Get()) .. " is on.", "Loaded")
		end,
	})
	tab:Button({
		Name = "Delete profile",
		Callback = function()
			local ok, why = win:DeleteProfile(nameBox:Get())
			result(ok, why, "Profile deleted.", "Deleted")
		end,
	})
	tab:Button({
		Name = "Load this profile on start",
		Description = "Your script can call Win:AutoLoad()",
		Callback = function()
			local n = cleanName(nameBox:Get())
			if n == "" or not table.find(win:ListProfiles(), n) then
				win:Notify({ Title = "Profile", Text = "Save the profile first.", Type = "warn" })
				return
			end
			win:SetAutoLoad(n)
			win:Notify({ Title = "Auto-load", Text = n .. " will load next time.", Type = "success" })
		end,
	})
	tab:Section("Share settings")
	tab:Button({
		Name = "Copy settings code",
		Description = "One line of text with all your settings",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:Export())
			win:Notify({
				Title = ok and "Copied" or "Can't copy",
				Text = ok and "Send it to a friend. They paste it below." or "This executor can't copy text.",
				Type = ok and "success" or "warn",
			})
		end,
	})
	tab:Button({
		Name = "Copy theme code",
		Description = "Just the colors (a short RBLT code)",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:ExportTheme())
			win:Notify({ Title = ok and "Copied" or "Can't copy", Text = ok and "Paste it in the box below on another device." or "This executor can't copy text.", Type = ok and "success" or "warn" })
		end,
	})
	tab:Button({
		Name = "Copy this panel as code",
		Description = "Lua that builds the panel as it is now",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:GenerateCode())
			win:Notify({ Title = ok and "Copied" or "Can't copy", Text = ok and "The Lua code is on your clipboard." or "This executor can't copy text.", Type = ok and "success" or "warn" })
		end,
	})
	tab:Input({
		Name = "Paste settings code",
		Placeholder = "paste, then tap done",
		Clear = true,
		Callback = function(text)
			if tostring(text) ~= "" then
				local ok = win:Import(text)
				win:Notify({
					Title = ok and "Imported" or "Not a settings code",
					Text = ok and "The settings were applied." or "Copy the whole code and try again.",
					Type = ok and "success" or "warn",
				})
			end
		end,
	})
	if o.Utilities ~= false then
		tab:Section("Utilities")
		local lp = Players.LocalPlayer
		tab:Toggle({
			Name = "Anti-AFK",
			Description = "Stops the 20 minute idle kick",
			Flag = "__antiafk",
			Callback = function(on)
				if win._afk then
					win._afk:Disconnect()
					win._afk = nil
				end
				if on and lp then
					local ok, vu = pcall(function()
						return game:GetService("VirtualUser")
					end)
					if ok and vu then
						local okc, c = pcall(function()
							return lp.Idled:Connect(function()
								pcall(function()
									vu:CaptureController()
									vu:ClickButton2(Vector2.new())
								end)
							end)
						end)
						if okc and c then
							win._afk = c
							win._conns[#win._conns + 1] = c
						end
					end
				end
			end,
		})
		if type(setfpscap) == "function" then
			tab:Slider({
				Name = "FPS cap",
				Min = 30,
				Max = 240,
				Step = 10,
				Default = 60,
				Flag = "__fpscap",
				Callback = function(v)
					pcall(setfpscap, v)
				end,
			})
		end
		tab:Button({
			Name = "Rejoin this server",
			Callback = function()
				win:Dialog({
					Title = "Rejoin?",
					Text = "You will leave this server and come back to the same game.",
					Buttons = {
						{
							Name = "Rejoin",
							Callback = function()
								pcall(function()
									game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
								end)
							end,
						},
						{ Name = "Cancel" },
					},
				})
			end,
		})
		tab:Toggle({
			Name = "Auto-save",
			Description = "A backup of your settings every minute",
			Default = win._autoOn == true,
			Flag = "__autosave",
			Callback = function(on)
				win:AutoSave(on and 60 or nil)
			end,
		})
		tab:Button({
			Name = "Restore auto-save",
			Callback = function()
				local ok = win:RestoreSnapshot()
				win:Notify({ Title = ok and "Restored" or "Nothing to restore", Text = ok and "Your last backup is back." or "Turn on Auto-save first.", Type = ok and "success" or "warn" })
			end,
		})
		tab:Button({
			Name = "Check for updates",
			Callback = function()
				win:CheckUpdate()
			end,
		})
		tab:Button({
			Name = "Copy game ID",
			Description = "The place id of this game",
			Callback = function()
				local ok = type(setclipboard) == "function" and pcall(setclipboard, tostring(game.PlaceId))
				win:Notify({ Title = ok and "Copied" or "Can't copy", Text = tostring(game.PlaceId), Type = ok and "success" or "warn" })
			end,
		})
	end
	tab:Section("Files")
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
	tab:Section("About")
	local cr = o.Credits or {}
	tab:Paragraph({
		Title = (cr.Name or win.TitleText) .. "  |  RebelUI v" .. RebelUI.Version,
		Text = (cr.Text or "Made by prorizz196. Thank you for using it!") .. (cr.Discord and ("\n" .. cr.Discord) or ""),
	})
	if cr.Discord then
		tab:Button({ Name = "Copy Discord invite", Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, cr.Discord)
			win:Notify({ Title = ok and "Copied!" or "Can't copy", Text = ok and "Paste it in your browser." or cr.Discord, Type = ok and "success" or "warn" })
		end })
	end
	tab:Button({ Name = "Check for updates", Callback = function()
		win:CheckUpdate()
	end })
	tab:Button({
		Name = "Unload panel",
		Callback = function()
			win:Dialog({
				Title = "Unload the panel?",
				Text = "Everything you turned on stays as it is. The panel closes for good.",
				Buttons = { { Name = "Unload", Callback = function() win:Destroy() end }, { Name = "Cancel" } },
			})
		end,
	})
	return tab
end

-- ============================================================ key gate
-- Asks for a key before your script goes on. It waits (yields) until the key is right or the window is closed.
--   local ok = UI:KeyGate({ Title = "My Script", Keys = { "ABC-123" }, Link = "https://discord.gg/..." })
--   if not ok then return end
-- Use Check = function(key) return true/false end to ask your own server (for example an HttpGet).
function RebelUI:KeyGate(o)
	o = o or {}
	local theme = THEMES[o.Theme or "Red"] or THEMES.Red
	local clean = tostring(o.Name or o.Title or "RebelUI"):gsub("[^%w]", "")
	local file = o.File or ("RebelUI_" .. (clean == "" and "Script" or clean) .. "_key.txt")

	local function trim(s)
		s = tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")
		return s
	end
	local function valid(k)
		k = trim(k)
		if k == "" then
			return false
		end
		if type(o.Check) == "function" then
			local ok, r = pcall(o.Check, k)
			return ok and r == true
		end
		for _, good in ipairs(o.Keys or {}) do
			if k == tostring(good) then
				return true
			end
		end
		return false
	end

	-- a key saved on an earlier run
	if o.Save ~= false and type(readfile) == "function" and type(isfile) == "function" then
		local okf, saved = pcall(function()
			if isfile(file) then
				return readfile(file)
			end
		end)
		if okf and saved and valid(saved) then
			return true, trim(saved)
		end
	end

	local name = (o.Name or "RebelUI") .. "_KeyGate"
	clearOld(name)
	local gui = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1001,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	local back = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, gui)
	local card = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 196),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
	}, back)
	corner(card, 12)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(theme.BG0, theme.BG1) }, card)
	local scl = new("UIScale", { Scale = 0.7 }, card)
	local ring = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5 }, card)
	local rg = new("UIGradient", { Color = ringSeq(theme) }, ring)
	local spin = RunService.RenderStepped:Connect(function()
		rg.Rotation = (os.clock() * 80) % 360
	end)
	tween(scl, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	local title = label(card, o.Title or "Enter your key", 15, theme.Glow, true)
	title.Position = UDim2.fromOffset(16, 12)
	title.Size = UDim2.new(1, -52, 0, 22)
	title.Font = Enum.Font.GothamBlack
	local sub = label(card, o.Subtitle or "Paste the key and tap Continue.", 10, C.Dim, false)
	sub.Position = UDim2.fromOffset(16, 34)
	sub.Size = UDim2.new(1, -32, 0, 14)
	local closeB = new("TextButton", {
		Position = UDim2.new(1, -30, 0, 8),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "X",
		TextColor3 = Color3.fromRGB(235, 40, 50),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, card)
	local box = new("TextBox", {
		Position = UDim2.fromOffset(16, 62),
		Size = UDim2.new(1, -32, 0, 34),
		BackgroundColor3 = theme.Inset,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "your key",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ClearTextOnFocus = false,
	}, card)
	corner(box, 8)
	new("UIStroke", { Color = theme.Dark, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, box)
	local status = label(card, "", 10, C.Dim, false)
	status.Position = UDim2.fromOffset(16, 100)
	status.Size = UDim2.new(1, -32, 0, 14)

	local function button(text, x, w, accent)
		local b = new("TextButton", {
			Position = UDim2.new(0, x, 0, 124),
			Size = UDim2.new(w, -6, 0, 34),
			BackgroundColor3 = accent and theme.Accent or theme.Item,
			BorderSizePixel = 0,
			Text = text,
			TextColor3 = C.Text,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, card)
		corner(b, 8)
		if accent then
			new("UIStroke", { Color = theme.Glow, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
		end
		return b
	end
	local hasLink = o.Link ~= nil
	local go = button("Continue", 16, hasLink and 0.5 or 1, true)
	if not hasLink then
		go.Size = UDim2.new(1, -32, 0, 34)
	end
	local getB
	if hasLink then
		getB = button("Get key", 0, 0.5, false)
		getB.Position = UDim2.new(0.5, 6, 0, 124)
		getB.Size = UDim2.new(0.5, -22, 0, 34)
		go.Size = UDim2.new(0.5, -22, 0, 34)
	end
	local foot = label(card, o.Footer or "", 9, C.Dim, false)
	foot.Position = UDim2.fromOffset(16, 168)
	foot.Size = UDim2.new(1, -32, 0, 14)
	foot.TextXAlignment = Enum.TextXAlignment.Center

	local result, savedKey
	local busy = false
	local tries = 0
	local function submit()
		if busy or result ~= nil then
			return
		end
		busy = true
		status.TextColor3 = C.Dim
		status.Text = "Checking..."
		task.spawn(function()
			local k = trim(box.Text)
			if valid(k) then
				status.TextColor3 = C.Green
				status.Text = "Correct. Welcome!"
				if o.Save ~= false and type(writefile) == "function" then
					pcall(writefile, file, k)
				end
				savedKey = k
				task.wait(0.5)
				result = true
			else
				tries += 1
				status.TextColor3 = C.Bad
				status.Text = k == "" and "Type your key first." or "That key is not right. Try again."
				if o.MaxTries and tries >= o.MaxTries then
					task.wait(0.8)
					result = false
				end
			end
			busy = false
		end)
	end
	go.MouseButton1Click:Connect(submit)
	box.FocusLost:Connect(function(enter)
		if enter then
			submit()
		end
	end)
	if getB then
		getB.MouseButton1Click:Connect(function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, tostring(o.Link))
			status.TextColor3 = C.Dim
			status.Text = ok and "Link copied. Paste it in your browser." or tostring(o.Link)
		end)
	end
	closeB.MouseButton1Click:Connect(function()
		result = false
	end)

	local waited = 0
	while result == nil do
		task.wait(0.1)
		waited += 0.1
		if o.Timeout and waited >= o.Timeout then
			result = false
		end
	end
	spin:Disconnect()
	tween(scl, 0.2, { Scale = 0.7 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(back, 0.2, { BackgroundTransparency = 1 })
	task.wait(0.2)
	gui:Destroy()
	if result then
		return true, savedKey
	end
	return false
end

-- how the panel is opened: a round logo button, a square logo button, or the top bar
function Window:SetTrigger(style, barOpts)
	style = tostring(style or "Circle")
	if style ~= "Circle" and style ~= "Square" and style ~= "Bar" then
		style = "Circle"
	end
	self.TriggerStyle = style
	if style == "Bar" then
		if not self._bar then
			self:CreateBar(barOpts or self._barOpts or { Items = { "FPS", "Logo", "Timer" }, Logo = self._icon })
		end
		self._bar:Show(true)
		self._hasBar = true
		self._fab.Visible = false
	else
		if self._bar then
			self._bar:Show(false)
		end
		self._hasBar = false
		if self._fabCorner then
			self._fabCorner.CornerRadius = UDim.new(0, style == "Circle" and 22 or 8)
		end
		self._fab.Visible = not self.Open
	end
	return style
end

-- ============================================================ game assistant (full-screen HUD)
-- win:GameAssistant({ Logo, Title, Color = "Rainbow", Crosshair = "Cross", Key, OnSummary = function(hud, done) end })
-- hud:Open() :Close() :Toggle() :SetColor(name) :SetCrosshair(name) :CrosshairInGame(bool) :Show(panel, bool)
-- hud:Target(name | "nearest" | nil) :Spectate(name | nil) :Command("crosshair dot") :GetSummary() :ShowBrief(text) :Destroy()
local HUD_COLORS = {
	Rainbow = "rainbow",
	Theme = "theme",
	Red = Color3.fromRGB(255, 48, 56),
	Cyan = Color3.fromRGB(40, 220, 255),
	Lime = Color3.fromRGB(120, 255, 90),
	Gold = Color3.fromRGB(255, 200, 60),
	Pink = Color3.fromRGB(255, 80, 200),
	Violet = Color3.fromRGB(160, 100, 255),
}
RebelUI.HudColors = { "Rainbow", "Theme", "Red", "Cyan", "Lime", "Gold", "Pink", "Violet" }
RebelUI.Crosshairs = { "Cross", "Dot", "Circle", "Chevron", "Diamond", "X", "Plus", "Square", "Sniper" }
RebelUI.CrossSizes = { Small = 50, Medium = 90, Large = 140, XL = 200 }
RebelUI.HudPresets = { "Low", "Medium", "High", "Extreme" }

local function hudBattery()
	local tries = { { "Stats", "BatteryLevel" }, { "UserInputService", "BatteryLevel" }, { "GuiService", "BatteryLevel" }, { "PlatformService", "BatteryLevel" } }
	for _, t in ipairs(tries) do
		local ok, v = pcall(function()
			return game:GetService(t[1])[t[2]]
		end)
		if ok and type(v) == "number" and v >= 0 then
			return v <= 1 and v * 100 or v
		end
	end
	for _, name in ipairs({ "getbatterylevel", "get_battery_level" }) do
		local f = getgenv and getgenv()[name]
		if type(f) == "function" then
			local ok, v = pcall(f)
			if ok and type(v) == "number" then
				return v <= 1 and v * 100 or v
			end
		end
	end
	return nil
end

-- draws one crosshair style inside `parent`. paint(inst, prop) registers things that follow the HUD color.
local function drawCross(parent, style, s, paint, th, alpha)
	th = th or 2
	alpha = alpha or 0
	for _, c in ipairs(parent:GetChildren()) do
		c:Destroy()
	end
	local function bar(x, y, w, h, rot)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, x, 0.5, y),
			Size = UDim2.fromOffset(w, h),
			BorderSizePixel = 0,
			Rotation = rot or 0,
			BackgroundTransparency = alpha,
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, parent)
		paint(f, "BackgroundColor3")
		return f
	end
	local function ring(d, t2)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(d, d),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, parent)
		corner(f, d)
		local st = new("UIStroke", { Thickness = t2 or th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, f)
		paint(st, "Color")
		return f
	end
	local dotS = math.max(3, th * 1.6)
	local g, L = math.floor(s * 0.1), math.floor(s * 0.28)
	if style == "Dot" then
		bar(0, 0, dotS * 1.6, dotS * 1.6)
		ring(s * 0.5)
	elseif style == "Circle" then
		ring(s * 0.6)
		bar(0, 0, dotS, dotS)
	elseif style == "Chevron" then
		bar(-s * 0.08, 0, L, th, 35)
		bar(s * 0.08, 0, L, th, -35)
		bar(0, s * 0.16, dotS, dotS)
	elseif style == "Diamond" then
		local d = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(s * 0.34, s * 0.34),
			Rotation = 45,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, parent)
		paint(new("UIStroke", { Thickness = th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, d), "Color")
		bar(0, 0, dotS, dotS)
	elseif style == "Square" then
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s * 0.4, s * 0.4), BackgroundTransparency = 1, BorderSizePixel = 0 }, parent)
		paint(new("UIStroke", { Thickness = th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, d), "Color")
		bar(0, 0, dotS, dotS)
	elseif style == "X" then
		local o2 = g + L * 0.35
		for _, p in ipairs({ { -o2, -o2, 45 }, { o2, -o2, -45 }, { -o2, o2, -45 }, { o2, o2, 45 } }) do
			bar(p[1], p[2], L * 0.8, th, p[3])
		end
	elseif style == "Plus" then
		bar(0, -(g + L / 2), th, L)
		bar(0, g + L / 2, th, L)
		bar(-(g + L / 2), 0, L, th)
		bar(g + L / 2, 0, L, th)
	elseif style == "Sniper" then
		bar(0, 0, s, math.max(1, th * 0.5))
		bar(0, 0, math.max(1, th * 0.5), s)
		ring(s * 0.28, math.max(1, th * 0.6))
		bar(0, 0, dotS, dotS)
	else -- Cross
		bar(0, -(g + L / 2), th, L)
		bar(0, g + L / 2, th, L)
		bar(-(g + L / 2), 0, L, th)
		bar(g + L / 2, 0, L, th)
		bar(0, 0, dotS, dotS)
	end
end

function Window:GameAssistant(o)
	o = o or {}
	local win = self
	if win.HUD and not win.HUD._dead then
		return win.HUD
	end
	local lp = Players.LocalPlayer
	local hud = { IsOpen = false, ColorName = HUD_COLORS[o.Color or "Rainbow"] and (o.Color or "Rainbow") or "Rainbow", CrossName = o.Crosshair or "Cross", CrossSize = o.CrosshairSize or 90, CrossThick = 2, CrossAlpha = 0, Preset = "Medium", Interval = 0.35, Fancy = true, Boost = 1, _panels = {}, _glows = {}, _dead = false }
	win.HUD = hud
	local name = o.Name or "RebelUI_HUD"
	clearOld(name)
	local gui = new("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 998, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false })
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	hud.Gui = gui

	local root = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, gui)
	new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(4, 2, 4), BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 1 }, root)
	for i = 0, 1 do -- dark bands top and bottom
		local b = new("Frame", { Size = UDim2.new(1, 0, 0.22, 0), Position = UDim2.fromScale(0, i == 0 and 0 or 0.78), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 1 }, root)
		new("UIGradient", { Rotation = i == 0 and 90 or -90, Transparency = NumberSequence.new(0.2, 1) }, b)
	end
	local ui = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, root)
	local sc = new("UIScale", {}, ui)
	local function relayout()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
		local s = math.clamp(vp.Y / 560, 0.62, 1.35) * (hud.Boost or 1)
		sc.Scale = s
		ui.Size = UDim2.fromScale(1 / s, 1 / s)
	end
	relayout()
	hud._relayout = relayout
	pcall(function()
		win._conns[#win._conns + 1] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
	end)

	-- ---------- colors: everything registered here follows the HUD color (rainbow / theme / fixed)
	local paints, grads = {}, {}
	local function paint(inst, prop)
		table.insert(paints, { inst, prop })
		return inst
	end
	local function curColor(now)
		local c = HUD_COLORS[hud.ColorName]
		if c == "rainbow" then
			return Color3.fromHSV((now * 0.12) % 1, 0.82, 1)
		elseif c == "theme" then
			return win.Theme.Glow
		end
		return c
	end
	local function gradSeq()
		local c = HUD_COLORS[hud.ColorName]
		if c == "rainbow" then
			local k = {}
			for i = 0, 6 do
				k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.85, 1))
			end
			return ColorSequence.new(k)
		end
		c = c == "theme" and win.Theme.Glow or c
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, c),
			ColorSequenceKeypoint.new(0.35, c:Lerp(Color3.new(0, 0, 0), 0.7)),
			ColorSequenceKeypoint.new(0.5, c:Lerp(Color3.new(1, 1, 1), 0.5)),
			ColorSequenceKeypoint.new(0.65, c:Lerp(Color3.new(0, 0, 0), 0.7)),
			ColorSequenceKeypoint.new(1, c),
		})
	end
	local function neon(stroke) -- a stroke whose gradient races around the edge
		stroke.Color = Color3.new(1, 1, 1)
		local g = new("UIGradient", { Color = gradSeq() }, stroke)
		table.insert(grads, g)
		return stroke
	end
	local function applyColors(now)
		local c = curColor(now or os.clock())
		for i = #paints, 1, -1 do
			local pi = paints[i]
			if pi[1].Parent == nil then
				table.remove(paints, i) -- the thing was destroyed (a redrawn crosshair)
			else
				pi[1][pi[2]] = c
			end
		end
	end
	local function applyGrads()
		local seq = gradSeq()
		for _, g in ipairs(grads) do
			g.Color = seq
		end
	end

	local DARK = Color3.fromRGB(10, 6, 9)
	local function text(parent, str, size, bold, pos, sz, align, accent, z)
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			Text = str,
			TextSize = size,
			Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium,
			TextColor3 = accent and Color3.new(1, 1, 1) or Color3.fromRGB(235, 230, 232),
			TextXAlignment = align or Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = pos,
			Size = sz or UDim2.new(1, 0, 0, size + 2),
			ZIndex = z or 6,
			RichText = false,
		}, parent)
		if accent then
			paint(l, "TextColor3")
		end
		return l
	end

	-- a sharp panel: dark glass, racing neon edge, glow, corner brackets, slanted header
	local function panel(key, pos, size, title, anchor)
		local f = new("Frame", { Position = pos, Size = size, AnchorPoint = anchor or Vector2.new(0, 0), BackgroundColor3 = DARK, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 3 }, ui)
		neon(new("UIStroke", { Thickness = 1.8, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f))
		local glow = new("Frame", { Position = UDim2.fromOffset(-4, -4), Size = UDim2.new(1, 8, 1, 8), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, f)
		local gs = neon(new("UIStroke", { Thickness = 5, Transparency = 0.78, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, glow))
		gs.Transparency = 0.78
		table.insert(hud._glows, glow)
		for _, c in ipairs({ { 0, 0, 1, 1 }, { 1, 0, -1, 1 }, { 0, 1, 1, -1 }, { 1, 1, -1, -1 } }) do
			local ax, ay = c[1], c[2]
			local h = new("Frame", { AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.fromOffset(16, 3), BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			local v = new("Frame", { AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.fromOffset(3, 16), BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			paint(h, "BackgroundColor3")
			paint(v, "BackgroundColor3")
		end
		if title then
			local hd = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 4 }, f)
			paint(hd, "BackgroundColor3")
			new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, hd)
			text(f, title, 13, true, UDim2.fromOffset(26, 6), UDim2.new(1, -60, 0, 16), nil, true)
			for i = 0, 2 do -- slanted slashes
				local sl = new("Frame", { Position = UDim2.fromOffset(8 + i * 5, 8), Size = UDim2.fromOffset(2, 13), Rotation = 25, BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
				paint(sl, "BackgroundColor3")
			end
			local ln = new("Frame", { Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 5, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			paint(ln, "BackgroundColor3")
			new("UIGradient", { Transparency = NumberSequence.new(0.1, 1) }, ln)
		end
		hud._panels[key] = f
		return f
	end

	local function bar(parent, pos, size, z)
		local back = new("Frame", { Position = pos, Size = size, BackgroundColor3 = Color3.fromRGB(34, 28, 32), BorderSizePixel = 0, ZIndex = z or 6 }, parent)
		local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = (z or 6) + 1 }, back)
		return back, fill
	end

	-- ---------- top: logo, banner, close, AI brief
	local logo = new("Frame", { Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(150, 40), BackgroundTransparency = 1, ZIndex = 5 }, ui)
	if o.Logo then
		new("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Image = asset(o.Logo), ZIndex = 6 }, logo)
	end
	text(logo, "REBELUI", 20, true, UDim2.fromOffset(o.Logo and 44 or 0, 4), UDim2.new(1, -44, 0, 30), nil, true)

	local banner = panel("banner", UDim2.new(0.5, 0, 0, 8), UDim2.fromOffset(330, 46), nil, Vector2.new(0.5, 0))
	hud._title = text(banner, o.Title or "ELITE GAME ASSISTANT", 15, true, UDim2.fromOffset(0, 6), UDim2.new(1, 0, 0, 18), Enum.TextXAlignment.Center, true)
	hud._sub = text(banner, "", 10, false, UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 14), Enum.TextXAlignment.Center)
	hud._sub.TextColor3 = Color3.fromRGB(180, 170, 175)

	local function chipButton(parent, label, pos, size, cb)
		local b = new("TextButton", { Position = pos, Size = size, BackgroundColor3 = DARK, BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = label, TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, ZIndex = 8 }, parent)
		neon(new("UIStroke", { Thickness = 1.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b))
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			cb(b)
		end)
		return b
	end
	chipButton(ui, "X", UDim2.new(1, -52, 0, 10), UDim2.fromOffset(40, 34), function()
		hud:Close()
	end)
	chipButton(ui, "PANEL", UDim2.new(1, -112, 0, 10), UDim2.fromOffset(54, 34), function()
		win:Toggle(true)
	end)
	local brief = chipButton(ui, "AI BRIEF", UDim2.new(1, -184, 0, 10), UDim2.fromOffset(66, 34), function(b)
		hud:Brief()
	end)

	-- color chips (top left) and crosshair chips (top center)
	local function chipRow(pos, width, items, current, cb)
		local sf = new("ScrollingFrame", { Position = pos, Size = UDim2.fromOffset(width, 26), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 6 }, ui)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
		local btns = {}
		for i, it in ipairs(items) do
			local b = new("TextButton", { Size = UDim2.fromOffset(#it * 7 + 18, 24), LayoutOrder = i, BackgroundColor3 = DARK, BackgroundTransparency = 0.2, BorderSizePixel = 0, Text = it, TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(200, 195, 198), AutoButtonColor = false, ZIndex = 7 }, sf)
			local st = new("UIStroke", { Thickness = 1, Color = Color3.fromRGB(70, 60, 66), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
			btns[it] = { b, st }
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				cb(it)
			end)
		end
		return function(sel)
			for k, v in pairs(btns) do
				local on = k == sel
				v[1].TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(200, 195, 198)
				v[1].BackgroundTransparency = on and 0.0 or 0.2
				v[2].Color = on and Color3.new(1, 1, 1) or Color3.fromRGB(70, 60, 66)
			end
		end
	end
	local markColor = chipRow(UDim2.fromOffset(14, 58), 250, RebelUI.HudColors, hud.ColorName, function(n)
		hud:SetColor(n)
	end)
	local sizeNames = { "Small", "Medium", "Large", "XL" }
	local markSize = chipRow(UDim2.fromOffset(14, 88), 250, sizeNames, "Medium", function(n)
		hud:SetCrosshairSize(n)
	end)
	local markPreset = chipRow(UDim2.fromOffset(14, 118), 280, RebelUI.HudPresets, "Medium", function(n)
		hud:SetPreset(n)
	end)
	local markCross = chipRow(UDim2.new(0.5, -150, 0, 62), 300, RebelUI.Crosshairs, hud.CrossName, function(n)
		hud:SetCrosshair(n)
	end)

	-- ---------- left middle: your stats
	local stats = panel("stats", UDim2.new(0, 14, 0.5, -112), UDim2.fromOffset(216, 232), "YOUR STATS")
	local srow = {}
	local function statRow(i, label)
		local y = 36 + (i - 1) * 32
		local lb = text(stats, label, 10, true, UDim2.fromOffset(14, y), UDim2.new(0.5, 0, 0, 12))
		lb.TextColor3 = Color3.fromRGB(170, 160, 165)
		local v = text(stats, "-", 14, true, UDim2.fromOffset(14, y + 11), UDim2.new(0.55, 0, 0, 16), nil, true)
		local back, fill = bar(stats, UDim2.new(0.5, 6, 0, y + 14), UDim2.new(0.5, -20, 0, 6))
		paint(fill, "BackgroundColor3")
		srow[label] = { v = v, fill = fill }
	end
	for i, l in ipairs({ "PING", "FPS", "BATTERY", "MEMORY", "SPEED" }) do
		statRow(i, l)
	end
	hud._session = text(stats, "SESSION 00:00", 10, true, UDim2.fromOffset(14, 202), UDim2.new(1, -28, 0, 12))
	hud._session.TextColor3 = Color3.fromRGB(170, 160, 165)

	-- ---------- bottom left: your health
	local health = panel("health", UDim2.new(0, 14, 1, -96), UDim2.fromOffset(310, 84), "HEALTH")
	local hpText = text(health, "100 / 100", 22, true, UDim2.fromOffset(14, 34), UDim2.new(0.6, 0, 0, 26), nil, false)
	local hpName = text(health, "", 10, true, UDim2.new(1, -150, 0, 40), UDim2.fromOffset(136, 14), Enum.TextXAlignment.Right)
	hpName.TextColor3 = Color3.fromRGB(170, 160, 165)
	local hpBack, hpFill = bar(health, UDim2.fromOffset(14, 62), UDim2.new(1, -28, 0, 12))
	for i = 1, 9 do -- segment lines
		new("Frame", { Position = UDim2.new(i / 10, 0, 0, 0), Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Color3.fromRGB(10, 6, 9), BorderSizePixel = 0, ZIndex = 9 }, hpBack)
	end

	-- ---------- right: players
	local plist = panel("players", UDim2.new(1, -234, 0, 96), UDim2.new(0, 220, 1, -300), "PLAYERS")
	local pcount = text(plist, "", 12, true, UDim2.new(1, -90, 0, 7), UDim2.fromOffset(78, 14), Enum.TextXAlignment.Right, true)
	local scroll = new("ScrollingFrame", { Position = UDim2.fromOffset(6, 34), Size = UDim2.new(1, -12, 1, -40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 5 }, plist)
	paint(scroll, "ScrollBarImageColor3")
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	local rows = {}

	-- ---------- right bottom: your profile
	local prof = panel("profile", UDim2.new(1, -234, 1, -192), UDim2.fromOffset(220, 180), "YOU")
	local avatar = new("ImageLabel", { Position = UDim2.fromOffset(12, 38), Size = UDim2.fromOffset(84, 84), BackgroundColor3 = Color3.fromRGB(26, 20, 24), BorderSizePixel = 0, ZIndex = 6, Image = "" }, prof)
	paint(new("UIStroke", { Thickness = 1.5 }, avatar), "Color")
	pcall(function()
		avatar.Image = "rbxthumb://type=AvatarBust&id=" .. lp.UserId .. "&w=150&h=150"
	end)
	text(prof, lp.DisplayName, 16, true, UDim2.fromOffset(106, 40), UDim2.new(1, -116, 0, 20), nil, true)
	local un = text(prof, "@" .. lp.Name, 11, false, UDim2.fromOffset(106, 62), UDim2.new(1, -116, 0, 14))
	un.TextColor3 = Color3.fromRGB(180, 170, 175)
	local pid = text(prof, "ID " .. tostring(lp.UserId), 10, false, UDim2.fromOffset(106, 80), UDim2.new(1, -116, 0, 12))
	pid.TextColor3 = Color3.fromRGB(140, 130, 135)
	local age = text(prof, "ACCOUNT " .. tostring(lp.AccountAge) .. " DAYS", 10, true, UDim2.fromOffset(12, 130), UDim2.new(1, -24, 0, 12))
	age.TextColor3 = Color3.fromRGB(170, 160, 165)
	hud._where = text(prof, "", 10, true, UDim2.fromOffset(12, 148), UDim2.new(1, -24, 0, 24), nil, true)
	hud._where.TextWrapped = true
	hud._where.TextTruncate = Enum.TextTruncate.None

	-- ---------- center: radar crosshair
	local center = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(260, 260), BackgroundTransparency = 1, ZIndex = 4 }, ui)
	hud._panels.crosshair = center
	local function ringF(d, th, tr)
		local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4 }, center)
		corner(f, d)
		local st = new("UIStroke", { Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		return f, st
	end
	local _, st1 = ringF(252, 2)
	neon(st1)
	local _, st2 = ringF(256, 7, 0.82)
	neon(st2)
	local _, st3 = ringF(170, 1.2, 0.2)
	neon(st3)
	local _, st4 = ringF(80, 1, 0.5)
	paint(st4, "Color")
	local ticks = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(236, 236), BackgroundTransparency = 1, ZIndex = 4 }, center)
	for i = 0, 59 do
		local a = math.rad(i * 6)
		local long = i % 5 == 0
		local t = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.sin(a) * 114, 0.5, -math.cos(a) * 114), Size = UDim2.fromOffset(long and 3 or 1.5, long and 11 or 6), Rotation = i * 6, BorderSizePixel = 0, ZIndex = 4, BackgroundColor3 = Color3.new(1, 1, 1) }, ticks)
		paint(t, "BackgroundColor3")
	end
	local arcs = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(190, 190), BackgroundTransparency = 1, ZIndex = 4 }, center)
	for i = 0, 35 do
		if i % 12 < 4 then
			local a = math.rad(i * 10)
			local t = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.sin(a) * 90, 0.5, -math.cos(a) * 90), Size = UDim2.fromOffset(5, 13), Rotation = i * 10, BorderSizePixel = 0, ZIndex = 4, BackgroundColor3 = Color3.new(1, 1, 1) }, arcs)
			paint(t, "BackgroundColor3")
		end
	end
	local sweep = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(170, 2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 4 }, center)
	paint(sweep, "BackgroundColor3")
	new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0) }) }, sweep)
	local dots = {} -- other players on the radar
	local cross = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(90, 90), BackgroundTransparency = 1, ZIndex = 8 }, center)
	local function redrawCross()
		cross.Size = UDim2.fromOffset(hud.CrossSize, hud.CrossSize)
		drawCross(cross, hud.CrossName, hud.CrossSize, paint, hud.CrossThick, hud.CrossAlpha)
		applyColors()
	end
	hud._target = text(ui, "", 12, true, UDim2.new(0.5, -130, 0.5, -170), UDim2.fromOffset(260, 16), Enum.TextXAlignment.Center, true)

	-- ---------- in-game crosshair (stays on screen after the HUD closes)
	local cgui = new("ScreenGui", { Name = name .. "_Cross", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 997, Enabled = false }, nil)
	clearOld(name .. "_Cross")
	cgui.Parent = pickParent()
	local cbox = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1 }, cgui)
	local function redrawGameCross()
		cbox.Size = UDim2.fromOffset(hud.CrossSize, hud.CrossSize)
		drawCross(cbox, hud.CrossName, hud.CrossSize, paint, hud.CrossThick, hud.CrossAlpha)
		applyColors()
	end

	-- ---------- brief card (AI summary)
	local card = panel("brief", UDim2.new(0.5, 0, 1, -150), UDim2.fromOffset(420, 120), "AI BRIEF", Vector2.new(0.5, 0))
	card.Visible = false
	hud._briefText = text(card, "", 12, false, UDim2.fromOffset(14, 36), UDim2.new(1, -28, 1, -44))
	hud._briefText.TextWrapped = true
	hud._briefText.TextYAlignment = Enum.TextYAlignment.Top
	hud._briefText.TextTruncate = Enum.TextTruncate.None
	hud._briefText.RichText = false
	hud._briefText.TextSize = 12
	local briefToken = 0
	function hud:ShowBrief(str, hold)
		briefToken += 1
		local my = briefToken
		hud._briefText.Text = tostring(str or "")
		card.Visible = true
		hud._panels.brief = nil
		task.delay(hold or 14, function()
			if briefToken == my then
				card.Visible = false
			end
		end)
	end
	function hud:Brief()
		if type(o.OnSummary) == "function" then
			hud:ShowBrief("Reading the room...", 30)
			local ok, err = pcall(o.OnSummary, hud, function(result)
				hud:ShowBrief(result, 18)
			end)
			if not ok then
				hud:ShowBrief("The summary failed: " .. tostring(err), 6)
			end
		else
			hud:ShowBrief(hud:GetSummary(), 18)
		end
	end

	-- ---------- extras: damage flash, status tags, compare card, hotbar
	local vig = {}
	for i, e in ipairs({ { UDim2.new(1, 0, 0.2, 0), UDim2.fromScale(0, 0), 90 }, { UDim2.new(1, 0, 0.2, 0), UDim2.fromScale(0, 0.8), -90 }, { UDim2.new(0.12, 0, 1, 0), UDim2.fromScale(0, 0), 0 }, { UDim2.new(0.12, 0, 1, 0), UDim2.fromScale(0.88, 0), 180 } }) do
		local v = new("Frame", { Size = e[1], Position = e[2], BackgroundColor3 = Color3.fromRGB(255, 20, 30), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Active = false }, root)
		new("UIGradient", { Rotation = e[3], Transparency = NumberSequence.new(0, 1) }, v)
		vig[i] = v
	end
	function hud:_damage(n)
		for _, v in ipairs(vig) do
			v.BackgroundTransparency = math.clamp(0.75 - n / 80, 0.15, 0.7)
			tween(v, 0.7, { BackgroundTransparency = 1 })
		end
		local t = text(ui, "-" .. math.floor(n), 24, true, UDim2.new(0.5, math.random(-40, 40), 0.5, 40), UDim2.fromOffset(80, 28), Enum.TextXAlignment.Center, false, 12)
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.TextColor3 = Color3.fromRGB(255, 70, 70)
		tween(t, 0.9, { Position = t.Position - UDim2.fromOffset(0, 60), TextTransparency = 1 })
		task.delay(1, function()
			t:Destroy()
		end)
	end
	hud._status = text(ui, "", 11, true, UDim2.new(0, 16, 1, -118), UDim2.fromOffset(320, 16), nil, true)
	local cmp = panel("compare", UDim2.new(0.5, 0, 0, 96), UDim2.fromOffset(300, 62), nil, Vector2.new(0.5, 0))
	cmp.Visible = false
	local cmpL = text(cmp, "", 11, true, UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 48))
	cmpL.TextWrapped = true
	cmpL.TextYAlignment = Enum.TextYAlignment.Top
	cmpL.TextTruncate = Enum.TextTruncate.None
	local hot = panel("hotbar", UDim2.new(0.5, 0, 1, -64), UDim2.fromOffset(200, 52), nil, Vector2.new(0.5, 0))
	hot.Visible = false
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, hot)
	local lastHp
	local sh

	-- ---------- data
	local Stats = game:GetService("Stats")
	local fps, frames, acc, started = 60, 0, 0, os.clock()
	local function hum(p)
		local ch = p and p.Character
		return ch and ch:FindFirstChildOfClass("Humanoid"), ch and ch:FindFirstChild("HumanoidRootPart")
	end
	local function distTo(p)
		local _, mine = hum(lp)
		local _, theirs = hum(p)
		if mine and theirs then
			return (mine.Position - theirs.Position).Magnitude
		end
		return nil
	end
	local targetPlayer = nil
	local hl
	local function setTarget(p)
		targetPlayer = p
		if hl then
			hl:Destroy()
			hl = nil
		end
		if p and p.Character then
			pcall(function()
				hl = new("Highlight", { FillTransparency = 0.75, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 60, 60), OutlineColor = Color3.new(1, 1, 1), Name = "RebelHUDTarget" }, p.Character)
			end)
		end
	end
	local function findPlayer(q)
		q = tostring(q or ""):lower()
		if q == "" then
			return nil
		end
		local best
		for _, p in ipairs(Players:GetPlayers()) do
			local a, b = p.Name:lower(), p.DisplayName:lower()
			if a == q or b == q then
				return p
			elseif (a:find(q, 1, true) or b:find(q, 1, true)) and not best then
				best = p
			end
		end
		return best
	end
	local function nearest()
		local best, bd = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local d = distTo(p)
				if d and d < bd then
					best, bd = p, d
				end
			end
		end
		return best, bd
	end

	local function makeRow(p)
		local r = new("TextButton", { Size = UDim2.new(1, -2, 0, 40), BackgroundColor3 = Color3.fromRGB(26, 18, 22), BackgroundTransparency = 0.25, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 6 }, scroll)
		local img = new("ImageLabel", { Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = Color3.fromRGB(40, 30, 35), BorderSizePixel = 0, ZIndex = 7, Image = "" }, r)
		pcall(function()
			img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=100&h=100"
		end)
		local nm = text(r, p.DisplayName, 12, true, UDim2.fromOffset(42, 3), UDim2.new(1, -92, 0, 14), nil, false, 7)
		local un2 = text(r, "@" .. p.Name, 9, false, UDim2.fromOffset(42, 17), UDim2.new(1, -92, 0, 11), nil, false, 7)
		un2.TextColor3 = Color3.fromRGB(150, 140, 145)
		local dl = text(r, "", 11, true, UDim2.new(1, -52, 0, 4), UDim2.fromOffset(48, 13), Enum.TextXAlignment.Right, true, 7)
		local hb, hf = bar(r, UDim2.fromOffset(42, 32), UDim2.new(1, -50, 0, 4), 7)
		local st = new("UIStroke", { Thickness = 1.3, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, r)
		paint(st, "Color")
		r.MouseButton1Click:Connect(function()
			win:_playClick()
			if targetPlayer == p then
				setTarget(nil)
			else
				setTarget(p)
			end
		end)
		rows[p] = { f = r, d = dl, hf = hf, st = st, nm = nm }
	end
	local function dropRow(p)
		if rows[p] then
			rows[p].f:Destroy()
			rows[p] = nil
		end
		if targetPlayer == p then
			setTarget(nil)
		end
	end
	win._conns[#win._conns + 1] = Players.PlayerAdded:Connect(function(p)
		if hud.IsOpen then
			makeRow(p)
		end
	end)
	win._conns[#win._conns + 1] = Players.PlayerRemoving:Connect(dropRow)

	local function colorHP(f)
		return Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(70, 235, 110), math.clamp(f, 0, 1))
	end

	local function refreshData(now)
		-- you
		local h, root0 = hum(lp)
		local hp, mx = h and h.Health or 0, h and math.max(h.MaxHealth, 1) or 100
		hpText.Text = string.format("%d / %d", math.floor(hp), math.floor(mx))
		hpFill.Size = UDim2.fromScale(math.clamp(hp / mx, 0, 1), 1)
		hpFill.BackgroundColor3 = colorHP(hp / mx)
		hpText.TextColor3 = colorHP(hp / mx)
		hpName.Text = lp.DisplayName:upper()
		local ping = 0
		pcall(function()
			ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		local bat = hudBattery()
		local mem = 0
		pcall(function()
			mem = Stats:GetTotalMemoryUsageMb()
		end)
		local spd = h and root0 and root0.AssemblyLinearVelocity and Vector3.new(root0.AssemblyLinearVelocity.X, 0, root0.AssemblyLinearVelocity.Z).Magnitude or 0
		local function set(k, v, f)
			srow[k].v.Text = v
			srow[k].fill.Size = UDim2.fromScale(math.clamp(f, 0.02, 1), 1)
		end
		set("PING", string.format("%d ms", ping), 1 - math.clamp(ping / 300, 0, 1))
		set("FPS", tostring(math.floor(fps)), math.clamp(fps / 60, 0, 1))
		set("BATTERY", bat and string.format("%d%%", bat) or "N/A", bat and bat / 100 or 0)
		set("MEMORY", string.format("%d MB", mem), 1 - math.clamp(mem / 3000, 0, 1))
		set("SPEED", string.format("%.0f", spd), math.clamp(spd / 80, 0, 1))
		local t = math.floor(now - started)
		hud._session.Text = string.format("SESSION %02d:%02d", t // 60, t % 60)
		hud._sub.Text = string.format("%s  |  %d / %d PLAYERS", (game.Name or "Game"):upper(), #Players:GetPlayers(), Players.MaxPlayers or 0)
		if root0 then
			local p = root0.Position
			hud._where.Text = string.format("POS %d, %d, %d", p.X, p.Y, p.Z)
		end
		-- players
		pcount.Text = string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers or 0)
		local list = Players:GetPlayers()
		for _, p in ipairs(list) do
			if not rows[p] then
				makeRow(p)
			end
		end
		local used = {}
		for i, p in ipairs(list) do
			local r = rows[p]
			local d = distTo(p)
			local ph = hum(p)
			r.d.Text = d and (p == lp and "YOU" or string.format("%dm", d)) or "--"
			local f = ph and math.clamp(ph.Health / math.max(ph.MaxHealth, 1), 0, 1) or 0
			r.hf.Size = UDim2.fromScale(math.max(f, 0.02), 1)
			r.hf.BackgroundColor3 = colorHP(f)
			r.f.LayoutOrder = p == lp and -1 or math.floor(d or 99999)
			r.st.Transparency = (p == targetPlayer) and 0 or 1
			r.f.BackgroundTransparency = (p == targetPlayer) and 0.05 or 0.25
			used[p] = true
		end
		for p in pairs(rows) do
			if not used[p] then
				dropRow(p)
			end
		end
		-- radar dots
		local n = 0
		for _, p in ipairs(list) do
			if p ~= lp then
				local _, tr = hum(p)
				local d = distTo(p)
				if tr and root0 and d and d < 150 then
					n += 1
					local dot = dots[n]
					if not dot then
						dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, ZIndex = 5, BackgroundColor3 = Color3.new(1, 1, 1) }, center)
						corner(dot, 6)
						dots[n] = dot
					end
					local rel = tr.Position - root0.Position
					local cam = workspace.CurrentCamera
					local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
					local ang = math.atan2(rel.X, -rel.Z) - math.atan2(look.X, -look.Z)
					local rr = math.clamp(d / 150, 0, 1) * 78
					dot.Position = UDim2.new(0.5, math.sin(ang) * rr, 0.5, -math.cos(ang) * rr)
					dot.BackgroundColor3 = p == targetPlayer and Color3.fromRGB(255, 60, 60) or Color3.new(1, 1, 1)
					dot.Visible = true
				end
			end
		end
		for i = n + 1, #dots do
			dots[i].Visible = false
		end
		-- target readout
		if targetPlayer and targetPlayer.Parent then
			local d = distTo(targetPlayer)
			local th = hum(targetPlayer)
			hud._target.Text = string.format("TARGET  %s  %s  %s", targetPlayer.DisplayName:upper(), d and (math.floor(d) .. "m") or "--", th and (math.floor(th.Health) .. " HP") or "")
		else
			hud._target.Text = ""
		end
		-- status tags and the compare card
		local tags = {}
		if h then
			local okS, stn = pcall(function()
				return h:GetState().Name
			end)
			if okS and stn then
				table.insert(tags, stn:upper())
			end
			if hp / mx < 0.3 and hp > 0 then
				table.insert(tags, "LOW HP")
			end
		end
		if ping > 220 then
			table.insert(tags, "HIGH PING")
		end
		if fps < 30 then
			table.insert(tags, "LOW FPS")
		end
		hud._status.Text = table.concat(tags, "  |  ")
		if targetPlayer and targetPlayer.Parent and hud._panels.compare then
			local th = hum(targetPlayer)
			local _, tr = hum(targetPlayer)
			local tsp = tr and tr.AssemblyLinearVelocity and Vector3.new(tr.AssemblyLinearVelocity.X, 0, tr.AssemblyLinearVelocity.Z).Magnitude or 0
			cmpL.Text = string.format("YOU vs %s\nHP  %d  |  %d      SPEED  %d  |  %d      DIST  %s", targetPlayer.DisplayName:upper(), hp, th and th.Health or 0, spd, tsp, distTo(targetPlayer) and (math.floor(distTo(targetPlayer)) .. "m") or "--")
			cmp.Visible = hud._cmpOn ~= false
		else
			cmp.Visible = false
		end
	end

	-- ---------- one loop: racing edges, spinning rings, colors, data
	local dataAcc = 0
	win._conns[#win._conns + 1] = RunService.RenderStepped:Connect(function(dt)
		frames += 1
		acc += dt
		if acc >= 0.5 then
			fps = frames / acc
			frames, acc = 0, 0
		end
		if not (hud.IsOpen or hud._gameCross) then
			return
		end
		local now = os.clock()
		applyColors(now)
		if not hud.IsOpen then
			return
		end
		local rot = (now * 90) % 360
		for _, g in ipairs(grads) do
			g.Rotation = rot
		end
		if hud.Fancy then
			ticks.Rotation = (now * 6) % 360
			arcs.Rotation = -(now * 22) % 360
			sweep.Rotation = (now * 140) % 360
		end
		local hh = hum(lp)
		if hh then
			if lastHp and hh.Health < lastHp - 0.5 then
				hud:_damage(lastHp - hh.Health)
			end
			lastHp = hh.Health
		end
		if sh then
			local k = 1 - (now - sh.t0) / sh.dur
			if k <= 0 then
				sh = nil
				ui.Position = UDim2.new()
			else
				local m = 8 * sh.p * k
				ui.Position = UDim2.fromOffset((math.random() - 0.5) * 2 * m, (math.random() - 0.5) * 2 * m)
			end
		end
		dataAcc += dt
		if dataAcc >= (hud.Interval or 0.35) then
			dataAcc = 0
			local okR, eR = pcall(refreshData, now)
			if not okR and not hud._warned then
				hud._warned = true
				warn("[RebelUI] HUD refresh: " .. tostring(eR))
			end
		end
	end)

	-- ---------- public methods
	function hud:SetColor(n)
		if not HUD_COLORS[n] then
			return false
		end
		hud.ColorName = n
		applyGrads()
		applyColors()
		markColor(n)
		return true
	end
	function hud:SetCrosshair(n)
		if not table.find(RebelUI.Crosshairs, n) then
			return false
		end
		hud.CrossName = n
		redrawCross()
		redrawGameCross()
		markCross(n)
		return true
	end
	function hud:CrosshairInGame(on)
		hud._gameCross = on == true
		cgui.Enabled = hud._gameCross
		if hud._gameCross then
			redrawGameCross()
		end
	end
	function hud:_shake(power, dur)
		sh = { t0 = os.clock(), dur = dur, p = power }
	end
	function hud:SetCrosshairSize(n)
		local px = RebelUI.CrossSizes[n] or tonumber(n)
		if not px then
			return false
		end
		hud.CrossSize = math.clamp(math.floor(px), 20, 240)
		redrawCross()
		redrawGameCross()
		for name2, v in pairs(RebelUI.CrossSizes) do
			if v == hud.CrossSize then
				markSize(name2)
				return true
			end
		end
		markSize(nil)
		return true
	end
	function hud:SetCrosshairThickness(n)
		hud.CrossThick = math.clamp(tonumber(n) or 2, 1, 8)
		redrawCross()
		redrawGameCross()
	end
	function hud:SetCrosshairOpacity(pct)
		hud.CrossAlpha = 1 - math.clamp((tonumber(pct) or 100) / 100, 0.1, 1)
		redrawCross()
		redrawGameCross()
	end
	function hud:SetPreset(n)
		local P = {
			Low = { 0.8, false, 0.9, false },
			Medium = { 0.35, true, 1, true },
			High = { 0.25, true, 1.08, true },
			Extreme = { 0.2, true, 1.15, true },
		}
		local c = P[n]
		if not c then
			return false
		end
		hud.Preset, hud.Interval, hud.Fancy, hud.Boost = n, c[1], c[2], c[3]
		for _, g in ipairs(hud._glows) do
			g.Visible = c[4]
		end
		ticks.Visible, arcs.Visible, sweep.Visible = c[2], c[2], c[2]
		if n == "Extreme" then
			hud:SetColor("Rainbow")
		end
		hud._relayout()
		markPreset(n)
		return true
	end
	-- the game's name decides a starting setup (a template)
	local TEMPLATES = {
		{ "Shooter", { "shoot", "gun", "war", "arsenal", "phantom", "strike", "combat", "battle", "fps", "rivals", "business", "criminality", "sniper", "zombie", "blox" }, { cross = "Cross", size = 70, preset = "High", show = { players = true, crosshair = true } } },
		{ "Murder mystery", { "murder", "mm2", "sheriff", "mystery", "among", "impostor" }, { cross = "Dot", size = 60, preset = "Medium", show = { players = true, crosshair = true } } },
		{ "Obby / parkour", { "obby", "tower", "parkour", "difficulty", "escape", "climb", "jump" }, { cross = "Dot", size = 40, preset = "Low", show = { players = false, crosshair = false } } },
		{ "Simulator / tycoon", { "tycoon", "simulator", "farm", "grow", "idle", "clicker", "pet", "garden", "fisch", "bee" }, { cross = "Plus", size = 50, preset = "Low", show = { players = true, crosshair = false } } },
		{ "Racing", { "race", "racing", "drive", "driving", "car", "speed", "drift" }, { cross = "Chevron", size = 60, preset = "Medium", show = { players = true, crosshair = false } } },
		{ "Roleplay / social", { "roleplay", "rp", "hangout", "life", "town", "city", "school" }, { cross = "Dot", size = 40, preset = "Low", show = { players = true, crosshair = false } } },
	}
	function hud:Detect(apply)
		local nm = (game.Name or ""):lower()
		pcall(function()
			nm = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower()
		end)
		local found, cfg = "General", { cross = "Cross", size = 90, preset = "Medium", show = { players = true, crosshair = true } }
		for _, t in ipairs(TEMPLATES) do
			for _, w in ipairs(t[2]) do
				if nm:find(w, 1, true) then
					found, cfg = t[1], t[3]
					break
				end
			end
			if found ~= "General" then
				break
			end
		end
		hud.Template = found
		if apply ~= false then
			hud:SetCrosshair(cfg.cross)
			hud:SetCrosshairSize(cfg.size)
			hud:SetPreset(cfg.preset)
			for k, v in pairs(cfg.show) do
				hud:Show(k, v)
			end
		end
		return found
	end
	-- profiles: one file per game (and a share code)
	local function profileData()
		local hidden = {}
		for k, f in pairs(hud._panels) do
			if k ~= "brief" and k ~= "compare" and k ~= "hotbar" and f.Visible == false then
				hidden[#hidden + 1] = k
			end
		end
		return { color = hud.ColorName, cross = hud.CrossName, size = hud.CrossSize, thick = hud.CrossThick, alpha = hud.CrossAlpha, preset = hud.Preset, hidden = hidden, game = hud._gameCross == true }
	end
	local function applyProfile(d)
		if type(d) ~= "table" then
			return false
		end
		hud:SetColor(d.color or "Rainbow")
		hud:SetCrosshair(d.cross or "Cross")
		hud.CrossThick, hud.CrossAlpha = d.thick or 2, d.alpha or 0
		hud:SetCrosshairSize(d.size or 90)
		hud:SetPreset(d.preset or "Medium")
		hud:Show("all", true)
		for _, k in ipairs(d.hidden or {}) do
			hud:Show(k, false)
		end
		hud:CrosshairInGame(d.game == true)
		return true
	end
	local function pfile()
		return "RebelUI_HUD_" .. tostring(game.PlaceId) .. ".json"
	end
	function hud:SaveProfile()
		local ok = pcall(function()
			writefile(pfile(), game:GetService("HttpService"):JSONEncode(profileData()))
		end)
		return ok
	end
	function hud:LoadProfile()
		local ok, d = pcall(function()
			if isfile and isfile(pfile()) then
				return game:GetService("HttpService"):JSONDecode(readfile(pfile()))
			end
		end)
		if ok and d then
			return applyProfile(d)
		end
		return false
	end
	function hud:Export()
		local code = "RBH1:" .. b64encode(game:GetService("HttpService"):JSONEncode(profileData()))
		pcall(function()
			setclipboard(code)
		end)
		return code
	end
	function hud:Import(code)
		code = tostring(code or "")
		if code:sub(1, 5) ~= "RBH1:" then
			return false
		end
		local ok, d = pcall(function()
			return game:GetService("HttpService"):JSONDecode(b64decode(code:sub(6)))
		end)
		return ok and applyProfile(d)
	end
	function hud:SetHotbar(list)
		for _, c in ipairs(hot:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		list = list or {}
		hot.Size = UDim2.fromOffset(math.max(120, #list * 84 + 16), 52)
		for i, it in ipairs(list) do
			local b = new("TextButton", { Size = UDim2.fromOffset(78, 34), LayoutOrder = i, BackgroundColor3 = DARK, BackgroundTransparency = 0.1, BorderSizePixel = 0, Text = tostring(it.Name or ("Slot " .. i)), TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, ZIndex = 8 }, hot)
			neon(new("UIStroke", { Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b))
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				safe(it.Callback)
			end)
		end
		hot.Visible = #list > 0
		return hot.Visible
	end
	-- a quick demo of the effects (test mode)
	function hud:Demo()
		hud:_damage(25)
		hud:_shake(1.2, 0.5)
		win:Confetti(30)
		hud:ShowBrief("Test mode: damage flash, shake and confetti. Nothing in the game changed.", 5)
	end
	function hud:Show(key, v)
		local p = hud._panels[key]
		if key == "all" then
			for k, f in pairs(hud._panels) do
				if k ~= "brief" and k ~= "compare" and k ~= "hotbar" then
					f.Visible = v ~= false
				end
			end
			return true
		end
		if p then
			p.Visible = v ~= false
			return true
		end
		return false
	end
	function hud:Open()
		if not hud._init then
			hud._init = true
			if not hud:LoadProfile() and o.AutoDetect ~= false then
				pcall(hud.Detect, hud, true)
			end
		end
		hud.IsOpen = true
		gui.Enabled = true
		root.Visible = true
		pcall(refreshData, os.clock())
		if cgui.Enabled then
			cgui.Enabled = false
		end
		local intro = new("UIScale", { Scale = 1.08 }, ui)
		tween(intro, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		task.delay(0.5, function()
			intro:Destroy()
		end)
	end
	function hud:Close()
		hud.IsOpen = false
		gui.Enabled = false
		cgui.Enabled = hud._gameCross == true
		if o.OnClose then
			safe(o.OnClose)
		end
	end
	function hud:Toggle()
		if hud.IsOpen then
			hud:Close()
		else
			hud:Open()
		end
	end
	function hud:Target(q)
		if q == nil or q == "none" or q == "off" then
			setTarget(nil)
			return true, "Target cleared."
		end
		local p = q == "nearest" and (nearest()) or findPlayer(q)
		if not p or p == lp then
			return false, "I can't find that player."
		end
		setTarget(p)
		return true, "Targeting " .. p.DisplayName .. "."
	end
	function hud:Spectate(q)
		local cam = workspace.CurrentCamera
		if not cam then
			return false, "No camera."
		end
		if q == nil or q == "off" or q == "none" then
			local h = hum(lp)
			if h then
				cam.CameraSubject = h
			end
			return true, "Back to your own view."
		end
		local p = q == "nearest" and (nearest()) or findPlayer(q)
		local h = p and hum(p)
		if not h then
			return false, "I can't find that player."
		end
		cam.CameraSubject = h
		return true, "Watching " .. p.DisplayName .. "."
	end
	function hud:GetSummary()
		local h = hum(lp)
		local lines = {}
		table.insert(lines, string.format("You: %s (@%s), health %d/%d, ping %d ms, %d fps.", lp.DisplayName, lp.Name, h and h.Health or 0, h and h.MaxHealth or 100, (function()
			local v = 0
			pcall(function()
				v = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return v
		end)(), fps))
		table.insert(lines, string.format("Server: %d of %d players.", #Players:GetPlayers(), Players.MaxPlayers or 0))
		local near = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local d = distTo(p)
				local ph = hum(p)
				table.insert(near, { p, d or 99999, ph and ph.Health or 0 })
			end
		end
		table.sort(near, function(a, b)
			return a[2] < b[2]
		end)
		for i = 1, math.min(6, #near) do
			local e = near[i]
			table.insert(lines, string.format("Near %d: %s (@%s) %s, %d HP.", i, e[1].DisplayName, e[1].Name, e[2] < 99999 and (math.floor(e[2]) .. " studs") or "unknown distance", e[3]))
		end
		if targetPlayer then
			table.insert(lines, "Target: " .. targetPlayer.DisplayName)
		end
		return table.concat(lines, "\n")
	end
	-- text commands (the AI uses these): "open", "close", "color gold", "crosshair dot", "crosshair game on",
	-- "show players", "hide stats", "target nearest", "target name", "spectate name", "spectate off", "brief"
	function hud:Command(str)
		local w = {}
		for x in tostring(str or ""):lower():gmatch("%S+") do
			table.insert(w, x)
		end
		local cmd, a, b = w[1], w[2], w[3]
		local function cap(s)
			return s and (s:sub(1, 1):upper() .. s:sub(2)) or s
		end
		if cmd == "open" then
			hud:Open()
			win:Toggle(false)
			return true, "HUD open."
		elseif cmd == "close" then
			hud:Close()
			return true, "HUD closed."
		elseif cmd == "toggle" then
			hud:Toggle()
			return true, "Toggled."
		elseif cmd == "color" or cmd == "style" then
			if cap(a) == "Random" then
				a = RebelUI.HudColors[math.random(#RebelUI.HudColors)]:lower()
			end
			return hud:SetColor(cap(a)), "Color: " .. tostring(cap(a))
		elseif cmd == "crosshair" then
			if a == "size" then
				local ok = hud:SetCrosshairSize(RebelUI.CrossSizes[cap(b)] and cap(b) or (b == "xl" and "XL" or tonumber(b)))
				return ok, ok and ("Crosshair size " .. tostring(hud.CrossSize)) or "Use small, medium, large, xl or a number."
			elseif a == "thick" or a == "thickness" then
				hud:SetCrosshairThickness(tonumber(b))
				return true, "Thickness " .. hud.CrossThick
			elseif a == "opacity" or a == "alpha" then
				hud:SetCrosshairOpacity(tonumber(b))
				return true, "Crosshair opacity changed."
			elseif a == "game" then
				hud:CrosshairInGame(b ~= "off")
				return true, "In-game crosshair " .. (b == "off" and "off" or "on") .. "."
			elseif a == "on" or a == "off" then
				hud:CrosshairInGame(a == "on")
				return true, "In-game crosshair " .. a .. "."
			end
			local ok = hud:SetCrosshair(a == "random" and RebelUI.Crosshairs[math.random(#RebelUI.Crosshairs)] or (a == "x" and "X" or cap(a)))
			return ok, ok and "Crosshair changed." or "Unknown crosshair."
		elseif cmd == "show" or cmd == "hide" then
			local ok = hud:Show(a, cmd == "show")
			return ok, ok and (cmd .. " " .. tostring(a)) or "Unknown panel (players, stats, health, profile, crosshair, banner, all)."
		elseif cmd == "target" then
			return hud:Target(table.concat(w, " ", 2))
		elseif cmd == "spectate" or cmd == "watch" then
			return hud:Spectate(table.concat(w, " ", 2))
		elseif cmd == "preset" or cmd == "quality" then
			local ok = hud:SetPreset(cap(a))
			return ok, ok and ("Preset " .. cap(a)) or "Use low, medium, high or extreme."
		elseif cmd == "template" or cmd == "detect" then
			return true, "Template: " .. hud:Detect(true)
		elseif cmd == "save" then
			return hud:SaveProfile(), "Saved the HUD setup for this game."
		elseif cmd == "load" then
			local ok = hud:LoadProfile()
			return ok, ok and "Loaded." or "No saved setup for this game yet."
		elseif cmd == "export" or cmd == "share" then
			return true, "Copied a share code: " .. hud:Export():sub(1, 24) .. "..."
		elseif cmd == "demo" or cmd == "test" then
			hud:Demo()
			return true, "Test mode."
		elseif cmd == "shake" then
			win:ScreenShake(tonumber(a) or 1.5, 0.7)
			return true, "Shake."
		elseif cmd == "compare" then
			hud._cmpOn = a ~= "off"
			return true, "Compare " .. (hud._cmpOn and "on" or "off")
		elseif cmd == "brief" or cmd == "summary" then
			hud:Brief()
			return true, "Brief."
		end
		return false, "Unknown HUD command."
	end
	function hud:Destroy()
		hud._dead = true
		hud.IsOpen = false
		setTarget(nil)
		gui:Destroy()
		cgui:Destroy()
		if win.HUD == hud then
			win.HUD = nil
		end
	end
	if o.Key then
		win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == o.Key then
				hud:Toggle()
			end
		end)
	end
	win:_onTheme(function()
		applyGrads()
		applyColors()
	end)
	hud:SetColor(hud.ColorName)
	hud:SetCrosshair(table.find(RebelUI.Crosshairs, hud.CrossName) and hud.CrossName or "Cross")
	if o.InGameCrosshair then
		hud:CrosshairInGame(true)
	end
	if o.Open then
		hud:Open()
	end
	return hud
end



-- ============================================================ effects: animations, ripples, glow, confetti, shake
-- Win:SetOpenAnimation("Pop"|"Slide"|"Fade"|"Bounce"|"Drop"|"Spin")  Win:SetAnimSpeed(0.5 - 2.5)  Win:SetReduceMotion(bool)
-- Win:SetFx({ Ripple = true, Glow = false, Scan = false, Breathe = true })
-- Win:Confetti(count)  Win:Shake(power, seconds) shakes the panel  Win:ScreenShake(power, seconds) shakes the panel AND the game camera
RebelUI.OpenAnimations = { "Pop", "Slide", "Fade", "Bounce", "Drop", "Spin" }

function Window:SetOpenAnimation(style)
	if table.find(RebelUI.OpenAnimations, style) then
		self.OpenAnim = style
	end
	return self.OpenAnim
end

function Window:SetAnimSpeed(x)
	self.AnimSpeed = math.clamp(tonumber(x) or 1, 0.4, 2.5)
end

function Window:SetReduceMotion(on)
	self.ReduceMotion = on == true
	if self.ReduceMotion then
		self.Fx.Glow, self.Fx.Scan = false, false
		if self._glowDot then
			self._glowDot.Visible = false
		end
		if self._scan then
			self._scan.Visible = false
		end
	end
end

function Window:SetFx(t)
	for k, v in pairs(t or {}) do
		self.Fx[k] = v == true
	end
	if self._scan then
		self._scan.Visible = self.Fx.Scan and self.Open
	end
	if self._glowDot and not self.Fx.Glow then
		self._glowDot.Visible = false
	end
end

function Window:Confetti(n)
	n = math.clamp(math.floor(n or 36), 1, 80)
	if self.ReduceMotion or not self.Gui then
		return
	end
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 450)
	local cols = { Color3.fromRGB(255, 70, 90), Color3.fromRGB(255, 200, 60), Color3.fromRGB(80, 220, 130), Color3.fromRGB(70, 160, 255), Color3.fromRGB(190, 110, 255), Color3.fromRGB(255, 255, 255) }
	for i = 1, n do
		local s = math.random(5, 10)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.random(-60, 60), 0.3, 0),
			Size = UDim2.fromOffset(s, s * (math.random() < 0.5 and 1 or 2)),
			BackgroundColor3 = cols[math.random(#cols)],
			BorderSizePixel = 0,
			Rotation = math.random(0, 360),
			ZIndex = 200,
		}, self.Gui)
		local t = (0.9 + math.random() * 1.0) / (self.AnimSpeed or 1)
		tween(f, t, {
			Position = UDim2.new(0.5, math.random(-vp.X * 0.45, vp.X * 0.45), 0.3, math.random(vp.Y * 0.3, vp.Y * 0.75)),
			Rotation = f.Rotation + math.random(-540, 540),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		task.delay(t + 0.1, function()
			f:Destroy()
		end)
	end
end

function Window:Shake(power, dur)
	if self.ReduceMotion then
		return
	end
	power = math.clamp(tonumber(power) or 1, 0.2, 4)
	dur = math.clamp(tonumber(dur) or 0.5, 0.1, 3)
	local main = self.Main
	if not main then
		return
	end
	if not self._shakeBase then
		self._shakeBase = main.Position
	end
	self._shake = { t0 = os.clock(), dur = dur, p = power }
end

local function cameraShake(power, dur)
	local ok = pcall(function()
		local cam = workspace.CurrentCamera
		local t0 = os.clock()
		local name = "RebelUIShake"
		pcall(function()
			RunService:UnbindFromRenderStep(name)
		end)
		RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, function()
			local k = 1 - (os.clock() - t0) / dur
			if k <= 0 then
				RunService:UnbindFromRenderStep(name)
				return
			end
			local a = power * 0.012 * k
			cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * power * 0.5 * k, (math.random() - 0.5) * power * 0.5 * k, 0) * CFrame.Angles((math.random() - 0.5) * a, (math.random() - 0.5) * a, (math.random() - 0.5) * a)
		end)
	end)
	return ok
end

function Window:ScreenShake(power, dur)
	power = math.clamp(tonumber(power) or 1, 0.2, 4)
	dur = math.clamp(tonumber(dur) or 0.7, 0.1, 3)
	self:Shake(power * 1.4, dur)
	if self.HUD and self.HUD.IsOpen and self.HUD._shake then
		self.HUD:_shake(power, dur)
	end
	if not self.ReduceMotion then
		cameraShake(power, dur)
	end
end

-- called once from CreateWindow
function Window:_initFx()
	local win = self
	win.Fx = { Ripple = true, Glow = false, Scan = false, Breathe = true }
	local main = win.Main
	-- overlay that holds ripples (clipped to the panel)
	local layer = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Active = false, ZIndex = 40 }, main)
	corner(layer, 10)
	local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(110, 110), BackgroundTransparency = 0.88, BorderSizePixel = 0, Visible = false, Active = false, ZIndex = 39 }, layer)
	corner(dot, 110)
	win._glowDot = dot
	win:_onTheme(function(t)
		dot.BackgroundColor3 = t.Glow
	end)
	local scan = new("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.9, BorderSizePixel = 0, Visible = false, Active = false, ZIndex = 38 }, layer)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) }, scan)
	win._scan = scan
	local function local_(p)
		local s = win._scaleObj and win._scaleObj.Scale or 1
		return Vector2.new((p.X - main.AbsolutePosition.X) / s, (p.Y - main.AbsolutePosition.Y) / s)
	end
	local function inside(p)
		local a, s = main.AbsolutePosition, main.AbsoluteSize
		return p.X >= a.X and p.Y >= a.Y and p.X <= a.X + s.X and p.Y <= a.Y + s.Y
	end
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i)
		if win.Open and win.Fx.Ripple and not win.ReduceMotion and isPress(i) and i.Position and inside(i.Position) then
			local p = local_(i.Position)
			local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = win.Theme.Glow, BackgroundTransparency = 0.55, BorderSizePixel = 0, Active = false, ZIndex = 41 }, layer)
			corner(r, 200)
			local t = 0.55 / (win.AnimSpeed or 1)
			tween(r, t, { Size = UDim2.fromOffset(120, 120), BackgroundTransparency = 1 })
			task.delay(t + 0.05, function()
				r:Destroy()
			end)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if win.Open and win.Fx.Glow and not win.ReduceMotion and isMove(i) and i.Position then
			if inside(i.Position) then
				local p = local_(i.Position)
				dot.Position = UDim2.fromOffset(p.X, p.Y)
				dot.Visible = true
			else
				dot.Visible = false
			end
		end
	end)
	-- one hook in the shared frame loop: breathing border, scan line, panel shake
	table.insert(win._frame, function(now)
		local rs = win._ringStroke
		if rs and win.Open then
			rs.Thickness = (win.Fx.Breathe and not win.ReduceMotion) and (1.2 + 0.7 * math.sin(now * 2.2)) or 1
		end
		if win.Fx.Scan and win.Open and not win.ReduceMotion then
			scan.Visible = true
			scan.Position = UDim2.new(0, 0, ((now * 0.22) % 1.2) - 0.1, 0)
		elseif scan.Visible then
			scan.Visible = false
		end
		local sh = win._shake
		if sh then
			local k = 1 - (now - sh.t0) / sh.dur
			if k <= 0 then
				win._shake = nil
				main.Position = win._shakeBase
				win._shakeBase = nil
			else
				local m = 7 * sh.p * k
				main.Position = win._shakeBase + UDim2.fromOffset((math.random() - 0.5) * 2 * m, (math.random() - 0.5) * 2 * m)
			end
		end
	end)
end

-- ============================================================ tools tab: command bar, notes, usage + badges, randomizer, performance, accessibility, votes
-- Win:AddCommand("name", function(args) end, "what it does")  Win:RunCommand("name args")  Win:CreateToolsTab({ Icon, Features = { "Fly", "ESP" }, Tips = { ... } })
function Window:AddCommand(name, fn, desc)
	self._commands = self._commands or {}
	self._commands[tostring(name):lower()] = { fn = fn, desc = desc or "" }
end

function Window:RunCommand(text)
	text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local cmds = self._commands or {}
	local word, rest = text:match("^(%S+)%s*(.*)$")
	if not word then
		return false, "Type a command."
	end
	word = word:lower()
	local hit = cmds[word]
	if not hit then
		local names = {}
		for n in pairs(cmds) do
			names[#names + 1] = n
		end
		table.sort(names)
		for _, n in ipairs(names) do
			if n:sub(1, #word) == word then
				hit = cmds[n]
				break
			end
		end
		if not hit then
			for _, n in ipairs(names) do
				if n:find(word, 1, true) then
					hit = cmds[n]
					break
				end
			end
		end
	end
	if not hit then
		return false, "No command like '" .. word .. "'."
	end
	local ok, res = pcall(hit.fn, rest)
	return ok, ok and (res ~= nil and tostring(res) or "Done.") or tostring(res)
end

function Window:CreateToolsTab(o)
	o = o or {}
	local win = self
	local HttpService = game:GetService("HttpService")
	local tab = win:CreateTab({
		Name = o.Name or "Tools",
		Icon = o.Icon,
		Title = o.Title or "🧰 TOOLS",
		Description = o.Description or "Command bar, notes, stats, randomizer, performance and accessibility.",
	})

	-- built-in commands
	win:AddCommand("confetti", function()
		win:Confetti(50)
	end, "party")
	win:AddCommand("shake", function(a)
		win:ScreenShake(tonumber(a) or 1.5, 0.7)
	end, "shake the screen")
	win:AddCommand("theme", function(a)
		for _, n in ipairs(RebelUI.Themes) do
			if n:lower() == a:lower() then
				win:SetTheme(n)
				return "Theme " .. n
			end
		end
		return "Themes: " .. table.concat(RebelUI.Themes, ", ")
	end, "theme <name>")
	win:AddCommand("anim", function(a)
		for _, n in ipairs(RebelUI.OpenAnimations) do
			if n:lower() == a:lower() then
				win:SetOpenAnimation(n)
				return "Animation " .. n
			end
		end
		return "Animations: " .. table.concat(RebelUI.OpenAnimations, ", ")
	end, "anim <name>")
	win:AddCommand("hud", function(a)
		local h = win.HUD or win:GameAssistant({ Logo = o.Icon or win._icon })
		if a == "" then
			a = "open"
		end
		local ok, m = h:Command(a)
		return m
	end, "hud open / color gold / crosshair dot ...")
	win:AddCommand("close", function()
		win:Toggle(false)
	end, "hide the panel")

	-- ---------- command bar
	tab:Section("Quick command bar")
	local out = tab:Label("Type a command (try: confetti, shake, theme blue, hud open) and press enter.")
	tab:Input({
		Name = "Command",
		Placeholder = "confetti, shake 2, theme blue, hud color gold ...",
		Clear = true,
		Callback = function(text)
			local ok, m = win:RunCommand(text)
			out:Set((ok and "OK: " or "Oops: ") .. tostring(m))
		end,
	})
	tab:Button({ Name = "List commands", Callback = function()
		local names = {}
		for n, c in pairs(win._commands or {}) do
			names[#names + 1] = n .. (c.desc ~= "" and (" - " .. c.desc) or "")
		end
		table.sort(names)
		out:Set(table.concat(names, "\n"))
	end })

	-- ---------- quick notes (saved to a file)
	tab:Section("Quick notes")
	local NOTES = "RebelUI_notes.txt"
	local saved = ""
	pcall(function()
		if isfile and isfile(NOTES) then
			saved = readfile(NOTES)
		end
	end)
	tab:CodeBox({
		Name = "Notes",
		Height = 80,
		Default = saved,
		Placeholder = "Write anything. Tap Save.",
		RunText = "Save",
		Callback = function(text)
			local ok = pcall(function()
				writefile(NOTES, text)
			end)
			win:Notify({ Title = ok and "Saved" or "Can't save", Text = ok and "Notes saved on this device." or "This executor can't write files.", Type = ok and "success" or "warn" })
		end,
	})

	-- ---------- usage tracker and badges
	tab:Section("Your stats and badges")
	local FILE = "RebelUI_usage.json"
	local use = { seconds = 0, opens = 0, badges = {} }
	pcall(function()
		if isfile and isfile(FILE) then
			local d = HttpService:JSONDecode(readfile(FILE))
			if type(d) == "table" then
				use.seconds, use.opens, use.badges = d.seconds or 0, d.opens or 0, d.badges or {}
			end
		end
	end)
	use.opens += 1
	local BADGES = {
		{ "First steps", function() return use.opens >= 1 end },
		{ "Regular", function() return use.opens >= 10 end },
		{ "Veteran", function() return use.opens >= 50 end },
		{ "10 minutes", function() return use.seconds >= 600 end },
		{ "1 hour", function() return use.seconds >= 3600 end },
		{ "10 hours", function() return use.seconds >= 36000 end },
	}
	local shown = tab:Label("")
	local function fmt(s)
		return string.format("%dh %02dm", s // 3600, (s % 3600) // 60)
	end
	local function refresh(announce)
		local lines = { "Time used: " .. fmt(use.seconds) .. "    Sessions: " .. use.opens }
		local have = {}
		for _, b in ipairs(BADGES) do
			if b[2]() then
				have[#have + 1] = b[1]
				if not use.badges[b[1]] then
					use.badges[b[1]] = true
					if announce then
						win:Notify({ Title = "Badge unlocked!", Text = b[1], Type = "success" })
						win:Confetti(40)
					end
				end
			end
		end
		lines[#lines + 1] = "Badges: " .. (#have > 0 and table.concat(have, ", ") or "none yet")
		shown:Set(table.concat(lines, "\n"))
	end
	refresh(false)
	task.spawn(function()
		local n = 0
		while not win._dead do
			task.wait(5)
			use.seconds += 5
			n += 1
			refresh(true)
			if n % 6 == 0 then
				pcall(function()
					writefile(FILE, HttpService:JSONEncode(use))
				end)
			end
		end
	end)

	-- ---------- randomizer
	tab:Section("Randomizer")
	local rr = tab:Label("Tap one.")
	local function say(t)
		rr:Set(t)
		win:Notify({ Title = "Randomizer", Text = t, Duration = 2.5 })
	end
	tab:Button({ Name = "Flip a coin", Callback = function()
		say(math.random() < 0.5 and "Heads" or "Tails")
	end })
	tab:Button({ Name = "Roll a dice (1-6)", Callback = function()
		say("You rolled " .. math.random(6))
	end })
	tab:Button({ Name = "Roll a d20", Callback = function()
		say("You rolled " .. math.random(20))
	end })
	local picks = "pizza, burger, sushi"
	tab:Input({ Name = "Pick one of (comma separated)", Default = picks, Callback = function(t)
		picks = t
	end })
	tab:Button({ Name = "Pick for me", Callback = function()
		local list = {}
		for x in picks:gmatch("[^,]+") do
			x = x:gsub("^%s+", ""):gsub("%s+$", "")
			if x ~= "" then
				list[#list + 1] = x
			end
		end
		say(#list > 0 and ("Go with: " .. list[math.random(#list)]) or "Type some choices first.")
	end })
	tab:Button({ Name = "Random username idea", Callback = function()
		local a = { "Shadow", "Turbo", "Neon", "Pixel", "Ghost", "Rebel", "Cosmic", "Wild" }
		local b = { "Fox", "Blade", "Storm", "Panda", "Rider", "Ninja", "Bolt", "Wolf" }
		say(a[math.random(#a)] .. b[math.random(#b)] .. math.random(10, 99))
	end })

	-- ---------- performance
	tab:Section("Performance monitor")
	tab:Graph({ Name = "FPS", Source = "FPS", Max = 70 })
	tab:Graph({ Name = "Ping", Source = "Ping", Suffix = " ms" })
	tab:Graph({ Name = "Memory", Source = "Memory", Suffix = " MB" })

	-- ---------- accessibility
	tab:Section("Accessibility")
	tab:Toggle({ Name = "High contrast", Description = "Strong colors, easier to read", Flag = "__a11y_contrast", Callback = function(on)
		win:SetTheme(on and "Contrast" or "Red")
	end })
	tab:Toggle({ Name = "Colorblind friendly colors", Flag = "__a11y_cb", Callback = function(on)
		win:SetTheme(on and "Colorblind" or "Red")
	end })
	tab:Toggle({ Name = "Large panel", Description = "Bigger buttons and text", Flag = "__a11y_big", Callback = function(on)
		win:SetScale(on and 1.25 or 1)
	end })
	tab:Toggle({ Name = "Reduce motion", Description = "Fewer animations", Flag = "__a11y_motion", Default = win.ReduceMotion, Callback = function(on)
		win:SetReduceMotion(on)
	end })

	-- ---------- keyboard cheat sheet
	tab:Section("Keyboard cheat sheet")
	tab:Paragraph({
		Title = "Keys",
		Text = (win.ToggleKey and (win.ToggleKey.Name .. "  open / close the panel\n") or "") .. "H  open / close the game assistant (if set)\nEnter  send a chat message or run a command\nPhones: tap the top bar or the round button",
	})

	-- ---------- feature voting (saved on this device) and tips
	tab:Section("Vote for the next feature")
	local VOTES = "RebelUI_votes.json"
	local votes = {}
	pcall(function()
		if isfile and isfile(VOTES) then
			votes = HttpService:JSONDecode(readfile(VOTES)) or {}
		end
	end)
	local features = o.Features or { "More themes", "More crosshairs", "Macro recorder", "Cloud sync", "Sound packs" }
	local vtxt = tab:Label("")
	local function showVotes()
		local l = {}
		for _, f in ipairs(features) do
			l[#l + 1] = f .. ": " .. (votes[f] or 0)
		end
		vtxt:Set(table.concat(l, "\n"))
	end
	showVotes()
	for _, f in ipairs(features) do
		tab:Button({ Name = "Vote: " .. f, Callback = function()
			votes[f] = (votes[f] or 0) + 1
			pcall(function()
				writefile(VOTES, HttpService:JSONEncode(votes))
			end)
			showVotes()
		end })
	end
	local tips = o.Tips or { "Tap the top bar to hide the panel.", "Drag the corner grip to resize.", "Settings has 14 themes and a rainbow HUD.", "Say 'make the crosshair bigger' to the AI.", "Use the command bar for fast actions." }
	local seen = 0
	local tl = tab:Label("Tips seen: 0")
	tab:Button({ Name = "Show a tip", Callback = function()
		seen += 1
		local t = tips[math.random(#tips)]
		tl:Set("Tips seen: " .. seen)
		win:Notify({ Title = "Tip", Text = t, Duration = 4 })
	end })

	-- ---------- safe mode, sandbox, screenshot
	tab:Section("Safety and capture")
	tab:Toggle({ Name = "Safe mode lock", Description = "Blocks dangerous buttons until you turn it off", Flag = "__safemode", Callback = function(on)
		win.SafeMode = on
	end })
	tab:Section("Danger zone")
	tab:Button({
		Name = "DO NOT PRESS",
		Description = "Shakes the whole screen. Tap twice.",
		Danger = true,
		DoubleClick = true,
		Callback = function()
			win:Notify({ Title = "You pressed it", Text = "Everything is fine. Probably.", Type = "warn" })
		end,
	})
	tab:Button({ Name = "Take a screenshot", Description = "Saves to your Roblox captures (if the game allows it)", Callback = function()
		win:Toggle(false)
		task.wait(0.5)
		local ok = pcall(function()
			game:GetService("CaptureService"):CaptureScreenshot(function() end)
		end)
		task.wait(0.6)
		win:Toggle(true)
		win:Notify({ Title = ok and "Screenshot" or "Can't capture", Text = ok and "Taken." or "Your executor or this game blocks it.", Type = ok and "success" or "warn" })
	end })
	return tab
end

-- ============================================================ AI tab (optional: only exists if you call it)
-- local AITab, ai = Win:CreateAITab({ Keys = { "..." }, KeysReversed = false, Name = "AI", Icon = 123, Models = { ... } })
-- A chat with a Gemini bot: intent-aware loading words, voice, memory, 7 styles, /commands, HUD control and summaries.
-- Nothing AI is in this library unless you call this. ai.Ask(contents), ai.Brief(hud, done), ai.Boot(video), ai.Chat
function Window:CreateAITab(o)
	o = o or {}
	local Win = self
	local lp = Players.LocalPlayer
	local LOGO = o.Icon or Win._icon
	local UI = RebelUI
	local api = {}
	local AI = Win:CreateTab({
		Name = o.Name or "AI",
		Icon = LOGO,
		Title = o.Title or "🤖 REBEL AI",
		Description = o.Description or "Chat with the bot. It can talk back too.",
	})
	local POOL = {}
	for _, k in ipairs(o.Keys or {}) do
		if type(k) == "string" and #k > 10 then
			POOL[#POOL + 1] = o.KeysReversed and k:reverse() or k
		end
	end
	if #POOL == 0 then
		AI:Notice({ Type = "warn", Title = "AI is off", Text = "Pass Keys = { ... } to Win:CreateAITab to turn the bot on." })
		return AI, api
	end
	local function hudOf()
		return Win.HUD or Win:GameAssistant({ Logo = LOGO })
	end
	local HttpService = game:GetService("HttpService")
	local SoundService = game:GetService("SoundService")
	local getReq = (syn and syn.request) or request or http_request or (http and http.request)

	local MODELS = o.Models or { "gemini-flash-lite-latest", "gemini-2.5-flash-lite", "gemini-flash-latest", "gemini-2.5-flash", "gemini-2.0-flash" }
	local API = "https://generativelanguage.googleapis.com/v1beta/models/"
	local MEMFILE = "RebelAI_memory.txt"

	local PERSONAS = {
		["Rebel (default)"] = "Be warm, quick-witted and a bit playful.",
		["Chaos gremlin"] = "Be gloriously unhinged and funny, with wild energy, but still actually helpful.",
		["Scripter"] = "Be a sharp Luau mentor. Prefer short, correct, working code in ```lua blocks.",
		["Teacher"] = "Explain patiently with simple steps and tiny examples. Check the player understood.",
		["Sarcastic"] = "Be dry, sarcastic and clever, never cruel, and still give the real answer.",
		["Professional"] = "Be precise, calm and professional. Structured, no slang.",
		["Roleplay"] = "Stay fully in whatever character or story the player sets up. Remember every story detail and never break character unless asked.",
		["Tutor"] = "Be a patient AI tutor: teach in tiny steps, give one exercise at a time, check the player's answer, then go one level up.",
		["Designer"] = "Be a creative design assistant: palettes with hex codes, layouts, motion ideas, and bold original touches.",
		["Debugger"] = "Be a calm debugging assistant: ask for the missing detail only if you must, list likely causes ranked, give the quickest test first.",
	}
	local opt = { deep = false, web = false, refine = false, reason = false }
	local persona = "Rebel (default)"
	local replyLang = "English"
	local AITOOLS = {}
	local memory = ""
	pcall(function()
		if isfile and isfile(MEMFILE) then
			memory = readfile(MEMFILE):sub(1, 1500)
		end
	end)

	local SYSTEM = table.concat({
		"You are Rebel AI, the assistant inside the Rebelwar panel (made by prorizz196), running in Roblox through an executor on a phone.",
		"Talk like Claude: natural, warm, curious, honest and direct. Short paragraphs, plain words, no corporate filler, no lecturing, no begging for follow-ups.",
		"Match the player's language and mood. Answer the actual question first, then add a spark of personality. Think carefully and be correct; if unsure, say so.",
		"Keep replies compact (phones are small): usually under 120 words unless they ask for depth. Use **bold** and `code` sparingly. Code goes in fenced blocks.",
		"You love bizarre, original ideas: when asked for ideas, give surprising, specific, slightly absurd ones that could really be built or played (not generic lists).",
		"You can help with Roblox, Luau, game ideas, school, life, jokes, stories, math, anything. Never invent facts about the game or the panel.",
		"Hidden tags, put at the very end of a reply, never mention them: [[remember: one short fact about the player, only if it is durable and they said it]] and [[next: short follow-up 1 | short follow-up 2 | short follow-up 3]] (each under 28 characters, written as things the player might tap).",
		"You control the player's full-screen Game Assistant HUD. To do something, add hidden tags at the end: [[hud: open]], [[hud: close]], [[hud: color gold]] (rainbow, theme, red, cyan, lime, gold, pink, violet, random), [[hud: crosshair dot]] (cross, dot, circle, chevron, diamond, x, random), [[hud: crosshair on]] or off (keeps it on the game view), [[hud: show players]] or [[hud: hide stats]] (players, stats, health, profile, crosshair), [[hud: target nearest]] or a player's name, [[hud: spectate name]] or off. Only use a tag when the player asks for it, and say in words what you did. The HUD shows: players list on the right, your health bottom-left, your stats (ping, fps, battery) middle-left, your profile bottom-right, a radar crosshair in the middle.",
	}, " ")

	local mood
	local function detectMood(t)
		local l = t:lower()
		if l:find("ugh") or l:find("angry") or l:find("annoy") or l:find("hate") or l:find("doesn't work") or l:find("doesnt work") or l:find("!!!") then
			return "frustrated"
		elseif l:find("sad") or l:find("lonely") or l:find("depress") or l:find("cry") then
			return "sad"
		elseif l:find("tired") or l:find("bored") then
			return "tired or bored"
		elseif l:find("lol") or l:find("haha") or l:find("awesome") or l:find("love") or l:find("yay") then
			return "happy"
		end
		return nil
	end
	local function system()
		local s = SYSTEM .. " " .. PERSONAS[persona]
		if replyLang ~= "English" then
			s ..= " Always reply in " .. replyLang .. " (keep code and command names as they are)."
		end
		if memory ~= "" then
			s ..= "\nThings you know about this player (use them naturally):\n" .. memory
		end
		if Win.HUD then
			s ..= "\nLive game info (from the HUD, may be a second old):\n" .. Win.HUD:GetSummary()
		end
		local gname = "a Roblox game"
		pcall(function()
			gname = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
		end)
		s ..= "\nContext: the player is in " .. gname .. " with " .. #game:GetService("Players"):GetPlayers() .. " players."
		if opt.reason then
			s ..= "\nShow your reasoning briefly as numbered steps before the final answer, labelled **Steps** and **Answer**."
		end
		if mood then
			s ..= "\nThe player seems " .. mood .. ". Read the emotion and adjust your tone to it, kindly and without announcing it."
		end
		return s
	end

	-- what is the player after? picks the loading words
	local PHRASES = {
		code = { "Reading your problem", "Writing Luau", "Checking it compiles in my head", "Hunting for bugs", "Polishing the code" },
		idea = { "Shaking the idea jar", "Mixing two bad ideas into a good one", "Asking my inner gremlin", "Making it weirder", "Stirring in chaos" },
		explain = { "Finding the simple way to say it", "Untangling this", "Picking a good example", "Making it click" },
		story = { "Setting the scene", "Inventing characters", "Sharpening the plot twist", "Writing" },
		joke = { "Warming up my comedy", "Timing the punchline", "Rolling a pun", "Ruining a perfectly good word" },
		math = { "Crunching numbers", "Double-checking the math", "Carrying the one" },
		roast = { "Sharpening a friendly roast", "Finding gentle burns", "Being mean, nicely" },
		summary = { "Reading our chat", "Scanning the server", "Connecting the dots", "Writing your briefing" },
		hello = { "Waking up", "Stretching", "Saying hi" },
		default = { "Thinking", "Reading what you wrote", "Looking for the best answer", "Putting it into words" },
	}
	local function intent(t)
		local l = t:lower()
		local function has(...)
			for _, w in ipairs({ ... }) do
				if l:find(w, 1, true) then
					return true
				end
			end
		end
		if has("script", "luau", "lua", "code", "function", "bug", "error", "```") then
			return "code"
		elseif has("idea", "bizarre", "weird", "invent", "brainstorm", "something cool", "surprise") then
			return "idea"
		elseif has("story", "poem", "write me", "imagine") then
			return "story"
		elseif has("joke", "funny", "pun", "meme") then
			return "joke"
		elseif has("summary", "brief", "recap") then
			return "summary"
		elseif has("roast") then
			return "roast"
		elseif has("calculate", "solve", "math", " + ", " * ", "equation") then
			return "math"
		elseif has("explain", "how does", "why ", "what is", "what's", "teach") then
			return "explain"
		elseif #l < 14 and has("hi", "hello", "hey", "yo", "sup") then
			return "hello"
		end
		return "default"
	end

	local WORDS = {
		"a haunted vending machine", "gravity that sneezes", "a polite volcano", "a pet cloud", "backwards elevators",
		"a bakery for ghosts", "a spy pigeon", "a sentient staircase", "socks that teleport", "a lazy black hole",
		"a disco in a lighthouse", "a moon with a tax office", "a shy tornado", "a robot gardener", "a talking doorknob",
		"a fog-powered train", "a bouncy castle dungeon", "a museum of lost sounds", "a duel with a mirror", "a time-travelling potato",
	}
	local function bizarrePrompt()
		local a, b = WORDS[math.random(#WORDS)], WORDS[math.random(#WORDS)]
		return ("Give me ONE truly bizarre but buildable Roblox game idea that mixes %s and %s. Name it, give the core mechanic in two sentences, and one unexpected twist."):format(a, b)
	end

	-- ---- Gemini call: tries models and connections until one answers ----
	local keyStart = math.random(#POOL)
	local cool, dead = {}, {}
	local function extract(data)
		local out = {}
		local c = data and data.candidates and data.candidates[1]
		local parts = c and c.content and c.content.parts
		for _, p in ipairs(parts or {}) do
			if type(p.text) == "string" and not p.thought then
				table.insert(out, p.text)
			end
		end
		return table.concat(out)
	end
	local function ask(contents, o)
		o = o or {}
		if not getReq then
			return nil, "This executor can't make web requests."
		end
		local tries, last = 0, "no answer"
		for mi, model in ipairs(MODELS) do
			if not dead[model] then
				for k = 0, #POOL - 1 do
					local ki = (keyStart - 1 + k) % #POOL + 1
					local id = ki .. model
					if (cool[id] or 0) <= os.clock() then
						tries += 1
						if tries > 14 then
							return nil, last
						end
						local useWeb = o.web and not dead.web
						local body = {
							tools = useWeb and { { google_search = {} } } or nil,
							systemInstruction = { parts = { { text = o.sys or system() } } },
							contents = contents,
							generationConfig = {
								maxOutputTokens = o.max or 700,
								temperature = o.temp or 1,
								thinkingConfig = { thinkingBudget = o.think or 0 },
							},
						}
						local ok, res = pcall(getReq, {
							Url = API .. model .. ":generateContent",
							Method = "POST",
							Headers = { ["Content-Type"] = "application/json", ["x-goog-api-key"] = POOL[ki] },
							Body = HttpService:JSONEncode(body),
						})
						if ok and res then
							local okD, data = pcall(HttpService.JSONDecode, HttpService, res.Body or "")
							if okD and type(data) == "table" then
								if data.error then
									local code = res.StatusCode or data.error.code or 0
									last = tostring(data.error.message or "error"):gsub("AIza[%w%-_]+", ""):sub(1, 90)
									if useWeb and tostring(data.error.message):lower():find("search") then
										dead.web = true
										return ask(contents, o)
									end
									if code == 404 then
										dead[model] = true
										break
									end
									cool[id] = os.clock() + (code == 429 and 30 or 120)
								else
									local text = extract(data)
									if text ~= "" then
										keyStart = ki
										return text
									end
									last = "empty answer"
									cool[id] = os.clock() + 5
								end
							else
								last = "bad reply (" .. tostring(res.StatusCode) .. ")"
								cool[id] = os.clock() + 20
							end
						else
							last = "request failed"
							cool[id] = os.clock() + 10
						end
					end
				end
			end
		end
		return nil, last
	end

	-- ---- voice: speaks the bot's replies with Google Translate's voice ----
	local voiceOn, voiceSpeed, voiceLang = false, 1, "en"
	local sound, speakId = nil, 0
	local function stopVoice()
		speakId += 1
		if sound then
			pcall(function()
				sound:Stop()
			end)
		end
	end
	local function speak(text)
		stopVoice()
		local my = speakId
		text = text:gsub("```.-```", " code block. "):gsub("[%*`#_]", ""):gsub("%s+", " ")
		if text == "" or not getReq or not getcustomasset or not writefile then
			return false
		end
		task.spawn(function()
			local chunks = {}
			for s in text:gmatch("[^%.%!%?\n]+[%.%!%?]*") do
				while #s > 180 do
					local cut = s:sub(1, 180):match("^.*()%s") or 180
					table.insert(chunks, s:sub(1, cut))
					s = s:sub(cut + 1)
				end
				if s:match("%S") then
					table.insert(chunks, s)
				end
			end
			for i = 1, math.min(#chunks, 8) do
				if my ~= speakId then
					return
				end
				local ok, res = pcall(getReq, {
					Url = "https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=" .. voiceLang .. "&q=" .. HttpService:UrlEncode(chunks[i]),
					Method = "GET",
				})
				if ok and res and res.Body and #res.Body > 200 then
					local file = "RebelAI_voice" .. (i % 2) .. ".mp3"
					pcall(writefile, file, res.Body)
					local okA, asset = pcall(getcustomasset, file)
					if okA and my == speakId then
						if not sound then
							sound = Instance.new("Sound")
							sound.Name = "RebelAIVoice"
							sound.Parent = SoundService
						end
						sound.SoundId = asset
						sound.PlaybackSpeed = voiceSpeed
						sound.Volume = 1.2
						sound:Play()
						local t0 = os.clock()
						repeat
							task.wait(0.1)
						until my ~= speakId or not sound.IsPlaying and os.clock() - t0 > 0.6 or os.clock() - t0 > 14
					end
				end
			end
		end)
		return true
	end

	-- ---- the tab ----
	local history = {}
	local busy = false
	local chat

	local function finish(reply)
		local remember = reply:match("%[%[remember:%s*(.-)%]%]")
		local nxt = reply:match("%[%[next:%s*(.-)%]%]")
		for hc in reply:gmatch("%[%[hud:%s*(.-)%]%]") do
			if Win.HUD then
				pcall(Win.HUD.Command, Win.HUD, hc)
			end
		end
		reply = reply:gsub("%[%[.-%]%]", ""):gsub("%s+$", "")
		if remember and #remember > 2 and not memory:find(remember, 1, true) then
			memory = (memory .. "\n- " .. remember):sub(-1500)
			pcall(function()
				writefile(MEMFILE, memory)
			end)
		end
		local chips = {}
		for c in (nxt or ""):gmatch("[^|]+") do
			c = c:gsub("^%s+", ""):gsub("%s+$", "")
			if c ~= "" and #chips < 3 then
				table.insert(chips, c)
			end
		end
		return reply, chips
	end

	local STARTERS = { "/summary", "/gen a simple fly script", "Give me a bizarre idea", "/plan make a simple obby", "/explain how Luau tables work", "Tell me a joke", "Surprise me" }

	local function send(text)
		if busy then
			return
		end
		local cmd = text:lower()
		local forceThink, forceWeb
		local tname, targ = text:match("^/(%a+)%s*(.*)$")
		local tool = tname and AITOOLS[tname:lower()]
		if tool then
			if targ == "" and tool.hint then
				chat:Add("system", "Usage: /" .. tname:lower() .. " " .. tool.hint)
				return
			end
			text = (tool.prompt:gsub("%%s", function()
				return targ
			end))
			forceThink, forceWeb = tool.think, tool.web
			cmd = ""
		end
		if cmd == "/clear" then
			history = {}
			chat:Clear()
			chat:Add("system", "Chat cleared.")
			return
		elseif cmd == "/stop" then
			stopVoice()
			return
		elseif cmd == "/assist" or cmd == "/hud" then
			Win:Toggle(false)
			hudOf():Open()
			return
		elseif cmd:sub(1, 5) == "/hud " then
			local ok, m = hudOf():Command(text:sub(6))
			chat:Add("system", m or (ok and "Done." or "No."))
			return
		elseif cmd == "/summary" then
			text = "Make a cool briefing card. Use exactly these four lines, each under 20 words, each starting with a bold label: **Chat** (what we talked about so far), **Game** (what is happening around me right now, from the live game info), **Vibe** (one fun word and why), **Next move** (the single best thing I should do or try). Add one small emoji per line."
		elseif cmd == "/bizarre" then
			text = bizarrePrompt()
		elseif cmd:sub(1, 6) == "/plan " then
			text = "Make a complete plan for this goal: " .. text:sub(7) .. ". Give numbered steps, what to build first, the code or files if it is a script, and how to run it. Be concrete."
		elseif cmd:sub(1, 11) == "/summarize " then
			text = "Summarize this in 3 short bullets, then a one-line takeaway:\n" .. text:sub(12)
		elseif cmd:sub(1, 11) == "/translate " then
			text = "Translate this naturally and keep the tone. If the target language isn't named, translate to English; then add the language you detected:\n" .. text:sub(12)
		elseif cmd:sub(1, 9) == "/explain " then
			text = "Teach me this like a great teacher: a one-line gist, the idea step by step, one example, then one question to check I understood: " .. text:sub(10)
		elseif cmd:sub(1, 10) == "/forecast " then
			text = "Simulate what would happen if: " .. text:sub(11) .. ". Give the most likely outcome, a surprising outcome, the risks and a probability for each."
		elseif cmd:sub(1, 7) == "/teach " then
			local fact = text:sub(8)
			memory = (memory .. "\n- " .. fact):sub(-1500)
			pcall(function()
				writefile(MEMFILE, memory)
			end)
			chat:Add("bot", "Got it. I'll remember: **" .. fact .. "**", { Instant = true })
			return
		elseif cmd:sub(1, 10) == "/parallel " then
			local jobs = {}
			for j in text:sub(11):gmatch("[^|]+") do
				table.insert(jobs, (j:gsub("^%s+", ""):gsub("%s+$", "")))
			end
			if #jobs > 1 then
				busy = true
				chat:SetBusy(true)
				chat:SetStatus("Working on " .. #jobs .. " things at once")
				local res, left = {}, #jobs
				for i, j in ipairs(jobs) do
					task.spawn(function()
						local okJ, rJ = pcall(ask, { { role = "user", parts = { { text = j } } } }, { max = 500, web = opt.web })
						res[i] = okJ and rJ or "(no answer)"
						left -= 1
					end)
				end
				task.spawn(function()
					while left > 0 do
						task.wait(0.1)
					end
					chat:SetStatus(nil)
					busy = false
					chat:SetBusy(false)
					for i, j in ipairs(jobs) do
						chat:Add("bot", "**" .. j .. "**\n" .. (res[i]:gsub("%[%[.-%]%]", "")), { Speed = 200 })
					end
				end)
				return
			end
		elseif cmd == "/help" then
			chat:Add("bot", "Just talk to me. Tap the chips for quick replies.\n- **/bizarre** weird idea\n- **/plan** a goal: full step-by-step plan\n- **/explain** a topic: I teach it\n- **/forecast** what if X happens\n- **/summarize** or **/translate** some text\n- **/parallel** a | b | c: several jobs at once\n- **/teach** a fact: I remember it\n- **/summary** a cool briefing of our chat and the game\n- **/assist** opens the full game assistant, **/hud color gold** controls it (or just ask me)\n- **/gen** make a script, **/fix**, **/review**, **/refactor**, **/debug**, **/secure**, **/comment** work on code you paste\n- **/docs** an API, **/tutor** a topic, **/design** something, **/tips**, **/ideas** a topic\nOr use the **Code lab** below.\n- **/clear**, **/stop**\nTurn on **Live web** for fresh facts, **Think deeper** for hard problems, **Voice** to hear me.", { Instant = true })
			return
		end
		busy = true
		chat:SetBusy(true)
		chat:SetChips({})
		local list = PHRASES[intent(text)]
		local alive = true
		task.spawn(function()
			local i = math.random(#list)
			while alive do
				chat:SetStatus(list[i])
				i = i % #list + 1
				task.wait(1.1)
			end
		end)
		mood = detectMood(text)
		table.insert(history, { role = "user", parts = { { text = text } } })
		while #history > 16 do
			table.remove(history, 1)
		end
		task.spawn(function()
			local it = intent(text)
			local hard = it == "code" or it == "math" or opt.deep
			local deep = hard or forceThink
			local reply, err = ask(history, { think = deep and 1024 or 0, max = deep and 2400 or 900, web = opt.web or forceWeb })
			if reply and opt.refine and #reply > 80 then
				list = { "Double-checking my answer", "Hunting for mistakes", "Polishing it" }
				local fixed = ask({ { role = "user", parts = { { text = "Review this draft answer to the player's message for mistakes, missing steps or anything unclear. Return ONLY the improved final answer (keep any [[...]] tags at the end). If it is already right, return it unchanged.\n\nPlayer: " .. text .. "\n\nDraft:\n" .. reply } } } }, { think = 512, max = 1600 })
				if fixed then
					reply = fixed
				end
			end
			alive = false
			chat:SetStatus(nil)
			busy = false
			chat:SetBusy(false)
			if not reply then
				table.remove(history)
				chat:Add("bot", "I couldn't reach my brain just now (" .. tostring(err) .. "). Tap Retry or send it again.", { Instant = true })
				chat:SetChips({ "Retry" })
				chat._last = text
				return
			end
			local clean, chips = finish(reply)
			table.insert(history, { role = "model", parts = { { text = clean } } })
			chat:Add("bot", clean, { Speed = 160 })
			chat:SetChips(#chips > 0 and chips or STARTERS)
			if voiceOn then
				speak(clean)
			end
		end)
	end

	local origSend = send
	send = function(text)
		if text == "Retry" and chat._last then
			text = chat._last
		end
		origSend(text)
	end

	chat = AI:Chat({
		Name = "Rebel AI",
		Height = 250,
		Placeholder = "Ask me anything...",
		OnSend = function(text)
			send(text)
		end,
		Actions = {
			{ Name = "Speak", Callback = function(t)
				if not speak(t) then
					Win:Notify({ Title = "Voice", Text = "This executor can't play sound files.", Type = "warn" })
				end
			end },
		},
	})
	chat:Add("bot", "Hey, I'm **Rebel AI**. Ask me anything, or tap **Bizarre idea** and let's invent something weird. I can write Luau, tell stories, explain things, and talk out loud if you turn Voice on.", { Instant = true })
	chat:SetChips(STARTERS)

	-- the HUD's AI BRIEF button: a short tactical summary written by the bot
	api.Brief = function(hud, done)
		task.spawn(function()
			local r = ask({ { role = "user", parts = { { text = "Write a punchy 3-line tactical brief (max 45 words total, no markdown, no tags) about my situation right now, using the live game info. Start with the most important thing." } } } }, { max = 200, temp = 0.9 })
			done(r and (r:gsub("%[%[.-%]%]", "")) or hud:GetSummary())
		end)
	end
	AI:Section("Fun")
	AI:Button({ Name = "AI summary", Description = "A cool briefing of our chat and the game", Callback = function()
		chat:Submit("/summary")
	end })
	AI:Button({ Name = "Open game assistant", Description = "The full-screen HUD (or press H)", Callback = function()
		Win:Toggle(false)
		hudOf():Open()
	end })
	AI:Button({ Name = "Bizarre idea", Description = "A random wild game idea", Callback = function()
		chat:Submit(bizarrePrompt())
	end })
	-- ---------- code lab: paste code, then explain / fix / review / refactor / scan it. Offline tools work without the AI.
	AI:Section("Code lab")
	local lab = AI:CodeBox({ Name = "Code lab", Height = 120, Placeholder = "Paste or write Luau here. Run runs it.", RunText = "Run" })
	local EXAMPLES = {
		["Speed boost"] = "local h = game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')\nh.WalkSpeed = 40",
		["Infinite jump"] = "local UIS = game:GetService('UserInputService')\nUIS.JumpRequest:Connect(function()\n\tlocal c = game.Players.LocalPlayer.Character\n\tif c then c:FindFirstChildOfClass('Humanoid'):ChangeState(Enum.HumanoidStateType.Jumping) end\nend)",
		["Anti AFK"] = "local vu = game:GetService('VirtualUser')\ngame.Players.LocalPlayer.Idled:Connect(function()\n\tvu:CaptureController()\n\tvu:ClickButton2(Vector2.new())\nend)",
		["Player highlights"] = "for _, p in ipairs(game.Players:GetPlayers()) do\n\tif p ~= game.Players.LocalPlayer and p.Character then\n\t\tlocal h = Instance.new('Highlight')\n\t\th.FillTransparency = 0.7\n\t\th.Parent = p.Character\n\tend\nend",
		["Fullbright"] = "local L = game:GetService('Lighting')\nL.Brightness = 2\nL.ClockTime = 14\nL.GlobalShadows = false",
		["Click teleport"] = "local m = game.Players.LocalPlayer:GetMouse()\nm.Button1Down:Connect(function()\n\tif game:GetService('UserInputService'):IsKeyDown(Enum.KeyCode.LeftControl) then\n\t\tgame.Players.LocalPlayer.Character:MoveTo(m.Hit.Position)\n\tend\nend)",
		["Show FPS in console"] = "local rs = game:GetService('RunService')\nlocal n, t = 0, os.clock()\nrs.RenderStepped:Connect(function()\n\tn += 1\n\tif os.clock() - t >= 1 then print('FPS', n) n, t = 0, os.clock() end\nend)",
	}
	local exNames = {}
	for k in pairs(EXAMPLES) do
		exNames[#exNames + 1] = k
	end
	table.sort(exNames)
	AI:Dropdown({ Name = "One-click example", Options = exNames, Default = exNames[1], Callback = function(v)
		if EXAMPLES[v] then
			lab:Set(EXAMPLES[v])
			Win:Notify({ Title = "Example loaded", Text = v .. ": tap Run, or ask the AI to explain it.", Type = "success" })
		end
	end })
	local ACTIONS = {
		["Explain"] = "Explain this code line by line in simple words, then say what it does overall:",
		["Find and fix errors"] = "Find every bug or error in this code. Say what was wrong, then give the corrected code in a ```lua block:",
		["Review"] = "Review this code like a senior engineer: 3 biggest problems, 2 good things, then a better version:",
		["Refactor"] = "Refactor this for readability and speed without changing what it does. Show the new code and list what changed:",
		["Add comments"] = "Add clear, short comments to this code and return it in a ```lua block:",
		["Security scan (AI)"] = "Security scan this script: webhooks, cookie or token stealing, hidden loadstring or HttpGet, obfuscation, remote spam. Give a risk rating (Low / Medium / High) and the exact patterns that worry you:",
		["Make it faster"] = "Optimize this for performance (fewer allocations, no busy loops, cache lookups). Show the code and explain the gains:",
		["Convert to Luau"] = "Convert this code to clean Roblox Luau and explain any differences:",
		["Write tests"] = "Write small test cases (as Luau asserts) for this code:",
	}
	local actNames = { "Explain", "Find and fix errors", "Review", "Refactor", "Add comments", "Security scan (AI)", "Make it faster", "Convert to Luau", "Write tests" }
	local act = "Explain"
	AI:Dropdown({ Name = "AI action", Options = actNames, Default = "Explain", Callback = function(v)
		act = v
	end })
	local function labCode()
		local c = lab:Get() or ""
		if not c:match("%S") then
			Win:Notify({ Title = "Code lab", Text = "Put some code in the box first.", Type = "warn" })
			return nil
		end
		return c
	end
	AI:Button({ Name = "Ask AI about this code", Description = "Uses the action above", Callback = function()
		local c = labCode()
		if c then
			local n = select(2, c:gsub("\n", "\n")) + 1
			chat:Add("user", act .. " (" .. n .. " lines from the Code lab)")
			send(ACTIONS[act] .. "\n```lua\n" .. c .. "\n```")
		end
	end })
	AI:Button({ Name = "Check syntax (offline)", Description = "Finds the broken line without the AI", Callback = function()
		local c = labCode()
		if not c then
			return
		end
		if type(loadstring) ~= "function" then
			Win:Notify({ Title = "Can't check", Text = "This executor has no loadstring.", Type = "warn" })
			return
		end
		local fn, err = loadstring(c)
		if fn then
			chat:Add("bot", "No syntax errors found. The code compiles.", { Instant = true })
		else
			local ln = tonumber(tostring(err):match(":(%d+):"))
			local lines = {}
			for l in (c .. "\n"):gmatch("(.-)\n") do
				lines[#lines + 1] = l
			end
			local msg = "**Syntax error**" .. (ln and (" on line " .. ln) or "") .. "\n`" .. tostring(err):gsub("^.-:%d+:%s*", "") .. "`"
			if ln and lines[ln] then
				msg ..= "\n```lua\n>> " .. lines[ln] .. "\n```"
			end
			chat:Add("bot", msg, { Instant = true, Error = true })
		end
	end })
	local function formatLua(src)
		local out, lvl = {}, 0
		for line in (src .. "\n"):gmatch("(.-)\n") do
			local t = line:gsub("^%s+", ""):gsub("%s+$", "")
			if t == "" then
				out[#out + 1] = ""
			else
				local first = t:match("^(%a+)")
				if first == "end" or first == "else" or first == "elseif" or first == "until" or t:match("^[%)%}%]]") then
					lvl = math.max(0, lvl - 1)
				end
				out[#out + 1] = string.rep("\t", lvl) .. t
				local s = t:gsub("%-%-.*$", "")
				local inc = false
				if first == "else" or first == "elseif" then
					inc = true
				elseif s:match("%f[%w]then%s*$") or s:match("%f[%w]do%s*$") or s:match("%f[%w]repeat%s*$") then
					inc = true
				elseif s:match("%f[%w]function%f[%W]") and not s:match("%f[%w]end[%s%)%,;]*$") then
					inc = true
				elseif s:match("[%{%(]%s*$") then
					inc = true
				end
				if inc then
					lvl += 1
				end
			end
		end
		return table.concat(out, "\n")
	end
	AI:Button({ Name = "Format code", Description = "Tidies the indentation", Callback = function()
		local c = labCode()
		if c then
			lab:Set(formatLua(c))
			Win:Notify({ Title = "Formatted", Type = "success", Duration = 2 })
		end
	end })
	local RISKS = {
		{ "discord%.com/api/webhooks", "sends data to a Discord webhook", 3 },
		{ "webhook", "mentions a webhook", 2 },
		{ "roblosecurity", "touches the login cookie (account theft)", 3 },
		{ "loadstring%s*%(%s*game:httpget", "runs code downloaded from the internet", 2 },
		{ "httpget", "downloads from the internet", 1 },
		{ "request%s*%(", "sends web requests", 1 },
		{ "setclipboard", "writes to your clipboard", 1 },
		{ "getfenv", "reads the environment (often used to hide things)", 1 },
		{ "string%.char", "builds text from numbers (common in obfuscation)", 1 },
		{ "\\%d%d?%d?\\%d%d?%d?\\%d%d?%d?", "heavily escaped text (obfuscation)", 2 },
		{ "fireserver", "fires remotes (can be abused)", 1 },
		{ "%.kick", "kicks players", 1 },
		{ "password", "mentions passwords", 2 },
		{ "token", "mentions tokens", 1 },
		{ "while%s+true%s+do%s*\n?%s*[^\n]*\n?%s*end", "a loop with no wait (can freeze the game)", 2 },
	}
	AI:Button({ Name = "Security scan (offline)", Description = "Checks for risky patterns, no AI needed", Callback = function()
		local c = labCode()
		if not c then
			return
		end
		local low, found, score = c:lower(), {}, 0
		for _, r in ipairs(RISKS) do
			local n = select(2, low:gsub(r[1], ""))
			if n > 0 then
				found[#found + 1] = "- " .. r[2] .. " (" .. n .. "x)"
				score += r[3]
			end
		end
		local level = score >= 5 and "HIGH" or score >= 2 and "MEDIUM" or "LOW"
		chat:Add("bot", "**Security scan: " .. level .. " risk**\n" .. (#found > 0 and table.concat(found, "\n") or "Nothing suspicious found.") .. "\nThis only checks patterns. Ask the AI to review it for a deeper look.", { Instant = true, Error = level == "HIGH" })
	end })

	-- ---------- more AI commands: type them in the chat
	AITOOLS.fix = { prompt = "Find and fix the bug or error in this. Say what was wrong in one line, then give the corrected code in a ```lua block.\n%s", hint = "<code or error message>", think = true }
	AITOOLS.gen = { prompt = "Write a complete, working Roblox Luau script for: %s. It runs client-side in an executor. Clean structure, short comments, one ```lua block, then 2 lines on how to use it.", hint = "<what the script should do>", think = true }
	AITOOLS.review = { prompt = "Review this Luau like a senior engineer: the 3 biggest problems, 2 good things, then a short improved version.\n%s", hint = "<code>", think = true }
	AITOOLS.refactor = { prompt = "Refactor this for readability and speed without changing behaviour. New code in a ```lua block, then 3 bullets on what changed.\n%s", hint = "<code>", think = true }
	AITOOLS.debug = { prompt = "Act as my debugging assistant. For this problem list the most likely causes, ranked, and the quickest test for each: %s", hint = "<what goes wrong>", think = true }
	AITOOLS.secure = { prompt = "Security scan this script: webhooks, cookie or token stealing, hidden loadstring/HttpGet, obfuscation, remote spam, account risks. Give a risk rating (Low/Medium/High) and the exact patterns that worry you.\n%s", hint = "<code>", think = true }
	AITOOLS.comment = { prompt = "Add clear, short comments to this code and return it in a ```lua block.\n%s", hint = "<code>" }
	AITOOLS.docs = { prompt = "Look up the official Roblox documentation for: %s. Give the key API, a tiny example, and one gotcha.", hint = "<API or topic>", web = true }
	AITOOLS.tips = { prompt = "Give me 5 best-practice tips for writing safe, fast Luau for executors, one line each. Topic (optional): %s" }
	AITOOLS.tutor = { prompt = "Be my tutor on: %s. Start lesson 1: simple words, one tiny example, then one exercise. Wait for my answer before going on.", hint = "<topic>" }
	AITOOLS.design = { prompt = "Be my creative design assistant for: %s. Give a color palette (hex codes), a layout idea, 3 details that make it feel premium, and one bold surprising touch.", hint = "<what to design>" }
	AITOOLS.ideas = { prompt = "Give me 5 bizarre but buildable ideas about: %s. One line each, make them specific.", hint = "<topic>" }

	AI:Section("Brain")
	AI:Toggle({ Name = "Think deeper", Description = "Slower, better on hard problems", Flag = "aiDeep", Callback = function(v)
		opt.deep = v
	end })
	AI:Toggle({ Name = "Live web", Description = "Searches the web for fresh facts", Flag = "aiWeb", Callback = function(v)
		opt.web = v
	end })
	AI:Toggle({ Name = "Double-check answers", Description = "Reviews and fixes its own answer first", Flag = "aiRefine", Callback = function(v)
		opt.refine = v
	end })
	AI:Toggle({ Name = "Show its steps", Description = "Explains how it got the answer", Flag = "aiReason", Callback = function(v)
		opt.reason = v
	end })
	AI:Section("Voice")
	AI:Toggle({ Name = "Voice (talk back)", Description = "I read my answers out loud", Flag = "aiVoice", Callback = function(on)
		voiceOn = on
		if not on then
			stopVoice()
		end
	end })
	AI:Slider({ Name = "Voice speed", Min = 0.7, Max = 1.6, Default = 1, Step = 0.1, Flag = "aiVoiceSpeed", Callback = function(v)
		voiceSpeed = v
	end })
	AI:Dropdown({ Name = "Voice language", Options = { "en", "es", "fr", "de", "pt", "it", "ja", "ko", "ru", "tr", "ar", "id" }, Default = "en", Flag = "aiVoiceLang", Callback = function(v)
		voiceLang = tostring(v)
	end })
	AI:Button({ Name = "Stop talking", Callback = stopVoice })
	AI:Section("Personality")
	AI:Dropdown({ Name = "Style", Options = { "Rebel (default)", "Chaos gremlin", "Scripter", "Teacher", "Sarcastic", "Professional", "Roleplay", "Tutor", "Designer", "Debugger" }, Default = "Rebel (default)", Flag = "aiPersona", Callback = function(v)
		persona = PERSONAS[v] and v or persona
	end })
	AI:Dropdown({ Name = "Reply language", Options = { "English", "Malay", "Indonesian", "Spanish", "French", "German", "Portuguese", "Arabic", "Hindi", "Japanese", "Korean", "Chinese", "Turkish", "Russian" }, Default = "English", Flag = "aiLang", Callback = function(v)
		replyLang = v
	end })
	AI:Button({ Name = "Forget what you know about me", Risky = true, Callback = function()
		memory = ""
		pcall(function()
			if delfile and isfile and isfile(MEMFILE) then
				delfile(MEMFILE)
			end
		end)
		Win:Notify({ Title = "Rebel AI", Text = "Memory cleared.", Type = "success" })
	end })

	AI:Section("Cool stuff")
	AI:Toggle({ Name = "Rainbow rings", Description = "Every glowing edge turns rainbow", Flag = "aiRainbow", Callback = function(on)
		Win:SetRainbow(on)
	end })
	AI:Button({ Name = "Theme from my avatar", Description = "Colors the panel like your character", Callback = function()
		pcall(function()
			Win:ThemeFromAvatar()
		end)
	end })
	AI:Button({ Name = "Roast my username", Description = "Friendly, I promise", Callback = function()
		chat:Submit("Roast my Roblox username '" .. lp.Name .. "' in two funny, friendly sentences.")
	end })
	AI:Button({ Name = "Surprise me", Description = "A random fun fact, riddle or mini-game", Callback = function()
		local pick = { "Tell me a mind-blowing fact I've never heard, in 2 sentences.", "Give me a clever riddle and wait for my answer.", "Let's play a 5-question trivia game, one question at a time, starting now.", "Start a tiny text adventure set in a haunted Roblox lobby and ask what I do." }
		chat:Submit(pick[math.random(#pick)])
	end })

	local warm = false
	-- the AI loading video: plays on top while the bot wakes up (3.5 to 7 seconds)
	api.Boot = function(video)
		if not video then
			return
		end
		task.spawn(function()
			-- a small card at the bottom of the screen (it never covers the game and a tap closes it)
			local ok, card = pcall(function()
				local c = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -16),
					Size = UDim2.fromOffset(250, 160),
					BackgroundColor3 = Color3.fromRGB(10, 6, 9),
					BorderSizePixel = 0,
					Active = true,
					ZIndex = 60,
				}, Win.Gui)
				corner(c, 10)
				Win:_ring(new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, c))
				local vf = new("VideoFrame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 118), BackgroundColor3 = Color3.new(0, 0, 0), Looped = true, Volume = 0, Video = video, ZIndex = 61 }, c)
				vf.Playing = true
				pcall(function()
					vf:Play()
				end)
				task.delay(8, function()
					pcall(function()
						if vf.Parent and not vf.IsLoaded then
							vf:Destroy()
						end
					end)
				end)
				local l = new("TextLabel", { Position = UDim2.fromOffset(6, 128), Size = UDim2.new(1, -12, 0, 26), BackgroundTransparency = 1, Text = "Waking up Rebel AI...", TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), ZIndex = 61 }, c)
				c.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
						c:Destroy()
					end
				end)
				return { c, l }
			end)
			if not ok or not card then
				return
			end
			local t0 = os.clock()
			while card[1].Parent and ((os.clock() - t0 < 3.5) or (not warm and os.clock() - t0 < 7)) do
				task.wait(0.1)
			end
			if card[1].Parent then
				card[2].Text = "Ready!"
				task.wait(0.4)
				card[1]:Destroy()
			end
		end)
	end

	-- wake up the connection, then greet the player by name with something fresh every time
	task.spawn(function()
		local hour = tonumber(os.date("%H")) or 12
		local part = hour < 5 and "very late at night" or hour < 12 and "morning" or hour < 18 and "afternoon" or "evening"
		local g = ask({ { role = "user", parts = { { text = "Greet the player '" .. lp.DisplayName .. "' in ONE short, fun, original sentence. It is " .. part .. ". No questions. No tags." } } } }, { max = 60, temp = 1.2 })
		warm = true
		if g and chat then
			chat:Add("bot", (g:gsub("%[%[.-%]%]", "")), { Speed = 120 })
		end
	end)
	api.Ask = ask
	api.Chat = chat
	return AI, api
end

return RebelUI
