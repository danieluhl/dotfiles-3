-- lsp-zero does the wiring of lspconfig
local lsp_zero = require("lsp-zero")
local lspconfig = require("lspconfig")

lsp_zero.preset("recommended")

-- Fix Undefined global 'vim'
lsp_zero.configure("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "actions" },
			},
		},
	},
})

lsp_zero.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

lsp_zero.set_preferences({
	suggest_lsp_servers = false,
	set_lsp_keymaps = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

lsp_zero.setup()

-- SETUP SERVERS
lspconfig.tsserver.setup({
	on_attach = function(client, bufnr)
		client.resolved_capabilities.document_formatting = false
		on_attach(client, bufnr)
	end,
})
-- other servers that don't need config
lsp_zero.setup_servers({ "lua_ls", "rust_analyzer", "astro" })

require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = {},
	handlers = {
		lsp_zero.default_setup,
	},
})

vim.diagnostic.config({
	virtual_text = true,
})

-- diagnostics global defaults
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	-- Disable underline, it's very annoyinglsp
	underline = true,
	virtual_text = true,
	-- Enable virtual text, override spacing to 4
	-- virtual_text = {spacing = 4},
	-- Use a function to dynamically turn signs off
	-- and on, using buffer local variables
	signs = true,
	-- update_in_insert = false,
})
