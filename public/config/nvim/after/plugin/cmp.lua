-- set completeopt = menu,menuone,noselect

-- Set up nvim-cmp.
local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/my-snippets" } })

cmp.setup({
	completion = {
		completeopt = "menu,menuone,noselect",
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		-- ["<esc>"] = cmp.mapping.close(),
		-- ["<C-e>"] = cmp.mapping.complete(),
		-- ["<C-e>"] = cmp.mapping.complete(),
		-- ["<C-e>"] = luasnip.expand(),

		-- ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<CR>"] = cmp.mapping.confirm({
			-- behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	},

	formatting = {
		fields = { "kind", "abbr", "menu" },
	},

	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
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
