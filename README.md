# 🪓🔥 RebelUI

**A mobile-friendly panel library for Roblox executors. The same panel, top bar, toggles and loading screen as the Rebelwar Hub.**

![Version](https://img.shields.io/badge/RebelUI-v1.0.0-e94b35)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/works%20on-mobile%20%7C%20PC-blue)

RebelUI gives you a finished panel in a few lines: a spinning-ring window with embers, tabs that have a **Roblox image next to the name** and their own header, **every kind of toggle** (name, description, icon, color, locked, key, checkbox), sliders, dropdowns, color pickers, notifications, a **top bar** where the player chooses what shows (FPS, Timer, Logo and more), a **loading screen**, 14 themes that change live, and saving.

Made by **prorizz196**. Discord: https://discord.gg/Kq7N4gzH22

---

## Contents

1. [Quick start](#quick-start)
2. [The loading screen](#the-loading-screen)
3. [The window](#the-window)
4. [The top bar](#the-top-bar)
5. [Tabs](#tabs)
6. [All toggles](#all-toggles)
7. [Sliders, choices and progress bars](#sliders-choices-and-progress-bars)
8. [Buttons, dropdowns, inputs, keybinds](#buttons-dropdowns-inputs-keybinds)
9. [Colors](#colors)
10. [Text and images](#text-and-images)
11. [Notifications](#notifications)
12. [Themes and your own colors](#themes-and-your-own-colors)
13. [The ready-made Settings tab](#the-ready-made-settings-tab)
14. [Flags and saving settings](#flags-and-saving-settings)
15. [Mobile tips](#mobile-tips)
16. [Build it yourself](#build-it-yourself) (how every piece is made, step by step)
17. [Common mistakes](#common-mistakes)
18. [What is new in v1.0.0](#what-is-new-in-v100)
19. [Files in this repo](#files-in-this-repo)
20. [Search, resize, profiles and the key gate](#search-resize-profiles-and-the-key-gate)
21. [More tools: dialogs, collapsible sections, keybind modes](#more-tools)

---

## Quick start

### Try the demo first

Paste this into your executor. It shows the loading screen, then a panel with every element:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/Example.lua"))()
```

The demo is `Example.lua` in this repo. Read it next to this tutorial, it uses everything.

### Use the library in your own script

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"))()

local Win = UI:CreateWindow({ Title = "My Panel", Subtitle = "made by me", Icon = 114659273298746 })
local Bar = Win:CreateBar({ Items = { "FPS", "Logo", "Timer" }, Logo = 114659273298746 })

local Main = Win:CreateTab({ Name = "Main", Icon = 78400891408621, Title = "Main hub", Description = "Your first tab." })

Main:Toggle({
	Name = "Infinite jump",
	Description = "Jump again in the air",
	Callback = function(on)
		print("infinite jump:", on)
	end,
})
Main:Slider({ Name = "Walk speed", Min = 16, Max = 80, Default = 16, Callback = function(v) print(v) end })
Main:Button({ Name = "Say hi", Callback = function() Win:Notify({ Title = "Hi", Text = "It works!" }) end })

Win:CreateSettingsTab({ Bar = Bar }) -- themes, top bar choices, notifications, saving
```

That is a full panel. Tap the top bar (or press **RightShift** on a keyboard) to hide or show it. Drag the bar or the panel title to move them.

---

## The loading screen

A full-screen intro: a slowly zooming banner, rising embers, a logo with a spinning ring, a shining title and a loading bar that fills as you load. It is optional. Use it like this:

```lua
local Load = UI:Loading({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Logo = 114659273298746,     -- round logo with the spinning ring
	Banner = 125144167121839,   -- zooming picture behind everything
	Footer = "discord.gg/Kq7N4gzH22  |  v1.0.0",
})

Load:Badge("Murder Mystery 2") -- small pill at the top (a game name, "Supported" ...)
Load:Status("Loading images...")
Load:Preload({ 114659273298746, 125144167121839 }, 0, 0.6) -- bar goes 0% -> 60% while images load

Load:Status("Building the panel...")
Load:Progress(0.8)
-- ... create your window, tabs and toggles here ...

Load:Status("Ready!")
Load:Finish() -- fills the bar, fades out, then returns
```

### Options

| Option | What it does | Default |
|---|---|---|
| `Title` | Big shining title | `"RebelUI"` |
| `Subtitle` | Small capital letters under the title | none |
| `Logo` | Roblox image id for the round logo | none |
| `Banner` | Roblox image id for the background picture | none (plain dark) |
| `Footer` | Text at the bottom. `false` hides it | `"RebelUI v1.0.0"` |
| `Theme` | Any theme name. It colors the glow, bar and title | `"Red"` |
| `Name` | Name of the ScreenGui | `"RebelUI_Loading"` |
| `Timeout` | Seconds after which the screen removes itself if you never call `Finish` (so it can never get stuck) | `40` |

### Methods

| Method | What it does |
|---|---|
| `Load:Progress(0.5)` | Moves the bar to 50% (a number from 0 to 1). The bar glides there smoothly |
| `Load:Status("text")` | Changes the line above the bar. The text slides in |
| `Load:Badge("text", color)` | Shows a pill at the top. The color is optional |
| `Load:Preload({ ids }, from, to)` | Loads images ahead of time. While it works the bar moves from `from` to `to` (0 to 1). Stops waiting after 5 seconds |
| `Load:Run({ {"text", fn}, ... })` | Runs your steps one by one. It shows each text, runs the function and fills the bar. A step that errors only prints a warning |
| `Load:Fail("text")` | Turns the bar grey and shows the text in red. Use it when something is wrong. Then call `Load:Destroy()` |
| `Load:Finish()` | Fills the bar, fades everything out and removes it. It waits about one second, so code after it runs when the screen is gone |
| `Load:Destroy()` | Removes the screen at once, no fade |

### A loading screen that does real work

`Run` is the easiest way. Each step is `{ "text shown", function }`:

```lua
local Load = UI:Loading({ Title = "My Hub", Logo = 114659273298746 })
local Win

Load:Run({
	{ "Loading images", function() Load:Preload({ 114659273298746 }, 0, 0.5) end },
	{ "Building the panel", function()
		Win = UI:CreateWindow({ Title = "My Hub", Open = false })
		Win:CreateTab({ Name = "Main" })
	end },
	{ "Almost there", function() task.wait(0.3) end },
})
Load:Finish()
Win:Toggle(true) -- open the panel after the loading screen is gone
```

**Never get stuck.** If your script errors while the loading screen is up, the screen would cover the game. Wrap the building part in `pcall` and close the screen on failure:

```lua
local ok, err = pcall(function()
	-- build your window here
end)
if not ok then
	Load:Fail("Something went wrong")
	task.wait(3)
	Load:Destroy()
	warn(err)
end
```

> Tip: create the window with `Open = false` while the loading screen is up, then call `Win:Toggle(true)` after `Load:Finish()`. The panel then pops open exactly when the intro fades.

---

## The window

```lua
local Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Icon = 114659273298746,
	Theme = "Red",
})
```

The window has: a **logo and title** in the corner, a **tab list** on the left, the **page** on the right with a glowing line under the page title, a **player card** (your avatar and name) at the bottom left, a minimise `-` button and a close `X` button. A bright ring spins around the panel and small embers float up behind it.

### Options

| Option | What it does | Default |
|---|---|---|
| `Title` | Name in the corner | `"RebelUI"` |
| `Subtitle` | Small text under the title | none |
| `Icon` | Roblox image id for the small logo (also used on the round open button) | none |
| `Theme` | `Red`, `Crimson`, `Blue`, `Green`, `Purple`, `Orange`, `Pink`, `Gold`, `Cyber`, `Blood`, `Ice`, `Mono`, `Contrast`, `Colorblind`, or a theme you added | `"Red"` |
| `Width`, `Height` | Panel size in pixels (it shrinks to fit small screens) | `420`, `340` |
| `Open` | `false` keeps the panel closed at the start | `true` |
| `Opacity` | How solid the panel is, 10 to 100. `100` = fully solid | `100` |
| `Search` | `false` hides the search box next to the page title | `true` |
| `Resizable` | `false` removes the corner grip that resizes the panel | `true` |
| `Inertia` | `false` stops the panel gliding after you let go | `true` |
| `Scramble` | `false` turns off the title decode effect | `true` |
| `AutoSave` | Seconds between backups (needs `writefile`) | off |
| `ToggleKey` | Key that shows or hides the panel on a keyboard | `Enum.KeyCode.RightShift` |
| `Profile` | `false` hides the player card at the bottom left | `true` |
| `Name` | Name of the ScreenGui (a second window with the same name replaces the first) | `"RebelUI"` |
| `Sound` | Soft click sounds | `false` |
| `Toasts` | Show notification cards | `true` |
| `ConfirmClose` | `true` asks you to tap `X` twice | `false` |
| `Position` | Where the panel starts, as a `UDim2` | center |

### Methods

| Method | What it does |
|---|---|
| `Win:CreateTab(...)` | Adds a tab. See [Tabs](#tabs) |
| `Win:CreateBar(...)` | Adds the top bar. See [The top bar](#the-top-bar) |
| `Win:CreateSettingsTab(...)` | Adds a finished Settings tab. See [the Settings tab](#the-ready-made-settings-tab) |
| `Win:Notify(...)` | Shows a notification card. See [Notifications](#notifications) |
| `Win:Toggle()` | Shows or hides the panel. `Win:Toggle(true)` opens, `Win:Toggle(false)` closes |
| `Win:SetTheme("Blue")` | Changes the whole theme live |
| `Win:SetAccent(Color3)` | Makes a theme from any color |
| `Win:SetScale(1.2)` | Makes the panel bigger or smaller (0.5 to 1.6) |
| `Win:Dialog({...})` | A pop-up question with up to 3 buttons. See [More tools](#more-tools) |
| `Win:CreateKeybindList({...})` | An on-screen list of your keybinds. See [More tools](#more-tools) |
| `Win:CreateTabDivider("GAMES")` | A small caption between tabs in the side list |
| `Win:Export()` / `Win:Import(text)` | All your settings as one short code (`RBL1:`), and back |
| `Win:ExportTheme()` | Just the colors (`RBLT:#RRGGBB`) |
| `Win:GenerateCode()` | The Lua that builds this panel as it is now |
| `Win:AutoSave(60)` / `Win:RestoreSnapshot()` | Backup every N seconds, and bring it back |
| `Win:ThemeFromAvatar()` | Accent from your avatar's colors |
| `Win:CheckUpdate({...})` | Tells the player when a newer version exists |
| `Win:Log(text, kind)` | Writes to the first console |
| `UI:SetLanguage({...})` | Translate every label |
| `Win:SetOpacity(100)` | How solid the panel is, 10 to 100 (`100` = solid) |
| `Win:SetTransparency(0.3)` | The same thing the other way round (0 to 0.9) |
| `Win:SetSize(500, 380)` | Resizes the panel (it stays on the screen, minimum 320 x 240) |
| `Win:SetToggleKey(Enum.KeyCode.F4)` | Changes the key that opens and closes the panel |
| `Win:SaveProfile(name)` / `LoadProfile` / `DeleteProfile` / `ListProfiles` | Named settings. See [Profiles](#search-resize-profiles-and-the-key-gate) |
| `Win:SetAutoLoad(name)` / `Win:AutoLoad()` | Pick and apply the profile that loads on start |
| `UI:KeyGate({...})` | Asks for a key before your script goes on. See [the key gate](#search-resize-profiles-and-the-key-gate) |
| `Win:Save(file)` / `Win:Load(file)` | Save or load every element that has a `Flag`. See [saving](#flags-and-saving-settings) |
| `Win:Destroy()` | Removes the whole panel and stops everything |

### Fields you can change

```lua
Win.Toasts = false        -- no notification cards
Win.ToggleToasts = true   -- a card every time a toggle flips
Win.Sound = true          -- click sounds
Win.NotifyTime = 3        -- seconds a card stays
Win.ConfirmClose = true   -- tap X twice
Win.OnDestroy = function() print("closed") end -- runs when the panel is closed (clean up here)
Win.Flags.myflag:Get()    -- read any element that has Flag = "myflag"
```

---

## The top bar

A small pill at the top of the screen. **Tap it to open or close the panel. Drag it to move it.** On a phone it replaces the round open button.

```lua
local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" },   -- what it shows
	Logo = 114659273298746,               -- the picture used by the "Logo" item
})
```

### What the bar can show

| Item | Shows |
|---|---|
| `FPS` | Your frames per second |
| `Ping` | Your ping in ms |
| `Logo` | Your logo (a little pulse) |
| `Title` | The window title |
| `Timer` | How long you have been playing (`00:12:30`) |
| `Clock` | The time of day |
| `Players` | Players in the server (`8/12`) |
| `Memory` | Memory used in MB |
| `Executor` | The name of your executor |
| `Game` | The game name |

Items always appear in the order of this table. The list is also in `UI.BarItems`.

### Ready-made styles

| Preset | Items |
|---|---|
| `Classic` | FPS, Logo, Timer |
| `Minimal` | Logo |
| `Gamer` | FPS, Ping, Clock |
| `Info` | Logo, Title, Players, Executor |
| `Full` | everything |

```lua
local Bar = Win:CreateBar({ Preset = "Gamer" })
```

### Options

| Option | What it does | Default |
|---|---|---|
| `Items` | List of item names | the `Classic` preset |
| `Preset` | A preset name (used when you give no `Items`) | `"Classic"` |
| `Logo` | Image id for the `Logo` item | none (shows an `R`) |
| `Visible` | `false` starts hidden | `true` |
| `Position` | A `UDim2` | top center |

### Methods

```lua
Bar:SetItems({ "FPS", "Ping", "Players" })  -- replace what it shows
Bar:SetPreset("Full")                       -- use a preset
Bar:Add("Clock")                            -- add one item
Bar:Remove("Timer")                         -- remove one item
Bar:GetItems()                              -- { "FPS", "Ping", ... }
Bar:SetLogo(114659273298746)                -- change the logo picture
Bar:Show(false)                             -- hide or show the whole bar
Bar:ResetPosition()                         -- put it back at the top
Bar:Destroy()                               -- remove it (the round open button comes back)
Bar.OnChange = function(items) print(#items) end
```

### Let the player choose (one line)

`Tab:BarSettings(Bar)` adds the controls that let the player pick what shows: a **Show top bar** toggle, a **Bar style** choice (the presets) and a multi-select **Bar items** list ("ADD MORE" is just ticking more boxes).

```lua
local Settings = Win:CreateTab({ Name = "Settings", Icon = 81306187910490 })
Settings:BarSettings(Bar)
```

Use `Settings:BarSettings(Bar, { Section = "My bar", Preset = "Info" })` to rename the section or pick a start style. `Win:CreateSettingsTab({ Bar = Bar })` already does this for you.

---

## Tabs

```lua
local Farm = Win:CreateTab({
	Name = "Auto Farm",
	Icon = 78400891408621,          -- picture next to the name
	Title = "💰 AUTO FARM",         -- the tab's own header (the "text hub")
	Description = "Collect coins on your own.",
})
```

| Option | What it does |
|---|---|
| `Name` | Text on the tab button and the page title |
| `Icon` | A Roblox image id. It shows next to the name and is dimmed until the tab is selected |
| `Title`, `Description` | If you give either, a header card appears at the top of the page |
| `HeaderIcon` | Picture for the header card (defaults to `Icon`) |

The short form works too: `Win:CreateTab("Main", 78400891408621)`.

**Tab methods:** `Tab:Select()`, `Tab:SetName("New")`, `Tab:SetIcon(123)`, plus every element below (`Tab:Toggle`, `Tab:Slider`, ...). The first tab you create is selected automatically. The selected tab glows with the theme color and its page slides in.

---

## All toggles

```lua
local t = Tab:Toggle({
	Name = "Infinite jump",
	Description = "Jump again in the air",
	Callback = function(on) print(on) end,
})
```

### Every toggle option

| Option | What it does | Default |
|---|---|---|
| `Name` | The label | `"Toggle"` |
| `Description` | Small second line under the name | none |
| `Icon` | Roblox image id shown on the left | none |
| `Default` | `true` starts ON | `false` |
| `Style` | `"Switch"` (pill) or `"Checkbox"` | `"Switch"` |
| `Color` | A `Color3` used when ON (instead of the theme color) | theme color |
| `Locked` | `true` stops it from being changed | `false` |
| `Key` | An `Enum.KeyCode` that flips it on a keyboard | none |
| `Flag` | A name so you can read or save it later | none |
| `Callback` | `function(on)` called when it changes | none |

> A toggle with `Default = true` calls your `Callback(true)` once at the start, so your feature really starts ON.

### Every toggle method

| Method | What it does |
|---|---|
| `t:Set(true)` | Turn it on or off (runs `Callback`). `t:Set(true, true)` changes it without running `Callback` |
| `t:Get()` | `true` or `false` |
| `t:Toggle()` | Flip it (a locked toggle shows a warning card instead) |
| `t:Lock(true)` / `t:Lock(false)` | Lock or unlock |
| `t:SetName("x")`, `t:SetDescription("x")` | Change the text |
| `t:SetColor(Color3)` | Change its ON color |

### The kinds of toggle

```lua
-- 1. Plain
Tab:Toggle({ Name = "Plain switch" })

-- 2. Name + description
Tab:Toggle({ Name = "God mode", Description = "Take no damage" })

-- 3. With a Roblox image icon
Tab:Toggle({ Name = "ESP", Description = "See everyone", Icon = 71415024616002 })

-- 4. Checkbox style
Tab:Toggle({ Name = "Remember me", Style = "Checkbox", Default = true })

-- 5. Its own color (green when ON)
Tab:Toggle({ Name = "Good vibes", Color = Color3.fromRGB(60, 210, 90), Default = true })

-- 6. A key flips it (PC)
Tab:Toggle({ Name = "Speed", Description = "Press X", Key = Enum.KeyCode.X })

-- 7. Locked, and unlock it later
local locked = Tab:Toggle({ Name = "VIP only", Description = "Locked for now", Locked = true })
Tab:Button({ Name = "Unlock", Callback = function() locked:Lock(false) end })

-- 8. A toggle that really does something
local infJump = false
Tab:Toggle({
	Name = "Infinite jump",
	Flag = "infjump",
	Callback = function(on) infJump = on end,
})
game:GetService("UserInputService").JumpRequest:Connect(function()
	local char = game.Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if infJump and hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)
```

When a toggle flips, the knob stretches, the switch glows, the row tints and the text says **ON** or **OFF**. Turn on `Win.ToggleToasts = true` (or the **Toggle pop-ups** switch in the Settings tab) to also get a small card each time.

---

## Sliders, choices and progress bars

### Slider

```lua
local speed = Tab:Slider({
	Name = "Walk speed (16-80)",
	Min = 16,
	Max = 80,
	Default = 16,
	Step = 1,        -- snaps to this size (0.1 works too)
	Suffix = "",     -- text after the number, like "%" or "s"
	Callback = function(v) print(v) end,
})
speed:Set(40)   -- move it from code
speed:Get()     -- the number
```

Drag anywhere along the bar. While your finger is on it the page does not scroll.

### Choice bar

A bar of buttons where one is chosen.

```lua
local mode = Tab:Choice({
	Name = "Difficulty",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",     -- use false to start with nothing chosen
	Callback = function(choice) print(choice) end,
})
mode:Set("Hard")
mode:Get()
```

### Cycle picker (the `<  option  >` arrows)

Good for long lists like themes, because it takes one row.

```lua
local theme = Tab:Cycle({
	Name = "Theme Mode",
	Description = "14 themes - tap the arrows",
	Options = UI.Themes,
	Default = "Red",                       -- a name or a number
	Callback = function(name, index) Win:SetTheme(name) end,
})
theme:Set("Blue")   -- or theme:Set(3)
```

### Progress bar

A read-only bar you fill from your code.

```lua
local coins = Tab:Progress({ Name = "Coins", Min = 0, Max = 40, Suffix = " / 40" })
coins:Set(12)
```

---

## Buttons, dropdowns, inputs, keybinds

### Button

A shiny gradient button with a spinning ring, a moving shine, a squish when pressed and a ripple when clicked.

```lua
local b = Tab:Button({
	Name = "Teleport to spawn",
	Description = "Optional second line",  -- makes it a little taller
	Callback = function() print("clicked") end,
})
b:Fire()                  -- press it from code
b:SetName("New name")
```

### Dropdown (one choice or many)

```lua
Tab:Dropdown({
	Name = "Mode",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(choice) print(choice) end,
})

local many = Tab:Dropdown({
	Name = "Features",
	Options = { "Speed", "Jump", "Fly", "Fog" },
	Multi = true,
	Default = { "Jump" },
	Callback = function(set) -- a table like { Speed = true, Fly = true }
		for name in pairs(set) do print("on:", name) end
	end,
})
many:Set({ "Speed", "Fly" }) -- choose from code
many:Refresh({ "A", "B" })   -- replace the options
many:Close()
```

### Input (text box)

```lua
Tab:Input({
	Name = "Player name",
	Placeholder = "type a name",
	Clear = false,          -- true empties the box after Enter
	Callback = function(text) print(text) end,
})
```

### Keybind

```lua
Tab:Keybind({
	Name = "Action key",
	Default = Enum.KeyCode.F,
	Callback = function() print("pressed") end,     -- when the key is pressed
	Changed = function(key) print(key.Name) end,    -- when the player picks a new key
})
```

---

## Colors

```lua
local c = Tab:Color({
	Name = "Murderer color",
	Default = Color3.fromRGB(235, 40, 50),
	Callback = function(color) print(color) end,
})
c:Set(Color3.fromRGB(0, 255, 0))
c:GetHex()       -- "#00FF00"
c:SetHex("#FF8800")
```

The row shows the color as a small pill and its hex code. **Tap the pill** to open the picker: a rainbow hue bar, a saturation bar, a brightness bar and nine preset swatches. You can also type a hex code in the box.

---

## Text and images

### Roblox images (asset ids)

Anywhere a picture is expected (`Icon`, `Logo`, `Image`, `Banner`) you can give the number from the Roblox website, or the long form. All three are the same:

```lua
Icon = 78400891408621
Icon = "78400891408621"
Icon = "rbxassetid://78400891408621"
```

Upload your pictures to Roblox as **Decal/Image** assets you own and use the asset id. If a picture does not show, the id is wrong or it is not public.

### Image

```lua
Tab:Image({ Image = 125144167121839, Height = 110, Caption = "My banner", Crop = true })
```

`Crop = true` fills the box and crops the edges. `false` fits the whole picture.

### Header (a card with a title, text and picture)

```lua
Tab:Header({ Title = "Welcome", Text = "Everything you need is here.", Icon = 114659273298746 })
```

### Section, Label, Paragraph, Divider

```lua
Tab:Section("⚡ MOVEMENT")              -- a colored heading
Tab:Label("A small grey note.")          -- plain text, wraps
Tab:Paragraph({ Title = "Tip", Text = "A titled block of text. It grows to fit." })
Tab:Divider()                            -- a thin line
```

---

## Notifications

Small cards that slide up from the bottom, stack, and have a bar that shrinks until they go away.

```lua
Win:Notify({ Title = "Saved", Text = "Your settings are saved.", Type = "success", Duration = 4 })
Win:Notify("Just a line of text")
```

| Option | What it does | Default |
|---|---|---|
| `Title` | Bold first line | `"Rebelwar"` |
| `Text` | Smaller second line (wraps) | none |
| `Type` | `"success"` (green), `"warn"` (yellow), `"error"` (red), or none (theme color) | none |
| `Duration` | Seconds on screen | `Win.NotifyTime` (4) |
| `Actions` | Up to 3 buttons: `{ { Name = "Yes", Callback = fn }, { Name = "No" } }`. Tapping one runs it and closes the card | none |

```lua
Win:Notify({
	Title = "Update ready",
	Text = "Reload now?",
	Duration = 8,
	Actions = {
		{ Name = "Reload", Callback = function() print("reloading") end },
		{ Name = "Later" },
	},
})
```

---

## Themes and your own colors

Fourteen themes are built in. `Red` is the exact Rebelwar Hub look. `Contrast` (black and bright yellow) and `Colorblind` (blue) are made to be easy to read.

| Theme | Color |
|---|---|
| `Red` | Rebelwar red (default) |
| `Crimson` | Deep red |
| `Blue` | Bright blue |
| `Green` | Green |
| `Purple` | Purple |
| `Orange` | Orange |
| `Pink` | Hot pink |
| `Gold` | Gold |
| `Cyber` | Cyan |
| `Blood` | Dark blood red |
| `Ice` | Ice blue |
| `Mono` | Grey / white |
| `Contrast` | Pure black with bright yellow (easy reading) |
| `Colorblind` | Blue (easy to tell apart from orange) |

```lua
Win:SetTheme("Cyber")                          -- everything recolors live
Win:SetAccent(Color3.fromRGB(255, 120, 0))     -- build a theme from any color
UI:AddTheme("Mint", Color3.fromRGB(80, 230, 180))
Win:SetTheme("Mint")
print(table.concat(UI.Themes, ", "))           -- all names, includes ones you added
```

A theme changes the accent glow, the spinning ring, the panel and side gradients, the rows, the top bar, the buttons and the tabs.

---

## The ready-made Settings tab

One line gives you a full Settings tab, the same one the Rebelwar Hub has:

```lua
Win:CreateSettingsTab({
	Bar = Bar,                          -- adds the top bar choices (optional)
	Icon = 81306187910490,              -- tab picture (optional)
	-- Name = "Settings", Title = "...", Description = "...", File = "my_settings.json"
})
```

It contains: a **Theme** cycle (14 themes) · **Match my avatar colors** · an **Accent color** picker · **Panel size** · **Opacity** (100% = solid) · **Open / close key** · **Profiles** (name, save, load, delete, load on start) · the **top bar choices** (show bar, style, items) · **Notifications**, **Toggle pop-ups**, **Sound effects**, **Notification time** · **Copy / paste settings code**, **Copy theme code**, **Copy this panel as code** · **Auto-save**, **Check for updates**, **Anti-AFK**, **Rejoin** · **Confirm on close** · **Reset position** · **Save settings** · **Load settings** · **Unload panel**.

---

## Flags and saving settings

Give an element a `Flag` and you can read it from anywhere, and save it.

```lua
Tab:Toggle({ Name = "Auto farm", Flag = "farm" })
Tab:Slider({ Name = "Speed", Min = 16, Max = 80, Default = 16, Flag = "speed" })

print(Win.Flags.farm:Get())       -- true / false
Win.Flags.speed:Set(50)           -- move it from code

Win:Save()   -- writes "<Title>_settings.json" (needs an executor with writefile). Returns true if it worked
Win:Load()   -- reads it back and applies it (your Callbacks run). Returns true if a file was found
```

Put `Win:Load()` at the end of your script to bring a player's settings back. `Win:Save("my_file.json")` uses your own file name. Toggles, sliders, choices, cycles, dropdowns (one or many), text boxes, keybinds, colors and the theme are saved.

---

## Mobile tips

- The panel is made small on purpose (420 x 340) with text sizes that stay readable on a phone. Use **Panel size** in Settings (or `Win:SetScale(1.2)`) to enlarge.
- Always make a way to open the panel without a keyboard: the **top bar** (tap it) or the round open button that shows when there is no bar.
- Sliders and color bars lock page scrolling while a finger is on them, so they do not fight with scrolling.
- Keep descriptions short. Long names are cut with `...` to keep rows tidy.
- Test with the panel smaller than the screen. If you set a big `Width`, RebelUI shrinks it to fit.

## Build it yourself

This part shows how every piece is made with plain Roblox code: `Instance.new`, `TweenService` and `UserInputService`. There are no tricks. If you understand the toggle and the slider, you understand the whole library. (The real RebelUI adds the spinning ring, embers and shine on top of these same ideas.)

The steps build on each other. Paste the helpers from Step 1 first, then the window from Step 2, and after that you can add any later step to see it work. Everything works with a **finger** and a mouse.

Window dragging is a short extra at the end ([Bonus: dragging the window](#bonus-dragging-the-window)), so the steps can start with the pieces you care about.

**Quick map:** 1 helpers · 2 window · 3 button · 4 toggle (+ 6 upgrades: description, icon, checkbox, color, locked, key) · 5 slider · 6 choice bar · 7 dropdown · 8 text box · 9 keybind · 10 color picker · 11 tabs (+ icons, headers, Roblox images) · 12 notifications · 13 themes · 14 top bar (FPS, logo, timer, choose what shows) · 15 loading screen.


### Step 1: the three ideas and two helpers

1. **A panel is just Instances.** A `ScreenGui` holds a `Frame`. The `Frame` holds `TextLabel`s, `TextButton`s and so on. You decorate them with `UICorner` (round corners) and `UIStroke` (outlines).
2. **Input comes from events.** A tap or click fires `MouseButton1Click`. A drag needs `InputBegan`, `InputChanged` and `InputEnded` on `UserInputService`.
3. **Animations are tweens.** `TweenService:Create(object, TweenInfo.new(0.15), { Property = value }):Play()` smoothly changes a property.

Two small helpers keep the code short. We reuse them in every snippet:

```lua
local TweenService = game:GetService("TweenService")

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function tween(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end
```


### Step 2: the window

```lua
local gui = new("ScreenGui", { Name = "MyPanel", ResetOnSpawn = false }, (gethui and gethui()) or game:GetService("CoreGui"))

local window = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 280),
	BackgroundColor3 = Color3.fromRGB(14, 14, 18),
	BorderSizePixel = 0,
}, gui)

new("UICorner", { CornerRadius = UDim.new(0, 12) }, window)
new("UIStroke", { Color = Color3.fromRGB(233, 75, 53), Thickness = 1.5 }, window)
```

- `AnchorPoint = (0.5, 0.5)` with `Position = (0.5, 0.5)` centers it on the screen.
- `UDim2.fromScale` uses a fraction of the parent, and `UDim2.fromOffset` uses pixels.
- `gethui()` is an executor function that gives a safe place for your UI. `CoreGui` is the fallback.

Tip for phones: keep the window smaller than the screen. `workspace.CurrentCamera.ViewportSize` tells you how big the screen is.


### Step 3: a button

```lua
local button = new("TextButton", {
	Position = UDim2.new(0, 16, 0, 56),
	Size = UDim2.new(1, -32, 0, 38),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38),
	Text = "Press me",
	TextColor3 = Color3.fromRGB(240, 240, 245),
	TextSize = 14,
	Font = Enum.Font.GothamMedium,
	AutoButtonColor = false,
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, button)

button.MouseButton1Click:Connect(function()
	print("pressed")
	button.BackgroundColor3 = Color3.fromRGB(233, 75, 53) -- flash the accent color
	tween(button, 0.3, { BackgroundColor3 = Color3.fromRGB(30, 30, 38) })
end)
```

`Size = UDim2.new(1, -32, 0, 38)` means "full width minus 32 pixels, 38 pixels tall". Mixing scale and offset is the most useful trick in UI layout.


### Step 4: the toggle (on/off switch)

A toggle is: **a track**, **a knob inside it**, **a boolean**, and **one tween**.

```lua
local ON, OFF = Color3.fromRGB(233, 75, 53), Color3.fromRGB(52, 52, 64)
local state = false

local row = new("Frame", {
	Position = UDim2.new(0, 16, 0, 104),
	Size = UDim2.new(1, -32, 0, 38),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38),
	BorderSizePixel = 0,
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, row)

new("TextLabel", {
	BackgroundTransparency = 1, Text = "Infinite jump", TextColor3 = Color3.fromRGB(240, 240, 245),
	TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0),
}, row)

local track = new("Frame", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(40, 22), BackgroundColor3 = OFF, BorderSizePixel = 0,
}, row)
new("UICorner", { CornerRadius = UDim.new(0, 11) }, track)

local knob = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
	Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
}, track)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, knob)

-- an invisible button over the whole row, so you can tap anywhere
local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1) }, row)

hit.MouseButton1Click:Connect(function()
	state = not state
	tween(track, 0.15, { BackgroundColor3 = state and ON or OFF })
	tween(knob, 0.15, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
	print("toggle is now", state) -- put your feature here
end)
```

How it works: the knob is 16 wide in a 40-wide track. Off, it sits 3 pixels from the left. On, it sits 3 pixels from the right, which is `Position X = (1, -19)` (19 = 16 knob + 3 gap). The tween slides it between the two.

**Rule for features:** turn the feature on and off inside the callback. If the feature is a loop, use the variable: `while state do ... task.wait() end`, or connect and disconnect an event.

### Toggle upgrade 1: a name and a description

The description is a second `TextLabel` under the name. Make the row taller, and move the name up:

```lua
local function descToggle(parent, y, nameText, descText)
	local row = new("Frame", {
		Position = UDim2.new(0, 16, 0, y), Size = UDim2.new(1, -32, 0, 54),   -- 54 instead of 38
		BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, row)

	new("TextLabel", {       -- the name, near the top
		BackgroundTransparency = 1, Text = nameText, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 14,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 12, 0, 7), Size = UDim2.new(1, -70, 0, 20),
	}, row)
	new("TextLabel", {       -- the description, smaller and grey, below it
		BackgroundTransparency = 1, Text = descText, TextColor3 = Color3.fromRGB(150, 150, 165), TextSize = 12,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 12, 0, 27), Size = UDim2.new(1, -70, 0, 18),
	}, row)
	return row   -- add the track, knob and hit button to this row exactly like the plain toggle
end
```

### Toggle upgrade 2: an icon

An icon is an `ImageLabel`. Put it on the left, then move the text to the right to make room:

```lua
local icon = new("ImageLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),   -- vertically centered
	Size = UDim2.fromOffset(20, 20),
	Image = "rbxassetid://71415024616002",   -- any Roblox image id
}, row)
-- the name label now starts at x = 40 instead of 12
```

An asset id is a number. `"rbxassetid://" .. number` turns it into something `Image` accepts.

### Toggle upgrade 3: a checkbox instead of a switch

Replace the track and knob with one square and a tick. The tick shows only when on:

```lua
local box = new("Frame", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(22, 22), BackgroundColor3 = Color3.fromRGB(52, 52, 64), BorderSizePixel = 0,
}, row)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, box)

local tick = new("TextLabel", {
	BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "✓", TextSize = 16,
	Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), Visible = false,
}, box)

-- in the click handler:
--   tick.Visible = state
--   tween(box, 0.15, { BackgroundColor3 = state and ON or OFF })
```

### Toggle upgrade 4: its own color

Use a variable instead of one shared color:

```lua
local ON = Color3.fromRGB(60, 200, 110)     -- this toggle is green
-- tween(track, 0.15, { BackgroundColor3 = state and ON or OFF })
```

### Toggle upgrade 5: locked

A locked toggle ignores taps and looks faded:

```lua
local locked = true
name.TextTransparency = locked and 0.55 or 0         -- name: the toggle's TextLabel
track.BackgroundTransparency = locked and 0.5 or 0

hit.MouseButton1Click:Connect(function()
	if locked then return end      -- the whole feature: do nothing
	-- ...flip the toggle as before
end)
```

### Toggle upgrade 6: a key that flips it

```lua
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
		-- flip the toggle: the same code as the click handler
	end
end)
```

Put the flipping code in a function (`flip()`) and call it from both the click and the key.


### Step 5: the slider

A slider is: **a bar**, **a fill**, **a knob**, and **math**. The math turns the finger position into a value.

```lua
local MIN, MAX, STEP = 16, 100, 1
local value = MIN

local sliderRow = new("Frame", {
	Position = UDim2.new(0, 16, 0, 152), Size = UDim2.new(1, -32, 0, 54),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, sliderRow)

local valueText = new("TextLabel", {
	BackgroundTransparency = 1, Text = tostring(MIN), TextColor3 = Color3.fromRGB(150, 150, 165),
	TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -82, 0, 6), Size = UDim2.new(0, 70, 0, 20),
}, sliderRow)

local barBg = new("Frame", {
	Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 8),
	BackgroundColor3 = Color3.fromRGB(52, 52, 64), BorderSizePixel = 0,
}, sliderRow)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, barBg)

local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(233, 75, 53), BorderSizePixel = 0 }, barBg)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, fill)

local sKnob = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
	Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2,
}, barBg)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, sKnob)

local function setValue(v)
	v = math.clamp(v, MIN, MAX)
	v = MIN + math.floor((v - MIN) / STEP + 0.5) * STEP -- snap to the step
	value = v
	local rel = (v - MIN) / (MAX - MIN)               -- 0 to 1
	fill.Size = UDim2.fromScale(rel, 1)
	sKnob.Position = UDim2.new(rel, 0, 0.5, 0)
	valueText.Text = tostring(v)
	print("slider value", v) -- put your feature here
end

local function fromInput(input)
	-- finger X minus bar left edge, divided by bar width = 0..1
	local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
	setValue(MIN + rel * (MAX - MIN))
end

local sliding = false
barBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = true
		fromInput(input)
	end
end)
UIS.InputChanged:Connect(function(input)
	if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		fromInput(input)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = false
	end
end)

setValue(MIN)
```

The important line is the math:

```
rel   = (fingerX - barLeft) / barWidth     -- 0 at the left edge, 1 at the right edge
value = MIN + rel * (MAX - MIN)             -- turns 0..1 into your range
```

- `math.clamp` stops the value leaving the range when your finger slides past the bar.
- The `STEP` line rounds the value, so `STEP = 5` gives 15, 20, 25 and so on.
- **Scrolling problem:** if the slider is inside a `ScrollingFrame`, dragging also scrolls the page. Set `scrollFrame.ScrollingEnabled = false` when the drag starts and `true` when it ends. RebelUI does this for you.


### Step 6: the choice bar (a bar where you choose)

A choice bar is **one dark bar with N buttons inside it**. The chosen button is filled with the accent color.

```lua
local options = { "Easy", "Normal", "Hard" }
local chosen = "Normal"

local choiceRow = new("Frame", {
	Position = UDim2.new(0, 16, 0, 56), Size = UDim2.new(1, -32, 0, 66),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, choiceRow)

new("TextLabel", {
	BackgroundTransparency = 1, Text = "Difficulty", TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 14,
	Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -24, 0, 20),
}, choiceRow)

local choiceBar = new("Frame", {
	Position = UDim2.new(0, 12, 0, 32), Size = UDim2.new(1, -24, 0, 28),
	BackgroundColor3 = Color3.fromRGB(14, 14, 18), BorderSizePixel = 0,
}, choiceRow)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, choiceBar)

local choiceButtons = {}
local function refresh()
	for name, b in pairs(choiceButtons) do
		local on = (name == chosen)
		b.BackgroundTransparency = on and 0 or 1
		b.TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 165)
	end
end

for i, name in ipairs(options) do
	local b = new("TextButton", {
		-- button i takes the i-th slice of the bar: (i-1)/N from the left, 1/N wide
		Position = UDim2.new((i - 1) / #options, 2, 0, 2), Size = UDim2.new(1 / #options, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(233, 75, 53), BackgroundTransparency = 1,
		Text = name, TextSize = 12, Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(150, 150, 165),
		AutoButtonColor = false,
	}, choiceBar)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
	choiceButtons[name] = b
	b.MouseButton1Click:Connect(function()
		chosen = name
		refresh()
		print("chosen", name) -- put your feature here
	end)
end
refresh()
```

The trick is the position math: with 3 options, button 1 starts at `0/3`, button 2 at `1/3`, button 3 at `2/3`, and each is `1/3` wide. Add an option to the list and the bar re-divides by itself.


### Step 7: the dropdown

A dropdown is a row that **grows** to show a list, and shrinks back.

```lua
local options = { "Easy", "Normal", "Hard" }
local HEAD, ITEM = 38, 28

local dd = new("Frame", {
	Position = UDim2.new(0, 16, 0, 216), Size = UDim2.new(1, -32, 0, HEAD),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0, ClipsDescendants = true,
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, dd)

local current = new("TextButton", {
	BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEAD), Text = "Mode: Normal",
	TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 14, Font = Enum.Font.Gotham,
}, dd)

local list = new("Frame", { Position = UDim2.new(0, 6, 0, HEAD), Size = UDim2.new(1, -12, 1, -HEAD - 6), BackgroundTransparency = 1 }, dd)
new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

local open = false
current.MouseButton1Click:Connect(function()
	open = not open
	tween(dd, 0.18, { Size = UDim2.new(1, -32, 0, open and (HEAD + #options * (ITEM + 2) + 8) or HEAD) })
end)

for _, name in ipairs(options) do
	local item = new("TextButton", {
		Size = UDim2.new(1, 0, 0, ITEM), BackgroundColor3 = Color3.fromRGB(14, 14, 18), Text = name,
		TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 13, Font = Enum.Font.Gotham,
	}, list)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, item)
	item.MouseButton1Click:Connect(function()
		current.Text = "Mode: " .. name
		open = false
		tween(dd, 0.18, { Size = UDim2.new(1, -32, 0, HEAD) })
		print("chosen", name) -- put your feature here
	end)
end
```

The key is `ClipsDescendants = true`. The list is always there but is hidden by the row's small height. Growing the row reveals it.

**Multi-select** is the same idea. Keep a table `selected[name] = true`, flip it on click, and do not close the list.


### Step 8: a text box

```lua
local box = new("TextBox", {
	Position = UDim2.new(0, 16, 0, 56), Size = UDim2.new(1, -32, 0, 34),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
	Text = "", PlaceholderText = "type a name", PlaceholderColor3 = Color3.fromRGB(150, 150, 165),
	TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 14, Font = Enum.Font.Gotham, ClearTextOnFocus = false,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, box)

box.FocusLost:Connect(function(enterPressed)
	print("typed:", box.Text)
end)
```

Use `FocusLost` and not every keystroke. The feature runs once, when the player is done typing. On phones, `FocusLost` runs when the keyboard closes.


### Step 9: a keybind

```lua
local bound = Enum.KeyCode.F
local listening = false

local kbButton = new("TextButton", {
	Position = UDim2.new(0, 16, 0, 100), Size = UDim2.fromOffset(160, 32),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38), Text = "F", TextColor3 = Color3.fromRGB(240, 240, 245),
	TextSize = 13, Font = Enum.Font.GothamMedium,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, kbButton)

kbButton.MouseButton1Click:Connect(function()
	listening = true
	kbButton.Text = "press a key..."
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if listening then
		bound = input.KeyCode
		listening = false
		kbButton.Text = bound.Name
	elseif not gameProcessed and input.KeyCode == bound then
		print("keybind pressed")  -- put your feature here
	end
end)
```

`gameProcessed` is `true` when the key was used to type in a text box or chat, so ignore those. Keybinds are for PC only. A phone has no keyboard, so always give a button or toggle as well.


### Step 10: a color picker (rainbow bar)

The picker uses the HSV color model: **hue** (which color), **saturation** (how strong) and **value** (how bright). `Color3.fromHSV(h, s, v)` takes numbers from 0 to 1. A **rainbow bar** is a `UIGradient` with the same colors as the hue range.

```lua
local hueBar = new("Frame", {
	Position = UDim2.new(0, 16, 0, 150), Size = UDim2.new(1, -32, 0, 14),
	BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 7) }, hueBar)
new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00, 1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1)),
	}),
}, hueBar)

local preview = new("Frame", { Position = UDim2.new(0, 16, 0, 172), Size = UDim2.fromOffset(60, 24), BorderSizePixel = 0 }, gui)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, preview)

local function pick(input)
	local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
	preview.BackgroundColor3 = Color3.fromHSV(rel, 1, 1)
end

local picking = false
hueBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then picking = true; pick(i) end
end)
UIS.InputChanged:Connect(function(i)
	if picking and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then pick(i) end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then picking = false end
end)
```

This is the slider again. Only the output changes: the 0 to 1 number goes into `Color3.fromHSV` and not into a speed value.


### Step 11: tabs

Tabs are **a row of buttons** and **one page per button**. Click one, show its page, hide the others.

```lua
local pages, buttons = {}, {}

local function showTab(name)
	for n, page in pairs(pages) do
		page.Visible = (n == name)
		buttons[n].BackgroundTransparency = (n == name) and 0 or 1
	end
end

local function addTab(name, order)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(30, 30, 38), BackgroundTransparency = 1,
		Text = name, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 13, Font = Enum.Font.GothamBold,
		LayoutOrder = order,
	}, sideFrame) -- sideFrame: a Frame with a UIListLayout on the left
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, b)

	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, Visible = false,
	}, pageHolder) -- pageHolder: a Frame on the right
	new("UIListLayout", { Padding = UDim.new(0, 6) }, page)

	pages[name], buttons[name] = page, b
	b.MouseButton1Click:Connect(function() showTab(name) end)
	return page
end
```

- `UIListLayout` stacks children by itself, so you never position rows by hand.
- `AutomaticCanvasSize = Y` lets the page scroll as far as its content needs.

### Tabs with an image icon and their own header

An icon next to the tab name is an `ImageLabel` placed **before** the text. Push the text right so they do not overlap:

```lua
local function tabButton(name, assetId)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(30, 30, 38), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false,
	}, sideFrame)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, b)

	local textX = 10
	if assetId then
		new("ImageLabel", {
			BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -9), Size = UDim2.fromOffset(18, 18),
			Image = "rbxassetid://" .. assetId, ImageColor3 = Color3.fromRGB(150, 150, 165),
		}, b)
		textX = 32       -- the text starts after the icon
	end

	new("TextLabel", {
		BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 13,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, textX, 0, 0), Size = UDim2.new(1, -textX - 6, 1, 0),
	}, b)
	return b
end
```

To make the icon change color when its tab is selected, set `ImageColor3` in the same place you set the tab's background.

**The tab's own header** is a card made at the top of the page, built just like any other row:

```lua
local function pageHeader(page, titleText, bodyText)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
		LayoutOrder = -1,   -- a low LayoutOrder puts it first in the UIListLayout
	}, page)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
	new("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = Color3.fromRGB(233, 75, 53), BorderSizePixel = 0 }, card)  -- accent bar

	new("TextLabel", {
		BackgroundTransparency = 1, Text = titleText, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 18,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(1, -26, 0, 24),
	}, card)
	new("TextLabel", {
		BackgroundTransparency = 1, Text = bodyText, TextColor3 = Color3.fromRGB(150, 150, 165), TextSize = 12,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		Position = UDim2.new(0, 16, 0, 34), Size = UDim2.new(1, -26, 0, 32),
	}, card)
	return card
end
```

### Roblox images in a panel

`ImageLabel.Image` takes the text `"rbxassetid://<number>"`. `ScaleType` decides how the picture fills the box:

```lua
local picture = new("ImageLabel", {
	Position = UDim2.new(0, 16, 0, 56), Size = UDim2.new(1, -32, 0, 104),
	BackgroundTransparency = 1,
	Image = "rbxassetid://125144167121839",
	ScaleType = Enum.ScaleType.Crop,     -- Crop fills the box and trims. Fit shows the whole picture.
}, window)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, picture)   -- round the image corners
```

If the picture does not show: check that the id is an **image** asset (not a decal's page id), and that the image was approved by Roblox and is allowed for your account to use.


### Step 12: notifications

A notification is a small card that slides in, waits, and slides out.

```lua
local function notify(title, text, seconds)
	local card = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 300, 0, 12), -- starts off-screen
		Size = UDim2.fromOffset(240, 52), BackgroundColor3 = Color3.fromRGB(30, 30, 38), BorderSizePixel = 0,
	}, gui)
	new("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
	new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -24, 0, 18),
		Text = title, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 14, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 26), Size = UDim2.new(1, -24, 0, 20),
		Text = text, TextColor3 = Color3.fromRGB(150, 150, 165), TextSize = 13, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	tween(card, 0.25, { Position = UDim2.new(1, -12, 0, 12) })   -- slide in
	task.delay(seconds or 4, function()
		tween(card, 0.25, { Position = UDim2.new(1, 300, 0, 12) }) -- slide out
		task.wait(0.3)
		card:Destroy()
	end)
end

notify("Hello", "Panel loaded")
```


### Step 13: themes (change every color at once)

Do not scatter `Color3.fromRGB(233, 75, 53)` everywhere. Keep one table, and one function that applies it:

```lua
local themes = {
	Red  = Color3.fromRGB(233, 75, 53),
	Blue = Color3.fromRGB(64, 140, 255),
}
local accentObjects = {}  -- every object that should follow the accent: { {object, "Property"}, ... }

local function applyTheme(name)
	for _, entry in ipairs(accentObjects) do
		entry[1][entry[2]] = themes[name]
	end
end

-- when you build something that uses the accent color:
-- table.insert(accentObjects, { fill, "BackgroundColor3" })
```

RebelUI does this with `win:_onTheme(function(t) ... end)`. Each element registers a small function that repaints itself. `Win:SetTheme("Blue")` runs them all.


### Step 14: the top bar (FPS, logo, timer, and choosing what shows)

A top bar is **a rounded Frame** that lays its children out in a row, plus **labels that update** while the game runs.

```lua
local RunService = game:GetService("RunService")

local pill = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.new(0, 0, 0, 34), AutomaticSize = Enum.AutomaticSize.X, -- the width grows with the content
	BackgroundColor3 = Color3.fromRGB(20, 20, 26), BorderSizePixel = 0,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 17) }, pill)
new("UIStroke", { Color = Color3.fromRGB(233, 75, 53), Thickness = 1.5 }, pill)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 8),
}, pill)
new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, pill)

local function item(text)
	return new("TextLabel", {
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 22),
		Text = text, TextColor3 = Color3.fromRGB(240, 240, 245), TextSize = 13, Font = Enum.Font.GothamMedium,
	}, pill)
end

local fpsLabel = item("FPS 60")
local logo = new("ImageLabel", {
	Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Image = "rbxassetid://114659273298746",
}, pill)
local timeLabel = item("00:00:00")
```

`UIListLayout` with `FillDirection = Horizontal` puts the three pieces side by side. `AutomaticSize = X` makes the pill as wide as they need, so adding or removing one resizes it by itself.

**FPS counter and timer.** FPS is "how many frames happened in the last half second, divided by that half second". `Heartbeat` runs every frame and gives `dt` (the seconds since the last frame):

```lua
local started = os.clock()
local frames, acc = 0, 0

RunService.Heartbeat:Connect(function(dt)
	frames += 1
	acc += dt
	if acc >= 0.5 then                                   -- update twice a second, not every frame
		fpsLabel.Text = "FPS " .. math.floor(frames / acc + 0.5)
		frames, acc = 0, 0
		local s = math.floor(os.clock() - started)       -- seconds since the script started
		timeLabel.Text = string.format("%02d:%02d:%02d", s // 3600, s // 60 % 60, s % 60)
	end
end)
```

**More items** use the same pattern: a label, and one line that fills its text.

```lua
local pingLabel = item("Ping 0ms")
local clockLabel = item(os.date("%H:%M"))
local playersLabel = item("Players 1/1")

task.spawn(function()
	while pill.Parent do
		pcall(function()
			pingLabel.Text = "Ping " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) .. "ms"
		end)
		clockLabel.Text = os.date("%H:%M")
		playersLabel.Text = "Players " .. #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers
		task.wait(1)
	end
end)
```

`pcall` is there because not every executor or game gives you the ping stat. If it fails, the label simply keeps its old text.

**Choosing what shows.** Keep your items in a table and set `Visible` on each one. A hidden item takes no space in a `UIListLayout`, so the bar shrinks around it:

```lua
local items = { FPS = fpsLabel, Logo = logo, Timer = timeLabel, Ping = pingLabel, Clock = clockLabel, Players = playersLabel }

local function setShown(list)
	local on = {}
	for _, name in ipairs(list) do on[name] = true end
	for name, obj in pairs(items) do
		obj.Visible = on[name] == true
	end
end

setShown({ "FPS", "Logo", "Timer" })                 -- the "Classic" style
-- setShown({ "FPS", "Ping", "Clock" })              -- the "Gamer" style
```

Wire `setShown` to a choice bar (Step 6) for the style, or to a multi dropdown (Step 7) for custom picks.

**Tap to open, drag to move.** The trick is to measure how far the finger moved. A tiny movement is a tap, a bigger one is a drag:

```lua
local down, moved, startMouse, startPos = false, 0, nil, nil

pill.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		down, moved = true, 0
		startMouse, startPos = input.Position, pill.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if down and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - startMouse
		moved = math.max(moved, delta.Magnitude)
		if moved > 6 then                                 -- more than 6 pixels = it is a drag
			pill.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if down and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		down = false
		if moved <= 6 then
			window.Visible = not window.Visible           -- a tap: open or close the panel
		end
	end
end)
```

Without the `moved` check, every drag would also open or close the panel when you let go.


### Bonus: dragging the window

Dragging means: remember where the finger started, then move the window by how far the finger has moved.

```lua
local UIS = game:GetService("UserInputService")

local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(20, 20, 26), BorderSizePixel = 0 }, window)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, bar)

local dragging, startMouse, startPos = false, nil, nil

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		startMouse = input.Position
		startPos = window.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - startMouse
		window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
```

`Touch` is what makes it work on mobile. If you only check `MouseButton1`, a finger cannot drag it.

---


### Step 15: a loading screen

A loading screen is one full-screen `Frame` on a `ScreenGui` with a high `DisplayOrder`, a bar whose width you tween, and a fade at the end.

```lua
local TweenService = game:GetService("TweenService")
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10000
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(8, 3, 5)
root.BorderSizePixel = 0
root.Parent = gui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.42)
title.Size = UDim2.fromOffset(340, 60)
title.BackgroundTransparency = 1
title.Text = "Rebelwar"
title.Font = Enum.Font.GothamBlack
title.TextSize = 44
title.TextColor3 = Color3.fromRGB(255, 50, 60)
title.Parent = root

local track = Instance.new("Frame")
track.AnchorPoint = Vector2.new(0.5, 0.5)
track.Position = UDim2.fromScale(0.5, 0.8)
track.Size = UDim2.fromOffset(300, 14)
track.BackgroundColor3 = Color3.fromRGB(18, 7, 9)
track.BorderSizePixel = 0
track.Parent = root
Instance.new("UICorner", track).CornerRadius = UDim.new(0, 7)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(235, 40, 50)
fill.BorderSizePixel = 0
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 7)

-- move the bar a little at a time while you load things
for i = 1, 10 do
	TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(i / 10, 1) }):Play()
	task.wait(0.25)
end

-- fade everything out, then remove it
TweenService:Create(root, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
TweenService:Create(title, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
TweenService:Create(fill, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
TweenService:Create(track, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
task.wait(0.6)
gui:Destroy()
```

RebelUI's `UI:Loading` adds a zooming banner, embers, a logo with a spinning ring, a shining title, a smooth bar with a moving shimmer, status text, a badge, `Preload` and `Run`. Use it when you do not want to build this yourself.

---

## Common mistakes

| Problem | Cause and fix |
|---|---|
| The demo loader does nothing | The files in your repo are missing, private, or the old version. `Example.lua` and `source.lua` must be in the root of the `main` branch, and the repo must be public. Open the link in a browser: you should see code, not `404`. The demo now shows a message on screen saying what is wrong |
| Nothing appears | The executor blocked the script, or an error stopped it. Check the console. RebelUI uses `gethui()` and falls back to `CoreGui` |
| "attempt to index nil" on `Win` | The line that creates the window failed (often the `loadstring` link). Make sure the repo is public and the file name is exactly `source.lua` on the `main` branch |
| The panel never opens after a loading screen | You created it with `Open = false` and forgot `Win:Toggle(true)` |
| A picture does not show | The asset id is wrong or the image is not public. Try the number from the Roblox website |
| A toggle does nothing | The toggle only calls your `Callback`. Put your feature inside it |
| My toggle starts ON but the feature is off | Use `Default = true` with a `Callback`. RebelUI calls it once with `true` at the start |
| Settings do not save | `Win:Save()` needs an executor with `writefile`. Check that `Flag` is set on the elements you want saved |
| A callback fails with no message | Errors inside callbacks are caught and printed with `warn`. Look in the console |
| The panel is too big on my phone | Use **Panel size** in Settings, `Win:SetScale(0.8)`, or a smaller `Width` and `Height` |

---

## Search, resize, profiles and the key gate

New in v1.0.0. The search box, the resize grip and the opacity are on by default. Profiles and the key gate are one call each.

### Search box

A small box next to the page title. Type and the rows on the current tab that do not match hide. Clear it (or change tab) and everything comes back. Turn it off with `Search = false` in `CreateWindow`.

### Resize

Drag the little grip in the bottom-right corner of the panel. You can also set the size from code:

```lua
Win:SetSize(500, 380)   -- pixels. Minimum 320 x 240, and it never goes bigger than the screen
```

Turn the grip off with `Resizable = false`.

### Opacity

The panel is **100% solid** by default. Players can change it with the **Opacity** slider in Settings. From code:

```lua
local Win = UI:CreateWindow({ Title = "My Script", Opacity = 100 })
Win:SetOpacity(80)   -- 10 to 100
```

### The open / close key

The Settings tab has an **Open / close key** keybind. From code:

```lua
Win:SetToggleKey(Enum.KeyCode.F4)
```

### Profiles (named settings)

A profile is everything with a `Flag`, saved under a name like `Legit` or `Rage`. The Settings tab has a **Profiles** section (name box, list, Save, Load, Delete, Load on start). From code:

```lua
Win:SaveProfile("Legit")             -- returns true, or false and a reason
Win:LoadProfile("Legit")             -- your Callbacks run
Win:DeleteProfile("Legit")
print(table.concat(Win:ListProfiles(), ", "))
Win:SetAutoLoad("Legit")             -- the profile that starts with the script
Win:AutoLoad()                       -- call this once, after your tabs exist
```

Profiles are plain files next to your executor's workspace files. They need an executor with `writefile` and `readfile`.

### The key gate

Shows a small card that asks for a key, and **waits** until the key is right or the player closes it.

```lua
local ok = UI:KeyGate({
	Name = "MyScript",
	Title = "Enter your key",
	Subtitle = "Paste the key and tap Continue.",
	Keys = { "ABC-123", "XYZ-789" },     -- the allowed keys
	Link = "https://discord.gg/Kq7N4gzH22", -- adds a "Get key" button that copies this link
	Save = true,                         -- remember the key on this device
})
if not ok then
	return -- the player closed it
end
-- the rest of your script runs only with a good key
```

| Option | What it does | Default |
|---|---|---|
| `Keys` | List of allowed keys | none |
| `Check` | `function(key) return true end` to check the key yourself (for example against your own server). Used instead of `Keys` | none |
| `Title`, `Subtitle`, `Footer` | Texts on the card | `"Enter your key"` |
| `Link` | Adds a **Get key** button that copies the link | none |
| `Save` | Remember a good key so the card is skipped next time | `true` |
| `MaxTries` | Close after this many wrong keys (returns `false`) | no limit |
| `Timeout` | Close after this many seconds (returns `false`) | no limit |
| `Theme`, `Name`, `File` | Theme name, ScreenGui name, file for the saved key | `"Red"` |

It returns `true` and the key, or `false`. RebelUI is keyless by default: only use the gate if you want one. Remember that keys written inside a script can be read by anyone who opens it. For real protection use `Check` with your own server.

---

## More tools

### Dialog (a pop-up question)

```lua
Win:Dialog({
	Title = "Reset everything?",
	Text = "This turns every toggle off.",
	Buttons = {
		{ Name = "Yes, reset", Callback = function() print("reset") end }, -- the first button is the bright one
		{ Name = "Cancel" },
	},
})
```

Up to 3 buttons. Tapping one closes the dialog and runs its `Callback`.

### Collapsible sections

```lua
Tab:Section({ Name = "Advanced", Collapsible = true, Collapsed = true })
Tab:Toggle({ Name = "Hidden until you tap the line above" })
Tab:Section("Next section") -- a section ends where the next section starts
```

The line shows `v` when open and `>` when closed. `section:Collapse(true)` or `section:Collapse(false)` does it from code.

### Keybind modes

```lua
Tab:Keybind({ Name = "Fly", Default = Enum.KeyCode.F, Mode = "Toggle", Callback = function(on) print(on) end })
Tab:Keybind({ Name = "Sprint", Default = Enum.KeyCode.LeftShift, Mode = "Hold", Callback = function(held) print(held) end })
Tab:Keybind({ Name = "Press", Default = Enum.KeyCode.G, Callback = function() print("pressed") end }) -- default mode
```

### Number box

```lua
Tab:Input({ Name = "Delay", Numeric = true, Min = 0, Max = 10, Default = "2", Callback = function(n) print(n + 1) end })
```

Only digits, `.` and `-` can be typed, and the callback gets a real number kept between `Min` and `Max`.

### Hide or remove any element

Every element has `:SetVisible(true/false)` and `:Destroy()`, and a `.Row` field with its frame.

```lua
local t = Tab:Toggle({ Name = "Secret", Flag = "secret" })
t:SetVisible(false)
t:Destroy()
```

### Tab dividers

```lua
Win:CreateTab({ Name = "Main" })
Win:CreateTabDivider("Games")   -- a small "GAMES" caption in the side list
Win:CreateTab({ Name = "Murder Mystery" })
```

### Share your settings

`Win:Export()` returns all your `Flag` values as one line of text. `Win:Import(text)` puts them back (and returns `false` if the text is not a settings code). The Settings tab has **Copy settings code** and **Paste settings code**.

### Utilities (in the Settings tab)

**Anti-AFK**, **FPS cap** (when the executor has `setfpscap`), **Rejoin this server** (asks first), **Copy game ID**. Turn them off with `Win:CreateSettingsTab({ Utilities = false })`.

### Notification icons

```lua
Win:Notify({ Title = "Update", Text = "New version", Icon = 114659273298746 })
```


### Tooltips

```lua
Tab:Toggle({ Name = "Speed", Tooltip = "Makes you run faster. Might look suspicious." })
```

Any element can have `Tooltip = "text"`. A small card shows when you hover (PC) or hold your finger on the element (phone).

### Warning box (Notice)

```lua
Tab:Notice({ Type = "warn", Title = "Heads up", Text = "This works best in private servers." })
```

`Type` is `"warn"` (yellow), `"error"` (red), `"success"` (green) or none. Change it later with `notice:Set(title, text)` and `notice:SetType("error")`.

### Button extras

```lua
Tab:Button({ Name = "Reset all", Risky = true, DoubleClick = true, Callback = function() end }) -- red, asks "Tap again to confirm"
local b = Tab:Button({ Name = "Coming soon", Disabled = true })
b:SetDisabled(false)
```

### Show an element only when something is on

```lua
local master = Tab:Toggle({ Name = "Aimbot" })
Tab:Slider({ Name = "Smoothness", Min = 1, Max = 10 }):DependsOn(master)       -- visible only while master is ON
Tab:Dropdown({ Name = "Mode", Options = { "A", "B" } }):DependsOn(otherDropdown, "A") -- or while the value is "A"
```

### Searchable dropdown and the player list

Dropdowns with more than 7 options get a search box automatically (`Searchable = false` turns it off, `Searchable = true` forces it). `Options = "Players"` fills the list with everyone in the server and keeps it up to date.

```lua
Tab:Dropdown({ Name = "Target", Options = "Players", Callback = function(name) print(name) end })
```

### Keybind list (on screen)

```lua
local list = Win:CreateKeybindList({ Title = "Keybinds" })   -- drag it by the title
list:Show(false)   -- hide / show from code
```

It lists every `Keybind` and every `Toggle` that has a `Key`, and shows `ON` next to the ones that are active.

### Notifications you can update

```lua
local n = Win:Notify({ Title = "Downloading...", Text = "0%", Duration = 0 }) -- Duration = 0: stays until you close it
n:SetText("50%")
n:Progress(0.5)      -- the line at the bottom fills to 50%
n:SetTitle("Done!")
n:Close()
```

### More small options

| Where | Option | What it does |
|---|---|---|
| `Slider` | `Prefix = "x"` | Text before the number |
| `Input` | `MaxLength = 5` | Stops typing after 5 characters |


### Range slider (two knobs)

```lua
local r = Tab:RangeSlider({ Name = "Distance", Min = 0, Max = 500, Default = { 50, 300 }, Suffix = " studs", Flag = "dist",
	Callback = function(low, high) print(low, high) end })
print(r:Get().Low, r:Get().High)
r:Set({ Low = 10, High = 20 })
```

### 2D pad

```lua
Tab:Pad({ Name = "Aim offset", Default = { X = 0.5, Y = 0.5 }, Callback = function(x, y) print(x, y) end }) -- both from 0 to 1
```

### Slider extras

```lua
Tab:Slider({ Name = "Speed", Min = 1, Max = 1000, Log = true, Arrows = true })
```

`Arrows = true` adds `<` `>` buttons that move one `Step`. `Log = true` makes the left of the bar fine and the right of the bar coarse (`Min` must be above 0).

### Math box

```lua
Tab:Input({ Name = "Amount", Math = true, Callback = function(n) print(n) end }) -- type 16*4, (2+3)^2, 10/4 ...
```

It understands `+ - * / % ^` and brackets, and gives your function a number. It never runs code.

### Keybind combo

```lua
Tab:Keybind({ Name = "Panic", Default = Enum.KeyCode.X, Modifier = Enum.KeyCode.LeftShift, Callback = function() end }) -- Shift + X
```

### Console

```lua
local log = Tab:Console({ Name = "Log", Height = 120, MaxLines = 200 })
log:Log("started")
log:Log("careful", "warn")      -- "warn", "error", "success" or none
Win:Log("goes to the first console")
log:Copy()   log:Clear()   print(log:GetText())
```

### Live graph

```lua
Tab:Graph({ Name = "FPS", Source = "FPS" })            -- "FPS", "Ping", "Memory" or "Frame" (milliseconds per frame)
Tab:Graph({ Name = "Coins", Source = function() return myCoins end, Max = 100 })
```

### Code box

```lua
Tab:CodeBox({ Name = "Script", Default = "print('hi')", Height = 100 })                -- Run uses loadstring
Tab:CodeBox({ Name = "Command", Callback = function(code) print(code) end })           -- or do your own thing
```

### Feed (news from the web)

```lua
Tab:Feed({ Title = "News", Url = "https://raw.githubusercontent.com/you/repo/main/news.txt", MaxChars = 400 })
```

It loads a plain text page into a card (and shows `Text` if it cannot).

### Lazy tabs

```lua
Win:CreateTab({ Name = "Big tab", Build = function(tab)
	tab:Toggle({ Name = "Built when you first open me" })
end })
```

### State (a value that updates things)

```lua
local score = UI.State(0)
local label = Tab:Label("")
score:Bind(label, "Score: %d")   -- the label always shows the score
score:Set(5)
score:OnChange(function(v) print(v) end)
```

### Spring (smooth, bouncy numbers)

```lua
local s = UI.Spring.new(0, 12, 0.6)   -- start, speed, damping (0 bouncy ... 1 smooth)
s.Target = 1
game:GetService("RunService").RenderStepped:Connect(function(dt)
	print(s:Update(dt))
end)
```

### Settings codes, theme codes, code export

```lua
local code = Win:Export()      -- "RBL1:..."  all your settings as one short line (base64)
Win:Import(code)               -- also accepts a theme code
Win:ExportTheme()              -- "RBLT:#RRGGBB"  just the color
print(Win:GenerateCode())      -- Lua that builds this panel as it is now (Callbacks left empty)
```

### Auto-save, avatar colors, update check

```lua
Win:AutoSave(60)        -- backup every 60 seconds (or CreateWindow({ AutoSave = 60 }))  AutoSave(0) stops it
Win:RestoreSnapshot()   -- bring the last backup back
Win:ThemeFromAvatar()   -- the accent becomes your character's color
Win:CheckUpdate({ Url = "https://raw.githubusercontent.com/you/repo/main/script.lua", Current = "1.0.0" })
```

`CheckUpdate` reads `Version = "1.2.3"` from the page and tells the player when yours is older.

### Translate the panel

```lua
UI:SetLanguage({ ["Settings"] = "Tetapan", ["Save settings"] = "Simpan" })  -- before CreateWindow
```

### Smooth moves

The panel keeps gliding a little when you let go while dragging (`Inertia = false` turns it off), and page titles "decode" when you change tab (`Scramble = false` turns it off).

---

## What is new in v1.0.0

- **Opacity 100** by default, with a Settings slider and `Win:SetOpacity`.
- **Search box** on every page, and a **resize grip** with `Win:SetSize`.
- **Profiles** (named settings), **settings export / import**, and **`UI:KeyGate`** (an optional key card).
- **Notification buttons and icons**, **`Win:Dialog`** pop-ups, **collapsible sections**, **keybind modes**, **number boxes**, **tab dividers**, `:SetVisible()` / `:Destroy()` on every element.
- **Utilities** in Settings: Anti-AFK, Rejoin, Copy game ID.
- **Power tools**: range slider, 2D pad, console, live graphs (FPS, Ping, Memory), code box, news feed, lazy tabs, `UI.State`, `UI.Spring`, math box, keybind combos, slider arrows and log scale.
- **Shareable**: base64 settings codes (`RBL1:`), theme codes (`RBLT:`), `Win:GenerateCode()`, auto-save, `Win:CheckUpdate`, `RebelUI:SetLanguage`, avatar-matched theme.
- **Two accessibility themes** (`Contrast`, `Colorblind`), glide after dragging and title decode.
- **Tooltips**, **warning boxes** (`Tab:Notice`), **risky / double-tap / disabled buttons**, **`:DependsOn`**, **searchable dropdowns** and a **Players list**, an on-screen **keybind list**, and **notifications you can update** (`Win:Notify` returns a handle).
- **The Rebelwar Hub look**: spinning ring, thin black ring, embers, glowing tab marker, player card, shiny buttons, pill toggles with ON/OFF, stacked notification cards.
- **`UI:Loading`**: the full loading screen with `Preload` and `Run`.
- **Safe loading**: the demo checks the download and shows a message if something is wrong, and a loading screen can never get stuck (`Timeout`).
- **Top bar** in the Hub style, with 10 items, 5 presets and `Tab:BarSettings`.
- **Tabs** with an image next to the name, their own header, and a slide-in page.
- **Toggles**: switch or checkbox, description, icon, color, locked (with a warning card), key, flag.
- **`Tab:Cycle`** (the `<  option  >` picker) and a better color picker (tap to open).
- **`Win:CreateSettingsTab`**: a finished Settings tab in one line.
- **14 themes** that recolor everything live, `SetAccent`, `AddTheme`, `SetScale`, `SetTransparency`.
- **`Win:Save()` and `Win:Load()`** for every element with a `Flag`.

---

## Files in this repo

| File | What it is |
|---|---|
| `source.lua` | The library (RebelUI v1.0.0). Load it with `loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"))()` |
| `Example.lua` | The demo panel with the loading screen. It uses every element and every kind of toggle. Copy parts into your own script |
| `README.md` | This tutorial |
| `LICENSE` | MIT license |

## Help and community

Questions, bugs or ideas? Join the Discord: **https://discord.gg/Kq7N4gzH22**

## License

MIT. Use it, change it, make your own panel. Credit is appreciated. See `LICENSE`.

> RebelUI is a UI library. What your buttons and toggles do is up to you. Follow the rules of the game you play in and the Roblox Terms of Use. Rebelwar is not affiliated with or endorsed by Roblox.
