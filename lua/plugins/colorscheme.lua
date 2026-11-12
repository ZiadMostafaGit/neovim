-- Tokyo Night, "night" variant (the darkest of its styles).
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- load before everything else so no plugin renders unstyled
    opts = {
      style = "night", -- storm | moon | night | day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
      dim_inactive = false,
      lualine_bold = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}
