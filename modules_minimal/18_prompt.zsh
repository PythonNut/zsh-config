# ======
# Prompt
# ======

BORING_USERS=(pythonnut pi)

if (( $degraded_terminal[unicode] != 1 )); then
  # a prompt that commits suicide when pasted
  nbsp=$'\u00A0'
  global_bindkey $nbsp backward-kill-line
else
  nbsp=$' '
fi

PROMPT_HOSTNAME=
PROMPT_KEYMAP=

if (( $degraded_terminal[display_host] == 1 )); then
  if (( $degraded_terminal[colors256] != 1 )); then
    if (( $+commands[md5sum] )); then
      # hash hostname and generate one of 256 colors
      PROMPT_HOSTNAME="%F{$((0x${$(echo ${HOST%%.*} |md5sum):1:2}))}"
    elif (( $+commands[md5] )); then
      PROMPT_HOSTNAME="%F{$((0x${$(echo ${HOST%%.*} |md5):1:2}))}"
    fi
    PROMPT_HOSTNAME+="@${HOST:0:3}%k%f"
  fi
fi

function compute_prompt () {
  emulate -LR zsh -o prompt_subst -o transient_rprompt -o extended_glob
  local pure_ascii

  # show the last error code
  PS1=$'%{%F{red}%}%(?..Returned %?\n)'

  # user (highlight root in red)
  if [[ -z $BORING_USERS[(R)$USER] ]]; then
    PS1+='%{%F{default}%}%B%{%(!.%F{red}.%F{black})%}%n'
  fi

  # username and reset decorations
  PS1+='%{%b%F{default}%}'

  PS1+="$PROMPT_HOSTNAME "
  PS1+='%(1j.%{%B%F{yellow}%}%j%{%F{default}%b%} .)'
  PS1+='%1~'

  if (( $degraded_terminal[rprompt] != 1 )); then
    # shell depth
    PS1+=$((($SHLVL > 1)) && echo " <%L>")

    # vim normal/textobject mode indicator
    RPS1='${${PROMPT_KEYMAP/vicmd/%B%F{black\} [% N]% %b }/(afu|main)/}'

  else
    RPS1=''
  fi

  # finish the prompt
  if [[ -n $TMUX ]]; then
    PS1+=" %#$nbsp"
  else
    PS1+=" %(!.#.$)$nbsp"
  fi
}

compute_prompt
PS2="\${(l:\${#\${(M)\${\${(%%S)\$(eval \"echo \${\${(q)PS1}//\\\\\$/\\\$}\")//\%([BSUbfksu]|([FBK]|)\{*\})/}}%%[^$'\n']#}}:: :)\${:->$nbsp}}"
RPS2='%^'

# intercept keymap selection
function zle-line-init zle-keymap-select () {
  emulate -LR zsh -o prompt_subst -o transient_rprompt -o extended_glob
  PROMPT_KEYMAP=$KEYMAP
  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select
zle -N zle-line-init
