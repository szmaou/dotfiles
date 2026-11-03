-- Disable blur for every window
hl.window_rule({ match = { class = ".*" }, no_blur = true })

-- Floating dialogs
hl.window_rule({
	match = { title = "^(Open File|Select a File|Open Folder|Select the mod file to import|Save As|Library|File Upload|.*wants to save|.*wants to open)" },
	float = true,
	center = true,
})
hl.window_rule({
	match = { title = "^Choose wallpaper" },
	float = true,
	center = true,
	size = { "monitor_w*0.60", "monitor_h*0.65" },
})

-- Floating utility windows
hl.window_rule({ match = { class = "^(blueberry\\.py|guifetch)$" }, float = true })
hl.window_rule({ match = { class = "plasmawindowed|kcm_|bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = "illogical-impulse Settings" }, float = true })
hl.window_rule({ match = { title = "Welcome|Shell conflicts" }, float = true })
hl.window_rule({
	match = { class = "^(org\\.pulseaudio\\.)?pavucontrol$|^nm-connection-editor$" },
	float = true,
	center = true,
	size = { "monitor_w*0.45", "monitor_h*0.45" },
})
hl.window_rule({
	match = { class = "org.freedesktop.impl.portal.desktop.kde" },
	float = true,
	size = { "monitor_w*0.60", "monitor_h*0.65" },
})
hl.window_rule({
	match = { class = "^(Zotero)$" },
	float = true,
	size = { "monitor_w*0.45", "monitor_h*0.45" },
})

-- Tiling
-- Ignore app maximize requests so restored window states do not override tiling.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^dev\\.warp\\.Warp$" }, tile = true })
hl.window_rule({ match = { float = false }, no_shadow = true })

-- Picture-in-Picture
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = { "monitor_w*0.73", "monitor_h*0.72" },
	size = { "monitor_w*0.25", "monitor_h*0.25" },
})

-- Tearing
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- Proton / games fullscreen
hl.window_rule({ match = { xdg_tag = "^proton-game$" }, fullscreen = true })
hl.window_rule({ match = { class = "^(steam_proton|steam_app.*|overwatch|overwatch\\.exe)$" }, fullscreen = true })

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

-- Other helpers
hl.window_rule({ match = { class = "^(hyprland-share-picker)$" }, float = true, center = true })
hl.window_rule({
	match = { title = ".*is sharing (a window|your screen).*" },
	float = true,
	pin = true,
	move = "(monitor_w * 0.5 - window_w * 0.5) (monitor_h - window_h - 12)",
})
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
