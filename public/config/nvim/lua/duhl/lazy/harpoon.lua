return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- require("telescope").load_extension("harpoon")
    local harpoon = require("harpoon")

    -- -- REQUIRED
    harpoon:setup()
    -- -- REQUIRED

    vim.keymap.set("n", "'a", function()
      harpoon:list():add()
    end)
    vim.keymap.set("n", "'t", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set("n", "'s", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "'d", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "'f", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "'g", function()
      harpoon:list():select(4)
    end)
    vim.keymap.set("n", "'w", function()
      harpoon:list():select(5)
    end)
    vim.keymap.set("n", "'e", function()
      harpoon:list():select(6)
    end)
  end,
}
