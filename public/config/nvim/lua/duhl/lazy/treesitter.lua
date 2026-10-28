return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.install({
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
      "fish",
    })
    local prose = { markdown = true, text = true, gitcommit = true }
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        if not prose[vim.bo[args.buf].filetype] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
