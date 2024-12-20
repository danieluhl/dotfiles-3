return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"tsx",
				"typescript",
				"javascript",
				"markdown",
				"lua",
				"rust",
				"toml",
				"go",
				"ocaml",
				"astro",
				"gleam",
			},
			-- highlight = {
			-- 	enable = {
			-- 		"tsx",
			-- 		"typescript",
			-- 		"javascript",
			-- 		"markdown",
			-- 		"lua",
			-- 		"rust",
			-- 		"toml",
			-- 		"go",
			-- 		"ocaml",
			-- 		"astro",
			-- 	},
			-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
			-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
			-- Using this option may slow down your editor, and you may see some duplicate highlights.
			-- Instead of true it can also be a list of languages
			-- additional_vim_regex_highlighting = false,
			-- },
		})
	end,
}
