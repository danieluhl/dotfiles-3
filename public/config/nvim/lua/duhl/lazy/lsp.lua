return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",

		{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lua",
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
			config = function()
				require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/duhl/snips" })
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		"saadparwaiz1/cmp_luasnip",
	},
	config = function()
		--  LSP SETUP
		local lsp_zero = require("lsp-zero")
		lsp_zero.extend_lspconfig()
		local lspconfig = require("lspconfig")

		lsp_zero.preset("recommended")
		lsp_zero.on_attach(function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)
		lsp_zero.setup()

		-- other servers that don't need config
		lsp_zero.setup_servers({ "rust_analyzer", "astro", "htmx" })

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

		lspconfig.gleam.setup({})

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

		-- CMP SETUP
		local cmp = require("cmp")
		local types = require("cmp.types")
		local cmp_action = require("lsp-zero").cmp_action()
		local ls = require("luasnip")

		cmp.setup({
			preselect = types.cmp.PreselectMode.None,
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp_action.luasnip_jump_forward(),
				["<C-p>"] = cmp_action.luasnip_jump_backward(),
				["<Tab>"] = nil,
				["<S-Tab>"] = nil,
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			completion = {
				completeopt = "menu,menuone,noinsert,noselect",
			},
			snippet = {
				expand = function(args)
					ls.lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				fields = { "kind", "abbr", "menu" },
			},
			sources = cmp.config.sources({
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "spell", keyword_length = 5 },
				{ name = "path" },
			}),
			experimental = {
				ghost_text = true,
				native_menu = false,
			},
			enabled = function()
				-- disable when in a comment or in command mode
				if
					require("cmp.config.context").in_treesitter_capture("comment") == true
					or require("cmp.config.context").in_syntax_group("Comment")
					or vim.bo.buftype == "prompt"
				then
					return false
				else
					return true
				end
			end,
		})
	end,
}
