local opts = {

  nu = true,

  -- Nice menu when typing `:find *.py`
  wildmode = { "longest", "list", "full" },
  wildmenu = true,

  -- Colors
  -- cursorcolumn = true,
  cursorline = true,
  -- colorcolumn = "+1,+41",
  termguicolors = true,

  guicursor = "i:ver100",    -- cursor to line in insert mode,
  -- sets the default paste register to clipboard: "+
  clipboard = "unnamedplus", -- allow neovim to access clipboard,
  number = true,
  relativenumber = true,
  tabstop = 2,
  smartindent = true,
  shiftwidth = 2,
  undofile = true,
  autoindent = true,
  scrolloff = 8,
  expandtab = true,
  hlsearch = true,
  undodir = os.getenv("HOME") .. "/.local/share/nvim/undo",
  swapfile = false,
  ignorecase = true,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  laststatus = 2,
  incsearch = true,
  backup = false,
  errorbells = false,
  textwidth = 80,
  wrapmargin = 2,
  wrap = false,
  -- signcolumn = "number",
  backspace = { "indent", "eol", "start" },
  pyxversion = 3,
  cmdheight = 1,
  updatetime = 300,

  -- JavaScript
  conceallevel = 0,
  compatible = false,
  guifont = "DankMono Nerd Font",
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end

vim.opt.shortmess:append({ c = true })

-- enable astro syntax highlighting
vim.g.astro_typescript = "enable"
vim.g.astro_stylus = "enable"

-- vim.api.nvim_command("hi Nr guifg=#af00af")

-- this makes it so that dashes are considered part of the word
-- vim.cmd([[set iskeyword+=-]])

vim.loaded_matchit = 1
