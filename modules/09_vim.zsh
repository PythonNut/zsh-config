# ========
# VIM MODE
# ========

global_bindkey 'jj' vi-cmd-mode
global_bindkey 'kk' vi-cmd-mode
global_bindkey 'jk' vi-cmd-mode

bindkey -M vicmd 'u' undo
bindkey -M vicmd '^R' redo

global_bindkey '^R' redo
global_bindkey '^Z' undo

function _vi-insert () {
  # hack to enable Auto-FU during vi-insert
  zle .vi-insert
  zle zle-line-init
}
zle -N vi-insert _vi-insert

source $ZDOTDIR/zsh-vim-textobjects/opp.zsh
source $ZDOTDIR/zsh-vim-textobjects/opp/surround.zsh

zsh-x-kill-region () {
  zle kill-region
  print -rn $CUTBUFFER | xsel -i
}

zsh-x-yank () {
  CUTBUFFER=$(xsel -o -p </dev/null)
  zle yank
}

zsh-x-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | xsel -i
}

if (( $+commands[xsel] )); then
  zle -N zsh-x-yank
  zle -N zsh-x-kill-region
  zle -N zsh-x-copy-region-as-kill
  global_bindkey '\eW' zsh-x-copy-region-as-kill
  global_bindkey '^W' zsh-x-kill-region
  global_bindkey '^y' zsh-x-yank
fi
