return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-t>",
      },
      ignore_filetypes = { cpp = true, markdown = true },
      color = {
        suggestion_color = "#b19deb",
        cterm = 244,
      },
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })
  end,
}
