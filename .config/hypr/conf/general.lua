local c = require("colors.colors")

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1",
})

-- General
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 3,

		border_size = 1,
		resize_on_border = true,
		col = {
			active_border = c.active_border,
			inactive_border = c.inactive_border,
		},

		no_focus_fallback = true,
		allow_tearing = true, -- This just allows the `immediate` window rule to work

		layout = "dwindle",

		snap = {
			enabled = true,
			window_gap = 4,
			monitor_gap = 5,
			respect_gaps = true,
		},
	},
	decoration = {
		active_opacity = 0.95,
		inactive_opacity = 0.9,
		fullscreen_opacity = 1.0,

		rounding_power = 2,
		rounding = 5,

		blur = {
			enabled = true,
			xray = true,
			special = false,
			new_optimizations = true,
			size = 10,
			passes = 3,
			brightness = 1,
			noise = 0.05,
			contrast = 0.89,
			vibrancy = 0.5,
			vibrancy_darkness = 0.5,
			popups = false,
			popups_ignorealpha = 0.6,
			input_methods = true,
			input_methods_ignorealpha = 0.8,
		},

		shadow = {
			enabled = true,
			range = 10,
			render_power = 10,
			color = c.shadow,
		},

		dim_inactive = true,
		dim_strength = 0.05,
		dim_special = 0.2,
	},

	-- Layout
	dwindle = {
		preserve_split = true,
	},
	scrolling = {
		column_width = 1.0,
		direction = "down",
	},
})

-- Animation curves
hl.curve("expressiveFastSpatial", { type = "bezier", points = { { 0.42, 1.67 }, { 0.21, 0.90 } } })
hl.curve("expressiveSlowSpatial", { type = "bezier", points = { { 0.39, 1.29 }, { 0.35, 0.98 } } })
hl.curve("expressiveDefaultSpatial", { type = "bezier", points = { { 0.38, 1.21 }, { 0.22, 1.00 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("standardDecel", { type = "bezier", points = { { 0, 0 }, { 0, 1 } } })
hl.curve("menu_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("menu_accel", { type = "bezier", points = { { 0.52, 0.03 }, { 0.72, 0.08 } } })
hl.curve("stall", { type = "bezier", points = { { 1, -0.1 }, { 0.7, 0.85 } } })

-- Animations
hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 1,
	bezier = "emphasizedDecel",
	style = "popin 80%",
})
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1, bezier = "emphasizedDecel" })
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 1,
	bezier = "emphasizedDecel",
	style = "popin 90%",
})
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "emphasizedDecel" })
hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 2.7,
	bezier = "emphasizedDecel",
	style = "popin 93%",
})
hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 2.4,
	bezier = "menu_accel",
	style = "popin 94%",
})
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "stall" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slide" })
hl.animation({
	leaf = "specialWorkspaceIn",
	enabled = true,
	speed = 2.8,
	bezier = "emphasizedDecel",
	style = "slidevert",
})
hl.animation({
	leaf = "specialWorkspaceOut",
	enabled = true,
	speed = 1.2,
	bezier = "emphasizedAccel",
	style = "slidevert",
})
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3, bezier = "standardDecel" })

hl.config({
	input = {
		kb_layout = "us",
		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 35,

		follow_mouse = 1,
		off_window_axis_events = 2,
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 1,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot|kitty|allacritty|Alacritty)",
		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,
		session_lock_xray = true,
		initial_workspace_tracking = false,
		focus_on_activate = true,
	},
	binds = {
		scroll_event_delay = 0,
		hide_special_on_workspace_change = true,
	},
	cursor = {
		zoom_factor = 1,
		zoom_rigid = false,
		zoom_disable_aa = true,
		hotspot_padding = 1,
	},
	xwayland = {
		force_zero_scaling = true,
	},
})
