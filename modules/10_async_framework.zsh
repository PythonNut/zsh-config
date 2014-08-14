TMPPREFIX=/dev/shm/

function zsh_pickle () {
  # i - the name of the pickle
  emulate -LR zsh
  zparseopts -D -E i:=ID
  local session_id="zsh.$$.$ID[2]"
  typeset -p $@ > ${TMPPREFIX}$session_id
}

function zsh_unpickle () {
  # i - the name of the pickle
  # s - silently fail if pickle does not exists
  emulate -LR zsh
  zparseopts -D -E i:=ID s=S
  {
    # force variables to go up scope 
    declare() { builtin declare -g "$@"; }
    typeset() { builtin typeset -g "$@"; }
    
    local session_id="zsh.$$.$ID[2]"
    if [[ -f ${TMPPREFIX}$session_id || ! -n "$S" ]]; then
      source ${TMPPREFIX}$session_id
    fi
  } always {
    unset -f typeset declare
  }
}

function zsh_pickle_cleanup () {
  # i - the name of the pickle (or all pickles)
  emulate -LR zsh
  zparseopts -D -E i:=ID
  if [[ -n "$ID[2]" ]]; then
    local session_id="zsh.$$.$ID[2]"
    command rm -f ${TMPPREFIX}$session_id
  else 
    command rm -f ${TMPPREFIX}zsh.$$.*
  fi
}

add-zsh-hook zshexit zsh_pickle_cleanup
