local prettier = require("prettier")

prettier.setup({
	bin = "prettierd", -- or `'prettier'` (v0.22+)
	filetypes = {
		"css",
		"graphql",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"less",
		"markdown",
		"scss",
		"typescript",
		"typescriptreact",
		"yaml",
	},
	cli_options = {
		arrow_parens = "always",
		bracket_spacing = false,
		bracketSpacing = false,
		print_width = 80,
		tab_width = 2,
		trailing_comma = "es5",
		use_tabs = false,
	},
})
