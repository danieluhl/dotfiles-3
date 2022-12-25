vim.g.mapleader = ","

-- Don't need the highlight yank plugin
local yankGrp = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank()",
	group = yankGrp,
})

vim.cmd([[
	let g:VM_maps = {}
	let g:VM_maps['Find Under']         = '<M-d>'           " replace C-n
	let g:VM_maps['Find Subword Under'] = '<M-d>'           " replace visual C-n

	" dont add mappings from context for <S-h>
	let g:context_add_mappings = 0


	augroup ftplugin
		au!
		au BufWinEnter * set formatoptions-=cro
		au BufNewFile,BufRead *.json setl filetype=jsonc " To allow comments on json files
		au FileType man setl laststatus=0 noruler
		au FileType vim,html,css,json,javascript,javascriptreact,typescript,typescriptreact,lua,sh,zsh setl sw=2
		au TermOpen term://* setl nornu nonu nocul so=0 scl=no
	augroup END
]])
