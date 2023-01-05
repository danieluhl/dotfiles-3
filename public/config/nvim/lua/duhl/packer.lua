local fn = vim.fn

-- Borrowed from https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost packer.lua source <afile> | PackerSync
--   augroup end
-- ]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Only required if you have packer configured as `opt`
-- Plugins are just github repos that clone here: ~.local/share/nvim/site/pack/packer/start
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function()
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	use("haishanh/night-owl.vim")
	use("morhetz/gruvbox")
	use("EdenEast/nightfox.nvim")

	-- Telescope
	use("nvim-telescope/telescope-fzy-native.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- For syntax highlighting
	use("sheerun/vim-polyglot")

	-- for tables and such
	use("godlygeek/tabular")

	-- cmp plugins
	use("hrsh7th/nvim-cmp")
	use("saadparwaiz1/cmp_luasnip") -- snippet completions
	use("hrsh7th/cmp-buffer") -- buffer completions
	use("hrsh7th/cmp-path") -- path completions
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")
	use("hrsh7th/cmp-cmdline")

	-- snippets
	use("L3MON4D3/LuaSnip")
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- LSP (language server protocol)
	use("neovim/nvim-lspconfig") -- enable LSP
	use("williamboman/nvim-lsp-installer")
	use("jose-elias-alvarez/null-ls.nvim")
	use("udalov/kotlin-vim")

	-- Language server plugins (so you don't have to install these on every machine)
	use("jose-elias-alvarez/typescript.nvim")
	-- use("MunifTanjim/eslint.nvim")
	use("MunifTanjim/prettier.nvim")

	-- Neovim Tree shitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	use("nvim-treesitter/playground")

	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons", -- optional, for file icons
		},
		tag = "nightly", -- optional, updated every week. (see issue #1193)
	})
	use("nvim-tree/nvim-web-devicons")

	-- For Editing
	use("vim-scripts/ReplaceWithRegister")
	use("tpope/vim-surround")
	use("tpope/vim-commentary")
	use("tpope/vim-vinegar")
	use("tpope/vim-repeat")
	use("wellle/context.vim")
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})
	use("windwp/nvim-ts-autotag")

	-- Maybe Future Things I Want
	use("mbbill/undotree")
	use("jeetsukumaran/vim-indentwise")

	-- Github Plugins
	use("tyru/open-browser.vim")
	use("tyru/open-browser-github.vim")
	use("tpope/vim-fugitive")
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})

	-- usage tracking
	use("wakatime/vim-wakatime")

	-- extra support for react jsx
	use("neoclide/vim-jsx-improve")
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
