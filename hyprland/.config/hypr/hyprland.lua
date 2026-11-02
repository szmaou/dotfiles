package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path

require("conf.execs")
require("conf.general")
require("conf.keybinds")
require("conf.rules")
require("conf.plugins")

-- Noctalia theme (generated at ~/.config/hypr/noctalia.lua by its Hyprland
-- template). Optional so the config also loads before the theme exists.
local ok, noctalia = pcall(require, "noctalia")
if ok then
	noctalia.apply_theme()
end
