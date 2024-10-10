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
				javascript = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
				javascriptreact = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
				typescript = { "eslint_d", "prettierd" },
				typescriptreact = { "eslint_d", "prettierd" },
				svelte = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "htmlbeautifier", "prettierd", "prettier", stop_after_first = true },
				json = { "fixjson", "eslint_d", "prettierd", "prettier", stop_after_first = false },
				jsonc = { "fixjson", "eslint_d", "prettierd", "prettier", stop_after_first = false },
				yaml = { "yamlfmt", "prettier", stop_after_first = true },
				graphql = { "prettierd", "prettier", stop_after_first = true },
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
