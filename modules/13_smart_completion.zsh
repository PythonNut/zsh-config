# ========================
# smart tab - really smart
# ========================

function pcomplete() {
  emulate -L zsh
  {
    setopt function_argzero prompt_subst
    setopt list_packed list_rows_first

    setopt auto_list              # list if multiple matches
    setopt complete_in_word       # complete at cursor
    setopt menu_complete          # add first of multiple
    setopt auto_remove_slash      # remove extra slashes if needed
    setopt auto_param_slash       # completed directory ends in /
    setopt auto_param_keys        # smart insert spaces " "

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

    zstyle ':completion:*' show-completer true
    zstyle ':completion:*' extra-verbose true
    zstyle ':completion:*' verbose true
    zstyle ':completion:*' menu select=1 interactive
    zstyle ':completion:*' insert-unambiguous true

    # 0 -- vanilla completion    (abc => abc)
    # 1 -- smart case completion (abc => Abc)
    # 2 -- word flex completion  (abc => A-big-Car)
    # 3 -- full flex completion  (abc => ABraCadabra)
    zstyle ':completion:*' matcher-list '' \
      'm:{a-z\-}={A-Z\_}' \
      'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
      'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'
    
    zstyle ':completion:*' completer \
      _expand \
      _oldlist \
      _complete \
      _match \
      _approximate \
      _files \
      _history \
      _prefix

    if [[ $#LBUFFER == 0 || "$LBUFFER" == "$predict_buffer" ]]; then
      zle predict-next-line  
    else
      local cur_rbuffer space_index
      local -i single_match
      local -i file_match

      # detect single auto-fu match
      for i in $region_highlight; do
        # sanitize to prevent $((...)) from crashing
        i=(${(@s/ /)i[1,2]%%[^0-9]*} ${(@s/ /)i[3,-1]})
        if [[ $i[3] == *black* ]] && (($i[2] - $i[1] > 0 && $i[1] > 1)); then
          $0_forward_word
          break
        elif [[ $i[3] == *underline* ]] && (($i[2] - $i[1] > 0 && $i[1] >= $CURSOR)); then
          if  [[ $BUFFER != (*/|* */*) ]]; then
            file_match=1
          fi
          single_match=1
          break
        fi
      done

      if [[ $single_match == 1 ]]; then
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
        if [[ ! -o globcomplete ]]; then
          zle expand-word
        fi

        # store a temporary copy of the buffer
        local TEMP_BUFFER
        TEMP_BUFFER=$BUFFER
        zle complete-word

        # if the line is unchanged, show possible continuations
        if [[ $BUFFER == $TEMP_BUFFER ]]; then
          zle menu-complete
        fi
        RBUFFER=$cur_rbuffer
        if [[ $LBUFFER[-1] == " " || $LBUFFER[-2] == " " ]]; then
          zle .backward-delete-char
        fi
      fi
    fi

    zstyle ':completion:*' show-completer false
    zstyle ':completion:*' extra-verbose false
    zstyle ':completion:*' verbose false
    zstyle ':completion:*' completer _oldlist _complete
    zstyle ':completion:*' matcher-list '' 'm:{a-z\-}={A-Z\_}'

  } always {
    unfunction -m "$0_*"
  }
}

bindkey -M menuselect . self-insert

zle -N pcomplete

global_bindkey "^i" pcomplete

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
