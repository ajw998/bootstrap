#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────── SUDO LIFELINE ────────────────────────────── #
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "👉 1) Ensure Xcode Command-Line Tools …"
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

# ───────────────────────────────── Homebrew ───────────────────────────────── #
if ! command -v brew &>/dev/null; then
  echo "👉 2) Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"

# fish PATH
mkdir -p ~/.config/fish
grep -qxF 'set -gx PATH /opt/homebrew/bin $PATH' ~/.config/fish/config.fish 2>/dev/null \
  || echo 'set -gx PATH /opt/homebrew/bin $PATH' >> ~/.config/fish/config.fish

echo "👉 3) Updating Homebrew…"
brew update --quiet && brew upgrade --quiet

# ──────────────────────────────── Taps first ──────────────────────────────── #
brew tap hashicorp/tap
brew tap saulpw/vd

# ───────────────────────────────── Formulae ───────────────────────────────── #
echo "👉 4) Installing command-line toolchain…"
brew install \
  # Core tools                                                     \
  a2ps ansible ast-grep awscli coreutils diffutils docker docutils \
  duckdb exiftool eza fd ffmpeg findutils fzf git gnumeric go      \
  graphviz hashicorp/tap/terraform htop hyperfine jq ledger llvm   \
  luajit-openresty luarocks markdown moreutils mysql nasm          \
  neovim node openjdk pandoc pinentry-mac postgresql@14 pyright    \
  python pipx r redis ripgrep rlwrap \
  saulpw/vd/visidata sbcl stylua swift-format vim virtualfish      \
  watchman wget yarn youplot yt-dlp fish

# ──────────────────────────────── Casks ──────────────────────────────────── #
echo "👉 5) Installing desktop apps…"
brew install --cask \
  docker kitty firefox chatgpt google-chrome vlc slack microsoft-office xcode

sudo xcodebuild -license accept

# ───────────────────────────── macOS defaults ────────────────────────────── #
echo "👉 6) Applying macOS defaults…"
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 1
defaults write -g com.apple.trackpad.scaling -float 3
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
killall Finder Dock SystemUIServer || true

echo "✅  Finished!  Log out & back in (or reboot) so every PATH and default sticks."
