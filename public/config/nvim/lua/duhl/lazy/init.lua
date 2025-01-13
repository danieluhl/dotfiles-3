return {
  "tpope/vim-surround",
  "tpope/vim-commentary",
  "tpope/vim-repeat",
  "mbbill/undotree",
  "tpope/vim-fugitive",

  "moll/vim-bbye",
  "godlygeek/tabular",
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  "sheerun/vim-polyglot",
  "neoclide/vim-jsx-improve",
  "fatih/vim-go",
  {
    "gleam-lang/gleam.vim",
  },
}
