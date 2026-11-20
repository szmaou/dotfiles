local ipc = "hayu "
local terminal = "foot"
local fileManager = "thunar"
local taskManager = "foot -e btop"
local browser = "helium-browser"

-- #Session
hl.bind("SUPER + Escape", hl.dsp.exit())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + R", hl.dsp.exec_cmd("hyprland-run"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(ipc .. "session lock"))

-- #Apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(taskManager))

-- #hayu
hl.bind("SUPER + A", hl.dsp.exec_cmd(ipc .. "launcher toggle"))

-- #Noctalia / utilities
-- hl.bind("SUPER + A", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
-- hl.bind("SUPER + S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
-- hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
-- hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
-- hl.bind("SUPER + X", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/notes:panel"))
-- hl.bind("SUPER + W", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
-- hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/wallhaven:browser"))
-- hl.bind("SUPER + F1", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center media"))
-- hl.bind("SUPER + I", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
-- hl.bind("MENU", hl.dsp.exec_cmd(ipc .. "bar-toggle"))
-- hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
-- hl.bind("CTRL + Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
-- hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- #Window
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + T", hl.dsp.window.cycle_next({ floating = true }))
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))
-- hl.bind("SUPER + R", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + Comma", hl.dsp.layout("consume"))
hl.bind("SUPER + Period", hl.dsp.layout("consume_or_expel next"))

-- #Focus
hl.bind("SUPER + Left", hl.dsp.layout("focus l"))
hl.bind("SUPER + Right", hl.dsp.layout("focus r"))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + Left", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + SHIFT + Right", hl.dsp.layout("swapcol r"))

-- #Workspaces
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "+1" }))
for i = 1, 9 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + bracketright", hl.dsp.window.cycle_next())
hl.bind("SUPER + bracketleft", hl.dsp.window.cycle_next({ next = false }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.swap({ next = true }))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.swap({ prev = true }))
hl.bind("SUPER + grave", hl.dsp.focus({ last = true }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "+1" }))

-- #Column / layout
hl.bind("SUPER + Minus", hl.dsp.layout("colresize -0.1"), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.layout("colresize +0.1"), { repeating = true })
hl.bind("SUPER + BackSpace", hl.dsp.layout("consume_or_expel prev"))
hl.bind("SUPER + C", hl.dsp.layout("center"))
hl.bind("SUPER + SHIFT + C", hl.dsp.window.center())
hl.bind("SUPER + Space", function()
	local next = hl.get_config("general.layout") == "scrolling" and "dwindle" or "scrolling"
	hl.config({ general = { layout = next } })
end)
hl.bind("SUPER + ALT + K", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia
local locked = { locked = true }
local rep = { locked = true, repeating = true }
local function mm(key, cmd, opts)
	hl.bind(key, hl.dsp.exec_cmd(ipc .. cmd), opts)
end
for _, b in ipairs({
	{ "volume-up", rep, "XF86AudioRaiseVolume", "SUPER + F3" },
	{ "volume-down", rep, "XF86AudioLowerVolume", "SUPER + F2" },
	{ "volume-mute", locked, "XF86AudioMute", "SUPER + F4" },
	{ "brightness-up", rep, "XF86MonBrightnessUp", "SUPER + CTRL + Page_Up" },
	{ "brightness-down", rep, "XF86MonBrightnessDown", "SUPER + CTRL + Page_Down" },
	{ "media toggle", locked, "XF86AudioPlay", "SUPER + F7" },
	{ "media next", locked, "XF86AudioNext", "SUPER + F8" },
	{ "media previous", locked, "XF86AudioPrev", "SUPER + F6" },
	{ "media stop", locked, "SUPER + F5" },
}) do
	for i = 3, #b do
		mm(b[i], b[1], b[2])
	end
end
