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
calculator = "~/.config/fuzzel/scripts/calculator.sh"
emoji = "~/.config/fuzzel/scripts/emoji.sh"
powermenu = "~/.config/fuzzel/scripts/powermenu.sh"
floatTerm = "~/.config/hypr/scripts/kitty-float-toggle.sh"

-- Helper: prepend uwsm-runner
function run(cmd)
	return "runapp " .. cmd
end
