return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "tsx",
        "typescript",
        "javascript",
        "yaml",
        "markdown",
        "lua",
        "rust",
        "toml",
        "go",
        "ocaml",
        "astro",
        "gleam",
        "elixir",
      },
      highlight = {
        enable = {
          "tsx",
          "typescript",
          "javascript",
          "markdown",
          "yaml",
          "lua",
          "rust",
          "toml",
          "go",
          "ocaml",
          "astro",
          "gleam",
          "elixir",
        },
      },
    })
  end,
}
