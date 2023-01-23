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
	vim.cmd.packadd('packer.nvim')
end

return require("packer").startup(function(use)
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

	-- LSP (language server protocol)
	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})

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
	use("ThePrimeagen/harpoon")

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

	use("simrat39/rust-tools.nvim")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
