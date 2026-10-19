--[[
    RebelUI v1.2  ·  made by prorizz196
    A small, mobile-friendly UI library for Roblox executors.

    local UI  = loadstring(game:HttpGet("YOUR_LINK_TO_THIS_FILE"))()
    local Win = UI:CreateWindow({ Title = "Rebelwar", Subtitle = "my panel" })
    local Tab = Win:CreateTab("Main")
    Tab:Toggle({ Name = "Speed", Callback = function(on) print(on) end })

    Elements: Section, Label, Divider, Button, Toggle, Slider,
              Dropdown, Input, Keybind, Color
    Window:   CreateTab, Notify, SetTheme, Toggle, Destroy
    Every element returns an object with :Get() and :Set(value).
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local RebelUI = { Version = "1.2" }
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

-- ============================================================ theme
local THEMES = {
	Red = { Accent = Color3.fromRGB(233, 75, 53), Dark = Color3.fromRGB(120, 24, 20) },
	Blue = { Accent = Color3.fromRGB(64, 140, 255), Dark = Color3.fromRGB(20, 52, 120) },
	Green = { Accent = Color3.fromRGB(60, 200, 110), Dark = Color3.fromRGB(18, 90, 50) },
	Purple = { Accent = Color3.fromRGB(150, 100, 255), Dark = Color3.fromRGB(64, 36, 130) },
	Orange = { Accent = Color3.fromRGB(255, 150, 50), Dark = Color3.fromRGB(130, 64, 16) },
	Pink = { Accent = Color3.fromRGB(255, 90, 170), Dark = Color3.fromRGB(130, 30, 80) },
	Mono = { Accent = Color3.fromRGB(235, 235, 240), Dark = Color3.fromRGB(90, 90, 100) },
}
RebelUI.Themes = {}
for name in pairs(THEMES) do
	table.insert(RebelUI.Themes, name)
end
table.sort(RebelUI.Themes)

local C = {
	Window = Color3.fromRGB(14, 14, 18),
	Side = Color3.fromRGB(20, 20, 26),
	Elem = Color3.fromRGB(30, 30, 38),
	Stroke = Color3.fromRGB(52, 52, 64),
	Text = Color3.fromRGB(240, 240, 245),
	Dim = Color3.fromRGB(150, 150, 165),
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

local function tween(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
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
		TextSize = size or 14,
		TextColor3 = color or C.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
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

function Window:_onTheme(fn)
	fn(self.Theme)
	table.insert(self._fns, fn)
end

-- ============================================================ window
function RebelUI:CreateWindow(o)
	o = o or {}
	local win = setmetatable({ _conns = {}, _fns = {}, _tabs = {}, Flags = {}, Open = true }, Window)
	win.Theme = THEMES[o.Theme or "Red"] or THEMES.Red
	win.ThemeName = THEMES[o.Theme or "Red"] and (o.Theme or "Red") or "Red"

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	local width = math.clamp(o.Width or 540, 280, math.max(280, vp.X - 24))
	local height = math.clamp(o.Height or 360, 220, math.max(220, vp.Y - 24))
	local sideW = width < 460 and 96 or 132

	local gui = new("ScreenGui", {
		Name = o.Name or "RebelUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	gui.Parent = pickParent()
	win.Gui = gui

	local main = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = C.Window,
		BorderSizePixel = 0,
	}, gui)
	corner(main, 12)
	local ring = new("UIStroke", { Thickness = 1.5 }, main)
	win:_onTheme(function(t)
		ring.Color = t.Accent
	end)
	win.Main = main

	-- top bar (drag handle)
	local top = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.Side, BorderSizePixel = 0 }, main)
	corner(top, 12)
	new("Frame", {
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundColor3 = C.Side,
		BorderSizePixel = 0,
	}, top)
	local titleX = 14
	if o.Icon then
		local logo = new("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0.5, -11),
			Size = UDim2.fromOffset(22, 22),
			Image = asset(o.Icon),
		}, top)
		corner(logo, 6)
		titleX = 42
	end
	win.TitleText = o.Title or "RebelUI"
	local title = label(top, o.Title or "RebelUI", 16, C.Text, true)
	title.Position = UDim2.new(0, titleX, 0, 0)
	title.Size = UDim2.new(0.5, 0, 1, 0)
	if o.Subtitle then
		local sub = label(top, o.Subtitle, 12, C.Dim)
		sub.TextXAlignment = Enum.TextXAlignment.Right
		sub.Position = UDim2.new(0.4, 0, 0, 0)
		sub.Size = UDim2.new(0.6, -92, 1, 0)
	end
	local function topButton(txt, xOff)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOff, 0.5, 0),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = C.Elem,
			Text = txt,
			TextColor3 = C.Text,
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = true,
		}, top)
		corner(b, 8)
		return b
	end
	local closeBtn = topButton("×", -8)
	local miniBtn = topButton("–", -44)

	-- dragging the window by the top bar
	do
		local dragging, startPos, startMouse = false, nil, nil
		top.InputBegan:Connect(function(i)
			if isPress(i) then
				dragging = true
				startMouse = i.Position
				startPos = main.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - startMouse
				main.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + d.X,
					startPos.Y.Scale,
					startPos.Y.Offset + d.Y
				)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if isPress(i) then
				dragging = false
			end
		end)
	end

	-- side (tabs) and pages
	local side = new("ScrollingFrame", {
		Position = UDim2.new(0, 8, 0, 50),
		Size = UDim2.new(0, sideW, 1, -58),
		BackgroundColor3 = C.Side,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, main)
	corner(side, 10)
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, side)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	}, side)
	local pages = new("Frame", {
		Position = UDim2.new(0, sideW + 16, 0, 50),
		Size = UDim2.new(1, -(sideW + 24), 1, -58),
		BackgroundTransparency = 1,
	}, main)
	win._side, win._pages = side, pages

	-- notification holder
	local notes = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(250, 10),
		BackgroundTransparency = 1,
		ZIndex = 50,
	}, gui)
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	}, notes)
	win._notes = notes

	-- floating open button (works on phones that have no keyboard)
	local fab = new("TextButton", {
		Position = UDim2.new(0, 12, 0.5, -22),
		Size = UDim2.fromOffset(44, 44),
		Text = "R",
		TextSize = 20,
		Font = Enum.Font.GothamBlack,
		TextColor3 = C.Text,
		BorderSizePixel = 0,
		Visible = false,
		AutoButtonColor = false,
	}, gui)
	corner(fab, 22)
	local fabRing = new("UIStroke", { Thickness = 2 }, fab)
	win:_onTheme(function(t)
		fab.BackgroundColor3 = t.Dark
		fabRing.Color = t.Accent
	end)
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
					fab.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + d.X,
						startPos.Y.Scale,
						startPos.Y.Offset + d.Y
					)
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

	closeBtn.MouseButton1Click:Connect(function()
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

	-- open animation
	main.Size = UDim2.fromOffset(width * 0.92, height * 0.92)
	tween(main, 0.2, { Size = UDim2.fromOffset(width, height) })
	win._size = UDim2.fromOffset(width, height)
	return win
end

function Window:Toggle(state)
	if state == nil then
		state = not self.Open
	end
	self.Open = state
	self.Main.Visible = state
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
	-- any Color3 becomes the accent; the dark shade is made from it
	self.Theme = { Accent = color, Dark = color:Lerp(Color3.new(0, 0, 0), 0.55) }
	self.ThemeName = "Custom"
	for _, fn in ipairs(self._fns) do
		fn(self.Theme)
	end
end

function RebelUI:AddTheme(name, accent, dark)
	THEMES[name] = { Accent = accent, Dark = dark or accent:Lerp(Color3.new(0, 0, 0), 0.55) }
	if not table.find(self.Themes, name) then
		table.insert(self.Themes, name)
		table.sort(self.Themes)
	end
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	self._conns = {}
	if self.Gui then
		self.Gui:Destroy()
	end
end

function Window:Notify(o)
	if type(o) == "string" then
		o = { Text = o }
	end
	o = o or {}
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, self._notes)
	local card = new("Frame", {
		Position = UDim2.new(1, 30, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Elem,
		BorderSizePixel = 0,
	}, wrap)
	corner(card, 10)
	local bar = new("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0 }, card)
	corner(bar, 2)
	local kinds = {
		success = Color3.fromRGB(60, 200, 110),
		warn = Color3.fromRGB(255, 190, 60),
		error = Color3.fromRGB(235, 70, 70),
	}
	self:_onTheme(function(t)
		bar.BackgroundColor3 = kinds[o.Type or ""] or t.Accent
	end)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 10),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 2) }, card)
	local t1 = label(card, o.Title or "Rebelwar", 14, C.Text, true)
	t1.Size = UDim2.new(1, 0, 0, 18)
	if o.Text then
		local t2 = label(card, o.Text, 13, C.Dim)
		t2.TextWrapped = true
		t2.TextTruncate = Enum.TextTruncate.None
		t2.Size = UDim2.new(1, 0, 0, 0)
		t2.AutomaticSize = Enum.AutomaticSize.Y
	end
	tween(card, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
	task.delay(o.Duration or 4, function()
		if card.Parent then
			tween(card, 0.25, { Position = UDim2.new(1, 30, 0, 0) })
			task.wait(0.3)
			wrap:Destroy()
		end
	end)
end

-- ============================================================ tabs
function Window:CreateTab(name, icon)
	-- CreateTab("Main", "rbxassetid://123")  or  CreateTab({ Name=, Icon=, Title=, Description= })
	local opts = type(name) == "table" and name or { Name = name, Icon = icon }
	local win = self
	local tab = setmetatable({ Win = win, Name = opts.Name or "Tab", Icon = opts.Icon }, Tab)
	local active = false

	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = C.Elem,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #win._tabs + 1,
	}, win._side)
	corner(btn, 8)
	local pad = 10
	local img
	if opts.Icon then
		img = new("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0.5, -9),
			Size = UDim2.fromOffset(18, 18),
			Image = asset(opts.Icon),
			ImageColor3 = C.Dim,
		}, btn)
		pad = 32
	end
	local txt = label(btn, tab.Name, 13, C.Dim, true)
	txt.Position = UDim2.new(0, pad, 0, 0)
	txt.Size = UDim2.new(1, -pad - 6, 1, 0)
	local mark = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 0),
		BorderSizePixel = 0,
	}, btn)
	corner(mark, 2)

	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, win._pages)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 6),
	}, page)
	tab.Page = page
	tab.TabButton = btn

	local function paint()
		tween(btn, 0.15, { BackgroundTransparency = active and 0 or 1 })
		tween(txt, 0.15, { TextColor3 = active and C.Text or C.Dim })
		tween(mark, 0.15, { Size = UDim2.fromOffset(3, active and 18 or 0) })
		if img then
			tween(img, 0.15, { ImageColor3 = active and win.Theme.Accent or C.Dim })
		end
	end
	tab._set = function(a)
		active = a
		paint()
	end
	function tab:Select()
		for _, other in ipairs(win._tabs) do
			other.Page.Visible = false
			other._set(false)
		end
		page.Visible = true
		tab._set(true)
	end
	function tab:SetName(n)
		tab.Name = n
		txt.Text = n
	end
	function tab:SetIcon(i)
		if img then
			img.Image = asset(i)
		end
	end
	win:_onTheme(function(t)
		mark.BackgroundColor3 = t.Accent
		paint()
	end)
	btn.MouseButton1Click:Connect(function()
		tab:Select()
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
function Tab:_row(h)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 38),
		BackgroundColor3 = C.Elem,
		BorderSizePixel = 0,
		LayoutOrder = #self.Page:GetChildren(),
	}, self.Page)
	corner(f, 8)
	new("UIStroke", { Color = C.Stroke, Thickness = 1 }, f)
	return f
end

local function register(self, o, obj)
	if o.Flag then
		self.Win.Flags[o.Flag] = obj
	end
	return obj
end

function Tab:Section(text)
	local l = label(self.Page, string.upper(text or "Section"), 12, C.Dim, true)
	l.Size = UDim2.new(1, 0, 0, 22)
	l.LayoutOrder = #self.Page:GetChildren()
	self.Win:_onTheme(function(t)
		l.TextColor3 = t.Accent
	end)
	return l
end

function Tab:Divider()
	local d = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0,
		LayoutOrder = #self.Page:GetChildren(),
	}, self.Page)
	return d
end

function Tab:Label(text)
	local row = self:_row(38)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 0)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, row)
	local l = label(row, text or "", 13, C.Dim)
	l.TextWrapped = true
	l.TextTruncate = Enum.TextTruncate.None
	l.Size = UDim2.new(1, 0, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
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
	o = o or {}
	local win = self.Win
	local row = self:_row(38)
	local b = new("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = o.Name or "Button",
		TextColor3 = C.Text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, row)
	local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, row)
	corner(flash, 8)
	win:_onTheme(function(t)
		flash.BackgroundColor3 = t.Accent
	end)
	b.MouseButton1Click:Connect(function()
		flash.BackgroundTransparency = 0.6
		tween(flash, 0.3, { BackgroundTransparency = 1 })
		safe(o.Callback)
	end)
	return {
		Fire = function()
			safe(o.Callback)
		end,
	}
end

function Tab:Toggle(o)
	-- Name, Description, Icon, Default, Style ("Switch"|"Checkbox"), Color, Locked, Key, Flag, Callback
	o = o or {}
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local H = hasDesc and 54 or 38
	local row = self:_row(H)
	local left = 12
	if o.Icon then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			Image = asset(o.Icon),
		}, row)
		left = 40
	end
	local right = 62 + (o.Key and 34 or 0)
	local name = label(row, o.Name or "Toggle", 14, C.Text)
	name.Position = UDim2.new(0, left, 0, hasDesc and 7 or 0)
	name.Size = UDim2.new(1, -(left + right), 0, hasDesc and 20 or H)
	local desc
	if hasDesc then
		desc = label(row, o.Description, 12, C.Dim)
		desc.Position = UDim2.new(0, left, 0, 27)
		desc.Size = UDim2.new(1, -(left + right), 0, 18)
	end
	local tag
	if o.Key then
		tag = label(row, "[" .. o.Key.Name .. "]", 11, C.Dim)
		tag.TextXAlignment = Enum.TextXAlignment.Right
		tag.AnchorPoint = Vector2.new(1, 0.5)
		tag.Position = UDim2.new(1, -62, 0.5, 0)
		tag.Size = UDim2.fromOffset(40, 20)
	end

	local checkbox = o.Style == "Checkbox"
	local trackF, knob, tick
	if checkbox then
		trackF = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.Stroke,
			BorderSizePixel = 0,
		}, row)
		corner(trackF, 6)
		tick = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "✓",
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.new(1, 1, 1),
			Visible = false,
		}, trackF)
	else
		trackF = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(40, 22),
			BackgroundColor3 = C.Stroke,
			BorderSizePixel = 0,
		}, row)
		corner(trackF, 11)
		knob = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = C.Text,
			BorderSizePixel = 0,
		}, trackF)
		corner(knob, 8)
	end
	local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1) }, row)

	local obj = { Value = o.Default == true, Locked = o.Locked == true, Color = o.Color }
	local function render()
		local on = obj.Value
		local accent = obj.Color or win.Theme.Accent
		tween(trackF, 0.15, { BackgroundColor3 = on and accent or C.Stroke })
		if knob then
			tween(knob, 0.15, { Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
		end
		if tick then
			tick.Visible = on
		end
		name.TextTransparency = obj.Locked and 0.55 or 0
		trackF.BackgroundTransparency = obj.Locked and 0.5 or 0
	end
	function obj:Set(v, silent)
		self.Value = v and true or false
		render()
		if not silent then
			safe(o.Callback, self.Value)
		end
	end
	function obj:Get()
		return self.Value
	end
	function obj:Toggle()
		if not self.Locked then
			self:Set(not self.Value)
		end
	end
	function obj:Lock(state)
		self.Locked = state ~= false
		render()
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
		render()
	end
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
	win:_onTheme(render)
	return register(self, o, obj)
end

function Tab:Slider(o)
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local suffix = o.Suffix or ""
	local row = self:_row(54)
	local name = label(row, o.Name or "Slider", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 6)
	name.Size = UDim2.new(1, -90, 0, 20)
	local val = label(row, "", 13, C.Dim)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -82, 0, 6)
	val.Size = UDim2.new(0, 70, 0, 20)
	local bar = new("Frame", {
		Position = UDim2.new(0, 12, 0, 34),
		Size = UDim2.new(1, -24, 0, 8),
		BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0,
	}, row)
	corner(bar, 4)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 4)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = C.Text,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, bar)
	corner(knob, 8)
	win:_onTheme(function(t)
		fill.BackgroundColor3 = t.Accent
	end)

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
	bindBar(win, bar, function(rel)
		obj:Set(min + rel * (max - min))
	end, function(down)
		-- stop the page scrolling while the finger is on the slider
		page.ScrollingEnabled = not down
	end)
	obj.Value = snap(o.Default or min)
	render()
	return register(self, o, obj)
end

function Tab:Dropdown(o)
	o = o or {}
	local win = self.Win
	local options = o.Options or {}
	local multi = o.Multi == true
	local HEAD, ITEM = 38, 28
	local row = self:_row(HEAD)
	row.ClipsDescendants = true
	local name = label(row, o.Name or "Dropdown", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 0)
	name.Size = UDim2.new(0.5, -12, 0, HEAD)
	local cur = label(row, "", 13, C.Dim)
	cur.TextXAlignment = Enum.TextXAlignment.Right
	cur.Position = UDim2.new(0.5, 0, 0, 0)
	cur.Size = UDim2.new(0.5, -30, 0, HEAD)
	local arrow = label(row, "▾", 14, C.Dim)
	arrow.Position = UDim2.new(1, -24, 0, 0)
	arrow.Size = UDim2.fromOffset(16, HEAD)
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
			b.TextColor3 = selected(v) and win.Theme.Accent or C.Text
		end
	end
	local function build(v)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, ITEM),
			BackgroundColor3 = C.Window,
			Text = tostring(v),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextColor3 = C.Text,
			AutoButtonColor = true,
		}, list)
		corner(b, 6)
		items[v] = b
		b.MouseButton1Click:Connect(function()
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
		arrow.Text = open and "▴" or "▾"
	end
	function obj:Close()
		setOpen(false)
	end
	head.MouseButton1Click:Connect(function()
		setOpen(not obj.Open)
	end)
	function obj:Set(v, silent)
		if multi then
			obj.Value = {}
			for _, x in ipairs(type(v) == "table" and v or {}) do
				obj.Value[x] = true
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
	o = o or {}
	local row = self:_row(38)
	local name = label(row, o.Name or "Input", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 0)
	name.Size = UDim2.new(0.45, -12, 1, 0)
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.55, -16, 0, 26),
		BackgroundColor3 = C.Window,
		BorderSizePixel = 0,
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "type here",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 6)
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
	o = o or {}
	local win = self.Win
	local row = self:_row(38)
	local name = label(row, o.Name or "Keybind", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 0)
	name.Size = UDim2.new(1, -110, 1, 0)
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(86, 26),
		BackgroundColor3 = C.Window,
		BorderSizePixel = 0,
		TextColor3 = C.Text,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, row)
	corner(b, 6)
	local obj = { Value = o.Default or Enum.KeyCode.F, Listening = false }
	local function render()
		b.Text = obj.Listening and "press a key…" or obj.Value.Name
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
	Color3.fromRGB(233, 75, 53),
	Color3.fromRGB(255, 150, 50),
	Color3.fromRGB(250, 210, 60),
	Color3.fromRGB(60, 200, 110),
	Color3.fromRGB(60, 200, 220),
	Color3.fromRGB(64, 140, 255),
	Color3.fromRGB(150, 100, 255),
	Color3.fromRGB(255, 90, 170),
	Color3.fromRGB(240, 240, 245),
}

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

function Tab:Color(o)
	-- Name, Default (Color3), Callback(Color3). Hue, saturation and brightness bars, hex box, preset swatches.
	o = o or {}
	local win = self.Win
	local row = self:_row(136)
	local name = label(row, o.Name or "Color", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 6)
	name.Size = UDim2.new(1, -150, 0, 20)
	local preview = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -92, 0, 8),
		Size = UDim2.fromOffset(26, 18),
		BorderSizePixel = 0,
	}, row)
	corner(preview, 5)
	local hex = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 5),
		Size = UDim2.fromOffset(76, 24),
		BackgroundColor3 = C.Window,
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ClearTextOnFocus = false,
	}, row)
	corner(hex, 6)

	local function makeBar(y)
		local bar = new("Frame", {
			Position = UDim2.new(0, 12, 0, y),
			Size = UDim2.new(1, -24, 0, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
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
	local hueBar, hueG, hueKnob = makeBar(36)
	local satBar, satG, satKnob = makeBar(58)
	local valBar, valG, valKnob = makeBar(80)
	hueG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})

	local def = o.Default or Color3.fromRGB(233, 75, 53)
	local h, s, v = def:ToHSV()
	local obj = { Value = def }
	local function render()
		obj.Value = Color3.fromHSV(h, s, v)
		preview.BackgroundColor3 = obj.Value
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

	-- preset swatches
	local sw = new("Frame", { Position = UDim2.new(0, 12, 0, 104), Size = UDim2.new(1, -24, 0, 22), BackgroundTransparency = 1 }, row)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, sw)
	for i, c in ipairs(PRESETS) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = c,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
		}, sw)
		corner(b, 6)
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
	local row = self:_row(hasText and 70 or 48)
	row.ClipsDescendants = true
	local bar = new("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0 }, row)
	win:_onTheme(function(t)
		bar.BackgroundColor3 = t.Accent
	end)
	local left = 16
	if o.Icon then
		local holder = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 16, 0.5, 0),
			Size = UDim2.fromOffset(40, 40),
			BackgroundColor3 = C.Window,
			BorderSizePixel = 0,
		}, row)
		corner(holder, 10)
		new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			Image = asset(o.Icon),
		}, holder)
		left = 66
	end
	local title = label(row, o.Title or "Header", 18, C.Text, true)
	title.Position = UDim2.new(0, left, 0, hasText and 8 or 0)
	title.Size = UDim2.new(1, -(left + 10), 0, hasText and 24 or 48)
	local body
	if hasText then
		body = label(row, o.Text, 12, C.Dim)
		body.TextWrapped = true
		body.TextTruncate = Enum.TextTruncate.None
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.Position = UDim2.new(0, left, 0, 34)
		body.Size = UDim2.new(1, -(left + 10), 0, 32)
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
	-- Image ("rbxassetid://123" or just 123), Height, Caption, Crop (true = fill and crop)
	o = o or {}
	local h = o.Height or 120
	local row = self:_row(h + (o.Caption and 26 or 0))
	row.ClipsDescendants = true
	local img = new("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -16, 0, h - 16),
		Image = asset(o.Image),
		ScaleType = o.Crop and Enum.ScaleType.Crop or Enum.ScaleType.Fit,
	}, row)
	corner(img, 6)
	local cap
	if o.Caption then
		cap = label(row, o.Caption, 12, C.Dim)
		cap.TextXAlignment = Enum.TextXAlignment.Center
		cap.Position = UDim2.new(0, 8, 0, h - 6)
		cap.Size = UDim2.new(1, -16, 0, 20)
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
	-- Name, Min, Max, Default, Suffix. Read only bar: use :Set(value) from your own code.
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local suffix = o.Suffix or "%"
	local row = self:_row(46)
	local name = label(row, o.Name or "Progress", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 5)
	name.Size = UDim2.new(1, -90, 0, 20)
	local val = label(row, "", 13, C.Dim)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -82, 0, 5)
	val.Size = UDim2.fromOffset(70, 20)
	local bar = new("Frame", {
		Position = UDim2.new(0, 12, 0, 30),
		Size = UDim2.new(1, -24, 0, 8),
		BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0,
	}, row)
	corner(bar, 4)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 4)
	win:_onTheme(function(t)
		fill.BackgroundColor3 = t.Accent
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
	local row = self:_row(38)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 0)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local t = label(row, o.Title or "", 14, C.Text, true)
	t.Size = UDim2.new(1, 0, 0, 18)
	t.LayoutOrder = 1
	local b = label(row, o.Text or "", 13, C.Dim)
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
	-- Name, Options, Default (false = none chosen), Callback(choice): a bar of buttons where one is chosen
	o = o or {}
	local win = self.Win
	local options = o.Options or {}
	local n = math.max(#options, 1)
	local row = self:_row(66)
	local name = label(row, o.Name or "Choice", 14, C.Text)
	name.Position = UDim2.new(0, 12, 0, 6)
	name.Size = UDim2.new(1, -24, 0, 20)
	local bar = new("Frame", {
		Position = UDim2.new(0, 12, 0, 32),
		Size = UDim2.new(1, -24, 0, 28),
		BackgroundColor3 = C.Window,
		BorderSizePixel = 0,
	}, row)
	corner(bar, 8)
	local obj = { Value = nil }
	local buttons = {}
	local function render()
		for choice, b in pairs(buttons) do
			local on = choice == obj.Value
			tween(b, 0.15, {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and Color3.new(1, 1, 1) or C.Dim,
			})
			b.BackgroundColor3 = win.Theme.Accent
		end
	end
	for i, choice in ipairs(options) do
		local b = new("TextButton", {
			Position = UDim2.new((i - 1) / n, 2, 0, 2),
			Size = UDim2.new(1 / n, -4, 1, -4),
			BackgroundTransparency = 1,
			Text = tostring(choice),
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextColor3 = C.Dim,
			AutoButtonColor = false,
		}, bar)
		corner(b, 6)
		buttons[choice] = b
		b.MouseButton1Click:Connect(function()
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

	pcall(function()
		task.spawn(function()
			local ok, info = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
			end)
			if ok and info and info.Name then
				gameName = info.Name
			end
		end)
	end)

	local frame = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = o.Position or UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.Side,
		BorderSizePixel = 0,
		Visible = bar.Visible,
	}, win.Gui)
	corner(frame, 17)
	local ring = new("UIStroke", { Thickness = 1.5 }, frame)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, frame)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, frame)
	win._hasBar = true
	win._fab.Visible = false
	win._bar = bar

	local texts = {} -- item name -> TextLabel whose text is refreshed
	local function accentHex()
		return toHex(win.Theme.Accent)
	end
	local function line(name, value)
		return string.format('<font color="#9696A5">%s</font> <font color="%s">%s</font>', name, accentHex(), tostring(value))
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
				g = g:sub(1, 17) .. "…"
			end
			return string.format('<font color="%s">%s</font>', accentHex(), g)
		elseif name == "Title" then
			return string.format('<font color="#F0F0F5"><b>%s</b></font>', tostring(o.Title or win.TitleText or "Rebelwar"))
		end
		return ""
	end
	local function refresh()
		for name, l in pairs(texts) do
			l.Text = valueOf(name)
		end
	end

	local function rebuild()
		for _, c in ipairs(frame:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		texts = {}
		local order = 0
		for _, name in ipairs(BAR_ORDER) do
			if items[name] then
				order += 1
				if order > 1 then
					new("Frame", {
						Size = UDim2.fromOffset(1, 14),
						BackgroundColor3 = C.Stroke,
						BorderSizePixel = 0,
						LayoutOrder = order * 2 - 1,
					}, frame)
				end
				if name == "Logo" then
					if logo then
						local img = new("ImageLabel", {
							Size = UDim2.fromOffset(22, 22),
							BackgroundTransparency = 1,
							Image = asset(logo),
							LayoutOrder = order * 2,
						}, frame)
						corner(img, 6)
					else
						local r = label(frame, "R", 17, C.Text, true)
						r.TextXAlignment = Enum.TextXAlignment.Center
						r.Size = UDim2.fromOffset(16, 22)
						r.LayoutOrder = order * 2
						win:_onTheme(function(t)
							r.TextColor3 = t.Accent
						end)
					end
				else
					local l = new("TextLabel", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 22),
						RichText = true,
						Text = "",
						TextSize = 13,
						Font = Enum.Font.GothamMedium,
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
		frame.Visible = bar.Visible
	end
	function bar:Destroy()
		frame:Destroy()
		win._hasBar = false
		win._bar = nil
		if not win.Open then
			win._fab.Visible = true
		end
	end
	bar.Frame = frame

	-- drag, and a tap opens or closes the panel
	do
		local down, moved, startPos, startMouse = false, 0, nil, nil
		frame.InputBegan:Connect(function(i)
			if isPress(i) then
				down, moved = true, 0
				startMouse, startPos = i.Position, frame.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if down and isMove(i) then
				local d = i.Position - startMouse
				moved = math.max(moved, d.Magnitude)
				if moved > 6 then
					frame.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + d.X,
						startPos.Y.Scale,
						startPos.Y.Offset + d.Y
					)
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if down and isPress(i) then
				down = false
				if moved <= 6 then
					win:Toggle()
				end
			end
		end)
	end

	-- live numbers: FPS from Heartbeat, text refreshed twice a second
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
	end)

	win:_onTheme(function(t)
		ring.Color = t.Accent
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

return RebelUI
