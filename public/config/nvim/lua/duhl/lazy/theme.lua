-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	opts = {},
-- 	config = function()
-- 		vim.cmd([[colorscheme tokyonight-moon]])
-- 	end,
-- }

-- return {
-- 	"ayu-theme/ayu-vim",
-- 	-- name = "ayu",
-- 	config = function()
-- 	  vim.cmd("let ayucolor='dark'"),
-- 		vim.cmd("colorscheme ayu"),
-- 	end,
-- }

return {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
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
		})
		vim.cmd("colorscheme rose-pine-moon")
	end,
}
