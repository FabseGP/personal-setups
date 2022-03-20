# Export ~/.local/bin to path
typeset -U PATH path
path=("$HOME/.local/bin" "$path[@]")
export PATH

# Export default folder for zsh-files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZIM_HOME="$ZDOTDIR/.zim"

# Defaulting all apps to wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=wayland
export XDG_SESSION_DESKTOP=wayland
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Export default paths and editors
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export EDITOR="nvim"
export VISUAL="$EDITOR"
