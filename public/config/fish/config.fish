# Global variables
set -gx DOTFILES_PATH "$HOME/git/dotfiles/public"

# Loads all the PATH variables and exported environment in fish-compatible syntax.
if test -f $DOTFILES_PATH/env.sh
    source $DOTFILES_PATH/env.sh
end

# NOTE: Oh-My-Zsh (~/.ohmyzshrc) and other zsh-era files intentionally not loaded.
# Use a Fish plugin manager like Fisher for shell plugins.

# Load AI secrets
if test -f ~/.config/secrets/.ai-secrets
    source ~/.config/secrets/.ai-secrets
end

# Load secret env vars (shared from bitwarden)
if test -f ~/.config/secrets/.env-secrets
    source ~/.config/secrets/.env-secrets
end

# (z skipped; using zoxide init below for directory jumping.)

# Load aliases
if test -f ~/.aliases
    source ~/.aliases
end

# Fish handles completions automatically in ~/.config/fish/completions/
# (legacy zsh-era completions moved to $DOTFILES_PATH/legacy/zsh-era/completions/)

# Opam configuration (OCaml) — only source the fish-native init.
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish" >/dev/null 2>&1
end

# Google Cloud SDK — only source the fish SDK scripts (skip zsh fallbacks).
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

# Set up FZF (Fish native integration)
if test -f ~/.fzf.fish
    source ~/.fzf.fish
end
if command -q fzf
    fzf --fish | source
end

# SSH agent: bitwarden SSH agent exposes SSH_AUTH_SOCK at
# ~/.bitwarden-ssh-agent.sock, so we only forward it here. Uncomment the
# `ssh-agent -c` line if you need to start a fallback agent in fish.
if test -S "$HOME/.bitwarden-ssh-agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"
end
# eval (ssh-agent -c) # legacy — kept commented for reference

# Initialize Zoxide (Fish native)
zoxide init fish | source

# Initialize Mise (Fish native)
mise activate fish | source
mise activate fish --shims | source

# Make cursor a block (uncomment if desired)
# echo -ne '\e[2 q'

starship init fish | source
