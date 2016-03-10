# ========================
# smart tab - really smart
# ========================

function pcomplete() {
  if [[ -n $POSTDISPLAY ]]; then
    zle autosuggest-accept
    return 0
  fi

  if [[ $#LBUFFER == 0 || "$LBUFFER" == "$predict_buffer" ]]; then
    zle predict-next-line
  else
    local cur_rbuffer space_index i
    local -i single_match
    local -a match mbegin mend
    zle expand-or-complete
  fi
}

bindkey -M menuselect . self-insertq

zle -N pcomplete

global_bindkey '^i' pcomplete
bindkey -M menuselect '^i' pcomplete

function _magic-space () {
  emulate -LR zsh
  if [[ $LBUFFER[-1] != " "  ]]; then
    zle .magic-space
    if [[ $LBUFFER[-2] == " " ]]; then
      zle backward-delete-char
    fi
  else
    zle .magic-space
  fi
}

zle -N magic-space _magic-space
