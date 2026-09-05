return {
  -- Fuzzy finder. Backed by the fzf binary, so it stays fast on large repos.
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      "default-title",
      winopts = { height = 0.85, width = 0.85, preview = { layout = "vertical", vertical = "down:45%" } },
      files = { formatter = "path.filename_first" }, -- filename first, directory dimmed after it
      grep = { rg_glob = true }, -- lets you type `foo --*.py` to scope a search
    },
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      fzf.register_ui_select() -- vim.ui.select prompts use the same picker
    end,
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep project" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
      { "<leader>fw", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Grep selection" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fb", "<cmd>FzfLua blines<cr>", desc = "Search in buffer" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
      { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
      { "<leader>fR", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
      { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Switch buffer" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics" },
      { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
    },
  },

  -- Edit the filesystem as if it were a buffer: rename with cw, delete with dd, :w to apply.
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
  },

  -- Project sidebar: git status colours, diagnostics, and file operations.
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true }, -- keep the tree in sync with the open buffer
        use_libuv_file_watcher = true, -- reflect changes made outside Neovim
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true },
      },
      window = {
        width = 32,
        mappings = { ["<space>"] = "none" }, -- do not swallow the leader key
      },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "✖",
            renamed = "󰁕", untracked = "", ignored = "",
            staged = "", unstaged = "󰄱", conflict = "",
          },
        },
      },
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Explorer (reveal current file)" },
      { "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Explorer (git status)" },
    },
  },

  -- Shows what keys are available after you press a prefix.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      -- Labels come from config.groups so which-key and the cheatsheet agree.
      spec = vim.tbl_map(function(prefix)
        return { prefix, group = require("config.groups")[prefix]:lower() }
      end, vim.tbl_keys(require("config.groups"))),
    },
  },

  -- Jump anywhere on screen by typing two characters plus a label.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
    },
  },

  -- ci" da( ysiw) and friends.
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Auto-close brackets and quotes.
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Highlight and list TODO/FIX/HACK/NOTE comments.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "<leader>st", "<cmd>TodoFzfLua<cr>", desc = "Todo comments" },
    },
  },

  -- A navigable list of diagnostics, references, and symbols.
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols outline" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },

  -- Project-wide find and replace with a live preview of every match.
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Find and replace (project)" },
    },
  },

  -- Browse and restore any past state of a file.
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo history" },
    },
  },

  -- Per-directory sessions. Restoring is manual, from here or the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
  },
}
