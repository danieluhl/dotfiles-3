require("cmp").setup({ completion = { autocomplete = false } })

-- wrap lines for markdown by defualt, use gqq to hard wrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- local prettier = require("prettier")
-- prettier.setup({
--   filetypes = {
--     "markdown",
--   },
--   cli_options = {
--     arrow_parens = "always",
--     bracket_spacing = false,
--     print_width = 80,
--     tab_width = 4,
--     use_tabs = true,
--   },
-- })
