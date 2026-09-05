local augroup = vim.api.nvim_create_augroup("ziad", { clear = true })

-- Briefly highlight yanked text so you can see what got copied.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Restore the cursor to where you left off in a file.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Per-language indentation. Each ecosystem's own convention, so files look right to
-- everyone else. A project's .editorconfig overrides all of this.
local indents = {
  [2] = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "jsonc",
          "yaml", "html", "css", "scss", "lua", "markdown", "sql", "toml", "http" },
  [4] = { "python", "cpp", "c", "rust", "sh", "bash" },
}
for width, filetypes in pairs(indents) do
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = filetypes,
    callback = function()
      vim.bo.shiftwidth = width
      vim.bo.tabstop = width
      vim.bo.softtabstop = width
    end,
  })
end

-- gofmt mandates real tabs.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "go", "gomod", "gowork" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

-- Soft-wrap prose rather than letting it run off screen.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true -- wrap at word boundaries, not mid-word
  end,
})

-- q closes throwaway windows, so you never have to remember :bd for a help buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "query" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Warn once about system binaries Neovim cannot install for itself (they need sudo).
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  once = true,
  callback = function()
    local missing = {}
    for _, bin in ipairs({ "git", "rg", "fd", "fzf", "lazygit", "node", "gcc", "unzip" }) do
      if vim.fn.executable(bin) == 0 then
        table.insert(missing, bin)
      end
    end
    if #missing > 0 then
      vim.notify(
        "Missing system dependencies: " .. table.concat(missing, ", ") ..
        "\nInstall with:  sudo pacman -S " .. table.concat(missing, " "),
        vim.log.levels.WARN,
        { title = "nvim setup" }
      )
    end
  end,
})
