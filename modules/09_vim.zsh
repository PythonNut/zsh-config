# ========
# VIM MODE
# ========

bindkey -M afu   jj vi-cmd-mode
bindkey -M emacs jj vi-cmd-mode

function _vi-insert () {
  # hack to enable Auto-FU during vi-insert
  zle .vi-insert
  zle zle-line-init
}
zle -N vi-insert _vi-insert

source ~/.zsh.d/zsh-vim-pattern-search/en.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp/surround.zsh
