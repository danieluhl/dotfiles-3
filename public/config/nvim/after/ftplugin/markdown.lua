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
  -- "b:[ ]",
  -- "b:[x]",
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
vim.opt_local.formatoptions = "tqnlj"
-- this makes it so that when wrapping lines it won't add the list markers
vim.opt_local.formatlistpat = [[^\s*\(\d\+[.)]\|[-*+]\)\s\+\(\[[ xX]\]\s\+\)\?]]
-- vim.opt_local.formatoptions:remove { "r", "o" }
-- vim.opt_local.comments = ""

-- Toggle checkbox on line with <C-x>
local function toggle_checkbox_on_line(line)
  if line:match("^%[ %] ") then
    return line:gsub("^%[ %] ", "[x] ", 1)
  elseif line:match("^%[x%] ") then
    return line:gsub("^%[x%] ", "[ ] ", 1)
  else
    return "[ ] " .. line
  end
end

local function toggle_checkbox(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  for i, line in ipairs(lines) do
    lines[i] = toggle_checkbox_on_line(line)
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Normal mode: toggle current line
vim.keymap.set("n", "<C-x>", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  toggle_checkbox(line, line)
end, { desc = "Toggle checkbox" })

-- Visual mode: toggle selected lines
vim.keymap.set("x", "<C-x>", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  toggle_checkbox(start_line, end_line)
end, { desc = "Toggle checkbox" })

-- Insert mode (operate on current line, return to insert)
vim.keymap.set("i", "<C-x>", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row, col = pos[1], pos[2]

  toggle_checkbox(row, row)

  -- restore cursor position (adjust if we inserted "[ ] ")
  local line = vim.api.nvim_get_current_line()
  if col == 0 and line:match("^%[ %] ") then
    col = col + 4
  end

  vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "Toggle checkbox (insert mode)" })
