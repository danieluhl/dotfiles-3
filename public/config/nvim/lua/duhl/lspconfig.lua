-- SETUP MAPPINGS
local nnoremap = require("duhl.keymap").nnoremap

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
nnoremap("<leader>k", vim.diagnostic.open_float, opts)
-- nnoremap("<leader>[d", vim.diagnostic.goto_prev, opts)
-- nnoremap("<leader>]d", vim.diagnostic.goto_next, opts)
-- nnoremap("<space>q", vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	nnoremap("gD", vim.lsp.buf.declaration, bufopts)
	nnoremap("gd", vim.lsp.buf.definition, bufopts)
	nnoremap("<leader>gi", vim.lsp.buf.implementation, bufopts)
	nnoremap("<leader>gr", vim.lsp.buf.references, bufopts)
	-- nnoremap("<leader>k", vim.lsp.buf.hover, bufopts)
	nnoremap("<leader>sh", vim.lsp.buf.signature_help, bufopts)
	-- nnoremap("<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	-- nnoremap("<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	-- nnoremap("<leader>wl", function()
	-- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	-- end, bufopts)
	nnoremap("<leader>gt", vim.lsp.buf.type_definition, bufopts)
	nnoremap("<leader>rn", vim.lsp.buf.rename, bufopts)
	nnoremap("<leader>ca", vim.lsp.buf.code_action, bufopts)
	-- nnoremap("<leader>ff", vim.lsp.buf.format, bufopts)
end

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 150,
}

-- function to organize imports - replacing with typescript plugin
-- local function organize_imports()
-- 	local params = {
-- 		command = "_typescript.organizeImports",
-- 		arguments = { vim.api.nvim_buf_get_name(0) },
-- 		title = "",
-- 	}
-- 	vim.lsp.buf.execute_command(params)
-- end

-- SETUP LSPCONFIG
local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities =
vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

lspconfig.sumneko_lua.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "use", "vim", "actions" },
			},
		},
	},
	on_attach = on_attach,
})

lspconfig.eslint.setup({ on_attach = on_attach })

lspconfig.tailwindcss.setup({ on_attach = on_attach })

require("typescript").setup({
	-- disable_commands = false, -- prevent the plugin from creating Vim commands
	-- debug = false, -- enable debug logging for commands
	go_to_source_definition = {
		fallback = true, -- fall back to standard LSP definition on failure
	},
	server = { -- pass options to lspconfig's setup method
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			on_attach(client, bufnr)
		end,
	},
})

require("rust-tools").setup({
	server = {
		on_attach = function(_, bufnr)
			-- Hover actions
			vim.keymap.set("n", "<leader>h", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
	},
})

-- diagnostics global defaults
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	-- Disable underline, it's very annoying
	underline = true,
	virtual_text = true,
	-- Enable virtual text, override spacing to 4
	-- virtual_text = {spacing = 4},
	-- Use a function to dynamically turn signs off
	-- and on, using buffer local variables
	signs = true,
	-- update_in_insert = false,
})
