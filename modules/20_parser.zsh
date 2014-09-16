# ============
# Auto handler
# ============
typeset -a _preAlias

function _accept-line() {
  emulate -LR zsh
  setopt extended_glob prompt_subst transient_rprompt
  local cmd i
  
  if [[ $BUFFER == [[:space:]]##* ||  $CONTEXT == "cont" ]]; then
    zle .accept-line
    return 0

  # if buffer is empty, clear instead
  # otherwise pass through
  elif [[ ! -n $BUFFER ]]; then
    BUFFER="clear"
    zle .accept-line
    return 0
  fi

  # remove black completion "suggestions"
  for i in $region_highlight; do
    if [[ $param == (#b)[^0-9]##(<->)[^0-9]##(<->)(*) ]]; then
      i=("$match")
      if [[ $i[3] == *black* ]] && (($i[2] - $i[1] > 0 && $i[1] > 1)); then
        BUFFER=$BUFFER[1,$i[1]]$BUFFER[$i[2],$(($#BUFFER - 1))]
      fi
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

  unset i
  
  # split by command separation delimiters
  cmd=(${(s/;/)BUFFER})
  for token in $cmd; do
    # process the command, strip whitespace
    parser "${${token##[[:space:]]#}%%[[:space:]]#}"
  done

  zle .accept-line
}

zle -N accept-line _accept-line
integer command_not_found=1

function parser() {
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
      if [[ -o $1 ]]; then
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
    elif [[ -n $(fasd -d $@) ]]; then
      alias $@="go $@"
      _preAlias+=($@)

    else
    fi
  fi
}

function preexec() {
  emulate -LR zsh

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
