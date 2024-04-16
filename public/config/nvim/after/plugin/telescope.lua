-- require("git-worktree").setup({})
-- require("telescope").load_extension("git_worktree")

-- local vimgrep_arguments = {
-- 	"rg",
-- 	"--color=never",
-- 	"--no-heading",
-- 	"--with-filename",
-- 	"--line-number",
-- 	"--column",
-- 	"--smart-case",
-- 	"-uu",
-- }
-- local find_command = { "rg", "--files", "--hidden" }
-- local file_ignore_patterns = {
-- 	"yarn.lock",
-- 	"node_modules/",
-- 	"raycast/",
-- 	"dist/",
-- 	".next/",
-- 	".git/",
-- 	"build/",
-- 	-- for rust builds
-- 	"target/",
-- }
-- local function find_files()
-- 	local telescope_builtin = require("telescope.builtin")

-- 	telescope_builtin.find_files({
-- 		find_command = find_command,
-- 		file_ignore_patterns = file_ignore_patterns,
-- 	})
-- end

-- local function find_files_all()
-- 	local telescope_builtin = require("telescope.builtin")

-- 	telescope_builtin.find_files({
-- 		find_command = find_command,
-- 		-- file_ignore_patterns = file_ignore_patterns,
-- 	})
-- end

-- local function live_grep()
-- 	local telescope_builtin = require("telescope.builtin")

-- 	telescope_builtin.live_grep({
-- 		-- vimgrep_arguments = vimgrep_arguments,
-- 		find_command = find_command,
-- 		file_ignore_patterns = file_ignore_patterns,
-- 	})
-- end

-- local function live_grep_all()
-- 	local telescope_builtin = require("telescope.builtin")

-- 	telescope_builtin.live_grep({
-- 		vimgrep_arguments = vimgrep_arguments,
-- 		find_command = find_command,
-- 	})
-- end

-- vim.api.nvim_create_user_command("UserTelescopeFindFiles", function()
-- 	find_files()
-- end, { desc = "Open fuzzy finder with telescope" })

-- vim.api.nvim_create_user_command("UserTelescopeFindFilesAll", function()
-- 	find_files_all()
-- end, { desc = "Find all files including gitignored" })

-- vim.api.nvim_create_user_command("UserTelescopeLiveGrepAll", function()
-- 	live_grep_all()
-- end, { desc = "Open fuzzy finder with telescope" })

-- vim.api.nvim_create_user_command("UserTelescopeLiveGrep", function()
-- 	live_grep()
-- end, { desc = "Grep code with telescope" })
