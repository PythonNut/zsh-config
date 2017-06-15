# ========================
# smart tab - really smart
# ========================

function pcomplete() {
  emulate -L zsh
  {
    setopt function_argzero prompt_subst extended_glob
    setopt list_packed list_rows_first

    setopt auto_list              # list if multiple matches
    setopt complete_in_word       # complete at cursor
    setopt menu_complete          # add first of multiple
    setopt auto_remove_slash      # remove extra slashes if needed
    setopt auto_param_slash       # completed directory ends in /
    setopt auto_param_keys        # smart insert spaces " "

    # hack a local function scope using unfuction
    function pcomplete_forward_word () {
      local -i space_index
      space_index=${RBUFFER[(i) ]}
      if ((space_index == 0)); then
        zle .end-of-line
      else
        for ((x=0; x<$space_index-1; x+=1)); do
          zle .forward-char
        done
        while [[ $RBUFFER[1] == " " ]]; do
          zle .forward-char
        done
      fi
    }
    function pcomplete_force_auto () {
      zle magic-space
      zle backward-delete-char
    }

    zstyle ':completion:*' show-completer true
    zstyle ':completion:*' extra-verbose true
    zstyle ':completion:*' verbose true
    zstyle ':completion:*' insert-unambiguous true

    zstyle ':completion:*' completer \
      _oldlist \
      _expand \
      _complete \
      _match \
      _prefix

    local cur_rbuffer space_index i
    local -i single_match
    local -a match mbegin mend

    # detect single auto-fu match
    for param in $region_highlight; do
      if [[ $param == (#b)[^0-9]#(<->)[^0-9]##(<->)(*) ]]; then
        i=($match)
        if [[ $i[3] == *black* ]] && (($i[2] - $i[1] > 0 && $i[1] > 1)); then
          pcomplete_forward_word
          break
        elif [[ $i[3] == *underline* ]] && (($i[2] - $i[1] > 0 && $i[1] >= $CURSOR)); then
          single_match=1
          break
        fi
      fi
    done

    if [[ $single_match == 1 ]]; then
      pcomplete_forward_word
      if [[ $#RBUFFER == 0 ]]; then
          if [[ $LBUFFER[-1] == "/" ]]; then
            pcomplete_force_auto
          else
            zle magic-space
          fi
      else
        if [[ $LBUFFER[-2] == "/" ]]; then
          zle backward-char
          pcomplete
        fi
      fi
      if [[ $LBUFFER[-1] == " " ]]; then
        zle .backward-delete-char
      fi
    else
      zle menu-expand-or-complete
    fi

    zstyle ':completion:*' show-completer false
    zstyle ':completion:*' extra-verbose false
    zstyle ':completion:*' verbose false
    zstyle ':completion:*' completer _oldlist _complete

  } always {
    unfunction "pcomplete_forward_word" "pcomplete_force_auto"
  }
  _zsh_highlight 2>/dev/null
}

bindkey -M menuselect . self-insert

zle -N pcomplete

global_bindkey '^i' pcomplete
bindkey -M menuselect '^i' forward-char

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
