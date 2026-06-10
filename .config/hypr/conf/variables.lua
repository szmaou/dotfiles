-- Default apps
terminal = "kitty"
codeEditor = "zeditor"
fileManager = "thunar"
browser = "zen-browser"
taskManager = "kitty -1 btop"
clipboard = "~/.config/fuzzel/scripts/clipboard.sh"
launcher = "~/.config/fuzzel/scripts/app_laucnher.sh"
wallpaper = "~/.config/hypr/scripts/waypaper-toggle.sh"
volume = "~/.config/hypr/scripts/pavucontrol-toggle.sh"

-- Helper: prepend uwsm-runner
function run(cmd)
	return "runapp " .. cmd
end
