-- lsp-zero does the wiring of lspconfig and cmp for you
local lspZero = require("lsp-zero")

lspZero.preset("recommended")
lspZero.ensure_installed({
	"tsserver",
	"eslint",
	"lua_ls",
	"rust_analyzer",
})

-- Fix Undefined global 'vim'
lspZero.configure("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "actions" },
			},
		},
	},
})

-- note: none of this seems to work, if you want key
-- bindings, do it in the remap file
local on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", "<Plug>ReplaceWithRegisterOperator", opts)
	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "<leader>gi", function()
		vim.lsp.buf.implementation()
	end, opts)
	vim.keymap.set("n", "<leader>gt", function()
		vim.lsp.buf.type_definition()
	end, opts)
	vim.keymap.set("n", "<leader>h", function()
		vim.lsp.buf.hover()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>k", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "K", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>ca", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap.set("n", "<leader>gr", function()
		vim.lsp.buf.references()
	end, opts)
	vim.keymap.set("n", "<leader>rn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
end

lspZero.configure("tsserver", {
	settings = {
		completions = {
			completeFunctionCalls = true,
		},
	},
	-- remove tsc formatting - use prettier instead
	-- on_attach = function(client, bufnr)
	--   client.server_capabilities.documentFormattingProvider = false
	--   client.server_capabilities.documentRangeFormattingProvider = false
	--   on_attach(client, bufnr)
	-- end,
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lspZero.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<C-y>"] = cmp.mapping.confirm({ select = true }),
	-- ["<Tab>"] = cmp.mapping.confirm({ select = true }),
	-- ["<S-Tab>"] = cmp.mapping.confirm({ select = true }),
	["<Tab>"] = nil,
	["<S-Tab>"] = nil,
	["<CR>"] = cmp.mapping.confirm({ select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lspZero.setup_nvim_cmp({
	mapping = cmp_mappings,
})

lspZero.set_preferences({
	suggest_lsp_servers = false,
	set_lsp_keymaps = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

lspZero.on_attach = on_attach

require("lspconfig").lua_ls.setup(lspZero.nvim_lua_ls())

lspZero.setup()

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
