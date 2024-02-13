local lsp_zero = require("lsp-zero")
local lspconfig = require("lspconfig")
local cmp = require("cmp")

lsp_zero.extend_lspconfig()
lsp_zero.preset("recommended")

lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- diagnostics global defaults
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	virtual_text = true,
	signs = true,
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<Tab>"] = nil,
		["<S-Tab>"] = nil,
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
})

require("mason").setup()
require("mason-lspconfig").setup({
	handlers = {
		lsp_zero.default_setup,

		lua_ls = function()
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "it", "describe", "before_each", "after_each" },
						},
					},
				},
			})
		end,

		tsserver = function()
			lspconfig.tsserver.setup({
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
				single_file_support = false,
			})
		end,
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
