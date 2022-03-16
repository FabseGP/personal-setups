autoload -U compinit; compinit
zstyle ':completion::complete:*' gain-privileges 1

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

_comp_options+=(globdots) # With hidden files

cbonsai -p

bindkey -v
export KEYTIMEOUT=1

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

alias fabse="macchina"
alias rm="rm -i"
alias "rm -r"="rm -i"
alias "rm -f"="rm -i"
alias "rm -rf"="rm -i"
alias yay="paru"
alias sway="dbus-run-session sway"