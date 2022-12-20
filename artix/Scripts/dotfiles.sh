#!/usr/bin/bash

# Parameters

  USER_CONFIGS_PATH="/home/$(whoami)/.config"
  USER_LOCALS_PATH="/home/$(whoami)/.local"
  USER_SCRIPTS_PATH="/home/$(whoami)/Scripts"
  USER_WALLPAPERS_PATH="/home/$(whoami)/wallpapers"
  USER_ETC_PATH="/etc"
  DOTFILES_PATH="/home/$(whoami)/Repositories/personal-setups"
  DOTFILES_CONFIGS_PATH="$DOTFILES_PATH/artix/.config"
  DOTFILES_LOCALS_PATH="$DOTFILES_PATH/artix/.local"
  DOTFILES_CONFIGS_BACKUP_PATH="$DOTFILES_PATH/backups/artix/.config"
  DOTFILES_LOCALS_BACKUP_PATH="$DOTFILES_PATH/backups/artix/.local"
  DOTFILES_CONFIGS="alacritty dinit.d easyeffects foot gtk-2.0 gtk-3.0 gtk-4.0 helix i3status-rust macchina mako MangoHud nvim river swappy sway swaylock vimiv wofi yambar zathura zsh brave-flags.conf electron-flags.conf modprobed.db"
  DOTFILES_LOCALS="bin share/applications share/fonts"
  DOTFILES_ETC="tlp.conf intel-undervolt.conf pacman.d/hooks/{electron-flags.hook,wireplumber-update.hook} zsh"
  SCRIPTS_PATH="$DOTFILES_PATH/artix/Scripts"
  SCRIPTS_BACKUP_PATH="$DOTFILES_PATH/backups/artix/Scripts"

#----------------------------------------------------------------------------------------------------------------------------------

# Create backup of dotfiles
  echo -n "Creating $DOTFILES_BACKUP_PATH for backup of any existing dotfiles in ~ ..."
  mkdir -p "$DOTFILES_CONFIGS_BACKUP_PATH"
  mkdir -p "$DOTFILES_LOCALS_BACKUP_PATH"
  mkdir -p "$SCRIPTS_BACKUP_PATH"
  echo "done"

# Move and symlink dotfiles
  for dotfile in $DOTFILES_CONFIGS; do
    echo "Moving any existing dotfiles from ~ to $DOTFILES_CONFIGS_BACKUP_PATH"
    mv "$USER_CONFIGS_PATH"/"$dotfile" "$DOTFILES_CONFIGS_BACKUP_PATH"
    echo "Creating symlink to $dotfile in home directory."
    ln -s "$DOTFILES_CONFIGS_PATH"/"$dotfile" "$USER_CONFIGS_PATH"
  done

  for dotfile in $DOTFILES_LOCALS; do
    echo "Moving any existing dotfiles from ~ to $DOTFILES_LOCALS_BACKUP_PATH"
    mv "$USER_LOCALS_PATH"/"$dotfile" "$DOTFILES_LOCALS_BACKUP_PATH"/"$dotfile"
    echo "Creating symlink to $dotfile in home directory."
    ln -s "$DOTFILES_LOCALS_PATH"/"$dotfile" "$USER_LOCALS_PATH"/"$dotfile"
  done

  for script in "$USER_SCRIPTS_PATH"/*; do
    echo "Moving any existing script from ~ to $SCRIPTS_BACKUP_PATH"
    mv "$script" "$SCRIPTS_BACKUP_PATH"
    echo "Creating symlink to $script in home directory."
    rm -rf "/home/fabse/Scripts"
    ln -sf "$SCRIPTS_PATH"/ "/home/fabse/"
  done
