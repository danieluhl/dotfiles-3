return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "tsx",
        "typescript",
        "javascript",
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
