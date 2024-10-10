local inoremap = require("duhl.keymap").inoremap
local nnoremap = require("duhl.keymap").nnoremap
local xnoremap = require("duhl.keymap").xnoremap
local vnoremap = require("duhl.keymap").vnoremap
local cnoremap = require("duhl.keymap").cnoremap

-- CUSTOM FUNCTIONS
function Open_in_git()
	local file_dir = vim.fn.expand("%:h")
	local git_root = vim.fn.system("cd " .. file_dir .. "; git rev-parse --show-toplevel | tr -d '\n'")
	local file_path = vim.fn.substitute(vim.fn.expand("%:p"), git_root .. "/", "", "")
	local git_remote = vim.fn.system("cd " .. file_dir .. "; git remote get-url origin")
	local repo_path = string.gsub(git_remote, ".*:", "")
	repo_path = string.gsub(repo_path, "%..*", "")
	local url = "https://gitlab.com/" .. repo_path .. "/-/blob/main/" .. file_path .. "/"
	return vim.cmd("silent !open " .. url)
end

local nmaps = {

	-- notes on yanking and the clipboard: we set
	--  global setting `unnamedplus` which stores things
	--  in the "+ clipboard register

	-- jump up and down
	["<C-j>"] = "8jzz",
	["<C-k>"] = "8kzz",

	-- undo tree history toggle
	["<leader>u"] = ":UndotreeToggle<cr>",
	-- console.log the current word
	["clw"] = "yiwoconsole.log(<esc>pa);<esc>",
	-- console.log on the next line
	["clo"] = "oconsole.log();<esc>hi",
	-- disable q: because I accidentally hit it all the time
	["q:"] = ":",
	-- print date
	["<leader>pd"] = ":r!gdate --iso-8601=seconds<cr>",
	["<leader>pp"] = ":Telescope neoclip<cr>",
	["<leader>}"] = "wbi{<esc>ea}<esc>",
	-- jump into curly braces that are on the current line
	["<leader>{"] = "f{a<cr><esc>O",

	-- close buffer
	["'q"] = ":Bdelete<cr>",
	-- Delete all buffers but the current one
	["<leader>bw"] = ":bufdo :Bwipeout<cr>",

	-- FILE TREE (previously nvim-tree, now oil)
	["<leader>e"] = ":Oil<cr>",

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
	-- replace word with option to go next
	["R"] = "*Nciw<C-r>0<esc>",
	["ciw"] = "*Nciw",
	-- delete word to black hole register
	["<leader>d"] = '"_d',
	["<leader>D"] = '"_D',
	["<leader>c"] = '"_c',
	-- Typescript Plugin
	["<leader>to"] = ":TypescriptOrganizeImports<cr>",
	["<leader>ta"] = ":TypescriptAddMissingImports<cr>",
	["<leader>tf"] = ":TTypescriptFixAllypescriptFixAll<cr>",
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

	-- Tabularize - for formatting markdown tables
	["<Leader>a="] = ":Tabularize /<bar><cr>",

	-- Seamlessly treat visual lines as actual lines when moving around.
	["j"] = "gj",
	["k"] = "gk",
	-- move lines up or down
	["<A-Up>"] = ":m '<-2<cr>gv=gv",
	["<A-Down>"] = ":m '>+1<cr>gv=gv",

	-- Save and Quit
	-- ["<leader>f"] = ':lua require("conform").format({lsp_fallback = false, async = false, timeout_ms = 2000})',
	-- ["<leader>w"] = 'vim.api.nvim_command("write")<cr>:noh<cr>',
	["<leader>w"] = ":w<cr>:noh<cr>",
	-- <C-c> to exit oil first if it's open
	["<leader>q"] = "<C-c>:q<cr>",
	["<leader>!"] = ":q!<cr>",
	-- save all and quit
	["<leader>zz"] = ":conf xa<cr>",

	-- LSP Mappings
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	-- local bufopts = { noremap = true, silent = true, buffer = bufnr }
	-- ["<leader>ff"] = ":LspZeroFormat<cr>:lua vim.api.nvim_command('write')<cr>",
	-- ["<leader>w"] = ":lua vim.lsp.buf.format() vim.api.nvim_command('write')<CR>:noh<CR>",
	-- ["<leader>fp"] = ":lua vim.lsp.buf.format()<cr>",
	-- using <leader>f for special formatters in other languages
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
	["<leader>cc"] = ":lua vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<cr>",
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
	-- ["<C-t>"] = "copilot#Accept()",
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
