# =================================
# FASD - all kinds of teleportation
# =================================

function {
  emulate -LR zsh
  local fasd_cache=$ZDOTDIR/fasd-init-cache
  local fasd_path=$ZDOTDIR/fasd/fasd

  source $fasd_path

  if [[ ! -w $fasd_cache ]]; then
    touch $fasd_cache
    $fasd_path --init \
      zsh-hook \
      zsh-wcomp \
      zsh-wcomp-install \
      > $fasd_cache
  fi

  source $fasd_cache
}

# interactive directory selection
# interactive file selection
alias sd='fasd -sid'
alias sf='fasd -sif'

# cd, same functionality as j in autojump
alias j='fasd -e cd -d'
