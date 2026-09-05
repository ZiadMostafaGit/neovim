return {
  -- Hunk-level git in the gutter: stage, reset, preview, and blame without leaving the buffer.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = buffer, desc = desc })
        end

        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        map({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk")
        map({ "n", "v" }, "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.blame, "Blame file")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle inline blame")
        map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<cr>", "Select hunk")
      end,
    },
  },

  -- lazygit in a floating window, themed to match. Provided by snacks.nvim,
  -- which is already loaded for the dashboard, so this costs no extra plugin.
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit (log)" },
      { "<leader>gL", function() Snacks.lazygit.log_file() end, desc = "Lazygit (file history)" },
    },
  },

  -- Git pickers. <leader>gf is the changed-files search you asked for.
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>gf", "<cmd>FzfLua git_status<cr>", desc = "Changed files" },
      {
        "<leader>gG",
        function()
          -- Grep restricted to files this branch has touched, rather than the whole tree.
          local files = vim.fn.systemlist({ "git", "diff", "--name-only", "HEAD" })
          if vim.v.shell_error ~= 0 or #files == 0 then
            vim.notify("No changed files to search", vim.log.levels.WARN)
            return
          end
          require("fzf-lua").live_grep({ search_paths = files })
        end,
        desc = "Grep changed files",
      },
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits (project)" },
      { "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Commits (this file)" },
      { "<leader>gh", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
      { "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Stashes" },
    },
  },
}
