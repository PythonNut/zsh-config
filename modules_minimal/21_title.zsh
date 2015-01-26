integer chpwd_title_manual

# set the title
function _settitle() {
  emulate -LR zsh

  if (( $degraded_terminal[title] == 1 )); then
    return 0
  fi

  local titlestart titlefinish

  # determine the terminals escapes
  case "$_OLD_TERM" in
    (xterm-256color)
      # it's possible we're recursing
      if {hash tput && tput longname} &> /dev/null && [[ -n "$(tput tsl)" ]]; then
        titlestart='\e]0;'
        titlefinish='\a'
      else
        $degraded_terminal[title]=1
      fi;;
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
      else
        $degraded_terminal[title]=1
      fi
  esac

  if [[ -z "${titlestart}" ]]; then
    return 0
  else
    $degraded_terminal[title]=1
  fi

  print -Pn "${(%)titlestart}$* ${(%)titlefinish}"
}

# if title set manually, dont set automatically
function settitle() {
  emulate -LR zsh
  chpwd_title_manual=1
  _settitle $1
  if [[ ! -n $1 ]]; then
    chpwd_title_manual=0
    _settitle
  fi
}

function title_compress_command () {
  if (( $degraded_terminal[title] != 1 && $chpwd_title_manual == 0 )); then
    local cur_command

    local host=""
    if (( $degraded_terminal[display_host] == 1 )); then
      host="$(print -P '%m') "
    fi

    if [[ $1 == *sudo* ]]; then
      cur_command=\!${${1##[[:space:]]#sudo[[:space:]]#}%%[[:space:]]*}
    elif [[ $1 == [[:space:]]#(noglob|nocorrect|time|builtin|command|exec)* ]]; then
      cur_command=${${1##[[:space:]]#[^[:space:]]#[[:space:]]#}%%[[:space:]]*}
    else
      cur_command=${${1##[[:space:]]#}%%[[:space:]]*}
    fi

    _settitle "${host}$(print -P '%1~') $cur_command"
  fi
}

add-zsh-hook preexec title_compress_command

function title_compress () {
  if (( $degraded_terminal[title] != 1 && $chpwd_title_manual == 0 )); then
    local host=""

    if (( $degraded_terminal[display_host] == 1 )); then
      host="$(print -P '%m') "
    fi

    _settitle "${host}$(print -P '%1~')"
  fi
}

add-zsh-hook precmd title_compress
title_compress
