# =============================
# AutoFU continuous completions
# =============================

{
  setopt local_options no_rc_expand_param
  source $ZDOTDIR/auto-fu/auto-fu.zsh
  afu-zle-aysce-install () afu-zle-force-install;
  integer afu_enabled=1
  zle-line-init () {
    if (( $afu_enabled == 1 )); then
      auto-fu-init
    fi
  }
  zle -N zle-line-init

  zstyle ":auto-fu:var" postdisplay ""
  zstyle ":auto-fu:var" autoable-function/skipwords yum touch

  zstyle ':completion:*' show-completer no
  zstyle ':completion:*' extra-verbose no
  zstyle ':completion:*:options' description no
  zstyle ':completion:*' completer _oldlist _complete

  integer afu_menu=1
  toggle_afu() {
    if [[ $afu_menu == 1 ]]; then
      afu_menu=0
    else
      afu_menu=1
    fi
  }

  # highjack afu-comppost function
  afu-comppost () {
    emulate -LR zsh
    local -i will_complete
    will_complete=$afu_menu
    if [[ $BUFFER[1] == ' ' ]]; then
      will_complete=0
    fi
    
    if [[ $will_complete == 1 ]]; then
      local lines=$((compstate[list_lines] + BUFFERLINES + 2))
      if ((lines > LINES*0.75)) || ((lines > 30)); then
        compstate[list]=''
        [[ $WIDGET == afu+complete-word ]] || compstate[insert]=''
        zle -M "$compstate[list_lines]($compstate[nmatches]) too many matches..."
      else
        compstate[list]=autolist
      fi
    else
      # If this is unset, the list of matches will never be listed
      # according to zshall(1)
      compstate[list]=
    fi

    typeset -g afu_one_match_p=
    (( $compstate[nmatches] == 1 )) && afu_one_match_p=t
    afu_curcompleter=$_completer
  }
  setopt rc_expand_param
} &>> $ZDOTDIR/startup.log

function global_bindkey () {
  bindkey -M command $@
  bindkey -M emacs   $@
  bindkey -M main  $@
  bindkey -M afu   $@
  bindkey      $@
}

global_bindkey "^x^x^x" zle-line-init

global_bindkey "^Hk" describe-key-briefly
