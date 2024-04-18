return {
	"github/copilot.vim",
	config = function()
		-- use a key other than tab for completion
		vim.keymap.set("i", "<C-t>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		-- start with it disabled by default
		vim.g.copilot_enabled = false
	end,
}
