require("mason").setup()

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion
local code_actions = null_ls.builtins.code_actions
null_ls.setup({
  sources = {
    -- lua
    formatting.stylua,
    diagnostics.luacheck,

    -- snippets
    completion.luasnip,

    -- JS
    -- diagnostics.eslint,
    -- formatting.eslint,
    -- code_actions.eslint,
    formatting.prettier.with({ extra_filetypes = { "svelte" } }),
    require("typescript.extensions.null-ls.code-actions"),
    diagnostics.tsc,
    -- code_actions.tsc,
    -- JSON
    formatting.fixjson,
    -- diagnostics.jsonlint,

    -- YAML
    diagnostics.yamllint,
    formatting.yamlfmt,

    -- CSS
    -- formatting.eslint,
    -- diagnostics.stylelint,

    -- Tailwind CSS
    -- NOTE: this conflicts with prettier for class ordering
    -- formatting.rustywind,

    -- Python
    formatting.black,
    -- diagnostics.flake8,

    -- Kotlin
    formatting.ktlint,
    -- diagnostics.ktlint,

    -- Golang
    diagnostics.golangci_lint,
    diagnostics.staticcheck,
    formatting.goimports,
    formatting.golines,
    formatting.gofumpt,

    -- Markdown
    diagnostics.markdownlint,
    -- code_actions.proselint,
    -- diagnostics.codespell,

    -- RUST
    formatting.rustfmt,
  },
})
