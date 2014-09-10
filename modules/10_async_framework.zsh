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
  # l - force local definition(s)
  # c - cleanup pickle afterwards
  emulate -LR zsh
  zparseopts -D -E i:=ID s=S l=L c=C
  {
    if [[ ! -n "$L" ]]; then
      # force variables to go up scope 
      declare() { builtin declare -g "$@"; }
      typeset() { builtin typeset -g "$@"; }
    fi
    
    local session_id="zsh.$$.$ID[2]"
    if [[ -f ${TMPPREFIX}$session_id || ! -n "$S" ]]; then
      source ${TMPPREFIX}$session_id
    fi
  } always {
    if [[ -n "$C" ]]; then
      zsh_pickle_cleanup -i "$ID"
    fi
    unset -f typeset declare 2>/dev/null
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

# cleanup possibly stale pickles
zsh_pickle_cleanup
add-zsh-hook zshexit zsh_pickle_cleanup
