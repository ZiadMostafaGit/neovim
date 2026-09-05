return {
  -- Query PostgreSQL from a buffer, browse schemas in a sidebar, and get completion
  -- for your own table and column names.
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      -- Saved queries live in the config dir rather than scattered around projects.
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
  },

  -- REST client. Write requests in a .http file, run them, read the response in a split.
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {
      global_keymaps = false,
      default_view = "body",
      formatters = { json = { "jq", "." } },
    },
    keys = {
      { "<leader>Rs", function() require("kulala").run() end, ft = "http", desc = "Send request" },
      { "<leader>Ra", function() require("kulala").run_all() end, ft = "http", desc = "Send all requests" },
      { "<leader>Rr", function() require("kulala").replay() end, ft = "http", desc = "Replay last request" },
      { "<leader>Rt", function() require("kulala").toggle_view() end, ft = "http", desc = "Toggle body/headers" },
      { "<leader>Re", function() require("kulala").set_selected_env() end, ft = "http", desc = "Select environment" },
    },
  },
}
