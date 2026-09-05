-- Locate the Python interpreter a project actually uses, so basedpyright resolves
-- Django/FastAPI imports instead of flagging every one of them as missing.
local M = {}

-- Set by M.select() to override auto-detection for the current session.
M.override = nil

local candidates = { ".venv", "venv", "env" }

---@param root string|nil project root; falls back to cwd
---@return string interpreter absolute path to a python executable
function M.python_path(root)
  if M.override then
    return M.override
  end
  -- An already-activated venv wins: it is what the user explicitly chose.
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  root = root or vim.fn.getcwd()
  for _, dir in ipairs(candidates) do
    local python = root .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end
  return vim.fn.exepath("python3")
end

-- Pick a venv by hand for the projects that keep it somewhere unusual.
function M.select()
  local roots = { vim.fn.getcwd(), vim.fn.expand("~/.virtualenvs"), vim.fn.expand("~/.local/share/uv") }
  local found = {}
  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      local out = vim.fn.systemlist({
        "fd", "--hidden", "--no-ignore", "--type", "x", "--max-depth", "4",
        "--full-path", "bin/python$", ".", root,
      })
      if vim.v.shell_error == 0 then
        vim.list_extend(found, out)
      end
    end
  end
  if #found == 0 then
    vim.notify("No virtualenvs found. Create one with:  uv venv", vim.log.levels.WARN)
    return
  end
  require("fzf-lua").fzf_exec(found, {
    prompt = "Venv> ",
    actions = {
      ["default"] = function(selected)
        M.override = selected[1]
        vim.notify("Using " .. M.override, vim.log.levels.INFO)
        -- Restart so the language server picks up the new interpreter.
        for _, client in ipairs(vim.lsp.get_clients({ name = "basedpyright" })) do
          client:stop()
        end
        vim.defer_fn(function() vim.cmd("edit") end, 500)
      end,
    },
  })
end

return M
