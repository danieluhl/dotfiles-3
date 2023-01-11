local inoremap = require("duhl.keymap").inoremap
local nnoremap = require("duhl.keymap").nnoremap
local xnoremap = require("duhl.keymap").xnoremap
local vnoremap = require("duhl.keymap").vnoremap
local telescope = require("duhl.telescope")

-- Saving and quitting
local nmaps = {

	["]="] = "<Plug>(IndentWiseNextEqualIndent)",
	-- replace word with 0 register
	["<leader>p"] = "ciw<C-r>0<esc>",
	-- delete word to no register
	["<leader>d"] = '"_d',

	-- Typescript Plugin
	["<leader>to"] = ":TypescriptOrganizeImports<CR>",
	["<leader>ta"] = ":TypescriptAddMissingImports<CR>",
	["<leader>tf"] = ":TypescriptFixAll<CR>",
	["<leader>tr"] = ":TypescriptRenameFile<CR>",

	-- Quickfix lists
	-- note<CMD> <C-q> from telescope search puts in quickfix list
	["<leader>co"] = "<CMD>copen<CR>",
	["<leader>cl"] = "<CMD>ccl<CR>",
	["<leader>cn"] = "<CMD>cn<CR>",
	["<leader>cp"] = "<CMD>cp<CR>",

	-- Error Navigation
	-- ["<leader>en"] = "<CMD>lnext<CR>",
	-- ["<leader>ep"] = "<CMD>lprev<CR>",
	-- ["<leader>eo"] = "<CMD>lopen<CR>",
	-- ["<leader>ec"] = "<CMD>lclose<CR>",

	-- Save and Quit
	["<leader>w"] = "<CMD>w<CR>",
	["<leader>q"] = "<CMD>q<CR>",
	["<leader>!"] = "<CMD>q!<CR>",

	-- nvim-tree plugin remaps
	-- jump to current file in nav
	["<leader>e"] = "<CMD>NvimTreeFindFile<CR>",
	-- Show/hide nav
	["<S-e>"] = "<CMD>NvimTreeToggle<CR><C-w>l",

	-- Search under cursor
	["<leader>s"] = ":%s/",
	["<leader>S"] = ":%s/<C-r><C-w>//g<C-f>hi<C-c>",

	-- BUFFERS
	-- Delete all buffers but the current one
	["<leader>bd"] = "<CMD>%bd<bar>e#<CR>",
	-- cycle through buffers
	["<S-l>"] = "<CMD>bnext<CR>",
	["<S-h>"] = "<CMD>bprevious<CR>",
	-- jump to splits
	["<C-l>"] = "<C-w>l",
	["<C-h>"] = "<C-w>h",
	["<C-k>"] = "<C-w>k",
	["<C-j>"] = "<C-w>j",
	-- window mgmt
	-- ["<leader>wv"] = "<C-w>v<C-w>l",
	-- ["<leader>ws"] = "<C-w>s<C-w>j",
	-- ["<leader>wo"] = "<C-w><C-o>",

	-- Marks
	["mf"] = "mF",
	["'f"] = "'F",
	-- ["`f"] = "`F",
	["md"] = "mD",
	["'d"] = "'D",
	-- ["`d"] = "`D",
	["ms"] = "mS",
	["'s"] = "'S",
	-- ["`s"] = "`S",
	["ma"] = "mA",
	["'a"] = "'A",
	-- ["`a"] = "`A",

	-- print from 0 register
	["<leader>0"] = '"0p',

	-- Movements
	["<S-k>"] = "5k",

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
	["<leader>gq"] = "<CMD>g/./ normal gqq<CR>",
	["<leader>y"] = 'viw"+y',

	-- Foldings (use za to fold/unfold)
	-- ["zz"] = "<CMD>set foldmethod=syntax<CR>",

	-- center when mocing around
	["<C-d>"] = "<C-d>zz",
	["<C-u>"] = "<C-u>zz",
	["n"] = "nzzzv",
	["N"] = "Nzzzv",

	-- github
	["<leader>gh"] = "<CMD>OpenGithubFile<CR>",
	-- open link in browser
	["<leader>gl"] = "<Plug>(openbrowser-open)",

	-- telescope
	["<C-p>"] = "<CMD>UserTelescopeFindFiles<CR>",
	["<leader>fd"] = "<CMD>Telescope find_files hidden=true<CR>",
	["<C-f>"] = "<CMD>UserTelescopeLiveGrep<CR>",
	["<leader>fa"] = "<CMD>UserTelescopeLiveGrepAll<CR>",
	["<leader>fb"] = "<CMD>Telescope buffers<CR>",
	-- ["<leader>fg"] = "<CMD>Telescope git_files<CR>",
	["<leader>fs"] = "<CMD>Telescope grep_string<CR>",
	["<leader>fh"] = "<CMD>Telescope search_history<CR>",
	["<leader>fo"] = "<CMD>Telescope oldfiles<CR>",

	-- Tabularize - for formatting markdown tables
	-- ["<Leader>a="] = "<CMD>Tabularize /<bar><CR>",

	-- Format dat code (for lsp stuff see lspconfig.lua)
	["<leader>ff"] = ":lua vim.lsp.buf.format({}, 1000) vim.api.nvim_command('write')<CR>",
	-- ["<leader>fp"] = ":lua vim.lsp.buf.format({}, 10000) vim.api.nvim_command('write')<CR>",
	["<leader>ca"] = ":lua vim.lsp.buf.code_action()<CR>",

	-- Seamlessly treat visual lines as actual lines when moving around.
	["j"] = "gj",
	["k"] = "gk",
	["<Down>"] = "gj",
	["<Up>"] = "gk",

	-- move lines up or down
	["<A-Up>"] = ":m '<-2<CR>gv=gv",
	["<A-Down>"] = ":m '>+1<CR>gv=gv",

	-- resize windows
	["<C-Up>"] = ":resize -2<CR>",
	["<C-Down>"] = ":resize +2<CR>",
	["<A-k>"] = ":m .-2<CR>==",
	["<A-j>"] = ":m .+1<CR>==",
	["<C-Right>"] = ":vertical resize +2<CR>",
	["<C-Left>"] = ":vertical resize -2<CR>",
}

local vmaps = {
	-- Move 1 more lines up or down in normal and visual selection modes.
	["<A-k>"] = ":m '<-2<CR>gv=gv",
	["<A-j>"] = ":m '>+1<CR>gv=gv",
	["<A-Up>"] = ":m '<-2<CR>gv=gv",
	["<A-Down>"] = ":m '>+1<CR>gv=gv",

	-- Delete to black hole register
	["<leader>d"] = '"_d',

	["<S-j>"] = "5j",
	["<S-k>"] = "5k",
	-- ["<Leader>a="] = "<CMD>Tabularize /<bar><CR>",
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
	["<A-k>"] = "<esc>:m .-2<CR>==gi",
	["<A-j>"] = "<esc>:m .+1<CR>==gi",
	-- ["<A-k>"] = "<esc>:m .-2<CR>==gi",
	-- ["<A-j>"] = "<esc>:m .+1<CR>==gi",
}

local xmaps = {
	-- fix shift-a for visual-block select
	["A"] = "$A",
	-- Copy visual selection to clipboard
	["<leader>y"] = '"+y',
	["<leader>p"] = '"_dP',
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
