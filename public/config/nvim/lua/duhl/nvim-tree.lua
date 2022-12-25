-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
	sort_by = "case_sensitive",
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		debounce_delay = 50,
		icons = {
			hint = "⚡",
			info = "ℹ️",
			warning = "⚠️",
			error = "💢",
		},
	},
  view = {
		adaptive_size = true,
		mappings = {
			list = {
				{ key = "u", action = "dir_up" },
				{ key = "J", action = "expand" },
				{ key = "K", action = "expand" },
			},
		},
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = false,
	},
})

local events = require("nvim-tree.api").events.Event
events.Resize = 50


