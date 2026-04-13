# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi

# FE shell autocompletions with @bomb.sh
# These are installed locally now
# source <(tab pnpm zsh)
# npx @bomb.sh/tab pnpm zsh > $DOTFILES_PATH/completions/pnpm-completion.zsh
[[ -f $DOTFILES_PATH/completions/pnpm-completion.zsh ]] && source $DOTFILES_PATH/completions/pnpm-completion.zsh

# Gleam completions (https://github.com/giacomocavalieri/zsh_gleam_completions)
[[ -f $DOTFILES_PATH/completions/gleam-completion.zsh ]] && source $DOTFILES_PATH/completions/gleam-completion.zsh
compdef _gleam gleam

# Git completions
[[ -f $DOTFILES_PATH/completions/git-completion.zsh ]] && source $DOTFILES_PATH/completions/git-completion.zsh
[[ -f $DOTFILES_PATH/completions/git-completion-local.zsh ]] && source $DOTFILES_PATH/completions/git-completion-local.zsh
