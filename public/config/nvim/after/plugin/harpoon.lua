require("telescope").load_extension('harpoon')
local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "'a", function() harpoon:list():append() end)
vim.keymap.set("n", "'t", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "'s", function() harpoon:list():select(1) end)
vim.keymap.set("n", "'d", function() harpoon:list():select(2) end)
vim.keymap.set("n", "'f", function() harpoon:list():select(3) end)
vim.keymap.set("n", "'g", function() harpoon:list():select(4) end)
