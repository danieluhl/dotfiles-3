return {
	-- Core Utils
	"vim-scripts/ReplaceWithRegister",
	"moll/vim-bbye",
	"tpope/vim-surround",
	"tpope/vim-commentary",
	"tpope/vim-repeat",
	"ThePrimeagen/harpoon",
	"mbbill/undotree",
	-- "github/copilot.vim",
	-- Lesser used utils
	"godlygeek/tabular",
	"windwp/nvim-ts-autotag",
	"tpope/vim-fugitive",
	-- Style
	"nvim-tree/nvim-web-devicons",
	"EdenEast/nightfox.nvim",
	-- Core Functionality
	"sheerun/vim-polyglot",
	-- LSP Rare
	"prisma/vim-prisma",
	"wuelnerdotexe/vim-astro",
	-- Sus
	"duane9/nvim-rg",
	-- LSP Core
	"neoclide/vim-jsx-improve",
	"simrat39/rust-tools.nvim",
	"fatih/vim-go",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",

	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
	"neovim/nvim-lspconfig",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-nvim-lua",
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/duhl/snips" })
		end,
	},
	"saadparwaiz1/cmp_luasnip",
	"virchau13/tree-sitter-astro",
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	"ThePrimeagen/git-worktree.nvim",
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
	},
	{
		"gleam-lang/gleam.vim",
	},
}
