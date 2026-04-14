-- Basic Markdown settings
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
-- vim.opt_local.breakindent = true
-- vim.opt_local.breakindentopt = "shift:2"
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.spell = true
vim.opt_local.textwidth = 80

vim.opt_local.comments = {
  "b:-",
  "b:*",
  "b:+",
  "b:[ ]",
  "b:[x]",
  "n:>",
}

-- NOTE: These may be controlled by the `vim-polyglot` plugin
-- t: Auto-wrap text using textwidth
-- r: Add bullet on <Enter>
-- o: Add bullet on o/O
-- q: Allow formatting with 'gq'
-- n: Recognize numbered lists
-- l: Don't wrap lines that are already long
-- j: Remove comment leader when joining lines
-- (Notice 't' and 'c' are missing: this stops auto-wrap from adding bullets)
vim.opt_local.formatoptions = "troqnlj"
-- this makes it so that when wrapping lines it won't add the list markers
vim.opt_local.formatlistpat = [[^\s*\(\d\+[.)]\|[-*+]\)\s\+\(\[[ xX]\]\s\+\)\?]]
-- vim.opt_local.formatoptions:remove { "r", "o" }
-- vim.opt_local.comments = ""
