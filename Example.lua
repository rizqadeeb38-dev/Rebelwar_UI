--[[
    RebelUI v1.0.0 · demo panel (the Rebelwar look)

    Run this file to SEE what RebelUI can do: a loading screen, the panel with its spinning ring,
    a top bar (FPS + logo + timer), tabs with Roblox images next to the name, every kind of toggle,
    sliders, colors, dropdowns, notifications, themes and saving.

    Tabs: Elements (one of everything), AI (chat with Rebel AI, with voice), Tools, Discord and Settings.
    Copy any part you like into your own script. The tutorial is in README.md.
]]

-- To pin the library to one exact version (so a later push to the repo can never change what runs), replace "main" with a
-- commit id from GitHub (the long code next to a commit), e.g. REF = "3f2a9c1d...". "main" always loads the newest file.
local REF = "main"
local URL = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/" .. REF .. "/source.lua"

-- shows a message on screen (phones can't see the console) and in the console
local function problem(msg)
	warn("[Rebelwar] " .. msg)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Rebelwar", Text = msg, Duration = 10 })
	end)
end

-- 1. download the library, and say clearly if something is wrong
local okGet, src = pcall(function()
	return game:HttpGet(URL)
end)
if not okGet or type(src) ~= "string" or #src < 2000 then
	problem("Could not download source.lua. Is the repo public and is the file on the main branch?")
	return
end
local fn, err = loadstring(src)
if not fn then
	problem("source.lua has an error: " .. tostring(err))
	return
end
local okRun, UI = pcall(fn)
if not okRun or type(UI) ~= "table" or not UI.Loading or not UI.CreateWindow or not UI.KeyGate then
	problem("source.lua in the repo is an old version. Upload RebelUI v1.0.0 as source.lua.")
	return
end

-- ============================================================ DEVELOPER SWITCH
-- SCRIPT_ON = true  -> the script works.   SCRIPT_ON = false -> it does nothing when someone runs it.
-- SWITCH_URL (optional): a link to a text file that says "on" or "off". Change that file any time to turn the script on or off
-- for everyone without re-uploading anything (for example a GitHub raw link to switch.txt). nil = only SCRIPT_ON counts.
local SCRIPT_ON = true
local SWITCH_URL = nil -- e.g. "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/switch.txt"
if not UI:Switch({ On = SCRIPT_ON, Url = SWITCH_URL, Name = "Rebelwar", Message = "Rebelwar is switched off right now. Check the Discord for news." }) then
	return
end

-- Setup: "Auto" picks the Mobile or PC layout by itself (touch and no keyboard = Mobile). Force one with "Mobile" or "PC".
local SETUP = "Auto"

local Load, Win -- made inside main()

local function main()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Roblox image ids. Swap them for your own. A bare number works too.
local LOGO = 114659273298746
local BANNER = 125144167121839
-- Turn the AI tab on or off (false = no AI tab, no AI loading video, no web requests to Gemini).
local USE_AI = true
-- Your own proxy address (see ai_proxy_worker.js), e.g. "https://rebel-ai.yourname.workers.dev". nil = use the key file.
local AI_PROXY = nil
-- Videos are OFF by default because a phone has to download and decode them while the game is starting.
-- Turn them on (USE_VIDEOS = true) only after the panel opens fine without them.
local USE_VIDEOS = false
-- Loading videos. Paste a direct .mp4 link (a GitHub raw link is the most reliable) or a video page link:
-- the library downloads it first (once), then plays it. Set to nil to turn a video off. Keep each under ~20 MB.
local VIDEO = USE_VIDEOS and "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/1793093470606..mp4" or nil -- the Rebelwar logo loading video
local AI_VIDEO = USE_VIDEOS and "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/1793093466230..mp4" or nil -- plays while Rebel AI wakes up
local ICON = {
	ESP = 71415024616002,
	Settings = 81306187910490,
	Discord = 106575470880507,
}
-- Key screen. The panel is keyless by default. Set USE_KEY_GATE = true to ask for a key before the panel opens.
-- Put your own LootLabs (or any) link in GET_KEY_LINK. The "Get key" button copies it so the player can open it in a browser.
-- Honest note: a key that is checked inside this file can be read by someone who looks hard. For real protection
-- check the key on your own server with Check = function(key) ... end.
local USE_KEY_GATE = false
local GET_KEY_LINK = "https://lootlabs.gg/your-link-here" -- <- replace with your LootLabs link
local KEYS = { "REBEL-DEMO" } -- keys that are accepted (or use Check)
local function keyGateOptions(save)
	return {
		Name = "Rebelwar",
		Title = "REBELWAR",
		Subtitle = "Get your key, then paste it below.",
		Image = BANNER, -- the picture on the left (any Roblox asset id)
		Tagline = "Rebelwar  |  by prorizz196",
		Background = BANNER, -- a picture behind the whole card...
		BackgroundOpacity = 0.22, -- ...with its own opacity (0 to 1)
		ImageEffect = "Shimmer", -- Shimmer, Pulse, Float, Glow, Rainbow, Spin or None
		Logo = LOGO, -- round logo next to the title
		LogoEffect = "Rainbow",
		Note = "Tap Get key, finish the LootLabs steps, and paste the key here.\nThe key works for the whole day.",
		NoteIcon = "📌",
		NoteColor = "Gold", -- Green, Blue, Red, Gold, Purple, Pink, Orange, Cyan, Gray or a Color3
		Setup = SETUP, -- Auto / Mobile / PC: the key panel sizes itself for the device
		Video = VIDEO, -- a silent looping video at the top-left of the card (set USE_VIDEOS = true above). nil = just the picture
		ProviderStyle = "Row", -- "Row" = a picture button + its own colored Copy button per line, "Grid" = compact picture tiles
		-- the four picture buttons (images load from the repo Assets folder). Put your own link in each one.
		Providers = {
			{ "LootLabs", GET_KEY_LINK }, -- picture loads from imgur
			{ "Linkvertise", "https://linkvertise.com/your-link-here" },
			{ "Platoboost", "https://auth.platoboost.com/your-link-here" },
			{ "Rekonise", "https://rekonise.com/your-link-here" },
			{ "Work.ink", "https://work.ink/your-link-here" },
		},
		ProvidersText = "Get your key",
		Buttons = {
			{ Name = "Discord", Color = "Discord", Link = "https://discord.gg/8s7RR3wZ6b", Message = "Invite copied. Paste it in your browser." },
			{ Name = "Help", Color = "Blue", Link = "https://discord.gg/8s7RR3wZ6b", Message = "Ask in the Discord server." },
		},
		Keys = KEYS,
		Save = save, -- true remembers the key on this device
		Boom = true, -- explosion effect when the key is right
		BoomText = "WELCOME",
		Theme = "Red",
	}
end
local DISCORD = "https://discord.gg/8s7RR3wZ6b" -- the official RebelUI & Resources server

-- ============================================================ 1. loading screen
if USE_KEY_GATE then
	local okKey = UI:KeyGate(keyGateOptions(true))
	if not okKey then
		return
	end
end
local gameName = "Unknown game"
pcall(function()
	gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

Load = UI:Loading({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Logo = LOGO, -- the round logo with the spinning ring
	Banner = BANNER, -- the slow zooming picture behind everything
	Footer = "discord.gg/8s7RR3wZ6b  |  RebelUI v" .. UI.Version,
	Theme = "Red",
})
Load:Badge(gameName) -- the small pill at the top

-- Boot log + watchdog. Every step is written to RebelUI_boot.txt (in your executor's workspace folder) and shown on
-- the loading screen. If the screen ever stops, the LAST LINE of that file says exactly where. The loading screen also
-- removes itself and opens the panel after 25 seconds no matter what, so it can never lock the screen.
local T0, ready, bootLog = os.clock(), false, {}
local function stage(name, progress)
	table.insert(bootLog, string.format("%5.1fs  %s", os.clock() - T0, name))
	pcall(function()
		if writefile then
			writefile("RebelUI_boot.txt", table.concat(bootLog, "\n"))
		end
	end)
	if Load and not Load.Dead then
		pcall(Load.Status, Load, name)
		if progress then
			pcall(Load.Progress, Load, progress)
		end
	end
	task.wait() -- let the screen draw a frame before the next heavy step
end
task.delay(25, function()
	if not ready then
		warn("[Rebelwar] startup was still running after 25s. Last step: " .. tostring(bootLog[#bootLog]))
		pcall(function()
			if Load then
				Load:Destroy()
			end
			if Win then
				Win:Toggle(true)
			end
		end)
	end
end)
stage("Starting...", 0.05)

-- download both videos FIRST (first run only, they are kept after that), then play the logo video
local logoVid, aiVid
if VIDEO or (USE_AI and AI_VIDEO) then
	Load:Status("Downloading the loading videos (first run only)...")
	Load:Progress(0.08)
	local pending = 0
	local function grab(src, set)
		if not src then
			return
		end
		pending += 1
		task.spawn(function()
			local ok, a = pcall(UI.ResolveMedia, src)
			if ok and a then
				set(a)
			end
			pending -= 1
		end)
	end
	grab(VIDEO, function(a)
		logoVid = a
	end)
	grab(USE_AI and AI_VIDEO or nil, function(a)
		aiVid = a
	end)
	local t0 = os.clock()
	while pending > 0 and os.clock() - t0 < 25 do
		task.wait(0.1)
		pcall(Load.Progress, Load, 0.08 + 0.2 * math.min((os.clock() - t0) / 25, 1)) -- the bar keeps moving
	end
	if logoVid then
		Load:SetVideo(logoVid)
	end
end
stage("Loading images...", 0.3)
Load:Preload({ LOGO, BANNER, ICON.ESP, ICON.Settings, ICON.Discord }, 0, 0.6)

-- ============================================================ 2. the window and the top bar
stage("Building the panel...", 0.55)

Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Icon = LOGO, -- logo in the corner
	Theme = "Red", -- Red, Crimson, Blue, Green, Purple, Orange, Pink, Gold, Cyber, Blood, Ice, Mono
	Open = false, -- stay closed until the loading screen is done
	Opacity = 100, -- 100 = solid panel (10 to 100). Players can change it in Settings
	Setup = SETUP, -- Auto / Mobile / PC. PC gets a wider panel, Mobile a big thumb-sized open button and swipe between tabs
	Ambient = true, -- two soft glowing circles drift behind the panel
	Search = true, -- the search box next to the page title
	Resizable = true, -- drag the corner grip to resize
	ToggleKey = Enum.KeyCode.RightShift, -- phones use the top bar instead
})

stage("Building the top bar...", 0.6)
Win:CreateWatermark({ Text = "Rebelwar" }) -- small pill in the corner: name, FPS and ping
Win:SetPalette() -- Ctrl+K: search every tab and command
Win:SetBackground({ Image = BANNER, Opacity = 0.18 }) -- a picture behind the panel (Win:SetBackground() removes it)
Win:SetPanicKey(Enum.KeyCode.Delete) -- Delete hides every window and the open button; press again to bring them back
Win:SetOpenBoom("first") -- an explosion the first time the panel opens ("always" = every time, false = off)
Win:SetTabHotkeys() -- Ctrl+1 ... Ctrl+9 jump to the tabs
Win:SetDim(0.35) -- darken the game behind the panel while it is open (0 = off)
local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" }, -- the Rebelwar classic. Players can change it in Settings.
	Logo = LOGO,
})

-- ============================================================ 3. tabs
stage("Building tabs...", 0.65)
-- the Elements page builds itself the first time you open it (so the panel starts fast)
local function buildElements(Elements)
	-- ---------------------------------------------------------------- Elements: one of everything
	Elements:Stats({ { Name = "Kills", Value = 0 }, { Name = "Wins", Value = 0 }, { Name = "Streak", Value = 0 } }) -- number tiles: :Set("Kills", 5)
	Elements:Section("New: chips, steps, timeline, list, table")
	Elements:Chips({ "Legit", "Rage", "Closet" }, { Closable = true, Callback = function(name, what) Win:Notify({ Title = what, Text = name }) end })
	local steps = Elements:Steps({ "Pick", "Tune", "Go" }, 1)
	Elements:Button({ Name = "Next step", Callback = function() steps:Next() end })
	-- more animation: a shimmering placeholder while loading, and text that types itself
	Elements:Typewriter({ Text = "Rows rise in, tap squishes, numbers count up..." })
	local skel = Elements:Skeleton({ Lines = 2 })
	task.delay(3, function()
		skel:Remove()
	end)
	-- a live "Summary" feed: finished steps, notes, and a red glowing step while something is still working
	local feed = Elements:Activity({ Title = "Summary" })
	Elements:Button({ Name = "Run the Summary demo", Description = "Red glow = still working", Callback = function()
		feed:Clear()
		task.spawn(function()
			feed:Working("Sleuthing")
			task.wait(1.2)
			feed:Add({ Kind = "search" })
			task.wait(1)
			feed:Add({ Kind = "command", Detail = "cd /workspace && ls" })
			feed:Note("Adding notification history to the window.")
			task.wait(1.2)
			feed:Add({ Kind = "command", Detail = "run all tests" })
			task.wait(1)
			feed:Done()
			feed:Note("All done.")
		end)
	end })
	Elements:Timeline({ { Title = "v1.0.0", Time = "today", Text = "RebelUI released" }, { Title = "Watermark + palette", Time = "today" } })
	Elements:List({ Items = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta" }, Multi = true, Search = true, Callback = function(v) print("picked", #v) end })
	Elements:Table({ Columns = { "Player", "Kills", "Deaths" }, Rows = { { "Ava", 12, 3 }, { "Ben", 7, 9 }, { "Cy", 21, 2 }, { "Dee", 4, 4 }, { "Eli", 15, 6 } }, PageSize = 4 })
	Elements:Section("New: images with effects, boom, hold, undo, mini")
	Elements:Image({ Image = LOGO, Height = 96, Circle = true, Effect = "Rainbow", Caption = "Effect = Rainbow (also Pulse, Float, Glow, Spin, Shimmer)", OnClick = function() Win:Boom({ Text = "BOOM" }) end })
	Elements:Image({ Image = BANNER, Height = 90, Crop = true, Effect = "Shimmer" })
	Elements:Button({ Name = "BOOM!", Description = "The explosion effect: flash, rings and sparks", Callback = function() Win:Boom({ Text = "BOOM" }) end })
	Elements:HoldButton({ Name = "Hold to confirm (1 second)", Seconds = 1, Callback = function() Win:Notify({ Title = "Confirmed", Type = "success" }) end })
	Elements:Button({ Name = "Toast with Undo", Callback = function() Win:NotifyUndo({ Title = "Setting changed", Text = "Tap Undo within 5 seconds.", OnUndo = function() Win:Notify({ Title = "Undone", Type = "success" }) end }) end })
	local miniToggle = Elements:Toggle({ Name = "Mini pill target" })
	Elements:Button({ Name = "Show the mini pill", Description = "A small draggable pill with that toggle", Callback = function() Win:CreateMini({ Toggles = { miniToggle } }) end })
	Elements:Section("New: sub-tabs and columns")
	local sub = Elements:SubTabs({ "Aim", "Visuals", "Misc" }) -- pages inside a tab
	sub.Aim:Toggle({ Name = "A toggle in Aim" })
	sub.Visuals:Slider({ Name = "A slider in Visuals", Min = 0, Max = 100, Default = 40 })
	sub.Misc:Button({ Name = "A button in Misc", Callback = function() Win:Notify({ Title = "Misc button" }) end })
	local cols = Elements:Columns(2) -- two columns (one column on a narrow panel)
	cols[1]:Toggle({ Name = "Left" })
	cols[2]:Toggle({ Name = "Right" })
	Elements:Slider({ Name = "Panel picture opacity", Min = 0, Max = 100, Default = 18, Suffix = "%", Callback = function(v) Win:SetBackgroundOpacity(v / 100) end })
	Elements:Section("Danger zone")
	Elements:Button({
		Name = "Big red button",
		Description = "Danger = true: tap twice and the whole screen shakes",
		Danger = true,
		DoubleClick = true,
		Callback = function()
			Win:Notify({ Title = "Boom", Text = "The screen shook. Win:ScreenShake(power, seconds) does that.", Type = "warn" })
		end,
	})
	Elements:Section("1. Toggles")
	Elements:Toggle({ Name = "Plain switch" })
	Elements:Toggle({ Name = "Name + description", Description = "A second line of small text under the name", Default = true })
	Elements:Toggle({ Name = "With an icon", Description = "A Roblox image on the left", Icon = ICON.ESP })
	Elements:Toggle({ Name = "Checkbox style", Description = "Style = \"Checkbox\"", Style = "Checkbox", Default = true })
	Elements:Toggle({ Name = "Green when on", Description = "Color = Color3.fromRGB(...)", Color = Color3.fromRGB(60, 210, 90), Default = true })
	Elements:Toggle({ Name = "Blue when on", Color = Color3.fromRGB(64, 140, 255), Default = true })
	Elements:Toggle({ Name = "Toggle with a key", Description = "Press Z on a keyboard to flip it", Key = Enum.KeyCode.Z })
	local locked = Elements:Toggle({ Name = "Locked toggle", Description = "Tap it: it tells you it is locked", Locked = true })
	Elements:Button({
		Name = "Unlock / lock the toggle above",
		Callback = function()
			locked:Lock(not locked.Locked)
		end,
	})

	Elements:Section("2. Sliders and choices")
	Elements:Slider({ Name = "Slider with a suffix", Min = 0, Max = 100, Default = 30, Suffix = "%" })
	Elements:Choice({ Name = "Choice bar", Options = { "Easy", "Normal", "Hard" }, Default = "Normal" })
	Elements:Cycle({ Name = "Cycle picker", Description = "Tap the arrows", Options = { "One", "Two", "Three", "Four" } })
	Elements:Dropdown({ Name = "Dropdown", Options = { "Speed", "Jump", "Fly", "Fog" }, Default = "Speed" })
	Elements:Dropdown({ Name = "Dropdown (many)", Options = { "Speed", "Jump", "Fly", "Fog" }, Multi = true, Default = { "Jump" } })

	Elements:Section("3. Typing, keys and colors")
	Elements:Input({
		Name = "Text box",
		Placeholder = "name here",
		Callback = function(text)
			Win:Notify({ Title = "You typed", Text = text })
		end,
	})
	Elements:Keybind({ Name = "Keybind", Default = Enum.KeyCode.F })
	Elements:Color({ Name = "Color picker", Default = Color3.fromRGB(235, 40, 50) })

	Elements:Section("4. Text and images")
	Elements:Image({ Image = BANNER, Height = 100, Caption = "A Roblox asset image", Crop = true })
	Elements:Header({ Title = "Header card", Text = "A banner with its own title, text and icon.", Icon = LOGO })
	Elements:Paragraph({ Title = "Paragraph", Text = "A titled block of text. It grows to fit as long as you like." })
	Elements:Label("A label is plain small text.")
	Elements:Divider()

	Elements:Section("5. Notifications")
	Elements:Button({
		Name = "Show every notification type",
		Callback = function()
			Win:Notify({ Title = "Info", Text = "A normal card." })
			Win:Notify({ Title = "Success", Text = "A green card.", Type = "success" })
			Win:Notify({ Title = "Warning", Text = "A yellow card.", Type = "warn" })
			Win:Notify({ Title = "Error", Text = "A red card.", Type = "error" })
		end,
	})
	Elements:Button({
		Name = "Notification with buttons",
		Description = "Cards can have up to 3 buttons",
		Callback = function()
			Win:Notify({
				Title = "Update ready",
				Icon = LOGO, -- a small picture on the card
				Text = "A new version is out. Reload now?",
				Duration = 8,
				Actions = {
					{ Name = "Reload", Callback = function() Win:Notify({ Title = "Reloading...", Type = "success" }) end },
					{ Name = "Later" },
				},
			})
		end,
	})

	Elements:Section("6. Key gate")
	Elements:Button({
		Name = "Try the key gate",
		Description = "Image, note, Get key link and a boom. Demo key: REBEL-DEMO",
		Callback = function()
			local ok = UI:KeyGate(keyGateOptions(false)) -- the full screen: image, note, colored buttons, boom
			Win:Notify({ Title = ok and "Key accepted" or "Closed", Type = ok and "success" or "warn" })
		end,
	})

	Elements:Section("7. More tools")
	Elements:Keybind({
		Name = "Keybind: toggle mode",
		Default = Enum.KeyCode.G,
		Mode = "Toggle", -- Press (default), Toggle or Hold
		Callback = function(state)
			Win:Notify({ Title = "Toggle key", Text = state and "ON" or "OFF" })
		end,
	})
	Elements:Keybind({
		Name = "Keybind: hold mode",
		Default = Enum.KeyCode.J, -- (not H: H opens the game assistant)
		Mode = "Hold", -- Callback(true) while held, Callback(false) when let go
		Callback = function(held)
			print("held:", held)
		end,
	})
	Elements:Input({
		Name = "Number box",
		Numeric = true, -- only numbers
		Min = 0,
		Max = 500,
		Default = "100",
		Callback = function(n)
			Win:Notify({ Title = "Number", Text = "You set " .. n })
		end,
	})
	Elements:Button({
		Name = "Pop-up question",
		Description = "Win:Dialog with buttons",
		Callback = function()
			Win:Dialog({
				Title = "Are you sure?",
				Text = "A dialog asks something and runs a function for the button you tap.",
				Buttons = {
					{ Name = "Yes", Callback = function() Win:Notify({ Title = "You said yes", Type = "success" }) end },
					{ Name = "No" },
				},
			})
		end,
	})
	Elements:Section({ Name = "8. A collapsible section (tap me)", Collapsible = true })
	Elements:Label("Tap the line above to hide or show these rows.")
	local hideMe = Elements:Toggle({ Name = "Toggle inside the section" })
	Elements:Button({
		Name = "Hide the toggle above",
		Description = "Every element has :SetVisible(false) and :Destroy()",
		Callback = function()
			hideMe:SetVisible(false)
			task.delay(1.5, function()
				hideMe:SetVisible(true)
			end)
		end,
	})

	Elements:Section("9. Even more")
	Elements:Notice({ Type = "warn", Title = "Heads up", Text = "A Notice is a colored box for warnings and tips. Types: warn, error, success." })
	Elements:Button({ Name = "Risky button", Description = "Red, and asks you to tap twice", Risky = true, DoubleClick = true, Callback = function()
		Win:Notify({ Title = "Done", Text = "You confirmed it.", Type = "success" })
	end })
	Elements:Button({ Name = "Disabled button", Disabled = true })
	Elements:Toggle({ Name = "Tooltip toggle", Description = "Hold your finger here (or hover)", Tooltip = "A tooltip is a small help card. Add Tooltip = \"text\" to any element." })
	local master = Elements:Toggle({ Name = "Show the hidden slider" })
	Elements:Slider({ Name = "Hidden slider", Min = 0, Max = 10, Default = 5, Prefix = "x" }):DependsOn(master) -- only shows while the toggle is on
	local many = {}
	for i = 1, 12 do
		many[i] = "Option " .. i
	end
	Elements:Dropdown({ Name = "Searchable dropdown", Options = many, Tooltip = "Lists with more than 7 options get a search box." })
	Elements:Dropdown({ Name = "Players in the server", Options = "Players" })
	Elements:Input({ Name = "Max 5 letters", MaxLength = 5 })
	local kl = Win:CreateKeybindList({ Visible = false }) -- the keys that are set, on screen
	Elements:Toggle({ Name = "Show keybind list", Description = "On-screen list of your keys", Callback = function(on)
		kl:Show(on)
	end })
	Elements:Button({ Name = "Notification you can update", Callback = function()
		local n = Win:Notify({ Title = "Working...", Text = "0%", Duration = 0 }) -- Duration = 0 stays until Close()
		task.spawn(function()
			for i = 1, 10 do
				task.wait(0.3)
				n:SetText(i * 10 .. "%")
				n:Progress(i / 10)
			end
			n:SetTitle("Done!")
			task.wait(1)
			n:Close()
		end)
	end })

	Elements:Section("10. Power tools")
	Elements:RangeSlider({ Name = "Range slider", Min = 0, Max = 100, Default = { 20, 80 }, Suffix = "%", Flag = "demo_range", Callback = function(lo, hi)
		print("range", lo, hi)
	end })
	Elements:Pad({ Name = "2D pad", Flag = "demo_pad", Callback = function(x, y)
		print("pad", x, y)
	end })
	Elements:Slider({ Name = "Slider with arrows + log scale", Min = 1, Max = 1000, Default = 10, Log = true, Arrows = true })
	Elements:Input({ Name = "Math box", Math = true, Default = "16*4", Tooltip = "Type 16*4 or (2+3)^2 and tap done." })
	Elements:Keybind({ Name = "Combo key (Shift + X)", Default = Enum.KeyCode.X, Modifier = Enum.KeyCode.LeftShift, Callback = function()
		Win:Notify({ Title = "Combo", Text = "Shift + X pressed" })
	end })
	Elements:Graph({ Name = "FPS", Source = "FPS" })
	Elements:Graph({ Name = "Ping", Source = "Ping" })
	Elements:Graph({ Name = "Memory", Source = "Memory" })
	local Log = Elements:Console({ Name = "Console", Height = 100 })
	Log:Log("Console ready. Win:Log(text, kind) writes here.")
	Elements:Button({ Name = "Write to the console", Callback = function()
		Win:Log("An info line")
		Win:Log("A warning", "warn")
		Win:Log("An error", "error")
		Win:Log("A success", "success")
	end })
	Elements:CodeBox({ Name = "Code box", Default = 'print("hello from the code box")', Height = 70 })
	local score = UI.State(0) -- a value that updates anything bound to it
	local scoreLabel = Elements:Label("")
	score:Bind(scoreLabel, "Score: %d")
	Elements:Button({ Name = "Add 1 to the score", Callback = function()
		score:Set(score:Get() + 1)
	end })
	Elements:Feed({ Title = "News from GitHub", Url = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/README.md", Text = "Could not load the news.", MaxChars = 300 })
end

Win:CreateTab({ Name = "Elements", Icon = LOGO, Title = "🧩 ALL ELEMENTS", Description = "One of every element and every toggle style.", Build = buildElements })
local Discord = Win:CreateTab({ Name = "Discord", Icon = ICON.Discord, Title = "💬 DISCORD", Description = "Updates, support and suggestions." })
Discord:SetBadge("NEW") -- a small bubble on the tab button (nil removes it)
local ai -- the AI tab's tools (filled in below)
Win:SetAssistant({ -- the full-screen HUD is built only when it is first opened
	Logo = LOGO,
	Title = "ELITE GAME ASSISTANT",
	Color = "Rainbow",
	Key = Enum.KeyCode.H, -- press H on a keyboard to open or close it
	OnSummary = function(hud, done)
		if ai and ai.Brief then
			ai.Brief(hud, done)
		else
			done(hud:GetSummary())
		end
	end,
})
-- AI or no AI: set USE_AI to false (at the top) and the tab is simply not made.
if USE_AI then
	stage("Building the AI tab...", 0.75)
	local aiTab -- (the tab itself; we only need the tools)
	aiTab, ai = Win:CreateAITab({
		Name = "AI",
		Icon = LOGO,
		Title = "🤖 REBEL AI",
		-- No secret is in this file (it is public). Pick ONE:
		Proxy = AI_PROXY, -- your own small server that holds the keys (see ai_proxy_worker.js), or
		-- ON HOLD: the old keys are not used any more (not in this file, and their old key file is no longer read).
		-- When you have new keys, put them one per line in this NEW file inside your executor's workspace folder:
		KeyFile = "RebelAI_newkeys.txt",
	})
end
stage("Building the tools tab...", 0.85)
local Tools = Win:CreateToolsTab({ Icon = LOGO, Features = { "More themes", "More crosshairs", "Macro recorder", "Cloud sync", "Sound packs" } })
Win:CreateNotificationsTab({ Icon = LOGO }) -- every toast you saw, with an unread number on the tab
Win:CreateFavoritesTab({ Icon = LOGO }) -- pick toggles and buttons from other tabs and use them in one place
Win:CreateThemeEditor({ Icon = LOGO }) -- a color picker for every theme color, with copy / paste of the theme
stage("Building settings...", 0.92)
local Settings = Win:CreateSettingsTab({
	Icon = ICON.Settings,
	Bar = Bar,
	Credits = { Name = "Rebelwar", Text = "Made by prorizz196. Thank you for playing!", Discord = DISCORD },
}) -- the ready-made Settings tab

-- ---------------------------------------------------------------- Discord
Discord:Image({ Image = BANNER, Height = 110, Crop = true, Effect = "Shimmer" })
Discord:Paragraph({ Title = "🔥 REBELWAR — KEYLESS • SIMPLE • POWERFUL 🔥", Text = "✅ No keys needed. Open it, tap the bar, and go." })
Discord:Paragraph({
	Title = "⚡ THIS PANEL SHOWS",
	Text = "A loading screen\nA search box, a resize grip, panel opacity, dialogs, tooltips, a keybind list and collapsible sections\nNamed profiles in Settings (save Legit, Rage, ...)\nA top bar you can fill with FPS, Timer, Logo and more\nTabs with their own pictures and headers\nEvery kind of toggle, slider, color picker and menu\n14 themes that change live",
})
Discord:Paragraph({
	Title = "📚 REBELUI & RESOURCES",
	Text = "#examples: the tutorial source.lua (copy it and change it)\n#documentation: every document we have\nAsk questions, share your scripts, get help.",
})
Discord:Button({
	Name = "Copy the official Discord invite",
	Description = "Tutorials, documentation, updates and help",
	Callback = function()
		local ok = pcall(function()
			setclipboard(DISCORD)
		end)
		Win:Notify({
			Title = ok and "Copied!" or "Your executor can't copy",
			Text = ok and "Paste it in your browser to join." or DISCORD,
			Type = ok and "success" or "warn",
		})
	end,
})

-- ============================================================ 4. finish: close the loading screen, open the panel
stage("Ready!", 1)
ready = true
Load:Finish() -- fades the loading screen out
Win:Toggle(true) -- the panel pops open
if ai and ai.Boot then
	ai.Boot(aiVid) -- the AI loading video
end
Win:Notify({ Title = "Welcome, " .. lp.DisplayName, Text = "Tap the top bar (or press RightShift) to hide or show the panel.", Duration = 5 })
end

-- 2. run it. If anything goes wrong, the loading screen shows the problem and closes (it can never get stuck)
local okMain, errMain = pcall(main)
if not okMain then
	problem("Demo failed: " .. tostring(errMain))
	if Load then
		Load:Fail("Something went wrong. Check the console.")
		task.wait(4)
		Load:Destroy()
	end
	if Win then
		Win:Destroy()
	end
end
