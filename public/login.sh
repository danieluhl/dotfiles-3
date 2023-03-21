#!/bin/zsh

LOGIN_DATE_FILE="$DOTFILES_PATH/lastLogin.sh"
source $LOGIN_DATE_FILE

if [[ -v LOGIN_DATE ]];
then
  echo "Last login: $LOGIN_DATE"
else
  LOGIN_DATE=$(date +"%Y-%m-%d");
fi


CURRENTDATE=`date +"%Y-%m-%d"`
DIFF=$(( ($(gdate -d $CURRENTDATE +%s) - $(gdate -d $LOGIN_DATE +%s)) / 86400 )) 

if [[ $DIFF > 0 ]];
then
  echo "You haven't pulled latest dotfiles for $DIFF days, pulling now"
  prevDir=$(pwd)
  cd ~/git/dotfiles

  git pull
  git status

  npx get-warp-bg
  cd $prevDir

  echo "Writing login date: $CURRENTDATE"
  echo "export LOGIN_DATE=\"$CURRENTDATE\"" > $LOGIN_DATE_FILE
else
  echo "All set"
fi
