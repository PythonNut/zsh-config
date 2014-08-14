# ============
# Auto handler
# ============
_preAlias=()

function _accept-line() {
  emulate -LR zsh
  setopt extended_glob prompt_subst
  local cmd i
  
  # if buffer is effectively empty, clear instead
  # otherwise pass through
  if [[ $BUFFER == "" ]]; then
    BUFFER="clear"
    zle .accept-line
    return 0

  elif [[ $BUFFER == [[:space:]]# || $BUFFER[1] == " " ]]; then
    zle .accept-line
    return 0
  fi

  # remove black completion "suggestions"
  for i in $region_highlight; do
    i=("${(s/ /)i}")
    if [[ $i[3] == *black* ]] && ((${${i[2]%% *}:-0} - ${${i[1]%% *}:-0} > 0 && ${${i[1]%% *}:-0} > 2)); then
      BUFFER=$BUFFER[1,$i[1]]$BUFFER[$i[2],$(($#BUFFER - 1))]
    fi
  done

  # expand all aliases on return
  if [[ $#RBUFFER == 0 ]]; then
    expandAlias no_space
  fi
  
  # ignore prefix commands
  if [[ $cmd[1] == (nocorrect|noglob|exec|command|builtin|-) ]]; then
    cmd=($cmd[2,${#cmd}])
  fi

  # set the current command
  cur_command=$cmd[1]
  
  # split it by command seperation delimiters
  if [[ $BUFFER != (*\$\{*\}*) ]]; then
    cmd=(${(ps:;:e)${(ps:|:e)${(ps:|&:e)${(ps:&&:e)${(ps:||:)BUFFER}}}}})
    for token in $cmd; do
      # process the command, strip whitespace
      process ${${token##[[:space:]]#}%%[[:space:]]#}
    done
  fi

  zle .accept-line

  # hack the syntax highlighter to highlight old lines
  zle magic-space
  _zsh_highlight
  zle backward-delete-char
  _zsh_highlight
}

zle -N _accept-line
zle -N accept-line _accept-line
command_not_found=1

function process() {
  emulate -LR zsh
  setopt extended_glob null_glob ksh_glob
  if [[ $(type $1) == (*not*|*suffix*) ]]; then
    # skip assignments
    if [[ $1 == (*=*) ]]; then
      return 0
    
      # handle "/" teleport case
    elif [[ $1 == "/" ]]; then
      alias "$1"="cd /"
      _preAlias+=($1)
      
      # if it's in CDPATH, teleport there
    elif [[ ${${${$(echo $cdpath*(/))%/}##*/}[(r)${1%/}]} == ${1%/} ]]; then
      alias "$1"="cd ${1%/} >/dev/null; echo zsh: teleport: \$fg[blue]\$FX[bold]\${${:-.}:A}\$reset_color"
      _preAlias+=($1)
      
      # if it contains math special characters, try to evaluate it
    elif [[ ! -f "$1" && ! -d "$1" && $1 == *[\(\)\[\]/*-+%^]* ]]; then
      local s
      # check if it compiles
      s=$(python3 -c "print(compile('$1','','eval').co_names)" 2> /dev/null)
      if [[ $? == 0 ]]; then
        # it compiled, eval it
        alias "$1"="python -c 'print($1)'"
        _preAlias+=($1)

      elif [[ $1 == *[\(\)*+~^\&\[\]]* ]]; then
        # it didn't. it must be some kind of glob
        if [[ $options[globdots] == "on" ]]; then
          alias "$1"="unsetopt globdots;LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -dhx --group-directories-first;setopt globdots"
        else
          alias "$1"="LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -dhx --group-directories-first"
        fi
        if [[ $1 == "**" ]]; then
          # ** renders single level recursive summary
          alias "$1"="LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -h"
        fi
        _preAlias+=($1)
      fi
      
      # it's a file forward to go
    elif [[ -f "$1" && $(type $1) == (*not*)  && ! -x $1 ]]; then
      alias $1="go $1" && command_not_found=0
      _preAlias+=("$1")

      # If it's an option, set/unset it
    elif [[ -n $options[${1:l:gs/_/}] ]]; then
      if [[ $options[${1:l:gs/_/}] == "on" ]]; then
        alias "$1"="echo \"unsetopt: $1\"; unsetopt $1"
      else
        alias "$1"="echo \"setopt: $1\"; setopt $1"
      fi
      _preAlias+=($1)

      # if it's a parameter, echo it
    elif [[ -n ${(P)1} ]]; then
      alias "$1"="echo ${(P)1}"
      _preAlias+=($1)
      
      # last resort, forward to teleport handler
      # elif [[ -n $(j --stat | cut -f2 | sed -e '$d' | fgrep -i $1) ]]; then
    elif [[ -n $(fasd -d $@) ]]; then
      alias $@="go $@"
      _preAlias+=($@)

    else
    fi
  fi
}

function preexec() {
  emulate -LR zsh
  chpwd

  unalias ${(j: :)_preAlias} &> /dev/null
  _preAlias=( )
}

function command_not_found_handler() {
  # only error out if the tokenizer failed
  if [[ $command_not_found == 1 ]]; then
    echo "zsh: command not found:" $1
  fi
  command_not_found=1
}
