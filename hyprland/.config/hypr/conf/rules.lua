-- Mirrors umbriel/.config/umbriel/src/rules.toml.
-- Hyprland 0.57 has no per-window blur toggle, only no_blur.
hl.window_rule({ match = { class = ".*" }, no_blur = true })

-- Default scrolling extent (umbriel default_scrolling_extent)
hl.window_rule({ match = { class = "^(Alacritty|kitty|org\\.gnome\\.Nautilus)$" }, scrolling_width = 0.33 })
hl.window_rule({ match = { class = "^(helium|chromium)$" }, scrolling_width = 0.75 })

-- Proton / games fullscreen
hl.window_rule({ match = { xdg_tag = "^proton-game$" }, fullscreen = true })
hl.window_rule({ match = { class = "^(steam_proton|steam_app.*|overwatch|overwatch\\.exe)$" }, fullscreen = true })

-- Tearing
hl.window_rule({ match = { class = "^(steam_app_[0-9]+|gamescope)$" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })

-- Opacity
hl.window_rule({ match = { class = "^(code|org\\.gnome\\.Nautilus)$" }, opacity = "0.97" })
hl.window_rule({ match = { float = true, focus = false }, opacity = "0.4 override" })

-- Floating apps
hl.window_rule({
	match = { class = "^(Emulator|zenity|xdg-desktop-portal|qalculate-gtk|org\\.pulseaudio\\.pavucontrol)$" },
	float = true,
})
hl.window_rule({
	match = { class = "^dev\\.lemmy\\.swash$" },
	float = true,
	size = { 1000, 900 },
})

-- Floating dialogs
local dialog_titles = {
	"^(Open File|Select|Choose a wallpaper|Open Folder|Save As|Library|Choose Where to Download|File Operation Progress|Rename|Copy Files|Move Files|Search Files)",
}
for _, title in ipairs(dialog_titles) do
	hl.window_rule({ match = { title = title }, float = true })
end

-- Notification toasts: bottom right, unfocused, pinned
hl.window_rule({
	match = { title = "^notificationtoasts_.+_desktop$" },
	float = true,
	pin = true,
	no_initial_focus = true,
	move = "monitor_w - window_w - 12 monitor_h - window_h - 12",
})

-- Noctalia windows
hl.window_rule({
	match = { class = "^dev\\.noctalia\\.Noctalia$" },
	float = true,
	size = { 1020, 700 },
})
hl.window_rule({
	match = { class = "^dev\\.noctalia\\.NoctaliaSharePicker$" },
	float = true,
	size = { 800, 600 },
	move = "monitor_w - window_w - 32 monitor_h - window_h - 32",
})

-- Hyprland-specific helpers
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = "(monitor_w * 0.73) (monitor_h * 0.72)",
	size = "(monitor_w * 0.25) (monitor_h * 0.25)",
})
hl.window_rule({ match = { class = "^(hyprland-share-picker)$" }, float = true, center = true })
hl.window_rule({
	match = { title = ".*is sharing (a window|your screen).*" },
	float = true,
	pin = true,
	move = "(monitor_w * 0.5 - window_w * 0.5) (monitor_h - window_h - 12)",
})
hl.window_rule({ match = { class = "^dev\\.warp\\.Warp$" }, tile = true })
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
hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|desktop-widget-.*)$",
	},
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
