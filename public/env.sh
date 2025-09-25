#!/bin/zsh

# package managers
export PNPM_HOME="$HOME/pnpm"

# Set editor to vim
export EDITOR="nvim"
# Number of directories to show in the window title
export ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=2

# rust
export RUSTPATH="$HOME/.cargo"
# golang
export GOPATH="$HOME/go"
# bun
export BUN_INSTALL="$HOME/.bun"

PATH_DIRS=(
  # Homebrew packages
  "/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "$PNPM_HOME"
  "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
  "$RUSTPATH"
  "$GOPATH"
  "$BUN_INSTALL/bin"
  "$HOME/bin"
  "/usr/local/bin"
)

# Iterate over each directory in the list
for dir in "${PATH_DIRS[@]}"; do
  # Use the same safe check as before to see if the directory is already in the PATH
  # The ":$PATH:" trick handles edge cases.
  case ":$PATH:" in
    *":$dir:"*)
      # If the directory is found, do nothing.
      ;;
    *)
      # If the directory is not found, prepend it to the PATH.
      export PATH="$dir:$PATH"
      ;;
  esac
done

# Adds deno env variables to path
. "/Users/danieluhl/.deno/env"

