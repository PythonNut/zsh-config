# ============
# Auto handler
# ============

function _accept-line() {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt

  if [[ ! -n $BUFFER ]]; then
    zle clear-screen
    zle-line-init
    return 0
  fi

  # expand all aliases on return
  if [[ $#RBUFFER == 0 ]]; then
    expandAlias no_space
  fi

  zle .accept-line
}

zle -N accept-line _accept-line
