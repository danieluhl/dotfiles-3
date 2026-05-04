return {
  "danieluhl/grapple.nvim",
  -- dir = "~/git/external/grapple.nvim",
  branch = "main",
  -- Plugin dependencies required for grapple.nvim to function properly
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true }
  },
  opts = {
    scope = "package_json",

    scopes = {
      {
        name = "package_json",
        desc = "Scope defined by nearest package.json",
        fallback = "git",
        cache = {
          event = { "BufEnter", "FocusGained" },
          debounce = 1000,
        },
        resolver = function()
          local package_files = vim.fs.find("package.json", {
            upward = true,
            stop = vim.loop.os_homedir(),
          })

          if #package_files == 0 then
            return
          end

          local root = vim.fn.fnamemodify(package_files[1], ":h")
          local id = root
          local path = root

          return id, path
        end,
      },
    },
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    { "'a", "<cmd>Grapple tag<cr>",            desc = "Grapple toggle tag" },
    { "'t", "<cmd>Grapple toggle_tags<cr>",    desc = "Grapple open tags window" },

    { "'s", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
    { "'d", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
    { "'f", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
    { "'g", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
    -- index out of bounds... seems like I can only have 4 tags?
    { "'w", "<cmd>Grapple select index=5<cr>", desc = "Select fifth tag" },
    { "'e", "<cmd>Grapple select index=6<cr>", desc = "Select sixth tag" },
    -- { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    -- { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
  },
}
