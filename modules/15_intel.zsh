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
  emulate -LR zsh
  local cmds comp a
  cmds=$(comm -12 <(whatis -r . | cut -f1 -d " ") <(hash | cut -f1 -d "="))
  comp=$(typeset -f | \grep -P "^_" | cut -f1 -d " " | cut -c2-)
  for i in $(comm -13 <(echo $comp) <(echo $cmds)); do
    _autogen_$i() {
      local -a args
      if [[ $words[-1] = (*-*) ]]; then
        name=${0:9}
        manpage=$(man $name | col -bx)
        for arg in $(manopts $name | sort -u); do
          a=$arg
          if [[ $arg == (*=*) ]]; then
            a=${${(@s/=/)arg}[1]}
          fi
          arg=$(echo $manpage | grep -P -- "[^a-zA-Z]${a}[^a-zA-Z]" | tr -s " \n\t" " ")
          [[ -n $a ]] && args[$((${#args}+1))]="()${a}[(m)${(q)arg}]"
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

{autohelp;automan}>&/dev/null

zsh-mime-setup
