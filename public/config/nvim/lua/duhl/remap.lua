local inoremap = require("duhl.keymap").inoremap
local nnoremap = require("duhl.keymap").nnoremap
local xnoremap = require("duhl.keymap").xnoremap
local vnoremap = require("duhl.keymap").vnoremap

-- Saving and quitting
local nmaps = {

	-- jump into curly braces that are on the current line
	["<leader>{"] = "f{a<cr><esc>O",

	["<leader>k"] = ":lua vim.diagnostic.open_float()<cr>",
	-- Marks
	-- ["mf"] = "mF",
	-- ["'f"] = "'F",
	-- -- ["`f"] = "`F",
	-- ["md"] = "mD",
	-- ["'d"] = "'D",
	-- -- ["`d"] = "`D",
	-- ["ms"] = "mS",
	-- ["'s"] = "'S",
	-- -- ["`s"] = "`S",
	-- ["ma"] = "mA",
	-- ["'a"] = "'A",
	-- ["`a"] = "`A",

	-- harpoon marks
	["ma"] = ":lua require('harpoon.mark').add_file()<cr>",
	["mq"] = ":lua require('harpoon.ui').toggle_quick_menu()<cr>",
	["'1"] = ":lua require('harpoon.ui').nav_file(1)<cr>",
	["'2"] = ":lua require('harpoon.ui').nav_file(2)<cr>",
	["'3"] = ":lua require('harpoon.ui').nav_file(3)<cr>",
	["'4"] = ":lua require('harpoon.ui').nav_file(4)<cr>",
	["'5"] = ":lua require('harpoon.ui').nav_file(5)<cr>",
	["<leader>l"] = ":lua require('harpoon.ui').nav_next()<cr>",
	["<leader>h"] = ":lua require('harpoon.ui').nav_prev()<cr>",
	-- cycle through buffers
	["<S-l>"] = ":bnext<cr>",
	["<S-h>"] = ":bprevious<cr>",

	["]="] = "<Plug>(IndentWiseNextEqualIndent)",
	-- replace word with 0 register
	-- ["<leader>p"] = "ciw<C-r>0<esc>",
	-- replace word with option to go next
	["<leader>cw"] = "*Nciw<C-r>0<esc>",
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

	-- Save and Quit
	["<leader>w"] = ":w<cr>",
	["<leader>q"] = ":q<cr>",
	["<leader>!"] = ":q!<cr>",

	-- nvim-tree plugin remaps
	-- jump to current file in nav
	["<leader>e"] = ":NvimTreeFindFile<cr>",
	-- Show/hide nav
	["<S-e>"] = ":NvimTreeToggle<cr><C-w>l",

	-- Search under cursor
	["<leader>s"] = ":%s/",
	["<leader>S"] = ":%s/<C-r><C-w>//g<C-f>hi<C-c>",

	-- BUFFERS
	-- Delete all buffers but the current one
	["<leader>bd"] = ":%bd<bar>e#<cr>",
	-- jump to splits
	["<C-l>"] = "<C-w>l",
	["<C-h>"] = "<C-w>h",
	["<C-k>"] = "<C-w>k",
	["<C-j>"] = "<C-w>j",
	-- window mgmt
	-- ["<leader>wv"] = "<C-w>v<C-w>l",
	-- ["<leader>ws"] = "<C-w>s<C-w>j",
	-- ["<leader>wo"] = "<C-w><C-o>",

	-- print from 0 register
	["<leader>0"] = '"0p',

	-- Scroll screen up and down
	["<C-e>"] = "5<C-e>",
	-- Not sure why but <S-Tab> is sending <C-y>
	["<C-y>"] = "<C-^>",
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

	-- center when mocing around
	["<C-d>"] = "<C-d>zz",
	["<C-u>"] = "<C-u>zz",
	["n"] = "nzzzv",
	["N"] = "Nzzzv",

	-- github
	["<leader>gh"] = ":OpenGithubFile<cr>",
	-- open link in browser
	["<leader>gl"] = "<Plug>(openbrowser-open)",

	-- telescope
	["<C-p>"] = ":UserTelescopeFindFiles<cr>",
	["<leader>fd"] = ":Telescope find_files hidden=true<cr>",
	["<C-f>"] = ":UserTelescopeLiveGrep<cr>",
	["<leader>fa"] = ":UserTelescopeLiveGrepAll<cr>",
	["<leader>fb"] = ":Telescope buffers<cr>",
	-- ["<leader>fg"] = ":Telescope git_files<cr>",
	["<leader>fs"] = ":Telescope grep_string<cr>",
	["<leader>fh"] = ":Telescope search_history<cr>",
	["<leader>fo"] = ":Telescope oldfiles<cr>",

	-- Tabularize - for formatting markdown tables
	-- ["<Leader>a="] = ":Tabularize /<bar><cr>",

	-- Seamlessly treat visual lines as actual lines when moving around.
	["j"] = "gj",
	["k"] = "gk",
	["<Down>"] = "gj",
	["<Up>"] = "gk",

	-- move lines up or down
	["<A-Up>"] = ":m '<-2<cr>gv=gv",
	["<A-Down>"] = ":m '>+1<cr>gv=gv",

	-- resize windows
	["<C-Up>"] = ":resize -2<cr>",
	["<C-Down>"] = ":resize +2<cr>",
	["<A-k>"] = ":m .-2<cr>==",
	["<A-j>"] = ":m .+1<cr>==",
	["<C-Right>"] = ":vertical resize +2<cr>",
	["<C-Left>"] = ":vertical resize -2<cr>",

	-- LSP Mappings
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	-- local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- ["<leader>ff"] = ":LspZeroFormat<cr>:lua vim.api.nvim_command('write')<cr>",
	["<leader>ff"] = ":lua vim.lsp.buf.format({}, 1000) vim.api.nvim_command('write')<CR>",
	["<leader>fp"] = ":Prettier<cr>:lua vim.api.nvim_command('write')<cr>",
	["gD"] = ":lua vim.lsp.buf.declaration()<cr>",
	["gd"] = ":lua vim.lsp.buf.definition()<cr>",
	["<leader>gi"] = ":lua vim.lsp.buf.implementation()<cr>",
	["<leader>gr"] = ":lua vim.lsp.buf.references()<cr>",
	-- ["<leader>k"] = ":lua vim.lsp.buf.hover()<cr>",
	["<leader>sh"] = ":lua vim.lsp.buf.signature_help()<cr>",
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
	-- luasnip completion
	["<C-e>"] = "<Plug>luasnip-expand-snippet",

	-- Insert Mode Edits
	["<C-d>"] = "<del>",
	["<M-h>"] = "<esc>bi",
	["<M-l>"] = "<esc>ea",
	["<M-BS>"] = "<C-w>",
	["<M-Del>"] = "<C-w>",

	-- ["<Down>"] = "<C-o>gj",
	-- ["<Up>"] = "<C-o>gk",
	["<A-k>"] = "<esc>:m .-2<cr>==gi",
	["<A-j>"] = "<esc>:m .+1<cr>==gi",
	-- ["<A-k>"] = "<esc>:m .-2<cr>==gi",
	-- ["<A-j>"] = "<esc>:m .+1<cr>==gi",

	["<C-c>"] = "<esc>",
}

local xmaps = {
	-- fix shift-a for visual-block select
	["A"] = "$A",
	-- Copy visual selection to clipboard
	["<leader>y"] = '"+y',
	-- ["<leader>p"] = '"_dP',
}

for k, v in pairs(imaps) do
	inoremap(k, v)
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
