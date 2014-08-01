# =================================
# FASD - all kinds of teleportation
# =================================

fasd_cache="$HOME/.zsh.d/fasd-init-cache"
fasd_path="$HOME/.zsh.d/fasd/fasd"

if [[ ! -w $fasd_cache ]]; then
  echo setting fasd up
  touch $fasd_cache
  $fasd_path --init \
    zsh-hook \
    zsh-wcomp \
    zsh-wcomp-install \
    zsh-ccomp \
    zsh-ccomp-install \
    >! $fasd_cache
fi

source $fasd_cache
source $fasd_path
unset fasd_cache
unset fasd_path

alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection

alias z='fasd -e cd -d'     # cd, same functionality as j in autojump
alias zz='fasd -e cd -d -i' # cd with interactive selection
