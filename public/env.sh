#!/usr/bin/env fish
# Compatible with fish's `source`. If you ever need a bash/zsh version,
# duplicate this file as env.sh for sh-style and keep env.sh as the fish one.

# PRESENTERM
set -gx PRESENTERM_CONFIG_FILE "$HOME/.config/presenterm/config.yaml"

# gog-cli
set -gx GOG_ACCOUNT

# package managers
set -gx PNPM_HOME "$HOME/pnpm"

# Set editor
set -gx EDITOR "nvim"
set -gx ZSH_WINDOW_TITLE_DIRECTORY_DEPTH 2

# rust / golang / bun
set -gx RUSTPATH "$HOME/.cargo"
set -gx GOPATH "$HOME/go"
set -gx BUN_INSTALL "$HOME/.bun"

# Directories to prepend (commented-out options preserved from the original)
set -l PATH_DIRS \
  "/opt/homebrew/sbin" \
  "/opt/homebrew/bin" \
  "$PNPM_HOME" \
  "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin" \
  "$RUSTPATH" \
  "$GOPATH" \
  "$BUN_INSTALL/bin" \
  "$HOME/bin" \
  "$HOME/.local/bin" \
  "/usr/local/bin" \
  "/opt/homebrew/opt/openssl@3/bin" \
  "/opt/homebrew/opt/curl/bin" \
  # "/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin" \
  # "/opt/homebrew/lib/ruby/gems/3.4.0/bin" \
  # "$HOME/.rbenv/bin" \
  # "$HOME/.local/share/mise/shims"

for dir in $PATH_DIRS
    if not string match -q ":*$dir:*" "':$PATH:'"
        set -gx PATH "$dir:$PATH"
    end
end

# Deno env (its env file uses bash `case`; capture PATH via bash subshell)
if test -d "$HOME/.deno"
    set -l deno_path (bash -c 'source "$HOME/.deno/env" >/dev/null 2>&1 && echo "$PATH"')
    if test -n "$deno_path"
        set -gx PATH $deno_path
    end
end
