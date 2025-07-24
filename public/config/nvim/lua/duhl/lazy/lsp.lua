return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
    "williamboman/mason-lspconfig.nvim",
    "williamboman/mason.nvim",
  },

  config = function()
    local function organize_imports()
      local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = "",
      }
      vim.lsp.buf.execute_command(params)
    end

    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls", "rescriptls" },
    })

    local blink = require("blink.cmp")
    local lspconfig = require("lspconfig")

    -- see a list of servers here: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    local servers = {
      elmls = {},
      rust_analyzer = {},
      astro = {},
      gleam = {},
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "it", "describe", "before_each", "after_each" },
            },
          },
        },
      },
      ts_ls = {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          -- vim.api.nvim_create_autocmd("BufWritePre", {
          --   buffer = bufnr,
          --   command = "OrganizeImports",
          -- })
        end,
        commands = {
          OrganizeImports = {
            organize_imports,
            description = "Organize Imports",
          },
        },
        single_file_support = false,
      },
      rescriptls = {
        cmd = { "rescript-language-server", "--stdio" },
        commands = {
          ResOpenCompiled = {
            require("rescript-tools").open_compiled,
            description = "Open Compiled JS",
          },
          ResCreateInterface = {
            require("rescript-tools").create_interface,
            description = "Create Interface file",
          },
          ResSwitchImplInt = {
            require("rescript-tools").switch_impl_intf,
            description = "Switch Implementation/Interface",
          },
        },
      },
      biome = {
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                filter = function(client)
                  return client.name == "biome"
                end,
              })
            end,
          })
        end,
      },
      eslint = {
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      },
      svelte = {},
      jsonls = {},
      elixirls = {},
      denols = {
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
        init_options = {
          lint = true,
          unstable = true, -- Enable unstable APIs (if needed)
          suggest = {
            imports = {
              hosts = {
                ["https://deno.land"] = true,
              },
            },
          },
        },
      },
      tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
      },
    }
    for server, config in pairs(servers) do
      -- passing config.capabilities to blink.cmp merges with the capabilities in your
      -- `server.capabilities, if you've defined it
      config.capabilities = blink.get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end

    vim.diagnostic.config({
      virtual_text = true,
    })

    -- diagnostics global defaults
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Disable underline, it's very annoyinglsp
      underline = true,
      virtual_text = true,
      -- Enable virtual text, override spacing to 4
      -- virtual_text = {spacing = 4},
      -- Use a function to dynamically turn signs off
      -- and on, using buffer local variables
      signs = true,
      -- update_in_insert = false,
    })

    -- CMP SETUP
    -- local cmp = require("cmp")
    -- local types = require("cmp.types")
    -- local cmp_action = require("lsp-zero").cmp_action()
    -- local ls = require("luasnip")

    -- cmp.setup({
    -- 	preselect = types.cmp.PreselectMode.Item,
    -- 	mapping = cmp.mapping.preset.insert({
    -- 		["<C-n>"] = cmp_action.luasnip_jump_forward(),
    -- 		["<C-p>"] = cmp_action.luasnip_jump_backward(),
    -- 		["<Tab>"] = nil,
    -- 		["<S-Tab>"] = nil,
    -- 		["<CR>"] = cmp.mapping.confirm({ select = false }),
    -- 		["<C-Space>"] = cmp.mapping.complete(),
    -- 	}),
    -- 	completion = {
    -- 		completeopt = "menu,menuone,noinsert",
    -- 	},
    -- 	snippet = {
    -- 		expand = function(args)
    -- 			ls.lsp_expand(args.body) -- For `luasnip` users.
    -- 		end,
    -- 	},
    -- 	window = {
    -- 		completion = cmp.config.window.bordered(),
    -- 		documentation = cmp.config.window.bordered(),
    -- 	},
    -- 	formatting = {
    -- 		fields = { "kind", "abbr", "menu" },
    -- 	},
    -- 	sources = cmp.config.sources({
    -- 		{ name = "nvim_lsp", keyword_length = 1 },
    -- 		{ name = "luasnip", keyword_length = 2 },
    -- 		{ name = "buffer", keyword_length = 1 },
    -- 		{ name = "path", keyword_length = 3 },
    -- 		{ name = "spell", keyword_length = 5 },
    -- 	}),
    -- experimental = {
    -- ghost_text = true,
    -- native_menu = false,
    -- },
    -- enabled = function()
    -- 	-- disable when in a comment or in command mode
    -- 	if
    -- 		require("cmp.config.context").in_treesitter_capture("comment") == true
    -- 		or require("cmp.config.context").in_syntax_group("Comment")
    -- 		or vim.bo.buftype == "prompt"
    -- 	then
    -- 		return false
    -- 	else
    -- 		return true
    -- 	end
    -- end,
    -- })
  end,
}
