#!/bin/bash

sh ./vim-setup.sh

############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

# NOTE: to setup github ssh keys read this 
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
# you can do `gh auth login` to login to github and `gh auth setup-ssh` to setup ssh keys

########## Variables

dir=~/git/dotfiles/public        # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory

# Each of these files gets a symlink from home, 
# e.g. ~/.aliases -> ./aliases
# ~/.config/zed -> ./config/zed
files=(
  aliases
  aliases.local
  config/ghostty
  config/karabiner
  config/kitty
  config/nvim
  config/opencode
  config/presenterm
  config/raycast
  config/zed
  eslintrc
  gitconfig
  gitconfig.local
  gitignore
  gitmessage
  ohmyzshrc
  pnpm-completion.zsh
  profile
  tool-versions
  warp
  zshrc
  zshrc.local
)

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the "$dir" directory ..."
cd "$dir"
echo "done"

# Move any existing dotfiles in homedir to dotfiles_old directory
#  then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in "${files[@]}"; do
  echo "Moving any existing dotfiles from ~ to $olddir"
  mv ~/.$file ~/dotfiles_old/
  echo "Deleting any remaining symlinks"
  rm ~/.$file
  echo "Creating symlink to $file in home directory."
  ln -sfn "$dir"/$file ~/.$file
done

# make a symlink to this directory for self-reference
ln -sfn "$dir" ~/.dotdir

# add scratch directory if it doesn't exist
mkdir -p ~/Documents/scratch

# Add a symlink to my scratch file that syncs through icloud drive
ln -s ~/Documents/scratch ~/git/scratch
