if (( ! $+functions[_git] )); then
    echo "Warning: _git completion function is not yet defined. Check OMZ loading order."
else
  # pull
  # compdef _git gp=git-pull
  # push
  # compdef _git gpu=git-push
  # checkout
  compdef _git gc=git-checkout
  # branch
  # compdef _git gb=git-branch
  # compdef _git gbd=git-branch
  # fetch
  # compdef _git gf=git-fetch
  # merge
  # compdef _git gms=git-merge
  # compdef _git gm=git-merge
fi
