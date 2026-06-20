hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- udiskie")
	hl.exec_cmd("uwsm app -- qs -c noctalia-shell")
end)
