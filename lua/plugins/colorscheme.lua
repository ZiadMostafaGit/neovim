-- Your theme, carried over as-is. Only the LazyVim block was dropped (this config
-- does not use LazyVim); the colorscheme is applied directly instead.
return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000, -- load before everything else so no plugin renders unstyled
    opts = {
      options = {
        hide_end_of_buffer = true,
        transparent = false,
        terminal_colors = true,
        dim_inactive = false,
        styles = {
          comments = "italic",
          keywords = "italic",
        },
        darken = {
          floats = true,
          sidebars = {
            enable = true,
            list = {},
          },
        },
      },
      palettes = {
        all = {
          red = "#ff7b72",
        },
        github_dark_default = {
          -- Push the background down to a really-dark near-black
          bg0 = "#0d1117",
          bg1 = "#010409",
          bg2 = "#010409",
          bg3 = "#010409",
          bg4 = "#010409",
        },
      },
      groups = {
        all = {
          Normal = { bg = "#010409" },
          NormalFloat = { bg = "#0d1117" },
          SignColumn = { bg = "#010409" },
          LineNr = { bg = "#010409", fg = "#484f58" },
          WinSeparator = { fg = "#30363d", bg = "none" },
          FloatBorder = { bg = "#0d1117" },
          Pmenu = { bg = "#0d1117" },
          PmenuSel = { bg = "#21262d" },
        },
      },
    },
    config = function(_, opts)
      require("github-theme").setup(opts)
      vim.cmd.colorscheme("github_dark_default")
    end,
  },
}
