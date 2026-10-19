<div align="center">

# 🪓🔥 RebelUI

**Make your own Roblox executor panel. Toggles, sliders, tabs with image icons, color pickers and more.**

Free · Keyless · Built for mobile (touch) and PC · Made by prorizz196

[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/Kq7N4gzH22)
[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
![Version](https://img.shields.io/badge/RebelUI-v1.1-e94b35)

</div>

---

## Contents

1. [Quick start](#quick-start)
2. [The window](#the-window)
3. [The top bar: FPS, logo, timer and more](#the-top-bar)
4. [Tabs: image icon, name and their own header](#tabs)
5. [All toggles](#all-toggles)
6. [Sliders, choice bars and progress bars](#sliders-choice-bars-and-progress-bars)
7. [Buttons, dropdowns, inputs, keybinds](#buttons-dropdowns-inputs-keybinds)
8. [Colors](#colors)
9. [Text and images](#text-and-images)
10. [Notifications](#notifications)
11. [Themes and your own colors](#themes-and-your-own-colors)
12. [Flags and saving settings](#flags-and-saving-settings)
13. [Mobile tips](#mobile-tips)
14. [**Build it yourself: how every piece is made**](#build-it-yourself)
15. [Common mistakes](#common-mistakes)

> **Two ways to use this page.** Sections 1 to 13 show how to *use* the finished library, `source.lua`. Section 14 shows how to *build* each piece from scratch with plain Roblox code, so you can make your own.

---

## Quick start

### Try the demo first

Paste this into your executor and run it. It opens a panel that shows **every** element, every kind of toggle and the top bar:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/Example.lua"))()
```

### Use the library in your own script

The library is the file `source.lua` in this repo. Load it with one line:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"))()

local Win = UI:CreateWindow({ Title = "My Panel", Subtitle = "made by me" })
local Tab = Win:CreateTab("Main")

Tab:Toggle({ Name = "Infinite jump", Callback = function(on) print(on) end })
Tab:Slider({ Name = "Walk speed", Min = 16, Max = 100, Default = 16, Callback = function(v) print(v) end })
```

Run it. A panel appears. `Example.lua` in this repo is the demo above: it uses **every** element once, so open it next to this page and copy the parts you like.

**Every callback gets the new value.** A toggle gives `true` or `false`, a slider gives a number, a dropdown gives the chosen text, and so on. Errors inside your callback are caught and printed with `warn`, so one bad callback never breaks the panel.

**Every element returns an object** with `:Get()` and `:Set(value)`:

```lua
local jump = Tab:Toggle({ Name = "Infinite jump" })
jump:Set(true)          -- turns it on and runs the callback
jump:Set(true, true)    -- turns it on silently (no callback)
print(jump:Get())       --> true
```

---

## The window

```lua
local Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "my panel",
	Icon = "rbxassetid://114659273298746",
	Theme = "Red",
	Width = 540,
	Height = 360,
	ToggleKey = Enum.KeyCode.RightShift,
})
```

| Option | What it does | Default |
|---|---|---|
| `Title` | Big text in the title bar | `"RebelUI"` |
| `Subtitle` | Small text on the right of the title bar | none |
| `Icon` | A small logo left of the title. Roblox image id (see [Text and images](#text-and-images)) | none |
| `Theme` | `Red`, `Blue`, `Green`, `Purple`, `Orange`, `Pink`, `Mono`, or a theme you added | `"Red"` |
| `Width`, `Height` | Size in pixels. It shrinks to fit small phone screens | `540`, `360` |
| `ToggleKey` | Key that hides and shows the panel (PC) | `RightShift` |
| `Name` | Name of the `ScreenGui` | `"RebelUI"` |

| Window method | What it does |
|---|---|
| `Win:CreateTab(...)` | Adds a tab ([see Tabs](#tabs)) |
| `Win:Notify({...})` | Shows a notification ([see Notifications](#notifications)) |
| `Win:SetTheme("Blue")` | Changes the theme |
| `Win:SetAccent(Color3)` | Uses your own color as the accent |
| `Win:Toggle()` / `Win:Toggle(true)` / `Win:Toggle(false)` | Shows, hides or flips the panel |
| `Win:Destroy()` | Removes the panel |
| `Win.Flags` | Table of every element that has a `Flag` |

**Want a top bar with FPS, a logo and a timer?** See [The top bar](#the-top-bar).

**Title bar:** drag it to move the panel (mouse or finger). **–** hides it and shows a round **R** button. Tap **R** to bring the panel back; you can drag the **R** button around too. **×** closes the panel for good.

---

## The top bar

The top bar is a small round bar at the top of the screen. It shows live information (FPS, a logo, a timer and more). **Tap it to open or close the panel. Drag it to move it.** Players can choose what it shows.

```lua
local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" },          -- what to show (or use Preset = "Classic")
	Logo = "rbxassetid://114659273298746",       -- the picture for the "Logo" item
})
```

When a bar exists, the round **R** button is not needed, because the bar does its job.

### What the bar can show

| Item | Shows | Example |
|---|---|---|
| `"FPS"` | Frames per second | `FPS 60` |
| `"Ping"` | Network ping | `Ping 45ms` |
| `"Logo"` | Your logo picture (or a red **R** if you give none) | |
| `"Title"` | The window title | `Rebelwar` |
| `"Timer"` | How long the script has been running | `Time 00:12:30` |
| `"Clock"` | The time on the player's device | `Clock 14:05` |
| `"Players"` | Players in the server | `Players 12/30` |
| `"Memory"` | Memory used by the game | `Mem 840MB` |
| `"Executor"` | The executor's name, if it tells us | `Exec Delta` |
| `"Game"` | The game's name | |

The items always appear in this order: FPS, Ping, Logo, Title, Timer, Clock, Players, Memory, Executor, Game. So `{ "Timer", "Logo", "FPS" }` still shows `FPS | Logo | Timer`.

### Ready-made styles

| Preset | Shows |
|---|---|
| `"Classic"` | FPS, Logo, Timer |
| `"Minimal"` | Logo |
| `"Gamer"` | FPS, Ping, Clock |
| `"Info"` | Logo, Title, Players, Executor |
| `"Full"` | everything |

### Options

| Option | What it does | Default |
|---|---|---|
| `Items` | List of items to show | the `Preset` |
| `Preset` | One of the styles above | `"Classic"` |
| `Logo` | Image for the `"Logo"` item (id or `rbxassetid://`) | a red **R** |
| `Title` | Text for the `"Title"` item | the window title |
| `Visible` | Start shown or hidden | `true` |
| `Position` | A `UDim2` for where the bar starts | top center |

### Methods

```lua
Bar:SetItems({ "FPS", "Ping", "Timer" })   -- choose what to show
Bar:SetPreset("Gamer")                      -- use a ready-made style
Bar:Add("Clock")                            -- show one more item
Bar:Remove("Timer")                         -- hide one item
print(table.concat(Bar:GetItems(), ", "))   -- what is shown now
Bar:SetLogo("rbxassetid://123456")          -- change the logo
Bar:Show(false)                             -- hide the bar (Bar:Show(true) shows it)
Bar:Destroy()                               -- remove the bar (the round R button comes back)
```

### Let the player choose (one line)

`Tab:BarSettings(Bar)` adds the controls to a tab for you: a **Show top bar** toggle, a **Bar style** choice bar (Classic, Minimal, Gamer, Info, Full) and a **Bar items** multi-select list (tick any items you like).

```lua
local Settings = Win:CreateTab({ Name = "Settings", Title = "Settings", Description = "Theme and top bar" })
Settings:BarSettings(Bar)
```

Want your own version? Build the same controls yourself with a [choice bar](#sliders-choice-bars-and-progress-bars) and a [multi dropdown](#buttons-dropdowns-inputs-keybinds), and call `Bar:SetItems(list)` inside their callbacks.

---

## Tabs

A tab is a button in the left list, with its own scrolling page. Make a tab three ways, from simple to full:

```lua
-- 1. just a name
local Main = Win:CreateTab("Main")

-- 2. name + image icon next to it
local Player = Win:CreateTab("Player", "rbxassetid://119001011624125")

-- 3. everything: icon, and the tab's own header ("text hub") at the top of its page
local Hub = Win:CreateTab({
	Name = "Hub",
	Icon = "rbxassetid://106575470880507",
	Title = "Rebelwar Hub",
	Description = "Keyless, simple, powerful.",
})
```

| Tab option | What it does |
|---|---|
| `Name` | The text on the tab button |
| `Icon` | An image shown **next to** the name. It turns the accent color when the tab is selected |
| `Title` | Adds a header card at the top of the page with this big title |
| `Description` | The small text under the title in the header |
| `HeaderIcon` | A different image for the header card. It defaults to `Icon` |

| Tab method | What it does |
|---|---|
| `Tab:Select()` | Opens the tab from code |
| `Tab:SetName("New")` | Renames the tab |
| `Tab:SetIcon(id)` | Changes the tab's icon |
| `Tab.HeaderObj:SetTitle("x")` / `:SetText("y")` | Edits the header made by `Title`/`Description` |

The first tab you create opens by itself.

---

## All toggles

A toggle is the most-used element, so it has the most options.

```lua
local t = Tab:Toggle({
	Name = "Infinite jump",
	Description = "Jump again in the air.",
	Icon = "rbxassetid://71415024616002",
	Default = false,
	Style = "Switch",
	Color = Color3.fromRGB(60, 200, 110),
	Locked = false,
	Key = Enum.KeyCode.X,
	Flag = "infjump",
	Callback = function(on)
		print("infinite jump:", on)
	end,
})
```

### Every toggle option

| Option | What it does | Default |
|---|---|---|
| `Name` | The toggle's text | `"Toggle"` |
| `Description` | A second, smaller line of text under the name (makes the row taller) | none |
| `Icon` | A Roblox image on the left of the row | none |
| `Default` | `true` starts it on | `false` |
| `Style` | `"Switch"` (sliding switch) or `"Checkbox"` (a box with a tick) | `"Switch"` |
| `Color` | A `Color3` used only for this toggle when it is on. Without it the toggle follows the theme | theme accent |
| `Locked` | `true` greys it out and ignores taps until you unlock it | `false` |
| `Key` | A key that flips it (PC). A small `[X]` tag shows on the row | none |
| `Flag` | A name. `Win.Flags.<name>` then gives you this toggle from anywhere | none |
| `Callback` | `function(on)` runs every time it changes | none |

The callback does **not** run when the toggle is created, even with `Default = true`. If you need the starting state, read `t:Get()` yourself.

### Every toggle method

| Method | What it does |
|---|---|
| `t:Get()` | Returns `true` or `false` |
| `t:Set(true)` | Sets it and runs the callback |
| `t:Set(true, true)` | Sets it **silently** (no callback) |
| `t:Toggle()` | Flips it (does nothing while locked) |
| `t:Lock(true)` / `t:Lock(false)` | Locks or unlocks it. Check `t.Locked` |
| `t:SetName("New name")` | Changes the text |
| `t:SetDescription("New text")` | Changes the description (needs a `Description` at creation) |
| `t:SetColor(Color3)` | Changes this toggle's on-color |

### The eight kinds of toggle

```lua
-- 1. Plain
Tab:Toggle({ Name = "Plain switch" })

-- 2. Name + description
Tab:Toggle({ Name = "With a description", Description = "A line of small text.", Default = true })

-- 3. With an image icon
Tab:Toggle({ Name = "With an icon", Icon = "rbxassetid://71415024616002" })

-- 4. Checkbox
Tab:Toggle({ Name = "Checkbox style", Style = "Checkbox", Default = true })

-- 5. Own color
Tab:Toggle({ Name = "Green when on", Color = Color3.fromRGB(60, 200, 110) })

-- 6. Keybind
Tab:Toggle({ Name = "Toggle with a key", Key = Enum.KeyCode.X })

-- 7. Locked, then unlocked later
local locked = Tab:Toggle({ Name = "Locked", Locked = true })
Tab:Button({ Name = "Unlock", Callback = function() locked:Lock(false) end })

-- 8. All of them together
Tab:Toggle({
	Name = "Everything",
	Description = "Icon, description, key and its own color.",
	Icon = "rbxassetid://71415024616002",
	Style = "Switch",
	Color = Color3.fromRGB(255, 150, 50),
	Key = Enum.KeyCode.Z,
	Flag = "everything",
})
```

### Making a toggle do something

The toggle only tells you "on" or "off". You write what happens:

```lua
-- a feature that needs a loop: use the value
local running = false
Tab:Toggle({
	Name = "Auto jump",
	Callback = function(on)
		running = on
		task.spawn(function()
			while running do
				local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
				task.wait(0.5)
			end
		end)
	end,
})

-- a feature that needs an event: connect when on, disconnect when off
local conn
Tab:Toggle({
	Name = "Print every frame",
	Callback = function(on)
		if on then
			conn = game:GetService("RunService").Heartbeat:Connect(function() print("tick") end)
		elseif conn then
			conn:Disconnect()
			conn = nil
		end
	end,
})
```

---

## Sliders, choice bars and progress bars

### Slider

```lua
local speed = Tab:Slider({
	Name = "Walk speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Step = 1,
	Suffix = " studs/s",
	Flag = "speed",
	Callback = function(v)
		local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end,
})
```

| Option | What it does | Default |
|---|---|---|
| `Name` | Text above the bar | `"Slider"` |
| `Min`, `Max` | The range | `0`, `100` |
| `Default` | Starting value | `Min` |
| `Step` | Rounds to this step (`5` gives 5, 10, 15...). Decimals work: `0.1` | `1` |
| `Suffix` | Text after the number (`"%"`, `"°"`, `" studs"`) | none |
| `Flag` | Name for `Win.Flags` | none |
| `Callback` | `function(number)`. It runs while you drag, when the value changes | none |

Methods: `speed:Get()`, `speed:Set(50)`, `speed:Set(50, true)` (silent). Values outside the range are clamped.

### Choice bar

A **bar of buttons where you choose one**. Good for 2 to 4 short options.

```lua
local diff = Tab:Choice({
	Name = "Difficulty",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(choice)
		print("chosen:", choice)
	end,
})
```

| Option | What it does |
|---|---|
| `Name` | Text above the bar |
| `Options` | A list of texts. Each becomes a button, equal width |
| `Default` | The starting choice. Without it, the first option is chosen |
| `Callback` | `function(choice)`. It runs only when the choice **changes** |

Methods: `diff:Get()`, `diff:Set("Hard")`, `diff:Set("Hard", true)`. Unknown names are ignored. The chosen button uses the theme color.

### Progress bar

A read-only bar. You decide when it moves, from your own code:

```lua
local bar = Tab:Progress({ Name = "Loading", Min = 0, Max = 100, Default = 0, Suffix = "%" })

for i = 0, 100, 10 do
	bar:Set(i)
	task.wait(0.1)
end
```

---

## Buttons, dropdowns, inputs, keybinds

### Button

```lua
Tab:Button({ Name = "Say hello", Callback = function() Win:Notify({ Title = "Hello" }) end })
```

### Dropdown (one choice or many)

```lua
-- single choice
local mode = Tab:Dropdown({
	Name = "Mode",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(choice) print(choice) end,
})

-- multi choice: the callback gets a table like { Speed = true, Fly = true }
local feats = Tab:Dropdown({
	Name = "Features",
	Options = { "Speed", "Jump", "Fly", "Fog" },
	Multi = true,
	Callback = function(set)
		for name in pairs(set) do print("on:", name) end
	end,
})
```

| Option / method | What it does |
|---|---|
| `Options` | The list of texts |
| `Default` | Starting choice (single) |
| `Multi = true` | Allows several choices. `:Get()` returns a table `{ Name = true }` |
| `d:Set("Normal")` / `d:Set({ "Speed", "Fly" })` | Sets the choice (a list for multi) |
| `d:Refresh({ "new", "options" })` | Replaces the list of options |
| `d:Close()` | Closes the list |

### Input (text box)

```lua
Tab:Input({
	Name = "Player name",
	Placeholder = "type here",
	Default = "",
	Clear = false,
	Callback = function(text) print("typed:", text) end,
})
```

The callback runs when the player finishes typing (presses enter or closes the keyboard), not on every letter. `Clear = true` empties the box after each entry.

### Keybind

```lua
Tab:Keybind({
	Name = "Action key",
	Default = Enum.KeyCode.F,
	Callback = function() print("pressed") end,
	Changed = function(key) print("rebound to", key.Name) end,
})
```

Press the button, then press a key to rebind. `Escape` keeps the old key. `Callback` runs when the bound key is pressed. `Changed` runs when the player picks a new key. Keybinds are for PC, so give phone players a button too.

---

## Colors

```lua
local color = Tab:Color({
	Name = "ESP color",
	Default = Color3.fromRGB(233, 75, 53),
	Callback = function(c)
		print("color:", c)
	end,
})
```

The color element has everything a player needs to choose a color:

- **Hue bar** (the rainbow): which color.
- **Saturation bar**: from white to full color.
- **Brightness bar**: from black to bright.
- **Preview** box and a **hex box** (`#E94B35`). Type a hex code and press enter.
- **Nine preset swatches** at the bottom: tap one to jump to it.

| Method | What it does |
|---|---|
| `color:Get()` | Returns a `Color3` |
| `color:GetHex()` | Returns text like `"#E94B35"` |
| `color:Set(Color3)` | Sets the color and runs the callback (`:Set(c, true)` is silent) |
| `color:SetHex("#00FF00")` | Sets from a hex code. Bad codes are ignored |

The callback runs while the player drags a bar, so keep it fast (set a property, don't make a new part every call).

---

## Text and images

### Roblox images (asset ids)

Anywhere RebelUI takes an image, you can write it three ways. They all mean the same thing:

```lua
Icon = "rbxassetid://114659273298746"
Icon = "114659273298746"
Icon = 114659273298746
```

Use the **image asset id** from the Roblox website or Creator Hub. This works for the window `Icon`, tab `Icon`, toggle `Icon`, header `Icon` and the `Image` element.

### Image

```lua
local pic = Tab:Image({
	Image = "rbxassetid://125144167121839",
	Height = 120,
	Caption = "Rebelwar banner",
	Crop = true,
})

pic:Set("rbxassetid://114659273298746")   -- swap the picture later
pic:SetCaption("New caption")
```

| Option | What it does | Default |
|---|---|---|
| `Image` | The asset id | none |
| `Height` | Height in pixels | `120` |
| `Caption` | Small centered text under the image | none |
| `Crop` | `true` fills the box and crops. `false` fits the whole picture inside | `false` |

### Header (a tab's own text hub)

A banner card with a big title, small text and an icon.

```lua
local hub = Tab:Header({
	Title = "Rebelwar Hub",
	Text = "Keyless, simple, powerful.",
	Icon = "rbxassetid://114659273298746",
})
hub:SetTitle("New title")
hub:SetText("New text")
```

(`CreateTab({ Title = ..., Description = ... })` makes this same header for you at the top of the page.)

### Section, Label, Paragraph, Divider

```lua
Tab:Section("Movement")                       -- small accent-colored heading
Tab:Divider()                                 -- a thin line
local l = Tab:Label("A plain line of text.")  -- l:Set("new text"), l:Get()
local p = Tab:Paragraph({ Title = "Note", Text = "A titled block of text that grows to fit." })
p:Set("New title", "New text")
```

---

## Notifications

```lua
Win:Notify({ Title = "Saved", Text = "Settings were saved.", Duration = 4, Type = "success" })
Win:Notify("Just text works too")
```

| Option | What it does | Default |
|---|---|---|
| `Title` | Bold first line | `"Rebelwar"` |
| `Text` | Second line (wraps) | none |
| `Duration` | Seconds on screen | `4` |
| `Type` | `"success"` (green), `"warn"` (yellow), `"error"` (red). Without it the card uses the theme color | theme |

Cards slide in from the right and stack if there are several.

---

## Themes and your own colors

```lua
Win:SetTheme("Blue")                                -- built-in: Red, Blue, Green, Purple, Orange, Pink, Mono

UI:AddTheme("Gold", Color3.fromRGB(255, 200, 0))    -- make your own theme once...
Win:SetTheme("Gold")                                -- ...then use it

Win:SetAccent(Color3.fromRGB(10, 200, 10))          -- or set any color directly, any time
```

- `UI.Themes` is the list of theme names, so a dropdown can show them: `Tab:Dropdown({ Name = "Theme", Options = UI.Themes, Callback = function(n) Win:SetTheme(n) end })`.
- Everything repaints live: tabs, toggles, sliders, bars, headers, buttons, the window outline and the **R** button.
- Toggles with their own `Color` keep that color.

**A theme picker with your own color:**

```lua
Tab:Color({
	Name = "Accent color",
	Default = Color3.fromRGB(233, 75, 53),
	Callback = function(c) Win:SetAccent(c) end,
})
```

---

## Flags and saving settings

Give elements a `Flag`, and you can read all of them from one place:

```lua
Tab:Toggle({ Name = "ESP", Flag = "esp" })
Tab:Slider({ Name = "Range", Flag = "range", Min = 10, Max = 500, Default = 100 })

print(Win.Flags.esp:Get(), Win.Flags.range:Get())
```

Saving and loading with the executor's file functions:

```lua
local HttpService = game:GetService("HttpService")

local function save()
	local data = {}
	for name, element in pairs(Win.Flags) do
		local v = element:Get()
		if typeof(v) == "Color3" then v = { v.R, v.G, v.B } end   -- JSON can't store a Color3
		data[name] = v
	end
	writefile("mypanel.json", HttpService:JSONEncode(data))
end

local function load()
	if not (isfile and isfile("mypanel.json")) then return end
	local data = HttpService:JSONDecode(readfile("mypanel.json"))
	for name, v in pairs(data) do
		local element = Win.Flags[name]
		if element then
			if type(v) == "table" and #v == 3 then v = Color3.new(v[1], v[2], v[3]) end
			element:Set(v)
		end
	end
end
```

Call `load()` after you create the elements, and `save()` from a button. This covers toggles, sliders, colors, inputs and single dropdowns. A multi dropdown stores a table, so convert it to a list before you save it.

---

## Mobile tips

- Every drag works with a **finger**, not only a mouse.
- The panel **shrinks to fit** small screens. Use a `Width` and `Height` that are not too big.
- Phones have no keyboard, so **hiding** the panel leaves a round **R** button. Tap it to open the panel again. You can drag the **R** button.
- Sliders and color bars **stop the page scrolling** while your finger is on them.
- Give phone players a button or toggle for anything that only has a keybind.
- Test on your phone, not only on a computer.

---

---

## Build it yourself

This part shows how every piece is made with plain Roblox code: `Instance.new`, `TweenService` and `UserInputService`. There are no tricks. If you understand the toggle and the slider, you understand the whole library.

The steps build on each other. Paste the helpers from Step 1 first, then the window from Step 2, and after that you can add any later step to see it work. Everything works with a **finger** and a mouse.

Window dragging is a short extra at the end ([Bonus: dragging the window](#bonus-dragging-the-window)), so the steps can start with the pieces you care about.

**Quick map:** 1 helpers · 2 window · 3 button · 4 toggle (+ 6 upgrades: description, icon, checkbox, color, locked, key) · 5 slider · 6 choice bar · 7 dropdown · 8 text box · 9 keybind · 10 color picker · 11 tabs (+ icons, headers, Roblox images) · 12 notifications · 13 themes · 14 top bar (FPS, logo, timer, choose what shows).


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

## Common mistakes

| Problem | Cause and fix |
|---|---|
| Nothing appears | The `ScreenGui` has no parent, or the executor has no `gethui`. Use `CoreGui` as a fallback. |
| A slider jumps or scrolls the page | Missing `ScrollingEnabled = false` while dragging. |
| The toggle looks right but does nothing | You changed the colors but forgot to run your feature in the callback. |
| It works on PC but not on a phone | You only handled `MouseButton1`. Add `Enum.UserInputType.Touch`. |
| Everything is stuck at the top-left | `Position` was never set. Use `AnchorPoint` plus `Position`. |
| Rows overlap | Give the page a `UIListLayout` and do not set row positions by hand. |
| A callback does nothing and no error shows | Errors in callbacks are caught. RebelUI prints them with `warn`, so check the console. |

## What to learn next

1. Save settings with `writefile` and load them with `readfile` (turn the toggles and sliders into a table, then `HttpService:JSONEncode`).
2. Add a search box that hides rows whose names don't match.
3. Make your own element, such as a progress bar or a two-button row. Copy the toggle function, change the visual, and keep `:Set` and `:Get`.


---

## Files in this repo

| File | What it is |
|---|---|
| `source.lua` | The library. Load it with `loadstring(game:HttpGet("https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/source.lua"))()` |
| `Example.lua` | The demo panel. It uses every element and every kind of toggle. Copy parts of it into your own script |
| `README.md` | This tutorial |

## Help and community

Questions, bugs or ideas? Join the Discord: **https://discord.gg/Kq7N4gzH22**

## License

MIT. Use it, change it, make your own panel. Credit is appreciated. See `LICENSE`.

> RebelUI is a UI library. What your buttons and toggles do is up to you. Follow the rules of the game you play in and the Roblox Terms of Use. Rebelwar is not affiliated with or endorsed by Roblox.
