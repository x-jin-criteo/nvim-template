return {
  "craftzdog/solarized-osaka.nvim",
  name = "solarized-osaka",
  lazy = false,
  priority = 1000,
  opts = {
    -- configuration options...
    transparent = true,
    terminal_colors = true,
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "dark", -- style for sidebars, see below
      floats = "normal", -- style for floating windows
    },
    sidebars = { "qf", "help" },
    hide_inactive_statusline = false,
    dim_inactive = false,
    lualine_bold = false,
    on_colors = function(colors)
      -- 1 & 2. Change orange from being close to red error color
      -- to a more distinguishable purple
      colors.orange = "#8a6bde"
      colors.orange500 = "#8a6bde"
      -- 3. Make white more grey-tinted to reduce eye strain
      colors.base0 = "#aab5b9"
      colors.fg = "#aab5b9"
      -- 4. Make string color different from functions
      colors.cyan500 = "#2aa198"
      -- Modify the Background colors for UI components
      colors.bg_sidebar = "#002129"
      colors.bg_float = "#002730"
      colors.bg_highlight = "#33d6ff"
      colors.bg_statusline = "#33d6ff"
    end,
    on_highlights = function(highlights, colors)
      -- Change Special (used for parameters and special symbols)
      highlights.Special = { fg = colors.orange }

      -- Ensure strings have their own distinct color
      highlights.String = { fg = colors.cyan500 }
      highlights.CursorLine = { bg = "#002638" }
      highlights.Visual = { bg = "#113b4f" }
    end,
  },
}
