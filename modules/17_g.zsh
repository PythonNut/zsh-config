# ======================
# BEGIN HOLISTIC HANDLER
# ======================

alias -E g="nocorrect g"
compdef _cmd g

function g() {
  emulate -LR zsh -o no_case_glob -o no_case_match -o equals
  cmd=(${(s/ /)1})
  # if it's a file and it's not binary and I don't need to be root
  if [[ -f "$1" ]]; then
    if file $1 |& grep '\(ASCII text\|Unicode text\|no magic\)' &>/dev/null; then
      if [[ -r "$1" ]]; then
        if ps ax |& egrep -i 'emacs.*--daemon' &>/dev/null; then
          # launch GUI editor
          emacsclient -t -a "emacs" $1
        else
          # launch my editor
          $EDITOR "$1"
        fi
      else
        echo "zsh: insufficient permissions"
      fi
    else
      # it's binary, open it with xdg-open
      if [[ -n =xdg-open && -n "$DISPLAY" ]]; then
        (xdg-open "$1" &) &> /dev/null
      else
        # without x we try suffix aliases
        ($1&)>&/dev/null
      fi
    fi

  elif [[ -d "$1" ]]; then \cd "$1" # directory, cd to it
  elif [[ "" = "$1" ]]; then \cd    # nothing, go home
    
    # if it's a program, launch it in a seperate process in the background
  elif [[ $(type ${cmd[1]}) != *not* ]]; then
    ($@&)>&/dev/null

    # check if dir is registered in database
  elif [[ -n $(fasd -d $@) ]]; then
    local fasd_target=$(fasd -d $@)
    local teleport
    teleport=${${fasd_target:A}/${HOME:A}/\~}
    if [[ ${fasd_target:l} != (*${@:l}*) ]]; then
      read -k REPLY\?"zsh: teleport to$teleport? [ny] "
      if [[ $REPLY == [Yy]* ]]; then
        echo " ..."
        cd $fasd_target
      fi
    else
      echo -n "zsh: teleporting: $@ → "
      print -P "%B%F{magenta}$teleport%F{default}%b"
      cd $fasd_target
    fi
  else
    command_not_found=1
    command_not_found_handler $@
    return 1
  fi
}
