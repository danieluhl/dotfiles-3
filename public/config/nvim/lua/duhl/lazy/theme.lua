return {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
		local palette = require("rose-pine.palette")
		require("rose-pine").setup({
			dark_variant = "moon",
			styles = {
				bold = true,
				italic = true,
				transparency = true,
			},
			palette = {
				-- Override the builtin palette per variant
				moon = {
					base = "#18191a",
					overlay = "#363738",
				},
			},
			highlight_groups = {
				-- RECIPES https://github.com/rose-pine/neovim/wiki/Recipes
				Visual = { bg = palette.iris, blend = 25 },
				Search = { bg = palette.gold, blend = 40 },
				IncSearch = { bg = palette.gold, blend = 40 },
				CurSearch = { bg = palette.gold, blend = 90 },
				-- StatusLine = { fg = "love", bg = "love", blend = 10 },
				-- StatusLineNC = { fg = "subtle", bg = "surface" },
				-- TelescopeBorder = { fg = "highlight_high", bg = "none" },
				-- TelescopeNormal = { bg = "none" },
				-- TelescopePromptNormal = { bg = "base" },
				-- TelescopeResultsNormal = { fg = "subtle", bg = "none" },
				-- TelescopeSelection = { fg = "text", bg = "base" },
				-- TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
			},
		})
		vim.cmd("colorscheme rose-pine-moon")
	end,
}
