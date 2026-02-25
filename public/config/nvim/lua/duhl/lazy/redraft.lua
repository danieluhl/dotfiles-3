return {
  "jim-at-jibba/nvim-redraft",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {} } },
  },
  event = "VeryLazy",
  build = "cd ts && npm install && npm run build",
  opts = {
    llm = {
      models = {
        -- { provider = "openai", model = "gpt-5.3-codex", label = "codex latest" },
        { provider = "openai", model = "gpt-4o-mini", label = "GPT-4o Mini" },
        { provider = "openai", model = "gpt-4o",      label = "GPT-4o" },
        -- { provider = "anthropic",  model = "claude-3-5-sonnet-20241022",     label = "Claude 3.5 Sonnet" },
        -- { provider = "xai",        model = "grok-4-fast-non-reasoning",      label = "Grok 4 Fast" },
        -- { provider = "copilot",    model = "gpt-4o",                         label = "Copilot GPT-4o" },
        -- { provider = "openrouter", model = "anthropic/claude-3.5-sonnet",    label = "OpenRouter Claude" },
        -- { provider = "cerebras",   model = "qwen-3-235b-a22b-instruct-2507", label = "Cerebras Qwen" },
      },
      default_model_index = 1,
    },
    keys = {
      { "<leader>ae", function() require("nvim-redraft").edit() end,         mode = "v",              desc = "AI Edit Selection" },
      { "<leader>am", function() require("nvim-redraft").select_model() end, desc = "Select AI Model" },
    },
  },
}
