zimfw() { source /home/fabse/.config/zsh/.zim/zimfw.zsh "${@}" }
zmodule() { source /home/fabse/.config/zsh/.zim/zimfw.zsh "${@}" }
typeset -g _zim_fpath=(/home/fabse/.config/zsh/.zim/modules/zsh-completions/src)
fpath=(${_zim_fpath} ${fpath})

