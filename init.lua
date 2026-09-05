-- Entry point.
-- Leader keys must be set before lazy.nvim loads, or plugin keymaps bind to the wrong prefix.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
