-- set completeopt = menu,menuone,noselect

-- Set up nvim-cmp.
local cmp = require("cmp")
local types = require("cmp.types")
local cmp_action = require('lsp-zero').cmp_action()
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/my-snippets" } })

-- SETUP CMP
cmp.setup({
	preselect = types.cmp.PreselectMode.None,
	mapping = cmp.mapping.preset.insert({
		['<C-n>'] = cmp_action.luasnip_jump_forward(),
		['<C-p>'] = cmp_action.luasnip_jump_backward(),
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
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
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
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "spell",   keyword_length = 5 },
		{ name = "path" },
	}),
	experimental = {
		ghost_text = true,
		native_menu = false,
	},
	enabled = function()
		-- disable when in a comment or in command mode
		if require("cmp.config.context").in_treesitter_capture("comment") == true
				or require("cmp.config.context").in_syntax_group("Comment")
				or vim.bo.buftype == "prompt"
		then
			return false
		else
			return true
		end
	end,
})
