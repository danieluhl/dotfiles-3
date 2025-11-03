
# This is where I manage my dotfiles and program configurations

In a new setup I run `public/setup.sh` which runs `public/env.sh`

The magic here is that it takes a list of files in the `public` directory and
creates symlinks to them as dotfiles from the home directory. Then `env.sh`
wires up the paths.

There's a lot of cruft around my setup that is probably only helpful for me but
the pattern of creating symlinks to a git repo is great and I highly recommend
it.

# neovim

The other thing folks may find interesting here is my neovim configs. I use
Lazy package manager where each package is its own file which makes editing
smooth.

My `remaps.lua` file may also be interesting to folks. 

