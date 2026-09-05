-- Language servers, configured with the native vim.lsp.config()/vim.lsp.enable() API.
-- The old `require("lspconfig").<server>.setup{}` call is deprecated on Neovim 0.11+;
-- nvim-lspconfig is here purely to supply the per-server defaults it ships in lsp/.

-- Mason package names (not language-server names) for everything installed on first run.
local tools = {
  -- Language servers
  "basedpyright", "ruff", "gopls", "rust-analyzer", "vtsls", "clangd",
  "html-lsp", "css-lsp", "json-lsp", "yaml-language-server",
  "dockerfile-language-server", "lua-language-server", "bash-language-server", "taplo",
  -- Formatters
  "stylua", "prettier", "clang-format", "goimports", "shfmt", "sql-formatter",
}

-- Language-server names to enable.
local servers = {
  "basedpyright", "ruff", "gopls", "rust_analyzer", "vtsls", "clangd",
  "html", "cssls", "jsonls", "yamlls", "dockerls", "lua_ls", "bashls", "taplo",
}

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  -- Installs everything in `tools` on first launch, unattended.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = tools,
      run_on_start = true,
      start_delay = 1000, -- let the UI settle before downloading
    },
  },

  { "b0o/schemastore.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "b0o/schemastore.nvim", "saghen/blink.cmp" },
    config = function()
      -- Advertise the completion capabilities blink.cmp adds, for every server.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Point basedpyright at the project's own interpreter, or Django/FastAPI
      -- imports resolve against the system Python and every one of them goes red.
      vim.lsp.config("basedpyright", {
        -- Set in on_init, not before_init: Client.create() copies config.settings
        -- before before_init ever runs, so assigning there is silently dropped.
        on_init = function(client)
          client.settings = vim.tbl_deep_extend("force", client.settings, {
            python = { pythonPath = require("config.venv").python_path(client.root_dir) },
          })
          -- The automatic didChangeConfiguration has already been sent by this point.
          client:notify("workspace/didChangeConfiguration", { settings = client.settings })
        end,
        settings = {
          basedpyright = {
            typeCheckingMode = "standard",
            analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true },
          },
        },
      })

      -- Ruff lints and formats; basedpyright owns hover, so silence Ruff's version.
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            hint = { enable = true },
            diagnostics = { globals = { "vim", "Snacks" } },
          },
        },
      })

      -- SchemaStore gives JSON and YAML real validation and completion, including
      -- GitHub Actions workflows, docker-compose, and pyproject.toml adjacent files.
      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim supplies these instead
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--fallback-style=llvm",
        },
      })

      vim.lsp.enable(servers)

      -- Buffer-local keymaps, set only once a server actually attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Neovim 0.11+ already provides grn (rename), gra (code action),
          -- grr (references), gri (implementation), gO (symbols), K (hover).
          map("gd", "<cmd>FzfLua lsp_definitions<cr>", "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gy", "<cmd>FzfLua lsp_typedefs<cr>", "Go to type definition")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>uh", function()
              local filter = { bufnr = event.buf }
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
            end, "Toggle inlay hints")
          end
        end,
      })
    end,
  },
}
