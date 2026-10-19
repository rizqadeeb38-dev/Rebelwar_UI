--[[
    Example panel: uses EVERY RebelUI element and EVERY toggle style.
    1) Upload RebelUI.lua to your host and put its link below.
    2) Run this file in your executor.
]]

local UI = loadstring(game:HttpGet("PUT_YOUR_REBELUI_LINK_HERE"))()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- Roblox image ids (swap for your own). A bare number works too.
local LOGO = "rbxassetid://114659273298746"
local BANNER = "rbxassetid://125144167121839"
local ICON_PLAYER = "rbxassetid://119001011624125"
local ICON_DISCORD = "rbxassetid://106575470880507"
local ICON_ESP = "rbxassetid://71415024616002"

local Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "example panel",
	Icon = LOGO, -- small logo in the title bar
	Theme = "Red", -- Red, Blue, Green, Purple, Orange, Pink, Mono (or one you add)
	Width = 540,
	Height = 360,
	ToggleKey = Enum.KeyCode.RightShift, -- phones use the top bar (or a round R button) instead
})

-- The top bar: tap it to open/close the panel, drag it to move it.
-- Items: FPS, Ping, Logo, Title, Timer, Clock, Players, Memory, Executor, Game
local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" }, -- the "Classic" style. Or: Preset = "Gamer"
	Logo = LOGO,
})

-- ================= Tab 1: every toggle =================
local Toggles = Win:CreateTab({
	Name = "Toggles",
	Icon = ICON_PLAYER, -- image next to the tab name
	Title = "Toggle hub", -- the tab's own header
	Description = "Every kind of toggle RebelUI can make.",
})

Toggles:Section("1. Plain")
Toggles:Toggle({ Name = "Plain switch" })

Toggles:Section("2. Name + description")
Toggles:Toggle({
	Name = "With a description",
	Description = "A second line of small text under the name.",
	Default = true,
	Callback = function(on)
		print("description toggle:", on)
	end,
})

Toggles:Section("3. With an icon")
Toggles:Toggle({
	Name = "With an icon",
	Description = "Roblox image on the left.",
	Icon = ICON_ESP,
})

Toggles:Section("4. Checkbox style")
Toggles:Toggle({ Name = "Checkbox style", Style = "Checkbox", Default = true })

Toggles:Section("5. Own color")
Toggles:Toggle({ Name = "Green when on", Color = Color3.fromRGB(60, 200, 110), Default = true })
Toggles:Toggle({ Name = "Blue when on", Color = Color3.fromRGB(64, 140, 255), Default = true })

Toggles:Section("6. Keybind (PC)")
Toggles:Toggle({
	Name = "Toggle with a key",
	Description = "Press X to flip it.",
	Key = Enum.KeyCode.X,
})

Toggles:Section("7. Locked")
local locked = Toggles:Toggle({ Name = "Locked toggle", Description = "Cannot be changed until unlocked.", Locked = true })
Toggles:Button({
	Name = "Unlock / lock the toggle above",
	Callback = function()
		locked:Lock(not locked.Locked)
	end,
})

Toggles:Section("8. A real feature")
local infJump = false
Toggles:Toggle({
	Name = "Infinite jump",
	Description = "Jump again in the air.",
	Flag = "infjump", -- read it anywhere with Win.Flags.infjump:Get()
	Callback = function(on)
		infJump = on
	end,
})
UIS.JumpRequest:Connect(function()
	if infJump and lp.Character then
		local hum = lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- ================= Tab 2: sliders, choices, bars =================
local Bars = Win:CreateTab({
	Name = "Bars",
	Icon = ICON_ESP,
	Title = "Sliders and choices",
	Description = "Drag a slider, pick from a choice bar, watch a progress bar.",
})

Bars:Section("Slider")
Bars:Slider({
	Name = "Walk speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Step = 1,
	Callback = function(v)
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})
Bars:Slider({
	Name = "Field of view",
	Min = 40,
	Max = 120,
	Default = 70,
	Suffix = "°",
	Callback = function(v)
		workspace.CurrentCamera.FieldOfView = v
	end,
})

Bars:Section("Choice bar")
Bars:Choice({
	Name = "Difficulty",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(choice)
		Win:Notify({ Title = "Difficulty", Text = "You chose " .. choice })
	end,
})
Bars:Choice({
	Name = "Camera",
	Options = { "First", "Third", "Free" },
	Callback = function(choice)
		print("camera:", choice)
	end,
})

Bars:Section("Progress bar")
local prog = Bars:Progress({ Name = "Loading demo", Default = 0 })
Bars:Button({
	Name = "Run the progress bar",
	Callback = function()
		task.spawn(function()
			for i = 0, 100, 5 do
				prog:Set(i)
				task.wait(0.05)
			end
			Win:Notify({ Title = "Done", Text = "Progress finished.", Type = "success" })
		end)
	end,
})

-- ================= Tab 3: inputs =================
local Inputs = Win:CreateTab({ Name = "Inputs", Icon = ICON_PLAYER, Title = "Inputs", Description = "Lists, text, keys and colors." })

Inputs:Section("Dropdowns")
Inputs:Dropdown({
	Name = "Mode",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(choice)
		print("mode:", choice)
	end,
})
Inputs:Dropdown({
	Name = "Features (multi)",
	Options = { "Speed", "Jump", "Fly", "Fog" },
	Multi = true,
	Callback = function(set) -- a table like { Speed = true, Fly = true }
		for name in pairs(set) do
			print("on:", name)
		end
	end,
})

Inputs:Section("Type and bind")
Inputs:Input({
	Name = "Player name",
	Placeholder = "name here",
	Callback = function(text)
		Win:Notify({ Title = "You typed", Text = text })
	end,
})
Inputs:Keybind({
	Name = "Action key",
	Default = Enum.KeyCode.F,
	Callback = function()
		print("action key pressed")
	end,
	Changed = function(key)
		print("rebound to", key.Name)
	end,
})

Inputs:Section("Color")
Inputs:Color({
	Name = "Pick a color",
	Default = Color3.fromRGB(233, 75, 53),
	Callback = function(c)
		print("color:", c)
	end,
})

-- ================= Tab 4: text and images =================
local Info = Win:CreateTab({
	Name = "About",
	Icon = ICON_DISCORD,
	Title = "About this panel",
	Description = "Headers, paragraphs and Roblox images.",
})
Info:Image({ Image = BANNER, Height = 120, Caption = "A Roblox asset image", Crop = true })
Info:Header({ Title = "Header card", Text = "A banner with its own title, text and icon.", Icon = LOGO })
Info:Paragraph({ Title = "Paragraph", Text = "A titled block of text. It grows to fit as long as you like." })
Info:Label("A plain label is just text.")
Info:Divider()
Info:Button({
	Name = "Show every notification type",
	Callback = function()
		Win:Notify({ Title = "Info", Text = "Normal card." })
		Win:Notify({ Title = "Success", Text = "Green card.", Type = "success" })
		Win:Notify({ Title = "Warning", Text = "Yellow card.", Type = "warn" })
		Win:Notify({ Title = "Error", Text = "Red card.", Type = "error" })
	end,
})

-- ================= Tab 5: settings =================
local Settings = Win:CreateTab({ Name = "Settings", Title = "Settings", Description = "Themes, accent color and the window." })

-- one line: Show-bar toggle + style choice + a list to pick any bar items
Settings:BarSettings(Bar)

Settings:Section("Theme")
Settings:Dropdown({
	Name = "Theme",
	Options = UI.Themes,
	Default = "Red",
	Callback = function(name)
		Win:SetTheme(name)
	end,
})

Settings:Section("Your own accent color")
Settings:Color({
	Name = "Accent color",
	Default = Color3.fromRGB(233, 75, 53),
	Callback = function(c)
		Win:SetAccent(c)
	end,
})

Settings:Section("Window")
Settings:Button({
	Name = "Hide panel (tap the top bar to open)",
	Callback = function()
		Win:Toggle(false)
	end,
})
Settings:Button({
	Name = "Destroy panel",
	Callback = function()
		Win:Destroy()
	end,
})

Win:Notify({ Title = "Rebelwar", Text = "Panel loaded. Tap the top bar (or press RightShift) to hide or show it.", Duration = 5 })
