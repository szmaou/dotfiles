package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path

require("conf.variables")
require("conf.execs")
require("conf.general")
require("conf.keybinds")
require("conf.rules")
require("conf.plugins")
