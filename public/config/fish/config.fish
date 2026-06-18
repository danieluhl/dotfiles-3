# Global variables
set -gx DOTFILES_PATH "$HOME/git/dotfiles/public"

# Loads all the PATH variables
# (Note: You may need to update env.sh if it uses heavy Bash/Zsh syntax)
if test -f $DOTFILES_PATH/env.sh
    source $DOTFILES_PATH/env.sh
end

# NOTE: Oh-My-Zsh (~/.ohmyzshrc) skipped as it is incompatible with Fish.
# If you need Fish plugins, use a package manager like Fisher.

# Load AI secrets
if test -f ~/.config/secrets/.ai-secrets
    source ~/.config/secrets/.ai-secrets
end

# Load secret env vars (shared from bitwarden)
if test -f ~/.config/secrets/.env-secrets
    source ~/.config/secrets/.env-secrets
end

# Load z (Alternative: Since you use zoxide below, you can safely comment this out)
if test -f (brew --prefix)/etc/profile.d/z.sh
    source (brew --prefix)/etc/profile.d/z.sh
end

# Load aliases
if test -f ~/.aliases
    source ~/.aliases
end

# Local config
if test -f ~/.zshrc_local
    source ~/.zshrc_local
end

# Note: Zsh completion system (compinit/bashcompinit) skipped. 
# Fish handles completions automatically in ~/.config/fish/completions/

# Source misc completions
if test -f $DOTFILES_PATH/completions/index.sh
    source $DOTFILES_PATH/completions/index.sh
end

# Opam configuration (OCaml)
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish" > /dev/null 2>&1
else if test -r "$HOME/.opam/opam-init/init.zsh"
    # Fallback if opam hasn't generated a fish init yet
    source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1
end

# Google Cloud SDK PATH updates
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
else if test -f "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/path.zsh.inc"
end

# Google Cloud SDK shell command completion
if test -f "$HOME/google-cloud-sdk/completion.fish.inc"
    source "$HOME/google-cloud-sdk/completion.fish.inc"
end

# Set up FZF (Fish native integration)
if test -f ~/.fzf.fish
    source ~/.fzf.fish
end
fzf --fish | source

# Start SSH Agent
eval (ssh-agent -c) # Changed from -s to -c for Fish-compatible output

# Initialize Zoxide (Fish native)
zoxide init fish | source

# Initialize Mise (Fish native)
mise activate fish | source
mise activate fish --shims | source

# Post-load local config
if test -f ~/.zshrc.local
    source ~/.zshrc.local
end

# Make cursor a block (uncomment if desired)
# echo -ne '\e[2 q'
