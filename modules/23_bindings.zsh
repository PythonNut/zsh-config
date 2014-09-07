# ====================
# Interactive commands
# ====================

# increments the last number on the line
function _increase_number() {
  emulate -LR zsh
  local -a match mbegin mend
  while [[ ! $LBUFFER =~ '([0-9]+)[^0-9]*$' ]]; do
    zle up-line-or-search
  done
  
  LBUFFER[mbegin,mend]=$(printf %0${#match[1]}d $((10#$match+${NUMERIC:-1})))
}
zle -N increase-number _increase_number
global_bindkey '^X^a' increase-number
bindkey -s '^Xx' '^[-^Xa'

# C-r adds to line instead of replacing it
autoload -Uz narrow-to-region
function _history-incremental-preserving-pattern-search-backward {
  emulate -LR zsh
  local state
  MARK=CURSOR  # magick, else multiple ^R don't work
  narrow-to-region -p "$LBUFFER${BUFFER:+>>}" -P "${BUFFER:+<<}$RBUFFER" -S state
  zle end-of-history
  zle history-incremental-pattern-search-backward
  narrow-to-region -R state
}
zle -N _history-incremental-preserving-pattern-search-backward
global_bindkey "^R" _history-incremental-preserving-pattern-search-backward
global_bindkey "^S" history-incremental-pattern-search-forward

bindkey -M isearch "^R" history-incremental-pattern-search-backward

# M-, moves to the previous word on the current line, like M-.
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
global_bindkey "^[," copy-earlier-word

# Move to the place where flags are to be added
function after-first-word() {
  zle beginning-of-line
  zle forward-word
}
zle -N after-first-word
global_bindkey "^X1" after-first-word

# rationalize dots
rationalise_dot () {
  emulate -LR zsh
  # typing .... becomes ../../../ etc.
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}

zle -N rationalise_dot
global_bindkey . rationalise_dot
# without this, typing a "." aborts incremental history search
bindkey -M isearch . self-insert

# zaw: helm.el for zsh
function () {
  emulate -LR zsh
  source ~/.zsh.d/zsh-zaw/zaw.zsh
  source ~/.zsh.d/zaw-src-git-log/zaw-git-log.zsh
  source ~/.zsh.d/zaw-src-git-show-branch/zaw-git-show-branch.zsh

  # and import other zaw sources
  for file in ~/.zsh.d/zaw-misc-sources/*.zsh(n); do
    source $file
  done

  zle -N zaw-autoload-git-log
  zle -N zaw-autoload-git-show-branch
  
  global_bindkey "^X;" zaw
  global_bindkey "^R" zaw-history
  global_bindkey "^Xo" zaw-open-file
  global_bindkey "^Xa" zaw-applications


  global_bindkey "^Xgf" zaw-git-files
  global_bindkey "^Xgb" zaw-git-recent-branches
  global_bindkey "^Xgs" zaw-git-status
  global_bindkey "^Xgl" zaw-git-log
  global_bindkey "^Xgc" zaw-git-show-branch
  global_bindkey "^Xgr" zaw-git-reflog

  global_bindkey "^Xr" zaw-open-file-recursive
  
  zstyle ':filter-select' extended-search yes
  zstyle ':filter-select' case-insensitive yes
  zstyle ':filter-select' max-lines -10
}
