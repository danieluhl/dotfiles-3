-- vim.cmd("colorscheme night-owl")
-- vim.cmd("colorscheme gruvbox")

require("nightfox").setup({
  options = {
    -- Compiled file's destination location
    compile_path = vim.fn.stdpath("cache") .. "/nightfox",
    compile_file_suffix = "_compiled", -- Compiled file suffix
    transparent = false, -- Disable setting background
    terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
    dim_inactive = false, -- Non focused panes set to alternative background
    module_default = true, -- Default enable value for modules
    styles = { -- Style to be applied to different syntax groups
      comments = "italic", -- Value is any valid attr-list value `:help attr-list`
      conditionals = "NONE",
      constants = "NONE",
      functions = "italic",
      keywords = "NONE",
      numbers = "NONE",
      operators = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "italic",
    },
    inverse = { -- Inverse highlight for different types
      match_paren = false,
      visual = false,
      search = false,
    },
  },
  palettes = {},
  -- specs = {},
  groups = {

    duskfox = {
      -- Normal = { bg = "none" },
      -- NvimTreeNormal = { bg = "none" },
      -- NormalFloat = { bg = "none" },
    },
  },
})

vim.cmd("colorscheme duskfox")
-- bg3 in duskfox
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#191726" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#232136" })
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#ffffff" })

-- vim.api.nvim_set_hl(0, "LineNr", { fg = palette.fg3 })
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = palette.bg3 })
-- vim.api.nvim_set_hl(0, "Comment", { italic = true, fg = palette.comment })
-- vim.api.nvim_set_hl(0, "Identifier", { italic = true, fg = palette.cyan })
-- vim.api.nvim_set_hl(0, "Constant", { italic = true, fg = palette.magenta })
-- vim.api.nvim_set_hl(0, "Keyword", { italic = true, fg = palette.magenta })
