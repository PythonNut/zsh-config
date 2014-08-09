# ========================
# smart tab - really smart
# ========================

function pcomplete() {
  emulate -LR zsh
  {
    setopt function_argzero
    # hack a local function scope using unfuction
    function $0_forward_word () {
      local space_index
      space_index=$(expr index "$RBUFFER" ' ')
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
    function $0_force_auto () {
      zle magic-space
      zle backward-delete-char
    }

    zstyle ':completion:*' show-completer yes
    zstyle ':completion:*' extra-verbose yes
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' menu select=1 interactive
    zstyle ':completion:*' insert-unambiguous yes
    zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}' \
      'r:|[\.\_\-/\\]=* r:|=*' 'l:|[\.\_\-/\\]=* r:|[\.\_\-/\\]=*' \
      'r:[^[:upper:]0-9]||[[:upper:]0-9]=** r:|=*'
    
    # _user_expand \
    zstyle ':completion:*' completer \
      _expand \
      _oldlist \
      _complete \
      _prefix \
      _history \
      _approximate \
      _match \
      _prefix

    setopt local_options complete_in_word list_packed list_rows_first

    if [[ $#BUFFER == 0 ]]; then
      zle .accept-line
      BUFFER="popd"
    else
      local single_match="" file_match="" cur_rbuffer space_index

      # detect multiple auto-fu matches
      for i in $region_highlight; do
        i=("${(@s/ /)i}")
        _setTitle $i
        if [[ $i[3] == *black* ]] && ((${i[2]:-0} - ${i[1]:-0} > 0 && ${i[1]:-0} > 1)); then
          $0_forward_word
          break
        fi
      done

      # detect single auto-fu match
      for i in $region_highlight; do
        i=("${(@s/ /)i}")
        if [[ $i[3] == *underline* ]] && ((${i[2]:-0} - ${i[1]:-0} > 0)); then
          if  [[ $BUFFER != (*/|* */*) ]]; then
            file_match="t"
          fi
          single_match="t"
          break
        fi
      done

      if [[ $single_match == "t" ]]; then
        $0_forward_word
        if [[ $#RBUFFER == 0 ]]; then
            if [[ $LBUFFER[-1] == "/" ]]; then
            $0_force_auto
          else
            zle magic-space
          fi
        else
          if [[ $LBUFFER[-2] == "/" ]]; then
            zle backward-char
            $0
          fi
        fi
        if [[ $LBUFFER[-1] == " " ]]; then
          zle .backward-delete-char
        fi
      else
        $0_forward_word
        cur_rbuffer=$RBUFFER
        zle expand-or-complete
        RBUFFER=$cur_rbuffer
        if [[ $LBUFFER[-1] == " " || $LBUFFER[-2] == " " ]]; then
          zle .backward-delete-char
        fi
      fi
    fi

    zstyle ':completion:*' show-completer no
    zstyle ':completion:*' extra-verbose no
    zstyle ':completion:*' verbose no
    zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}'
    # _user_expand
    zstyle ':completion:*' completer _oldlist _complete
  } always {
    unfunction -m "$0_*"
  }
}

zle -N pcomplete

global_bindkey "^i" pcomplete

function _magic-space () {
  emulate -LR zsh
  if [[ $LBUFFER[-1] != " "  ]]; then
    zle magic-space
    if [[ $LBUFFER[-2] == " " ]]; then
      zle backward-delete-char
    fi
  else
    zle magic-space
  fi
}

zle -N magic-space _magic-space
