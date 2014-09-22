# set the title
function _settitle() {
  emulate -LR zsh

  if (( $degraded_terminal[title] == 1 )); then
    return 0
  fi
  
  local titlestart='' titlefinish=''

  # determine the terminals escapes
  case "$_OLD_TERM" in
    (xterm*)
      titlestart='\e]0;'
      titlefinish='\a';;
    (aixterm|dtterm|putty|rxvt)
      titlestart='\033]0;'
      titlefinish='\007';;
    (cygwin)
      titlestart='\033];'
      titlefinish='\007';;
    (konsole)
      titlestart='\033]30;'
      titlefinish='\007';;
    (screen*|screen)
      titlestart='\033k'
      titlefinish='\033\';;
    (*)
      if {hash tput && tput longname} &>/dev/null; then
        titlestart="$(tput tsl)"
        titlefinish="$(tput fsl)"
      fi
  esac

  test -z "${titlestart}" && return 0
  print -Pn "${(%)titlestart}$* ${(%)titlefinish}"
}

# if title set manually, dont set automatically
function settitle() {
  emulate -LR zsh
  _titleManual=1
  _settitle $1
  if [[ ! -n $1 ]]; then
    _titleManual=0
    _settitle
  fi
}

{
  # let's initialize the title
  alias settitle="nocorrect settitle"
} &>> ~/.zsh.d/startup.log
