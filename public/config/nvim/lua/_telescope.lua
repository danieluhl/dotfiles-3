require("telescope").setup({
	defaults = {
		file_sorter = require("telescope.sorters").get_fzy_sorter,
		promprt_prefix = " >",
		color_devicons = true,
		-- vimgrep_arguments = {
		-- 	"rg",
		-- 	"--color=never",
		-- 	"--no-heading",
		-- 	"--with-filename",
		-- 	"--line-number",
		-- 	"--column",
		-- 	"--smart-case",
		-- 	"-uu",
		-- },
		-- file_ignore_patterns = {
		-- 	"yarn.lock",
		-- 	"node_modules",
		-- 	"raycast",
		-- 	"dist",
		-- 	".git",
		-- },

		mapings = {
			i = {
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
	extensions = {
		fzy_native = {
			override_generic_sorter = false,
			override_file_sorter = true,
		},
	},
})
