require("conf.variables")

-- #Apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd(run(terminal)))
hl.bind("SUPER + E", hl.dsp.exec_cmd(run(fileManager)))
hl.bind("SUPER + B", hl.dsp.exec_cmd(run(browser)))
hl.bind("SUPER + C", hl.dsp.exec_cmd(run(codeEditor)))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(run(taskManager)))

-- #Utilities
hl.bind("SUPER + A", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + V", hl.dsp.exec_cmd(clipboard))
hl.bind("SUPER + W", hl.dsp.exec_cmd(run(wallpaper)))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("~/.config/fuzzel/scripts/emoji.sh"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + F1", hl.dsp.exec_cmd(run(volume)))
hl.bind("SUPER + F12", hl.dsp.exec_cmd("~/.config/fuzzel/scripts/calculator.sh"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
-- screenshots
hl.bind(
	"Print",
	hl.dsp.exec_cmd("grim - | wl-copy && grim ~/Pictures/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"),
	{ locked = true, non_consuming = true }
)
hl.bind("CTRL + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'), { locked = true })

-- #Scrolling layout
hl.bind("ALT + right", hl.dsp.layout("swapcol r"))
hl.bind("ALT + left", hl.dsp.layout("swapcol l"))
hl.bind("SUPER + mouse_up", hl.dsp.layout("move -col"))
hl.bind("SUPER + mouse_down", hl.dsp.layout("move +col"))

-- #Window
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + Tab", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("snappy-switcher prev --mod alt"))

-- move focus
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- move/resize window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("ALT + R", hl.dsp.layout("colresize +conf"))

-- minimize
hl.bind("SUPER + M", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end)

-- #Workspace
-- special workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- switch workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
end
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + +SHIFT + TAB", hl.dsp.focus({ workspace = "-1" }))

-- window to workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "-1" }))

-- #Session
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("~/.config/fuzzel/scripts/powermenu.sh"))

-- #Multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { repeating = true })
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl next play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl previoust"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })

-- #Multimedia custom
hl.bind("SUPER + F2", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind(
	"SUPER + F4",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind("SUPER + F5", hl.dsp.exec_cmd("swayosd-client --playerctl stop"), { locked = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("swayosd-client --playerctl previous"), { locked = true })
hl.bind("SUPER + F7", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("SUPER + F8", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("SUPER + page_up", hl.dsp.exec_cmd("swayosd-client --brightness +10 && ddcutil setvcp 10 + 10"))
hl.bind("SUPER + page_down", hl.dsp.exec_cmd("swayosd-client --brightness -10 && ddcutil setvcp 10 - 10"))
