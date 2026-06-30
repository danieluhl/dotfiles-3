-- NOTE: to install syncthing: brew install syncthing && brew services start syncthing

os.execute("sh ./vim-setup.sh")

local home = os.getenv("HOME")

local dir = home .. "/git/dotfiles/public"
local olddir = home .. "/dotfiles_old"

local links = {
  [home .. "/.aliases"] = "aliases",
  [home .. "/.aliases.local"] = "aliases.local",
  [home .. "/.claude/commands"] = "agents/commands",
  [home .. "/.claude/skills"] = "agents/skills",
  [home .. "/.claude/rules"] = "agents/rules",
  [home .. "/.agents/commands"] = "agents/commands",
  [home .. "/.agents/skills"] = "agents/skills",
  [home .. "/.agents/rules"] = "agents/rules",
  [home .. "/.codex/commands"] = "agents/commands",
  [home .. "/.codex/skills"] = "agents/skills",
  [home .. "/.codex/rules"] = "agents/rules",
  [home .. "/.config/opencode/commands"] = "agents/commands",
  [home .. "/.config/opencode/skills"] = "agents/skills",
  [home .. "/.config/opencode/rules"] = "agents/rules",
  [home .. "/.cursor/commands"] = "agents/commands",
  [home .. "/.cursor/skills"] = "agents/skills",
  [home .. "/.cursor/rules"] = "agents/rules",
  [home .. "/.config/fish"] = "config/fish",
  [home .. "/.config/ghostty"] = "config/ghostty",
  [home .. "/.config/karabiner"] = "config/karabiner",
  [home .. "/.config/kitty"] = "config/kitty",
  [home .. "/.config/nvim"] = "config/nvim",
  [home .. "/.config/presenterm"] = "config/presenterm",
  [home .. "/.config/raycast"] = "config/raycast",
  [home .. "/.config/zed"] = "config/zed",
  [home .. "/.eslintrc"] = "eslintrc",
  [home .. "/.gitconfig"] = "gitconfig",
  [home .. "/.gitconfig.local"] = "gitconfig.local",
  [home .. "/.gitignore"] = "gitignore",
  [home .. "/.gitmessage"] = "gitmessage",
  [home .. "/.ohmyzshrc"] = "ohmyzshrc",
  [home .. "/.pnpm-completion.zsh"] = "pnpm-completion.zsh",
  [home .. "/.profile"] = "profile",
  [home .. "/.tool-versions"] = "tool-versions",
  [home .. "/.warp"] = "config/warp",
  [home .. "/.zshrc"] = "zshrc",
  [home .. "/.zshrc.local"] = "zshrc.local",
}

local function shell_quote(s)
  return "'" .. s:gsub("'", [["'"']]) .. "'"
end

os.execute("mkdir -p " .. shell_quote(olddir))

for dest, src in pairs(links) do
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
