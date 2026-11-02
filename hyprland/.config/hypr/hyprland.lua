package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path

require("conf.execs")
require("conf.general")
require("conf.keybinds")
require("conf.rules")
require("conf.plugins")

-- Noctalia theme (generated at ~/.config/hypr/noctalia.lua). The literal
-- require("noctalia") call also stops Noctalia's hook from appending a
-- duplicate include on later theme applies.
local ok, noctalia = pcall(function()
	return require("noctalia")
end)
if ok then
	noctalia.apply_theme()
end
