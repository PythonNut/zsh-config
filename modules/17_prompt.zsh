# ======
# Prompt
# ======

if (( $degraded_terminal[unicode] != 1 )); then
  # a prompt that commits suicide when pasted
  nbsp=$'\u00A0'
  global_bindkey $nbsp backward-kill-line
else
  nbsp=$' '
fi

function compute_prompt () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt extended_glob
  local black=$fg_bold[black] pure_ascii

  # show the last error code
  PS1=$'%{%F{red}%}%(?..Error: (%?%)\n)'

  # highlight root in red
  PS1+="%{%F{default}%}[%B%{%(!.%F{red}.%F{black})%}"

  # username and reset decorations
  PS1+='%n%{%b%F{default}%}'

  if (( $degraded_terminal[display_host] == 1 )); then
    if (( $degraded_terminal[colors256] != 1 )); then
      if (( $+commands[md5sum] )); then
        # hash hostname and generate one of 256 colors
        PS1+="%F{$((0x${$(print -P '%m'|md5sum):1:2}))}"
      elif (( $+commands[md5] )); then
        PS1+="%F{$((0x${$(print -P '%m'|md5):1:2}))}"
      fi
      PS1+="@${${(j: :)$(print -P "%m")}:0:3}%k%f"
    fi
  fi

  # compressed_path
  PS1+=' $chpwd_minify_smart_str'

  if (( $degraded_terminal[rprompt] != 1 )); then
    # shell depth
    PS1+=$((($SHLVL > 1)) && echo " <%L>")

    # vim normal/textobject mode indicator
    local VIM_PROMPT="%B%F{black} [% N]% %b"
    local VIM_PROMPT_OPP="%B%F{black} [% N+]% %b"
    RPS1="${${${KEYMAP/vicmd/$VIM_PROMPT}/opp/$VIM_PROMPT_OPP}/(afu)/}"
    RPS1=$RPS1"\${vcs_info_msg_0_}"

  else
    RPS1=""
    PS1+=" \${vcs_info_msg_0_} "
  fi
  
  # finish the prompt
  PS1+="]%#$nbsp"


  pure_ascii=${$(print -P $PS1)//$(echo -e "\x1B")\[[0-9;]#[mK]/}
  if (( $degraded_terminal[colors] == 1)); then
      PS1="$pure_ascii"
  fi

  PS2="$(printf ' %.0s' {1..$(( $#pure_ascii - 2 ))})> "
}

compute_prompt

add-zsh-hook precmd compute_prompt

# intercept keymap selection
function zle-keymap-select () {
  emulate -LR zsh
  setopt zle 2> /dev/null
  setopt prompt_subst transient_rprompt extended_glob
  compute_prompt
  zle && zle reset-prompt
}
zle -N zle-keymap-select
