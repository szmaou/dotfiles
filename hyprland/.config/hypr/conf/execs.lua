hl.on("hyprland.start", function()
	-- Hyprland already exports the Wayland vars; --all also covers PATH etc.
	hl.exec_cmd("dbus-update-activation-environment --all")
	hl.exec_cmd("noctalia")
end)
