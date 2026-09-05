local map = vim.keymap.set

-- Escape without leaving the home row. Esc still works.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save from any mode, the way every other editor does.
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr><Esc>", { desc = "Save file" })

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window splits and sizing.
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Grow window" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shrink window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrow window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Widen window" })

-- Buffers. With no tab bar, these plus <leader>, are how you move between files.
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })

-- Keep the cursor centred while scrolling and jumping between search matches.
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Previous match" })

-- Move the selected lines up and down, reindenting as they go.
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Stay in visual mode when indenting, so you can repeat it.
map("v", "<", "<gv", { desc = "Outdent" })
map("v", ">", ">gv", { desc = "Indent" })

-- Paste over a selection without clobbering the yank register with the replaced text.
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Quickfix.
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })

-- Diagnostics. ]d and [d are Neovim defaults; this adds the readable float.
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Custom modules.
map("n", "<leader>r", function() require("config.run").run() end, { desc = "Run current file" })
map("n", "<leader>o", function() require("config.links").pick() end, { desc = "Open bookmark" })
map("n", "<leader>cv", function() require("config.venv").select() end, { desc = "Select Python venv" })

-- Smart open: URL under the cursor goes to the browser, a file path opens here.
local smart_open = function() require("config.open").smart_open() end
map("n", "gx", smart_open, { desc = "Open path or URL under cursor" })
map("n", "<leader>gx", smart_open, { desc = "Open path or URL under cursor" })

map("n", "<leader>qq", "<cmd>qall<cr>", { desc = "Quit all" })

-- Browsable list of every described keybind, generated from the live keymaps.
vim.api.nvim_create_user_command("Cheatsheet", function()
  require("config.cheatsheet").open()
end, { desc = "Show all keybinds" })
map("n", "<leader>?", "<cmd>Cheatsheet<cr>", { desc = "All keybinds (cheatsheet)" })
