return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		vim.cmd([[colorscheme tokyonight-moon]])
	end,
}

-- return {
-- 	"ayu-theme/ayu-vim",
-- 	-- name = "ayu",
-- 	config = function()
-- 	  vim.cmd("let ayucolor='dark'"),
-- 		vim.cmd("colorscheme ayu"),
-- 	end,
-- }

-- return {
-- 	"rose-pine/neovim",
-- 	name = "rose-pine",
-- 	config = function()
-- 		require("rose-pine").setup({
-- 			vim.cmd("colorscheme rose-pine"),
-- 		})
-- 	end,
-- }
