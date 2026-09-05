-- A browsable, categorised list of every keybind that has a description.
--
-- Built from the live keymap tables rather than a hand-written list, so it cannot
-- drift out of date: add or change a mapping anywhere and it shows up here.
local M = {}

local groups = require("config.groups")

-- Order sections appear in. Anything not listed is appended alphabetically.
local ORDER = {
  "Find", "Git", "Code / LSP", "Diagnostics", "Search", "Buffer", "Window",
  "Toggle", "REST client", "Session / quit", "Leader — other", "Global keys",
}

-- Ordered, so mode tags always read the same way. "v" is omitted deliberately:
-- nvim_get_keymap("v") and ("x") each return the other's mappings, so querying
-- both would tag every visual binding twice.
local MODES = {
  { mode = "n", label = "n" },
  { mode = "i", label = "i" },
  { mode = "x", label = "v" },
  { mode = "o", label = "o" },
  { mode = "t", label = "t" },
}

-- Descriptions that are noise rather than a feature you would look up.
local function uninteresting(lhs, desc)
  return lhs:match("^<Plug>")
    or lhs:match("^<SNR>")
    -- Built-in Vim keys whose description is just a help-tag pointer (`&`, `Y`,
    -- `i_CTRL-W`): the line would carry no information the key does not already give.
    or desc:match("^:help .*%-default$")
end

-- Turn the raw lhs into what a user would actually type.
local function readable(lhs)
  local leader = vim.g.mapleader or " "
  if lhs:sub(1, #leader) == leader then
    lhs = "<leader>" .. lhs:sub(#leader + 1)
  end
  -- Neovim escapes a literal `<` as `<lt>`, which reads as a key name it is not.
  return (lhs:gsub("<lt>", "<"))
end

---@param buf integer buffer whose local maps (LSP, gitsigns) should be included
local function collect(buf)
  local seen = {}
  for _, entry in ipairs(MODES) do
    local lists = {
      vim.api.nvim_get_keymap(entry.mode),
      vim.api.nvim_buf_get_keymap(buf, entry.mode),
    }
    for _, list in ipairs(lists) do
      for _, map in ipairs(list) do
        local desc = map.desc or ""
        if desc ~= "" and not uninteresting(map.lhs, desc) then
          local lhs = readable(map.lhs)
          local key = lhs .. "\0" .. desc
          if seen[key] then
            if not vim.tbl_contains(seen[key].modes, entry.label) then
              table.insert(seen[key].modes, entry.label)
            end
          else
            seen[key] = { lhs = lhs, desc = desc, modes = { entry.label } }
          end
        end
      end
    end
  end
  return vim.tbl_values(seen)
end

local function section_of(lhs)
  if lhs:sub(1, 8) ~= "<leader>" then
    return "Global keys"
  end
  return groups["<leader>" .. lhs:sub(9, 9)] or "Leader — other"
end

-- Build the display lines plus the highlights to apply to them.
---@param win_width integer used to truncate descriptions that would be clipped
local function render(entries, win_width)
  local sections = {}
  local width, tag_width = 0, 1
  for _, entry in ipairs(entries) do
    local name = section_of(entry.lhs)
    sections[name] = sections[name] or {}
    table.insert(sections[name], entry)
    width = math.max(width, #entry.lhs)
    tag_width = math.max(tag_width, #table.concat(entry.modes))
  end

  local names = vim.tbl_keys(sections)
  table.sort(names, function(a, b)
    local ia = vim.fn.index(ORDER, a)
    local ib = vim.fn.index(ORDER, b)
    -- Unlisted sections sort after listed ones, then alphabetically.
    if ia == ib then return a < b end
    if ia == -1 then return false end
    if ib == -1 then return true end
    return ia < ib
  end)

  local lines, highlights = {}, {}
  local function add(text, hl, col_start, col_end)
    table.insert(lines, text)
    if hl then
      table.insert(highlights, { #lines - 1, col_start or 0, col_end or -1, hl })
    end
  end

  add("  Keybinds active here", "Title")
  add("  / search · q close · <leader>fk fuzzy-search everything", "Comment")

  for _, name in ipairs(names) do
    local entries_in_section = sections[name]
    table.sort(entries_in_section, function(a, b) return a.lhs < b.lhs end)

    add("")
    add("  " .. name:upper(), "Title")

    for _, entry in ipairs(entries_in_section) do
      -- Only note the mode when it is not plain normal mode, to keep the noise down.
      local modes = table.concat(entry.modes)
      local tag = ("%-" .. tag_width .. "s"):format(modes == "n" and "" or modes)
      local key = ("%-" .. width .. "s"):format(entry.lhs)

      -- Wrapping would break the columns, so clip over-long descriptions instead
      -- of letting the window cut them off mid-word with no indication.
      local room = win_width - (2 + tag_width + 2 + width + 2) - 1
      local desc = entry.desc
      if room > 1 and #desc > room then
        desc = desc:sub(1, room - 1) .. "…"
      end
      local text = ("  %s  %s  %s"):format(tag, key, desc)

      table.insert(lines, text)
      local row = #lines - 1
      local key_start = 2 + tag_width + 2
      table.insert(highlights, { row, 2, 2 + tag_width, "Comment" }) -- mode tag
      table.insert(highlights, { row, key_start, key_start + width, "Identifier" })
    end
  end

  return lines, highlights
end

function M.open()
  -- Capture buffer-local maps from where the user actually is: LSP and gitsigns
  -- bindings only exist on an attached buffer, not on the scratch buffer below.
  local origin = vim.api.nvim_get_current_buf()
  local win_width = math.min(90, vim.o.columns - 4)
  local lines, highlights = render(collect(origin), win_width)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("cheatsheet")
  for _, hl in ipairs(highlights) do
    local row, col_start, col_end, group = unpack(hl)
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, col_start, {
      end_col = col_end == -1 and #lines[row + 1] or math.min(col_end, #lines[row + 1]),
      hl_group = group,
    })
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "cheatsheet"
  vim.bo[buf].buftype = "nofile"

  local height = math.min(#lines, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - win_width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Keybinds ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, silent = true })
  end
end

return M
