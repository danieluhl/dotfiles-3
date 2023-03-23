#!/bin/zsh

# to find a homebrew package to get the path use `brew info [package]`

# User configuration
export PATH=$PATH:/usr/local/share/npm/bin
export PATH=$PATH:/usr/local/lib/node_modules
export PATH=$PATH:~/Library/Python/3.8/bin
export PATH=$PATH:/usr/local/lib/node_modules
export PATH=$PATH:~/bin

# rustlang bin to path
export RUSTPATH=~/.cargo
export PATH=$PATH:$RUSTPATH/bin

# To install rust analyzer and get it in PATH:
# > rustup component add rust-analyzer
# > ln -s ~/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer ~/.cargo/rust-analyzer

export PATH=$PATH:$RUSTPATH/bin

# Add golang bin to PATH
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# package managers
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PNPM_HOME="/Users/duhl/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Top priority paths go at the start of path
export PATH="/usr/local/bin:$PATH"

# Homebrew packages
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# Set editor to vim
export EDITOR="nvim"
