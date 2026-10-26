--[[
    RebelUI v1.0.0 · demo panel (the Rebelwar look)

    Run this file to SEE what RebelUI can do: a loading screen, the panel with its spinning ring,
    a top bar (FPS + logo + timer), tabs with Roblox images next to the name, every kind of toggle,
    sliders, colors, dropdowns, notifications, themes and saving.

    Most buttons here are just a demo (they print or show a notification). The Player tab has a few
    that really work: walk speed, jump power, infinite jump, no clip, FOV and fullbright.
    Copy any part you like into your own script. The tutorial is in README.md.
]]

local URL = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"

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

local Load, Win -- made inside main()

local function main()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

-- Roblox image ids. Swap them for your own. A bare number works too.
local LOGO = 114659273298746
local BANNER = 125144167121839
local ICON = {
	Farm = 78400891408621,
	Murderer = 111317162835328,
	Sheriff = 139030746354372,
	ESP = 71415024616002,
	Fling = 134434294002758,
	Player = 119001011624125,
	Settings = 81306187910490,
	Discord = 106575470880507,
}
local DISCORD = "https://discord.gg/Kq7N4gzH22"

-- ============================================================ 1. loading screen
local gameName = "Unknown game"
pcall(function()
	gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

Load = UI:Loading({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Logo = LOGO, -- the round logo with the spinning ring
	Banner = BANNER, -- the slow zooming picture behind everything
	Footer = "discord.gg/Kq7N4gzH22  |  RebelUI v" .. UI.Version,
	Theme = "Red",
})
Load:Badge(gameName) -- the small pill at the top
Load:Status("Loading images...")
Load:Preload({ LOGO, BANNER, ICON.Farm, ICON.Murderer, ICON.Sheriff, ICON.ESP, ICON.Fling, ICON.Player, ICON.Settings, ICON.Discord }, 0, 0.6)

-- ============================================================ 2. the window and the top bar
Load:Status("Building the panel...")
Load:Progress(0.75)

Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Icon = LOGO, -- logo in the corner
	Theme = "Red", -- Red, Crimson, Blue, Green, Purple, Orange, Pink, Gold, Cyber, Blood, Ice, Mono
	Open = false, -- stay closed until the loading screen is done
	Opacity = 100, -- 100 = solid panel (10 to 100). Players can change it in Settings
	Search = true, -- the search box next to the page title
	Resizable = true, -- drag the corner grip to resize
	ToggleKey = Enum.KeyCode.RightShift, -- phones use the top bar instead
})

local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" }, -- the Rebelwar classic. Players can change it in Settings.
	Logo = LOGO,
})

-- ============================================================ 3. tabs
local Farm = Win:CreateTab({
	Name = "Auto Farm",
	Icon = ICON.Farm, -- the image next to the tab name
	Title = "💰 AUTO FARM", -- the tab's own header
	Description = "Demo toggles. Turn them on to see how they look and feel.",
})
local Murderer = Win:CreateTab({ Name = "Murderer", Icon = ICON.Murderer, Title = "🔪 MURDERER", Description = "Alerts and helpers for the murderer." })
local Sheriff = Win:CreateTab({ Name = "Sheriff", Icon = ICON.Sheriff, Title = "🎯 SHERIFF", Description = "Alerts and helpers for the sheriff." })
local ESP = Win:CreateTab({ Name = "ESP", Icon = ICON.ESP, Title = "👁️ ESP", Description = "Highlights, names, distance and colors." })
local Fling = Win:CreateTab({ Name = "Fling", Icon = ICON.Fling, Title = "🛡️ PROTECTION", Description = "Stop others from pushing you around." })
local Player = Win:CreateTab({ Name = "Player", Icon = ICON.Player, Title = "🧍 PLAYER", Description = "These ones really work in any game." })
Win:CreateTabDivider("Extras") -- a small caption between tabs
local Elements = Win:CreateTab({ Name = "Elements", Icon = ICON.ESP, Title = "🧩 ALL ELEMENTS", Description = "One of every element and every toggle style." })
local Discord = Win:CreateTab({ Name = "Discord", Icon = ICON.Discord, Title = "💬 DISCORD", Description = "Updates, support and suggestions." })
local Settings = Win:CreateSettingsTab({ Icon = ICON.Settings, Bar = Bar }) -- the ready-made Settings tab

-- ---------------------------------------------------------------- Auto Farm
Farm:Section("💰 COIN COLLECTION")
Farm:Toggle({
	Name = "Auto Collect Coins",
	Description = "Flies to & picks up coins automatically",
	Flag = "farm",
	Callback = function(on)
		print("auto collect:", on)
	end,
})
Farm:Slider({ Name = "Fly Speed (16-60)", Min = 16, Max = 60, Default = 40, Flag = "farmSpeed" })
Farm:Slider({ Name = "Delay Between Picks (ms)", Min = 0, Max = 3000, Default = 300, Step = 50, Flag = "farmDelay" })
Farm:Toggle({ Name = "Pause When Others Nearby", Description = "Stops if someone walks close to you" })
Farm:Toggle({ Name = "Stop After Time Limit", Description = "Auto-disables after a set time" })
local coins = Farm:Progress({ Name = "Coins collected (demo)", Min = 0, Max = 40, Suffix = " / 40" })
Farm:Button({
	Name = "Fill the progress bar",
	Callback = function()
		task.spawn(function()
			for i = 0, 40 do
				coins:Set(i)
				task.wait(0.04)
			end
			Win:Notify({ Title = "Auto Farm", Text = "You collected 40 coins!", Type = "success" })
		end)
	end,
})

-- ---------------------------------------------------------------- Murderer / Sheriff
Murderer:Section("⚠️ ALERTS")
Murderer:Toggle({ Name = "Distance Warning", Description = "Alert when someone gets too close" })
Murderer:Slider({ Name = "Warning Range (5-50)", Min = 5, Max = 50, Default = 15 })
Murderer:Section("🧰 UTILITIES")
Murderer:Toggle({ Name = "Round Info HUD", Description = "Small panel: your role, players alive, nearest player" })
Murderer:Toggle({ Name = "Death Notifications", Description = "Tells you when someone is eliminated" })
Murderer:Toggle({ Name = "Auto Equip Knife", Description = "Holds your knife automatically when you have it" })

Sheriff:Section("⚠️ ALERTS")
Sheriff:Toggle({ Name = "Proximity Alert", Description = "Notifies you when someone approaches quietly" })
Sheriff:Slider({ Name = "Alert Range (5-60)", Min = 5, Max = 60, Default = 20 })
Sheriff:Toggle({ Name = "Gun Drop Alert", Description = "Notify when the gun falls on the ground" })
Sheriff:Section("🧰 UTILITIES")
Sheriff:Toggle({ Name = "Auto Equip Gun", Description = "Holds your gun automatically when you have it" })
Sheriff:Toggle({ Name = "Teleport To Dropped Gun", Description = "Teleports you to the gun when it drops" })

-- ---------------------------------------------------------------- ESP
ESP:Section("🎯 PLAYER HIGHLIGHTS")
ESP:Toggle({ Name = "Enable ESP", Description = "Master on/off switch for all player highlights", Flag = "esp" })
ESP:Toggle({ Name = "Show Names", Description = "Display player names above their heads", Default = true })
ESP:Toggle({ Name = "Show Distance", Description = "See how far away each player is in studs", Default = true })
ESP:Toggle({ Name = "Tracer Lines", Description = "Draw lines from you to each player" })
ESP:Slider({ Name = "Max Distance (50-500)", Min = 50, Max = 500, Default = 250 })
ESP:Section("🎨 COLOR SETTINGS")
ESP:Color({ Name = "Murderer Color", Default = Color3.fromRGB(235, 40, 50), Flag = "cMurd" })
ESP:Color({ Name = "Sheriff Color", Default = Color3.fromRGB(40, 140, 255), Flag = "cSher" })
ESP:Color({ Name = "Innocent Color", Default = Color3.fromRGB(60, 210, 90), Flag = "cInno" })

-- ---------------------------------------------------------------- Fling
Fling:Section("🛡️ PROTECTION")
Fling:Toggle({ Name = "Anti-Fling", Description = "Stop others from flinging YOU" })
Fling:Toggle({ Name = "No Knockback", Description = "Don't get pushed around" })
Fling:Toggle({ Name = "Stay Grounded", Description = "Resist being launched" })

-- ---------------------------------------------------------------- Player (these really work)
local conns = {}
local function hum()
	return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
end

Player:Section("⚡ MOVEMENT")
Player:Slider({
	Name = "Walk Speed (16-80)",
	Min = 16,
	Max = 80,
	Default = 16,
	Flag = "walk",
	Callback = function(v)
		if hum() then
			hum().WalkSpeed = v
		end
	end,
})
Player:Slider({
	Name = "Jump Power (50-150)",
	Min = 50,
	Max = 150,
	Default = 50,
	Flag = "jump",
	Callback = function(v)
		local h = hum()
		if h then
			h.UseJumpPower = true
			h.JumpPower = v
		end
	end,
})
local infJump = false
Player:Toggle({
	Name = "Infinite Jump",
	Description = "Jump repeatedly without cooldown",
	Flag = "infjump",
	Callback = function(on)
		infJump = on
	end,
})
table.insert(conns, UIS.JumpRequest:Connect(function()
	if infJump and hum() then
		hum():ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))
Player:Toggle({
	Name = "No Clip",
	Description = "Walk through walls & objects",
	Flag = "noclip",
	Callback = function(on)
		if conns.noclip then
			conns.noclip:Disconnect()
			conns.noclip = nil
		end
		if on then
			conns.noclip = RunService.Stepped:Connect(function()
				if lp.Character then
					for _, p in ipairs(lp.Character:GetDescendants()) do
						if p:IsA("BasePart") then
							p.CanCollide = false
						end
					end
				end
			end)
		end
	end,
})
Player:Section("🎮 CAMERA & VISION")
Player:Slider({
	Name = "FOV (70-110)",
	Min = 70,
	Max = 110,
	Default = 70,
	Flag = "fov",
	Callback = function(v)
		workspace.CurrentCamera.FieldOfView = v
	end,
})
local old
Player:Toggle({
	Name = "Fullbright",
	Description = "See clearly in dark areas",
	Flag = "fullbright",
	Callback = function(on)
		if on then
			old = { Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient }
			Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		elseif old then
			Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient = old[1], old[2], old[3], old[4]
		end
	end,
})
Win.OnDestroy = function() -- clean up when the panel is closed
	for _, c in pairs(conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
end

-- ---------------------------------------------------------------- Elements: one of everything
Elements:Section("1. Toggles")
Elements:Toggle({ Name = "Plain switch" })
Elements:Toggle({ Name = "Name + description", Description = "A second line of small text under the name", Default = true })
Elements:Toggle({ Name = "With an icon", Description = "A Roblox image on the left", Icon = ICON.ESP })
Elements:Toggle({ Name = "Checkbox style", Description = "Style = \"Checkbox\"", Style = "Checkbox", Default = true })
Elements:Toggle({ Name = "Green when on", Description = "Color = Color3.fromRGB(...)", Color = Color3.fromRGB(60, 210, 90), Default = true })
Elements:Toggle({ Name = "Blue when on", Color = Color3.fromRGB(64, 140, 255), Default = true })
Elements:Toggle({ Name = "Toggle with a key", Description = "Press X on a keyboard to flip it", Key = Enum.KeyCode.X })
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
	Description = "Demo key: REBEL-DEMO",
	Callback = function()
		local ok = UI:KeyGate({
			Name = "RebelUIDemo",
			Title = "Enter your key",
			Subtitle = "This is only a demo. Use REBEL-DEMO.",
			Keys = { "REBEL-DEMO" }, -- or: Check = function(key) return true end
			Save = false, -- true remembers the key on this device
			Theme = Win.ThemeName,
		})
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
	Default = Enum.KeyCode.H,
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

-- a tab that builds itself the first time you open it (fast start)
Win:CreateTab({
	Name = "Lab",
	Icon = ICON.ESP,
	Title = "🧪 LAB",
	Description = "This tab was built when you opened it.",
	Build = function(tab)
		tab:Notice({ Type = "success", Title = "Lazy tab", Text = "Build = function(tab) ... end runs once, the first time the tab opens." })
		tab:Toggle({ Name = "A toggle made on demand" })
	end,
})

-- ---------------------------------------------------------------- Discord
Discord:Image({ Image = BANNER, Height = 110, Crop = true })
Discord:Paragraph({ Title = "🔥 REBELWAR — KEYLESS • SIMPLE • POWERFUL 🔥", Text = "✅ No keys needed. Open it, tap the bar, and go." })
Discord:Paragraph({
	Title = "⚡ THIS PANEL SHOWS",
	Text = "A loading screen\nA search box, a resize grip, panel opacity, dialogs, tooltips, a keybind list and collapsible sections\nNamed profiles in Settings (save Legit, Rage, ...)\nA top bar you can fill with FPS, Timer, Logo and more\nTabs with their own pictures and headers\nEvery kind of toggle, slider, color picker and menu\n14 themes that change live",
})
Discord:Button({
	Name = "Copy the Discord invite",
	Description = "Updates, support and suggestions",
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
Load:Status("Ready!")
Load:Finish() -- fades the loading screen out
Win:Toggle(true) -- the panel pops open
Win:Notify({ Title = "Rebelwar", Text = "Tap the top bar (or press RightShift) to hide or show the panel.", Duration = 5 })
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
