vim.cmd([[
    augroup ftplugin
      au!
      # don't automatically add comment prefix on next line
      au BufWinEnter * set formatoptions-=cro
      au BufNewFile,BufRead *.json setl filetype=jsonc " To allow comments on json files
      au FileType man setl laststatus=0 noruler
      au FileType vim,html,css,json,javascript,javascriptreact,typescript,typescriptreact,lua,sh,zsh setl sw=2
      au TermOpen term://* setl nornu nonu nocul so=0 scl=no
    augroup END
]])
