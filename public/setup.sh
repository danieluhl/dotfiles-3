#!/bin/bash

# install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"dd

# brew list output:
# ==> Formulae
# asdf			fmt			libsodium		lz4			rtx
# autoconf		folly			libtasn1		lzo			ruby
# automake		fontconfig		libtermkey		m4			snappy
# autopep8		freetype		libtool			mpdecimal		sqlite
# bash			gdbm			libunistring		msgpack			starship
# bdw-gc			gettext			libuv			ncurses			supabase
# boost			gflags			libvterm		neovim			tree-sitter
# brotli			gh			libx11			nettle			unbound
# c-ares			glib			libxau			openssl@1.1		unibilium
# ca-certificates		glog			libxcb			openssl@3		unixodbc
# cairo			gmp			libxdmcp		p11-kit			wangle
# coreutils		gnutls			libxext			pcre			xorgproto
# double-conversion	guile			libxrender		pcre2			xz
# edencommon		icu4c			libyaml			pixman			yarn
# emacs			jansson			lua			pkg-config		z
# exercism		libevent		lua-language-server	python@3.10		zsh
# fb303			libffi			luajit			python@3.11		zstd
# fbthrift		libidn2			luajit-openresty	python@3.9
# fd			libnghttp2		luarocks		readline
# fizz			libpng			luv			ripgrep

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

files="tool-versions zshrc aliases gitconfig eslintrc gitignore "\
"gitmessage npmrc profile prettier warp config/nvim config/raycast "\
"config/karabiner config/starship.toml"

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

