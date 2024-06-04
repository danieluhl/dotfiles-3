-- Borrowed from https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

-- Install Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ","

require("lazy").setup({
	spec = "duhl.lazy",
	change_detection = { notify = false },
})
