# =================================
# FASD - all kinds of teleportation
# =================================

_FASD_DATA=$ZDOTDIR/.fasd
_FASD_SHIFT+=(nocorrect noglob)
_FASD_VIMINFO=~/.vim/.viminfo

# interactive directory selection
# interactive file selection
alias sd='fasd -sid'
alias sf='fasd -sif'

# cd, same functionality as j in autojump
alias j='fasd -e cd -d'

_mydirstack() {
  local -a lines list
  for d in $dirstack; do
    lines+="$(($#lines+1)) -- $d"
    list+="$#lines"
  done
  _wanted -V directory-stack expl 'directory stack' \
          compadd "$@" -ld lines -S']/' -Q -a list
}

zsh_directory_name() {
  case $1 in
    (c) _mydirstack;;
    (n) case $2 in
          (<0-9>) reply=($dirstack[$2]);;
          (*) reply=($dirstack[(r)*$2*]);;
        esac;;
    (d) false;;
  esac
}
