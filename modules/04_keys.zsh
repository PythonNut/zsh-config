# ==================
# unified key system
# ==================

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

fpath+=$ZDOTDIR/zsh-git-escape-magic
autoload -Uz git-escape-magic
git-escape-magic

typeset -A key
function {
  emulate -LR zsh
  setopt function_argzero
  local zkbd_dest
  zkbd_dest=${ZDOTDIR:-$HOME}/.zkbd/$_OLD_TERM-$VENDOR-$OSTYPE
  local REPLY REPLY_PERM
  {
  if [[ -s $zkbd_dest ]]; then
    source $zkbd_dest
  elif [[ -f $zkbd_dest ]]; then
    throw KeyFallback
  else
    read -q "REPLY?Generate keybindings for $_OLD_TERM? (y/n) " -n 1

    if [[ $REPLY != [Yy]* ]]; then
      echo
      read -q "REPLY_PERM?Ask again? (y/n) " -n 1
      if [[ $REPLY_PERM != [Yy]* ]]; then
        touch $zkbd_dest
        exec $SHELL
      else
        throw KeyFallback
      fi
    fi

    if [[ $REPLY == [Yy]* ]]; then
      echo
      export TERM=$_OLD_TERM
      zkbd
      echo "Keys generated ... exiting"
      mv ${ZDOTDIR:-$HOME}/.zkbd/$TERM-:0 $zkbd_dest &> /dev/null
      source $zkbd_dest
    fi
  fi
  } always {
    if catch KeyFallback; then
      key[Home]=${terminfo[khome]}
      key[End]=${terminfo[kend]}
      key[Insert]=${terminfo[kich1]}
      key[Delete]=${terminfo[kdch1]}
      key[Up]=${terminfo[kcuu1]}
      key[Down]=${terminfo[kcud1]}
      key[PageUp]=${terminfo[kpp]}
      key[PageDown]=${terminfo[knp]}

      # these will get run anyway
      # key[Left]=${terminfo[kcub1]}
      # key[Right]=${terminfo[kcuf1]}
    fi
  }
}

[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]}    ]] && bindkey "${key[Insert]}"    overwrite-mode
[[ -n ${key[Home]}      ]] && bindkey "${key[Home]}"      beginning-of-line
[[ -n ${key[PageUp]}    ]] && bindkey "${key[PageUp]}"    up-line-or-history
[[ -n ${key[Delete]}    ]] && bindkey "${key[Delete]}"    delete-char
[[ -n ${key[End]}       ]] && bindkey "${key[End]}"       end-of-line
[[ -n ${key[PageDown]}  ]] && bindkey "${key[PageDown]}"  down-line-or-history
[[ -n ${key[Up]}        ]] && bindkey "${key[Up]}"        up-line-or-search
[[ -n ${key[Down]}      ]] && bindkey "${key[Down]}"      down-line-or-search

# let the terminal take care of these
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
# [[ -n ${key[Left]}      ]] && bindkey "${key[Left]}"      forward-char
# [[ -n ${key[Right]}     ]] && bindkey "${key[Right]}"     backward-char
