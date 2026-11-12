local o = vim.o

-- Line numbers
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- reserve the gutter so text never shifts when diagnostics appear
o.cursorline = true

-- Indentation. Per-filetype widths live in config/autocmds.lua; these are the fallback.
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true -- a capital letter in the pattern makes the search case-sensitive
o.inccommand = "split" -- live preview of :s substitutions

-- Splits open where you expect them
o.splitright = true
o.splitbelow = true

-- System clipboard (wl-copy on Linux, win32yank on Windows)
o.clipboard = "unnamedplus"

-- UI
o.termguicolors = true
o.winborder = "rounded" -- native 0.11+ default border for every float
o.scrolloff = 8
o.wrap = false
o.showmode = false -- lualine already shows the mode
o.laststatus = 3 -- one global statusline instead of one per split
o.pumheight = 10
o.confirm = true -- prompt to save instead of failing on :q with unsaved changes

-- Timing
o.updatetime = 200
o.timeoutlen = 400

-- Files
o.swapfile = false
o.undofile = true -- undo history survives restarts; cheap and hard to regret

-- Fish is not POSIX and breaks plugin subprocesses. Neovim uses bash internally;
-- :terminal and tmux still give you fish. Windows has no /bin/bash, so keep the
-- default cmd.exe there: plugins expect it.
if vim.fn.has("win32") == 0 then
  o.shell = "/bin/bash"
end

-- Diagnostics: full message on its own line, but only for the line under the cursor.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = { current_line = true },
  underline = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = { border = "rounded", source = true },
})
