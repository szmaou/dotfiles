-- Disable blur for all windows initially
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })
hl.window_rule({ match = { class = ".*" }, no_blur = true })

-- Floating dialogs
local dialog_patterns = {
	"^(Open File)(.*)$",
	"^(Select a File)(.*)$",
	"^(Select)(.*)",
	"^(Open Folder)(.*)$",
	"^(Save As)(.*)$",
	"^(Save)(.*)$",
	"^(Library)(.*)$",
	"^(File Upload)(.*)$",
	"^(File Operation)(.*)$",
	"^(Rename)(.*)$",
}
for _, pattern in ipairs(dialog_patterns) do
	hl.window_rule({ match = { title = pattern }, float = true, center = true })
end
hl.window_rule({ match = { title = "^(.*)(wants to save)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(.*)(wants to open)$" }, float = true, center = true })

-- Picture-in-Picture
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = "(monitor_w * 0.73) (monitor_h * 0.72)",
	size = "(monitor_w * 0.25) (monitor_h * 0.25)",
})

-- Share picker
hl.window_rule({ match = { class = "^(hyprland-share-picker)$" }, float = true, center = true })

-- Screen sharing
hl.window_rule({
	match = { title = ".*is sharing (a window|your screen).*" },
	float = true,
	pin = true,
	move = "(monitor_w * 0.5 - window_w * 0.5) (monitor_h - window_h - 12)",
})

-- Tearing (games / wine)
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- Tiling override
hl.window_rule({ match = { class = "^dev\\.warp\\.Warp$" }, tile = true })

-- No shadow for non-floating windows
hl.window_rule({ match = { float = false }, no_shadow = true })

-- Fix JetBrains IDEs focus / rerendering
hl.window_rule({
	match = { class = "^jetbrains-.*$", float = true, title = "^$|^\\s$|^win\\d+$" },
	no_initial_focus = true,
})

-- Layer rules
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0 })

-- Workspace rules
hl.workspace_rule({ workspace = "special:magic", gaps_out = 20 })

-- App
hl.window_rule({ match = { class = "vesktop" }, workspace = "special:magic" })
hl.window_rule({ match = { class = "^(org.gnome.FileRoller)$" }, float = true, center = true })
hl.window_rule({
	match = { class = "kitty-float" },
	float = true,
	center = true,
	size = { 500, 400 },
	border_size = 2,
	rounding = 0,
})
hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	float = true,
	center = true,
	size = "(monitor_w * 0.45) (monitor_h * 0.45)",
})
hl.window_rule({
	match = { class = "waypaper" },
	float = true,
	center = true,
})
