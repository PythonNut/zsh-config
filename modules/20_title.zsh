# set the title
function _setTitle() {
  emulate -LR zsh
  local titlestart titlefinish

  # determine the terminals escapes
  case "$_OLD_TERM" in
    (aixterm|dtterm|putty|rxvt|xterm*)
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
      if hash tput &>/dev/null; then
        if tput longname &>/dev/null; then
          titlestart="$(tput tsl)"
          titlefinish="$(tput fsl)"
        fi
      else
        titlestart=''
        titlefinish=''
      fi
  esac

  test -z "${titlestart}" && return 0
  [[ -n ${EMACS+1} || $_OLD_TERM == "dumb" ]] && return 0
  if [[ $EUID == 0 ]]; then
    printf "${titlestart}$* ! ${cur_command}${titlefinish}"
  else
    printf "${titlestart}$* ${cur_command}${titlefinish}"
  fi
}

# if title set manually, dont set automatically
function settitle() {
  emulate -LR zsh
  _titleManual=1
  _setTitle $1
  if [[ ! -n $1 ]]; then
    _titleManual=0
    chpwd_force
  fi
}

{
  # let's initialize the title
  alias settitle="nocorrect settitle"
  _setTitle $(minify_path .)
} &>> ~/.zsh.d/startup.log
