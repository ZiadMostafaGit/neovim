return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- pulls a prebuilt fuzzy-matcher binary, no Rust toolchain needed
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      appearance = { nerd_font_variant = "mono" },
      keymap = {
        preset = "default", -- C-space open, C-n/C-p select, C-y accept, C-e hide
        -- Tab accepts a Copilot suggestion when one is showing, and otherwise
        -- behaves normally, so the two never fight over the key.
        ["<Tab>"] = {
          function()
            local ok, suggestion = pcall(require, "copilot.suggestion")
            if ok and suggestion.is_visible() then
              suggestion.accept()
              return true
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false }, -- Copilot owns the inline ghost text
        menu = { border = "rounded" },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      snippets = { preset = "default" }, -- native vim.snippet, fed by friendly-snippets
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { "dadbod", "snippets", "buffer" },
          mysql = { "dadbod", "snippets", "buffer" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- Copilot as inline ghost text, disabled until you ask for it with <leader>ua.
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = false, -- nothing appears until you toggle it on
        keymap = {
          accept = false, -- blink.cmp maps <Tab> to accept instead
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = { markdown = true, gitcommit = true },
    },
    keys = {
      {
        "<leader>ua",
        function()
          require("copilot.suggestion").toggle_auto_trigger()
          vim.notify(
            "Copilot " .. (vim.b.copilot_suggestion_auto_trigger and "enabled" or "disabled"),
            vim.log.levels.INFO
          )
        end,
        desc = "Toggle Copilot",
      },
    },
  },
}
