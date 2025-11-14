return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- Use a sub-list to run only the first available formatter
        javascript = { "biome", "biome-organize-imports", "eslint", "prettier", stop_after_first = false },
        javascriptreact = { "biome", "biome-organize-imports", "eslint", "prettier", stop_after_first = false },
        typescript = { "biome", "biome-organize-imports", "eslint", "prettier", stop_after_first = false },
        typescriptreact = { "biome", "biome-organize-imports", "eslint", "prettier", stop_after_first = false },
        svelte = { "prettier", stop_after_first = true },
        css = { "prettier", stop_after_first = true },
        html = { "htmlbeautifier", "prettier", stop_after_first = false },
        json = { "prettier", stop_after_first = false },
        jsonc = { "prettier", stop_after_first = false },
        yaml = { "yamlfmt", "prettier", stop_after_first = true },
        graphql = { "prettier", stop_after_first = true },
        gleam = { "gleam", stop_after_first = true },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      },
    })
    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
