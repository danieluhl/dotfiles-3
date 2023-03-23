vim.g.mapleader = ","

-- Don't need the highlight yank plugin
local yankGrp = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank()",
	group = yankGrp,
})

-- local bufMruGroup = vim.api.nvim_create_augroup("BufMru", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
-- 	-- command = "silent! lua print('hello')",
-- 	callback = function(ev)
-- 		print(string.format("event fired: s", vim.inspect(ev)))
-- 		print(ev)
-- 		-- vim.cmd("Bclose")
-- 		-- print("here")
-- 	end,
-- })
-- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--   pattern = {"*.c", "*.h"},
--   callback = function(ev)
--     print(string.format('event fired: s', vim.inspect(ev)))
--   end
-- })

vim.cmd([[
	let g:VM_maps = {}
	let g:VM_maps['Find Under']         = '<M-d>'           " replace C-n
	let g:VM_maps['Find Subword Under'] = '<M-d>'           " replace visual C-n

	" dont add mappings from context for <S-h>
	let g:context_add_mappings = 0
	let g:astro_typescript = 'enable'
  let g:astro_stylus = 'enable'

]])
