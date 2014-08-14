TMPPREFIX=/dev/shm/

function zsh_pickle () {
  emulate -LR zsh
  zparseopts -D -E i:=ID
  local session_id="zsh.$$.$ID[2]"
  typeset -p $@ > ${TMPPREFIX}$session_id
}

function zsh_unpickle () {
  zparseopts -D -E i:=ID
  emulate -LR zsh
  {
    # force variables to go up scope 
    declare() { builtin declare -g "$@"; }
    typeset() { builtin typeset -g "$@"; }
    
    local session_id="zsh.$$.$ID[2]"
    source ${TMPPREFIX}$session_id
    
  } always {
    unset -f typeset declare
  }
}

function zsh_pickle_cleanup () {
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
