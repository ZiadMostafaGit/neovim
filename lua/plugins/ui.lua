return {
  -- Dashboard, notifications, smooth scrolling, and large-file handling in one plugin.
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true }, -- disable syntax/LSP on huge files instead of hanging
      quickfile = { enabled = true }, -- render the file before plugins finish loading
      notifier = { enabled = true, timeout = 3000 },
      scroll = { enabled = true },
      input = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
    ███╗   ██╗██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██║   ██║██║████╗ ████║
    ██╔██╗ ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            { icon = " ", key = "f", desc = "Find file", action = ":FzfLua files" },
            { icon = " ", key = "g", desc = "Grep project", action = ":FzfLua live_grep" },
            { icon = " ", key = "r", desc = "Recent files", action = ":FzfLua oldfiles" },
            { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
            { icon = " ", key = "k", desc = "Keybinds", action = ":Cheatsheet" },
            { icon = " ", key = "s", desc = "Restore session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Plugins", action = ":Lazy" },
            { icon = " ", key = "m", desc = "Tooling", action = ":Mason" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
  },

  -- Statusline.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = {
          { "filename", path = 1 }, -- path relative to cwd, so you know which app/ you're in
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_x = {
          -- Show which Python interpreter the LSP is using; silent otherwise.
          {
            function()
              local path = require("config.venv").python_path()
              return " " .. vim.fn.fnamemodify(path, ":h:h:t")
            end,
            cond = function() return vim.bo.filetype == "python" end,
          },
          "encoding",
          "filetype",
        },
      },
    },
  },

  -- Render headings, code blocks, tables, and checkboxes as styled text in the buffer.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = { completions = { lsp = { enabled = true } } },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
    },
  },
}
