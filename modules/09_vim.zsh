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

source ~/.zsh.d/zsh-vim-pattern-search/en.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp/surround.zsh
