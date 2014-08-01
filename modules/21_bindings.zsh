# ====================
# Interactive commands
# ====================

# increments the last number on the line
function _increase_number() {
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
function _history-incremental-preserving-pattern-search-backward
{
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

# ^Z to foreground the last suspended job.
foreground-current-job() { fg; }
zle -N foreground-current-job
global_bindkey '^z' foreground-current-job
