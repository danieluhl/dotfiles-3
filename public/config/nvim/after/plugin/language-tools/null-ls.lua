require("mason").setup()
require("mason-null-ls").setup({
	ensure_installed = {
		-- Opt to list sources here, when available in mason.
	},
	automatic_installation = false,
	automatic_setup = true, -- Recommended, but optional
})
local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
-- local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion
-- local code_actions = null_ls.builtins.code_actions
null_ls.setup({
	sources = {
		-- lua
		formatting.stylua,

		-- snippets
		completion.luasnip,

		-- JS
		-- diagnostics.eslint,
		-- formatting.eslint,
		-- code_actions.eslint,
		formatting.prettierd,
		-- require("typescript.extensions.null-ls.code-actions"),
		-- diagnostics.tsc,
		-- JSON
		formatting.fixjson,
		-- diagnostics.jsonlint,

		-- YAML
		-- diagnostics.yamllint,

		-- CSS
		-- formatting.eslint,
		-- diagnostics.stylelint,
		-- Tailwind CSS
		-- formatting.rustywind,

		-- Python
		formatting.black,
		-- diagnostics.flake8,

		-- Kotlin
		formatting.ktlint,
		-- diagnostics.ktlint,

		-- Markdown
		-- diagnostics.markdownlint,
		-- code_actions.proselint,
		-- diagnostics.codespell,

		-- RUST
		formatting.rustfmt,
	},
})

require("mason-null-ls").setup_handlers()
