# ========================================
# Title + Path compression + chpwd handler
# ========================================
_titleManual=0

TMPPREFIX=/dev/shm/ # use shared memory
LAST_PWD=${${:-.}:A}
LAST_TITLE=""

function chpwd_async_worker () {
  emulate -LR zsh
  chpwd_s_str=$(minify_path_smart .)

  printf "%s" $chpwd_s_str >! ${TMPPREFIX}/zsh-s-prompt.$$

  # Signal the parent shell to update the prompt.
  kill -USR2 $$
}

function chpwd_async_worker_subshell () {
  emulate -LR zsh
  chpwd_s_str=$(minify_path_smart .)
  typeset -f minify_path_smart
  local GPID
  #chpwd_j_str=$(minify_path_fasd $(pwd))
  GPID=$(ps -fp $PPID | awk "/$PPID/"' { print $3 } ')
  GPID=$(ps -fp $GPID | awk "/$GPID/"' { print $3 } ')
  
  printf "%s" $chpwd_s_str >! /dev/shm/zsh-s-prompt.$GPID

  # Signal the parent shell to update the prompt.
  kill -USR2 $GPID
}

function TRAPUSR2 {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  chpwd_s_str=$(cat "${TMPPREFIX}zsh-s-prompt.$$" 2> /dev/null)
  command rm ${TMPPREFIX}zsh-s-prompt.$$ &> /dev/null

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}

# Build the prompt in a background job.
chpwd_async_worker &!
function chpwd() {
  emulate -LR zsh
  cdpath=("${(s/ /)$(eval echo $(echo "\${(@)raw_cdpath:#${${:-.}:A}/}"))}")
  if [[ ${${:-.}:A} != $LAST_PWD ]]; then
    chpwd_force
  elif [[ $LAST_TITLE == "" ]]; then
    chpwd_force
  else
    _setTitle $LAST_TITLE
  fi
}

function chpwd_force() {
  emulate -LR zsh
  setopt equals
  if [[ -n $(ps $PPID 2> /dev/null | grep =mc) ]]; then
    chpwd_s_str=${${:-.}:A:t} # or $(basename $(pwd))
    zle && zle reset-prompt
  else
    chpwd_str=$(minify_path .)
    if [[ $_titleManual == 0 ]]; then 
      LAST_TITLE="$(minify_path .) [$(minify_path_fasd .)]"
      _setTitle $LAST_TITLE
    fi
    (chpwd_async_worker &!) 2> /dev/null
  fi
  LAST_PWD=${${:-.}:A}
}
