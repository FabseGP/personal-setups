# Export paths
typeset -U PATH path
path=("/home/fabse/.local/bin:/home/fabse/.cargo/bin" "$path[@]")
export PATH

# Export default folder for zimfw
export ZIM_HOME="$ZDOTDIR/.zim"

# Defaulting all apps to wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export XDG_SESSION_TYPE=wayland
export XKB_DEFAULT_LAYOUT=dk
export GDK_BACKEND=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Export default paths and editors
export XDG_CONFIG_HOME="/home/fabse/.config"
export XDG_CACHE_HOME="/home/fabse/.cache"
export EDITOR="helix"
export VISUAL="$EDITOR"
export TERMINAL_COMMAND="footclient"
export npm_config_prefix="$HOME/.local"
