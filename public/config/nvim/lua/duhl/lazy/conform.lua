return {
	"stevearc/conform.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "eslint", "biome", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "eslint", "biome", "prettierd", "prettier", stop_after_first = true },
				svelte = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "htmlbeautifier", "prettierd", "prettier", stop_after_first = true },
				json = { "fixjson", "prettierd", "prettier", stop_after_first = true },
				yaml = { "yamlfmt", "prettier", stop_after_first = true },
				graphql = { "prettierd", "prettier", stop_after_first = true },
				gleam = { "gleam", stop_after_first = true },
			},
		})

		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	pattern = "*",
		-- 	callback = function(args)
		-- 		require("conform").format({ bufnr = args.buf })
		-- 	end,
		-- })
	end,
}
