#!/usr/bin/env bash

set -euo pipefail

# -----------------------------
# CONFIG
# -----------------------------
DOTFILES_REPO="https://github.com/dbo-keeganpatton/lil-bros-dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"


declare -A LINKS=(
  ["alacritty"]="$HOME/.config/alacritty"
  ["hypr"]="$HOME/.config/hypr"
  ["nvim"]="$HOME/.config/nvim"
  ["waybar"]="$HOME/.config/waybar"
  ["bashrc"]="$HOME/.bashrc"
  ["starship.toml"]="$HOME/.config/starship.toml"
  ["tmux"]="$HOME/.tmux.conf"
)


# -----------------------------
# HELPERS
# -----------------------------
log() {
  printf "\033[1;32m==>\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33mWARN:\033[0m %s\n" "$1"
}

# -----------------------------
# CHECK DEPENDENCIES
# -----------------------------
install_git() {
  if command -v git >/dev/null 2>&1; then
    return
  fi

  log "Git not found, installing..."

  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm git
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y git
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git
  else
    echo "Could not determine package manager. Install git manually."
    exit 1
  fi
}

# -----------------------------
# CLONE DOTFILES
# -----------------------------
clone_repo() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Dotfiles repo already exists, pulling updates"
    git -C "$DOTFILES_DIR" pull
  else
    log "Cloning dotfiles repo"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

# -----------------------------
# BACKUP & SYMLINK
# -----------------------------
backup_and_link() {
  mkdir -p "$BACKUP_DIR"

  for item in "${!LINKS[@]}"; do
    src="$DOTFILES_DIR/$item"
    dest="${LINKS[$item]}"

    if [ ! -e "$src" ]; then
      warn "Source not found: $src — skipping"
      continue
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
      log "Backing up existing $dest"
      mkdir -p "$(dirname "$BACKUP_DIR/$dest")"
      mv "$dest" "$BACKUP_DIR/$dest"
    fi

    log "Linking $dest → $src"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
  done
}

# -----------------------------
# MAIN
# -----------------------------
log "Starting dotfiles install"

install_git
clone_repo
backup_and_link

log "Done!"
log "Backups saved to: $BACKUP_DIR"
