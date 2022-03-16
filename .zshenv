if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:/usr/local/bin"
fi

export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export HISTFILE="home/fabse/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file