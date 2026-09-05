-- Treesitter on the `main` branch: the `master` branch is frozen and no longer the
-- supported path on Neovim 0.11+. Highlighting is enabled per-buffer rather than
-- through the old `configs.setup({ highlight = ... })` entry point.
local parsers = {
  "bash", "c", "cpp", "css", "diff", "dockerfile", "git_config", "git_rebase",
  "gitcommit", "gitignore", "go", "gomod", "gosum", "gowork", "html", "http", "javascript",
  "json", "lua", "luadoc", "markdown", "markdown_inline", "python", "query",
  "regex", "requirements", "rust", "sql", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install only what is missing, so startup stays fast after the first run.
      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local missing = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
      end, parsers)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          -- Fails harmlessly for filetypes whose parser is not installed.
          if lang and pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Select and jump by syntax node: vaf takes a whole function, cif rewrites its body.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

      local select = require("nvim-treesitter-textobjects.select")
      local textobjects = {
        ["af"] = "@function.outer", ["if"] = "@function.inner",
        ["ac"] = "@class.outer", ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer", ["il"] = "@loop.inner",
      }
      for key, query in pairs(textobjects) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Textobject " .. query })
      end

      local move = require("nvim-treesitter-textobjects.move")
      local motions = {
        ["]f"] = { move.goto_next_start, "@function.outer", "Next function" },
        ["[f"] = { move.goto_previous_start, "@function.outer", "Previous function" },
        ["]]"] = { move.goto_next_start, "@class.outer", "Next class" },
        ["[["] = { move.goto_previous_start, "@class.outer", "Previous class" },
      }
      for key, spec in pairs(motions) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          spec[1](spec[2], "textobjects")
        end, { desc = spec[3] })
      end
    end,
  },
}
