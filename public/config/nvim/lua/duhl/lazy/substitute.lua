return {
  "gbprod/substitute.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    require("substitute").setup()
    vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
  end,
}
