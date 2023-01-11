local opts = {

  nu = true,

  -- Nice menu when typing `:find *.py`
  wildmode = { "longest", "list", "full" },
  wildmenu = true,

  -- Colors
  cursorcolumn = true,
  colorcolumn = "+1,+41",
  termguicolors = true,

  guicursor = "i:ver100", -- cursor to line in insert mode,
  clipboard = "unnamedplus", -- allow neovim to access clipboard,
  number = true,
  relativenumber = true,
  tabstop = 2,
  smartindent = true,
  shiftwidth = 2,
  undofile = true,
  autoindent = true,
  cursorline = true,
  scrolloff = 8,
  expandtab = true,
  hlsearch = false,
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
  cmdheight = 2,
  updatetime = 300,

  -- JavaScript
  conceallevel = 0,
  compatible = false,
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end

vim.opt.shortmess:append({ c = true })

-- vim.api.nvim_command("hi Nr guifg=#af00af")

vim.cmd([[set iskeyword+=-]])

vim.loaded_matchit = 1
