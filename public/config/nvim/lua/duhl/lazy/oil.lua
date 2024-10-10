return {
	"stevearc/oil.nvim",
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	opts = {},
	config = function()
		require("oil").setup({
			delete_to_trash = true,
			keymaps = {
				["<leader>e"] = "actions.close",
			},
		})
	end,
}
