#!/bin/bash

# install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"dd

# brew list output:
# ==> Formulae
# asdf			fribidi			libspiro		lzo			starship
# autoconf		gettext			libtermkey		m4			supabase
# automake		gflags			libtiff			mpdecimal		surreal
# boost			gh			libtool			msgpack			tree-sitter
# brotli			giflib			libuninameslist		ncurses			unibilium
# c-ares			glib			libuv			neovim			unixodbc
# ca-certificates		glog			libvterm		nghttp2			wangle
# cairo			gmp			libx11			openssl@1.1		watchman
# coreutils		go			libxau			openssl@3		woff2
# double-conversion	graphite2		libxcb			pango			xorgproto
# edencommon		harfbuzz		libxdmcp		pcre			xz
# exercism		icu4c			libxext			pcre2			yarn
# fb303			jemalloc		libxrender		pixman			z
# fbthrift		jpeg-turbo		libyaml			python@3.11		zsh
# fizz			libev			lua-language-server	readline		zstd
# fmt			libevent		luajit			ripgrep
# folly			libnghttp2		luajit-openresty	rtx
# fontconfig		libpng			luv			snappy
# freetype		libsodium		lz4			sqlite

# ==> Casks
# KEYCASTR	WARP

sh ./vim-setup.sh

############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/git/dotfiles/public        # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
#files="bashrc vimrc vim zshrc oh-my-zsh private scrotwm.conf Xresources"    # list of files/folders to symlink in homedir
files="tool-versions zshrc aliases gitconfig eslintrc gitignore gitmessage npmrc profile prettier warp config/nvim config/raycast"

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the "$dir" directory ..."
cd "$dir"
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
  echo "Moving any existing dotfiles from ~ to $olddir"
  mv ~/.$file ~/dotfiles_old/
  echo "Deleting any remaining symlinks"
  rm ~/.$file
  echo "Creating symlink to $file in home directory."
  ln -sfn "$dir"/$file ~/.$file
done

# make a symlink to this directory for self-reference
ln -sfn "$dir" ~/.dotdir

