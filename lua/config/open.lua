-- One key that inspects whatever is under the cursor: a URL opens in the browser,
-- a file path opens in Neovim. Handles config files that reference other files,
-- like `source = ~/.config/hypr/keybinds.conf`.
local M = {}

local URL_PATTERN = "%a[%w+.-]*://[%w-_.~:/?#%[%]@!$&'()*+,;=%%]+"

-- Returns the URL under the cursor, or nil. Matches only when the cursor is
-- actually inside the URL, so a link elsewhere on the line does not hijack the key.
local function url_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local from = 1
  while true do
    local start, stop = line:find(URL_PATTERN, from)
    if not start then
      return nil
    end
    if col >= start and col <= stop then
      return line:sub(start, stop)
    end
    from = stop + 1
  end
end

-- Resolve a possibly-relative, possibly-abbreviated path against the places it
-- could plausibly be: as written, relative to the current file, relative to cwd.
local function resolve_path(raw)
  if raw == "" then
    return nil
  end
  local expanded = vim.fn.expand(raw) -- handles ~, $HOME, $XDG_CONFIG_HOME
  local bases = { "", vim.fn.expand("%:p:h") .. "/", vim.fn.getcwd() .. "/" }
  for _, base in ipairs(bases) do
    local path = expanded:sub(1, 1) == "/" and expanded or base .. expanded
    if vim.uv.fs_stat(path) then
      return vim.fn.fnamemodify(path, ":p")
    end
  end
  return nil
end

function M.smart_open()
  local url = url_under_cursor()
  if url then
    vim.ui.open(url)
    vim.notify("Opening " .. url, vim.log.levels.INFO)
    return
  end

  local raw = vim.fn.expand("<cfile>")
  local path = resolve_path(raw)
  if path then
    vim.cmd.edit(vim.fn.fnameescape(path))
    return
  end

  vim.notify(
    raw ~= "" and ("Not a URL, and no such file: " .. raw) or "Nothing under the cursor",
    vim.log.levels.WARN
  )
end

return M
