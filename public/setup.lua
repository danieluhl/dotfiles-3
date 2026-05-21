os.execute("sh ./vim-setup.sh")

local home = os.getenv("HOME")

local dir = home .. "/git/dotfiles/public"
local olddir = home .. "/dotfiles_old"

local links = {
  ["aliases"] = home .. "/.aliases",
  ["aliases.local"] = home .. "/.aliases.local",
  -- note that some configs land in /config and others land in the root home
  -- directory
  ["config/claude"] = home .. "/.claude",
  ["config/codex"] = home .. "/.codex",
  ["config/cursor"] = home .. "/.cursor",
  ["config/ghostty"] = home .. "/.config/ghostty",
  ["config/karabiner"] = home .. "/.config/karabiner",
  ["config/kitty"] = home .. "/.config/kitty",
  ["config/nvim"] = home .. "/.config/nvim",
  ["config/opencode"] = home .. "/.config/opencode",
  ["config/presenterm"] = home .. "/.config/presenterm",
  ["config/raycast"] = home .. "/.config/raycast",
  ["config/warp"] = home .. "/.warp",
  ["config/zed"] = home .. "/.config/zed",
  ["eslintrc"] = home .. "/.eslintrc",
  ["gitconfig"] = home .. "/.gitconfig",
  ["gitconfig.local"] = home .. "/.gitconfig.local",
  ["gitignore"] = home .. "/.gitignore",
  ["gitmessage"] = home .. "/.gitmessage",
  ["ohmyzshrc"] = home .. "/.ohmyzshrc",
  ["pnpm-completion.zsh"] = home .. "/.pnpm-completion.zsh",
  ["profile"] = home .. "/.profile",
  ["tool-versions"] = home .. "/.tool-versions",
  ["zshrc"] = home .. "/.zshrc",
  ["zshrc.local"] = home .. "/.zshrc.local",
}

local function shell_quote(s)
  return "'" .. s:gsub("'", [["'"']]) .. "'"
end

os.execute("mkdir -p " .. shell_quote(olddir))

for src, dest in pairs(links) do
  local source = dir .. "/" .. src

  print("Backing up " .. dest)
  os.execute("mv " .. shell_quote(dest) .. " " .. shell_quote(olddir) .. " 2>/dev/null")

  print("Removing existing " .. dest)
  os.execute("rm -rf " .. shell_quote(dest))

  print("Linking " .. dest .. " -> " .. source)
  os.execute("ln -sfn " .. shell_quote(source) .. " " .. shell_quote(dest))
end

local dotdir = home .. "/.dotdir"
local scratch = home .. "/Documents/scratch"
local git_scratch = home .. "/git/scratch"

print("Linking " .. dotdir .. " -> " .. dir)
os.execute("ln -sfn " .. shell_quote(dir) .. " " .. shell_quote(dotdir))

print("Creating scratch directory " .. scratch)
os.execute("mkdir -p " .. shell_quote(scratch))

print("Linking " .. git_scratch .. " -> " .. scratch)
os.execute("ln -sfn " .. shell_quote(scratch) .. " " .. shell_quote(git_scratch))
