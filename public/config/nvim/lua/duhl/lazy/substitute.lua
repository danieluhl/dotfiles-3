return {
  "gbprod/substitute.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    local sub = require("substitute")
    sub.setup()
    vim.keymap.set("n", "s", sub.operator, { noremap = true, desc = "Substitute operator" })
    vim.keymap.set("n", "R", function()
      vim.cmd("normal! *N")
      sub.operator({ motion = "iw", register = "+" })
    end, { noremap = true, desc = "Substitute inner word" })
  end,
}
