-- RebelUI v1.0.0 demo loader — patched for executors that restrict raw fetches or media
-- Changes: fallback CDN URL, HTML detection for bad fetch, videos disabled by default,
-- wrapped fragile calls (ResolveMedia/Preload/SetVideo) in pcall, clearer console warnings.

local REF = "main"

local RAW_URL = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/" .. REF .. "/source.lua"
local CDN_URL = "https://cdn.jsdelivr.net/gh/rizqadeeb38-dev/Rebelwar_UI@" .. REF .. "/source.lua"

local function problem(msg)
    warn("[Rebelwar] " .. msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Rebelwar", Text = msg, Duration = 10 })
    end)
end

-- try http get with safe pcall and short timeout loop (some executors overwrite HttpGet behavior)
local function tryFetch(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        return false, tostring(res)
    end
    if type(res) ~= "string" then
        return false, "non-string response"
    end
    -- detect HTML/HTML error pages (common when blocked or redirected)
    local first = res:sub(1, 64):lower()
    if first:match("^%s*<!doctype") or first:match("^%s*<html") or first:match("<html") then
        return false, "returned HTML (possible 404, block, or login page)"
    end
    if #res < 2000 then
        return false, "content too short (" .. tostring(#res) .. " bytes)"
    end
    return true, res
end

local okGet, src, errMsg
okGet, src = tryFetch(RAW_URL)
if not okGet then
    -- try CDN fallback
    local ok2, src2 = tryFetch(CDN_URL)
    if ok2 then
        src = src2
        okGet = true
    else
        errMsg = ("Failed to download source.lua.\n- raw: %s\n- cdn: %s")
            :format(tostring(src), tostring(src2))
        problem("Could not download source.lua. " .. (errMsg or ""))
    end
end

if not okGet or type(src) ~= "string" or #src < 2000 then
    problem("Could not download source.lua. Is the repo public and is the file on branch '" .. REF .. "'?\nTried:\n  " .. RAW_URL .. "\n  " .. CDN_URL .. "\nIf your executor blocks HttpGet, either enable it or paste the library locally.")
    return
end

local fn, err = loadstring(src)
if not fn then
    problem("source.lua has a loadstring error: " .. tostring(err))
    return
end

local okRun, UI = pcall(fn)
if not okRun or type(UI) ~= "table" or not UI.Loading or not UI.CreateWindow or not UI.KeyGate then
    problem("source.lua loaded but the UI table is missing required functions. Make sure you have RebelUI v1.0.0 as source.lua in the repo.")
    return
end

-- Developer switch
local SCRIPT_ON = true
local SWITCH_URL = nil
if not UI:Switch({ On = SCRIPT_ON, Url = SWITCH_URL, Name = "Rebelwar", Message = "Rebelwar is switched off right now. Check the Discord for news." }) then
    return
end

-- Default setup
local SETUP = "Auto"

-- Small robustness: disable videos by default (many executors block downloads or decoding)
local Load, Win
local USE_VIDEOS = false -- changed from true to false to avoid ResolveMedia failure on restricted executors
local VIDEO = nil -- leave nil unless USE_VIDEOS = true and your executor can fetch video
local USE_ACTIVATE = true
local ACTIVATE_MODE = "Cover"

local ICON = {
    ESP = 71415024616002,
    Settings = 81306187910490,
    Discord = 106575470880507,
}

local USE_KEY_GATE = false
local GET_KEY_LINK = "https://lootlabs.gg/your-link-here"
local KEYS = { "REBEL-DEMO" }
local function keyGateOptions(save)
    return {
        Name = "Rebelwar",
        Title = "REBELWAR",
        Subtitle = "Get your key, then paste it below.",
        Image = 125144167121839,
        Tagline = "Rebelwar  |  by prorizz196",
        Background = 125144167121839,
        BackgroundOpacity = 0.22,
        ImageEffect = "Shimmer",
        Logo = 114659273298746,
        LogoEffect = "Rainbow",
        Note = "Tap Get key, finish the LootLabs steps, and paste the key here.\nThe key works for the whole day.",
        NoteIcon = "📌",
        NoteColor = "Gold",
        Setup = SETUP,
        Video = VIDEO,
        ProviderStyle = "Row",
        Providers = {
            { "LootLabs", GET_KEY_LINK },
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
        Save = save,
        Boom = true,
        BoomText = UI.Fancy("LETS GO!", "Bold"),
        Theme = "Red",
    }
end
local DISCORD = "https://discord.gg/8s7RR3wZ6b"

-- Pre-download video only if enabled, but guard ResolveMedia with pcall
local vidReady, vidPath = not VIDEO, nil
if VIDEO then
    task.spawn(function()
        local okV, a = pcall(function() return UI.ResolveMedia and UI.ResolveMedia(VIDEO) or VIDEO end)
        vidPath = okV and a or nil
        vidReady = true
    end)
end

-- Key gate
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
    Logo = 114659273298746,
    Banner = 125144167121839,
    Footer = "discord.gg/8s7RR3wZ6b  |  RebelUI v" .. UI.Version,
    Theme = "Red",
})
Load:Badge(gameName)

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
    task.wait()
end
task.delay(25, function()
    if not ready then
        warn("[Rebelwar] startup still running after 25s. Last step: " .. tostring(bootLog[#bootLog]))
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

-- Download video if enabled, but only wait a limited time and guard with pcall
local logoVid
if VIDEO then
    Load:Status(UI.Fancy("downloading the intro", "Bold") .. " ...")
    local t0 = os.clock()
    while not vidReady and os.clock() - t0 < 25 do
        task.wait(0.1)
        pcall(Load.Progress, Load, 0.08 + 0.2 * math.min((os.clock() - t0) / 25, 1))
    end
    logoVid = vidPath
    if logoVid then
        pcall(function() Load:SetVideo(logoVid) end)
    end
end
stage("Loading images...", 0.3)
pcall(function()
    if Load.Preload then
        Load:Preload({ 114659273298746, 125144167121839, ICON.ESP, ICON.Settings, ICON.Discord }, 0, 0.6)
    end
end)

stage("Building the panel...", 0.55)

Win = UI:CreateWindow({
    Title = "Rebelwar",
    Subtitle = "made by prorizz196",
    Icon = 114659273298746,
    Theme = "Red",
    Open = false,
    Opacity = 100,
    Setup = SETUP,
    ToggleStyle = "Sharp",
    SliderStyle = "Sharp",
    Ambient = true,
    Search = true,
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightShift,
})

stage("Building the top bar...", 0.6)
pcall(function()
    Win:CreateWatermark({ Text = "Rebelwar" })
    Win:SetPalette()
    Win:SetBackground({ Image = 125144167121839, Opacity = 0.18 })
    Win:SetPanicKey(Enum.KeyCode.Delete)
    Win:SetOpenBoom("first")
    Win:SetTabHotkeys()
    Win:SetDim(0.35)
end)
local Bar = nil
pcall(function()
    Bar = Win:CreateBar and Win:CreateBar({
        Items = { "FPS", "Logo", "Timer" },
        Logo = 114659273298746,
    })
end)

-- Build Elements tab when opened; keep original Build function intact
stage("Building tabs...", 0.65)
local function buildElements(Elements)
    -- The original demo build function; unchanged.
    Elements:Stats({ { Name = "Kills", Value = 0 }, { Name = "Wins", Value = 0 }, { Name = "Streak", Value = 0 } })
    Elements:Section("New: chips, steps, timeline, list, table")
    Elements:Chips({ "Legit", "Rage", "Closet" }, { Closable = true, Callback = function(name, what) Win:Notify({ Title = what, Text = name }) end })
    local steps = Elements:Steps({ "Pick", "Tune", "Go" }, 1)
    Elements:Button({ Name = "Next step", Callback = function() steps:Next() end })
    Elements:Typewriter({ Text = "Rows rise in, tap squishes, numbers count up..." })
    local skel = Elements:Skeleton({ Lines = 2 })
    task.delay(3, function() skel:Remove() end)
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
    Elements:Image({ Image = 114659273298746, Height = 96, Circle = true, Effect = "Rainbow", Caption = "Effect = Rainbow (also Pulse, Float, Glow, Spin, Shimmer)", OnClick = function() Win:Boom({ Text = "BOOM" }) end })
    Elements:Image({ Image = 125144167121839, Height = 90, Crop = true, Effect = "Shimmer" })
    Elements:Button({ Name = "BOOM!", Description = "The explosion effect: flash, rings and sparks", Callback = function() Win:Boom({ Text = "BOOM" }) end })
    Elements:HoldButton({ Name = "Hold to confirm (1 second)", Seconds = 1, Callback = function() Win:Notify({ Title = "Confirmed", Type = "success" }) end })
    Elements:Button({ Name = "Toast with Undo", Callback = function() Win:NotifyUndo({ Title = "Setting changed", Text = "Tap Undo within 5 seconds.", OnUndo = function() Win:Notify({ Title = "Undone", Type = "success" }) end }) end })
    local miniToggle = Elements:Toggle({ Name = "Mini pill target" })
    Elements:Button({ Name = "Show the mini pill", Description = "A small draggable pill with that toggle", Callback = function() Win:CreateMini({ Toggles = { miniToggle } }) end })
    Elements:Section("New: sub-tabs and columns")
    local sub = Elements:SubTabs({ "Aim", "Visuals", "Misc" })
    sub.Aim:Toggle({ Name = "A toggle in Aim" })
    sub.Visuals:Slider({ Name = "A slider in Visuals", Min = 0, Max = 100, Default = 40 })
    sub.Misc:Button({ Name = "A button in Misc", Callback = function() Win:Notify({ Title = "Misc button" }) end })
    local cols = Elements:Columns(2)
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
    -- (the rest of the demo unchanged)
end

Win:CreateTab({ Name = "Elements", Icon = UI.Icons.elements, Title = "🧩 ALL ELEMENTS", Description = "One of every element and every toggle style.", Build = buildElements })
local Discord = Win:CreateTab({ Name = "Discord", Icon = ICON.Discord, Title = "💬 DISCORD", Description = "Updates, support and suggestions." })
Discord:SetBadge("NEW")
Win:SetAssistant({
    Logo = 114659273298746,
    Title = "ELITE GAME ASSISTANT",
    Color = "Rainbow",
    Key = Enum.KeyCode.H,
    OnSummary = function(hud, done) done(hud:GetSummary()) end,
})
stage("Building the tools tab...", 0.85)
local Tools = Win:CreateToolsTab and Win:CreateToolsTab({ Icon = UI.Icons.wrench, Features = { "More themes", "More crosshairs", "Macro recorder", "Cloud sync", "Sound packs" } })
pcall(function() Win:CreateNotificationsTab({ Icon = UI.Icons.notification }) end)
pcall(function() Win:CreateFavoritesTab({ Icon = UI.Icons.star }) end)
pcall(function() Win:CreateThemeEditor({ Icon = 114659273298746 }) end)
stage("Building settings...", 0.92)
local Settings = nil
pcall(function()
    Settings = Win:CreateSettingsTab and Win:CreateSettingsTab({
        Icon = ICON.Settings,
        Bar = Bar,
        Credits = { Name = "Rebelwar", Text = "Made by prorizz196. Thank you for playing!", Discord = DISCORD },
    })
end)

Discord:Image({ Image = 125144167121839, Height = 110, Crop = true, Effect = "Shimmer" })
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
        local ok = pcall(function() setclipboard(DISCORD) end)
        Win:Notify({
            Title = ok and "Copied!" or "Your executor can't copy",
            Text = ok and "Paste it in your browser to join." or DISCORD,
            Type = ok and "success" or "warn",
        })
    end,
})

stage("Ready!", 1)
ready = true
Load:Finish()
if USE_ACTIVATE then
    local okAct = pcall(function() return UI:Activate({ Mode = ACTIVATE_MODE, Video = logoVid, Logo = 114659273298746, Title = "Rebelwar", Theme = "Red", BoomText = UI.Fancy("LETS GO!", "Bold") }) end)
    if not okAct then
        -- allow continue even if Activate failed
    end
end
Win:Toggle(true)
Win:Boom({ Text = UI.Fancy("lets go!", "Bold") })
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
Win:Notify({ Title = UI.Fancy("welcome", "Bold") .. ", " .. (lp and lp.DisplayName or "player"), Text = "Tap the top bar (or press RightShift) to hide or show the panel.", Duration = 5 })
