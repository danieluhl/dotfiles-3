local inoremap = require("duhl.keymap").inoremap
local nnoremap = require("duhl.keymap").nnoremap
local xnoremap = require("duhl.keymap").xnoremap
local vnoremap = require("duhl.keymap").vnoremap
local cnoremap = require("duhl.keymap").cnoremap

local nmaps = {
	["cll"] = "yiwoconsole.log({});<esc>hhhp",
	-- disable q: because I accidentally hit it all the time
	["q:"] = ":",
	-- print date
	["<leader>pd"] = ":r!gdate --iso-8601=seconds<cr>",
	["<leader>}"] = "wbi{<esc>ea}<esc>",
	-- jump into curly braces that are on the current line
	["<leader>{"] = "f{a<cr><esc>O",
	-- BUFFERS
	-- jump directly to buffer
	-- ["'1"] = ':lua require("bufferline").go_to_buffer(1, true)<cr>',
	-- ["'2"] = ':lua require("bufferline").go_to_buffer(2, true)<cr>',
	-- ["'3"] = ':lua require("bufferline").go_to_buffer(3, true)<cr>',
	-- ["'4"] = ':lua require("bufferline").go_to_buffer(4, true)<cr>',
	-- ["'5"] = ':lua require("bufferline").go_to_buffer(5, true)<cr>',

	-- HARPOON
	["'a"] = ':lua require("harpoon.mark").add_file()<cr>',
	["'t"] = ':lua require("harpoon.ui").toggle_quick_menu()<cr>',
	["'s"] = ':lua require("harpoon.ui").nav_file(1)<cr>',
	["'d"] = ':lua require("harpoon.ui").nav_file(2)<cr>',
	["'f"] = ':lua require("harpoon.ui").nav_file(3)<cr>',
	["'g"] = ':lua require("harpoon.ui").nav_file(4)<cr>',
	["<S-l>"] = ':lua require("harpoon.ui").nav_next()<cr>',
	["<S-h>"] = ':lua require("harpoon.ui").nav_prev()<cr>',
	-- close buffer
	["'q"] = ":Bdelete<cr>",
	-- Delete all buffers but the current one
	["<leader>bw"] = ":bufdo :Bwipeout<cr>",
	-- go to next/prev buffer
	-- ["<S-l>"] = ":BufferLineCycleNext<cr>",
	-- ["<S-h>"] = ":BufferLineCyclePrev<cr>",
	-- move buffer left/right in order
	-- ["<M-l>"] = ":BufferLineMoveNext<cr>",
	-- ["<M-h>"] = ":BufferLineMovePrev<cr>",

	-- WINDOWS
	-- create splits
	-- ["<C-w><C-v>"] = "<C-w>v<C-w>l",
	-- ["<leader>ws"] = "<C-w>s<C-w>j",
	-- ["<leader>wo"] = "<C-w><C-o>", jump to splits
	["<leader>e"] = ":NvimTreeFindFileToggle<cr>",
	-- ["<Left>"] = ":NvimTreeToggle<cr>",
	["<Right>"] = "<C-w>l",
	["<Left>"] = "<C-w>h",
	["<Down>"] = "<C-w>j",
	["<Up>"] = "<C-w>k",
	-- resize windows
	["<C-Up>"] = ":resize -2<cr>",
	["<C-Down>"] = ":resize +2<cr>",
	["<C-Left>"] = ":vertical resize +2<cr>",
	["<C-Right>"] = ":vertical resize -2<cr>",
	-- move lines up and down
	["<A-k>"] = ":m .-2<cr>==",
	["<A-j>"] = ":m .+1<cr>==",
	["]="] = "<Plug>(IndentWiseNextEqualIndent)",
	-- replace word with 0 register
	-- ["<replace>p"] = "ciw<C-r>0<esc>",
	-- replace word with option to go next
	["R"] = "*Nciw<C-r>0<esc>",
	["ciw"] = "*Nciw",
	-- delete word to no register
	["<leader>d"] = '"_d',
	["<leader>D"] = '"_D',
	["<leader>c"] = '"_c',
	-- Typescript Plugin
	["<leader>to"] = ":TypescriptOrganizeImports<cr>",
	["<leader>ta"] = ":TypescriptAddMissingImports<cr>",
	["<leader>tf"] = ":TypescriptFixAll<cr>",
	["<leader>tr"] = ":TypescriptRenameFile<cr>",
	-- Quickfix lists
	-- note: <C-q> from telescope search puts in quickfix list
	["<leader>co"] = ":copen<cr>",
	["<leader>cl"] = ":ccl<cr>",
	["<leader>cn"] = ":cn<cr>",
	["<leader>cp"] = ":cp<cr>",
	-- Error Navigation
	-- ["<leader>en"] = ":lnext<cr>",
	-- ["<leader>ep"] = ":lprev<cr>",
	-- ["<leader>eo"] = ":lopen<cr>",
	-- ["<leader>ec"] = ":lclose<cr>",

	-- Search under cursor
	-- ["<leader>s"] = ":s/<C-r><C-w>//g<C-f>hhi<C-c>",

	-- print from 0 register
	["<leader>0"] = '"0p',
	-- Scroll screen up and down
	["<C-e>"] = "5<C-e>",
	-- Not sure why but <S-Tab> is sending <C-y>
	["<C-y>"] = "<C-^>",
	-- ["<C-Tab>"] = "<C-^>",
	-- ["<S-Tab>"] = "<C-^>",

	-- Paste in quotes
	["<leader>'"] = "i''<esc>P",
	-- Select entire document
	["<leader>gg"] = "gg<S-v>G",
	-- Wrap only lines longer than 80ch
	["<leader>gq"] = ":g/./ normal gqq<cr>",
	-- Toggle soft wrap
	-- ["<leader>gw"] = ":set wrap linebreak<cr>",
	["<leader>gww"] = ":set nowrap<cr>",
	-- copy current word into clipboard
	-- ["<leader>y"] = 'viw"+y',

	-- Foldings (use za to fold/unfold)
	-- ["zz"] = ":set foldmethod=syntax<cr>",

	-- center when mucking around, add zv for folds if ever necessary
	["<C-d>"] = "<C-d>zz",
	["<C-u>"] = "<C-u>zz",
	["n"] = "nzz",
	["N"] = "Nzz",
	["g;"] = "g;zz",
	["g,"] = "g,zz",
	["gi"] = "gi<esc>zzi",
	-- github
	["gh"] = ":Git<cr>",
	["<leader>ghf"] = ":OpenGithubFile<cr>",
	["<leader>ghc"] = ":Git commit -a<cr>",
	["<leader>ghp"] = ":!git pull && git push<cr>",
	-- open link in browser
	["<leader>gl"] = "<Plug>(openbrowser-open)",
	-- telescope
	["<C-p>"] = ":UserTelescopeFindFiles<cr>",
	["<leader>fd"] = ":UserTelescopeFindFilesAll<cr>",
	-- ["<leader>fd"] = ":Telescope find_files hidden=true<cr>",
	["<C-f>"] = ":UserTelescopeLiveGrep<cr>",
	["<leader>fa"] = ":UserTelescopeLiveGrepAll<cr>",
	["<leader>fb"] = ":Telescope buffers<cr>",
	-- ["<leader>fg"] = ":Telescope git_files<cr>",
	["<leader>fs"] = ":Telescope grep_string<cr>",
	["<leader>fh"] = ":Telescope search_history<cr>",
	["<leader>fo"] = ":Telescope oldfiles<cr>",
	-- ["<leader>p"] = ":Telescope oldfiles<cr><C-p><cr>",

	-- Tabularize - for formatting markdown tables
	-- ["<Leader>a="] = ":Tabularize /<bar><cr>",

	-- Seamlessly treat visual lines as actual lines when moving around.
	["j"] = "gj",
	["k"] = "gk",
	-- move lines up or down
	["<A-Up>"] = ":m '<-2<cr>gv=gv",
	["<A-Down>"] = ":m '>+1<cr>gv=gv",
	-- Save and Quit
	["<leader>s"] = ":w<cr>",
	["<leader>q"] = ":q<cr>",
	["<leader>!"] = ":q!<cr>",
	-- LSP Mappings
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	-- local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- ["<leader>ff"] = ":LspZeroFormat<cr>:lua vim.api.nvim_command('write')<cr>",
	["<leader>w"] = ":lua vim.lsp.buf.format() vim.api.nvim_command('write')<CR>:noh<CR>",
	["<leader>fp"] = ":Prettier<cr>:lua vim.api.nvim_command('write')<cr>",
	["gD"] = ":lua vim.lsp.buf.declaration()<cr>",
	["gd"] = ":lua vim.lsp.buf.definition()<cr>",
	["<leader>gi"] = ":lua vim.lsp.buf.implementation()<cr>",
	["<leader>gr"] = ":lua vim.lsp.buf.references()<cr>",
	["<C-Space>"] = ":lua vim.lsp.buf.hover()<cr>",
	["<leader>k"] = ":lua vim.diagnostic.open_float()<cr>",
	["<leader>gs"] = ":lua vim.lsp.buf.signature_help()<cr>",
	-- ["<leader>wa"] = ":lua vim.lsp.buf.add_workspace_folder()<cr>",
	-- ["<leader>wr"] = ":lua vim.lsp.buf.remove_workspace_folder()<cr>",
	-- ["<leader>wl"] = ":lua function()
	-- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	-- end] = ":lua bufopts)
	["<leader>gt"] = ":lua vim.lsp.buf.type_definition()<cr>",
	["<leader>rn"] = ":lua vim.lsp.buf.rename()<cr>",
	["<leader>ca"] = ":lua vim.lsp.buf.code_action()<cr>",
}

local vmaps = {
	-- Move 1 more lines up or down in normal and visual selection modes.
	["<A-k>"] = ":m '<-2<cr>gv=gv",
	["<A-j>"] = ":m '>+1<cr>gv=gv",
	["<A-Up>"] = ":m '<-2<cr>gv=gv",
	["<A-Down>"] = ":m '>+1<cr>gv=gv",
	-- replace in selection with yanked word
	-- ["<leader>s"] = ':s/<C-r>"//g<C-f>hhi<C-c>',

	-- Delete to black hole register
	["<leader>d"] = '"_d',
	["<S-j>"] = "5j",
	["<S-k>"] = "5k",
	-- ["<Leader>a="] = ":Tabularize /<bar><cr>",
	["."] = ":norm .<cr>",
	-- jump to bottom after yank
	["y"] = "y']",
	["gy"] = "y']",
}

local imaps = {
	["<M-b>ackspace"] = "<C-w>",

	-- Insert Mode Edits
	["<C-d>"] = "<del>",
	["<M-h>"] = "<esc>bi",
	["<M-l>"] = "<esc>ea",
	["<M-BS>"] = "<C-w>",
	["<M-Del>"] = "<C-w>",
	["<A-k>"] = "<esc>:m .-2<cr>==gi",
	["<A-j>"] = "<esc>:m .+1<cr>==gi",
	["<C-c>"] = "<esc>",
}

local imaps_silent = {
	-- opilot completion
	["<C-t>"] = "copilot#Accept()",

	-- luasnip completion
	["<C-e>"] = "<Plug>luasnip-expand-snippet",
}

local xmaps = {
	-- fix shift-a for visual-block select
	["A"] = "$A",
	-- Copy visual selection to clipboard
	["<leader>y"] = '"+y',
	-- ["<leader>p"] = '"_dP',

	["."] = ":norm .<cr>",
}

local cmaps = {
	["<C-k>"] = "\\(.\\{-}\\)",
	["<C-j>"] = "\\(_.\\{-}\\)",
}

for k, v in pairs(imaps) do
	inoremap(k, v)
end

for k, v in pairs(cmaps) do
	cnoremap(k, v)
end

for k, v in pairs(imaps_silent) do
	inoremap(k, v, { expr = true, silent = true, replace_keycodes = false })
end

for k, v in pairs(xmaps) do
	xnoremap(k, v)
end

for k, v in pairs(nmaps) do
	nnoremap(k, v)
end

for k, v in pairs(vmaps) do
	vnoremap(k, v)
end
