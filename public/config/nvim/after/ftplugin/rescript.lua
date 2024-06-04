vim.api.nvim_create_autocmd({
	"BufNewFile",
	"BufRead",
}, {
	pattern = "*.res,*.resi",
	callback = function()
		vim.keymap.set("n", "<leader>f", ":Rescriptformat<cr>")
		vim.keymap.set("n", "<leader>th", ":RescriptTypeHint<cr>")
		vim.keymap.set("n", "gd", ":RescriptJumpToDefinition<cr>")
		vim.keymap.set("n", "<leader>b", ":RescriptBuild<cr>")
	end,
})
