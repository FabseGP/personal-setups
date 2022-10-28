#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)
  USER_CONFIGS_PATH="/home/$(whoami)/.config"
  USER_LOCALS_PATH="/home/$(whoami)/.local"
  USER_SCRIPTS_PATH="/home/$(whoami)/Scripts"
  USER_WALLPAPERS_PATH="/home/$(whoami)/wallpapers"
  USER_ETC_PATH="/home/$(whoami)/wallpapers"
  DOTFILES_PATH="/home/$(whoami)/Repositories/personal-setups"
  DOTFILES_CONFIGS_PATH="$DOTFILES_PATH/artix/.config"
  DOTFILES_SCRIPTS_PATH="$DOTFILES_PATH/artix/.config"
  DOTFILES_BACKUP_PATH="$DOTFILES_PATH/backups/artix"
  DOTFILES_CONFIGS="alacritty dinit.d easyeffects foot gtk-2.0 gtk-3.0 gtk-4.0 helix i3status-rust macchina MangoHud nvim river rsnapshot swappy sway swaylock wimiv wofi yambar zathura zsh brave-flags.conf electron-flags.conf"
  DOTFILES_LOCALS="/bin /local/share /local/fonts"
  DOTFILES_SCRIPTS="*"

#----------------------------------------------------------------------------------------------------------------------------------

# create dotfiles_old in homedir
  echo -n "Creating $DOTFILES_BACKUP_PATH for backup of any existing dotfiles in ~ ..."
  mkdir -p $DOTFILES_BACKUP_PATH
  echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
  for dotfile in $DOTFILES_CONFIGS; do
    echo "Moving any existing dotfiles from ~ to $DOTFILES_BACKUP_PATH"
    mv $USER_CONFIGS_PATH/$dotfile $DOTFILES_BACKUP_PATH
    echo "Creating symlink to $dotfile in home directory."
    ln -s $DOTFILES_CONFIGS_PATH/$file $USER_CONFIGS_PATH/$dotfile
  done
