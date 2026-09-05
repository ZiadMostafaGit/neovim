-- Compile and run the current file in a split terminal. Deliberately small:
-- anything more involved belongs in a tmux pane.
local M = {}

local out = "/tmp/nvim-run-out"

-- Each entry returns the shell command for the given file.
local commands = {
  python = function(file)
    return vim.fn.shellescape(require("config.venv").python_path()) .. " " .. file
  end,
  cpp = function(file)
    return ("g++ -std=c++23 -O2 -Wall -Wextra -DLOCAL -o %s %s && %s"):format(out, file, out)
  end,
  c = function(file)
    return ("gcc -std=c17 -O2 -Wall -Wextra -o %s %s && %s"):format(out, file, out)
  end,
  go = function(file)
    return "go run " .. file
  end,
  rust = function(file)
    -- Inside a cargo project, running the single file would miss its dependencies.
    if vim.fs.root(0, "Cargo.toml") then
      return "cargo run"
    end
    return ("rustc -o %s %s && %s"):format(out, file, out)
  end,
  lua = function(file)
    return "lua " .. file
  end,
  sh = function(file)
    return "bash " .. file
  end,
  bash = function(file)
    return "bash " .. file
  end,
  javascript = function(file)
    return "node " .. file
  end,
  typescript = function(file)
    return "npx tsx " .. file
  end,
}

function M.run()
  local ft = vim.bo.filetype
  local build = commands[ft]
  if not build then
    vim.notify("No run command for filetype: " .. (ft == "" and "none" or ft), vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! write")
  local cmd = build(vim.fn.shellescape(vim.fn.expand("%:p")))

  vim.cmd("botright 15split")
  vim.cmd.terminal(cmd)
  vim.bo.buflisted = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
end

return M
