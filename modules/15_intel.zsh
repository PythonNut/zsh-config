# ========================================
# Autogen Options - manfile/GNUdoc scraper
# ========================================

function manopts() {
  emulate -LR zsh
  findopts() {
    if [ "$1" = -a ]; then
      shift; EXPR="$@"
    fi
    perl -n -e ' while ( /'"$EXPR"'/g ) { print("$1\n"); } '
  }
  'man' "$@" 2> /dev/null | col -bx | findopts -a "[    ]((-|--)[A-Za-z0-9-=]+)"
}

function automan() {
  zparseopts -D -E v=V
  emulate -LR zsh
  local -a cmds comp man_names command_names autogens

  # the names of man pages
  # the names of commands in path
  # the names of completion functions
  man_names=("${(fo)$(whatis -r . |cut -f1 -d' ')}")
  command_names=("${(kos/ /)commands}")
  comp=${${(M)${(koni)functions}:#_*}/_}

  
  cmds=${command_names:*man_names}
  cmds=("${(s/ /)cmds}")
  comp=("${(s/ /)comp}")
  autogens=${cmds:|comp}
  if [[ -n $V ]]; then
    print -l ${(s/ /)autogens}
  fi
  for i in ${(s/ /)autogens}; do
    _autogen_$i() {
      emulate -LR zsh
      setopt extended_glob
      local -a args a
      if [[ $words[-1] = (*-*) ]]; then
        name=${0:9}
        manpage=$(man $name | col -bx)
        for arg in $(manopts $name | sort -u); do
          a=$arg
          if [[ $arg == (*=*) ]]; then
            a=${${(@s/=/)arg}[1]}
          fi
          arg=$(echo $manpage | grep -P -- "[^a-zA-Z]${a}[^a-zA-Z]")
          arg=${arg//[[:space:]]##/ }
          if [[ -n $a ]]; then
            args+="()${a}[(m)${(q)arg}]"
          fi
        done
        _arguments -s $args
      fi
      _files
    }
    compdef _autogen_$i $i
  done
}

function mangen() {
  emulate -LR zsh
  echo -e "$1" >> ~/.zsh.d/mangen
  sort ~/.zsh.d/mangen -o ~/.zsh.d/mangen
}

# scrapes helpfiles looking for arguments
function autohelp() {
  emulate -LR zsh
  if [[ ! -f ~/.zsh.d/helpgen ]]; then
    return 1
  fi
  for cmd in $(<~/.zsh.d/helpgen); do
    compdef _gnu_generic $cmd
  done
}

# helper function, mark a command as autohelpable
function helpgen() {
  emulate -LR zsh
  echo -e "$1" >> ~/.zsh.d/helpgen
  sort ~/.zsh.d/helpgen -o ~/.zsh.d/helpgen
  compdef _gnu_generic $1
}

autohelp
automan

zsh-mime-setup

function auto_recompile () {
  autoload -Uz zrecompile
  zrecompile ~/.zsh.d/.zshrc

  for zsh_module in ~/.zsh.d/modules/*.zsh(n); do
    zrecompile $zsh_module
  done

  for file in ~/.zsh.d/local/*.zsh(n); do
    zrecompile $file
  done
}

# asynchronously recompile in the background
auto_recompile $!
