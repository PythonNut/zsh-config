# ======
# Prompt
# ======
# a prompt that commits suicide when pasted
nbsp=$'\u00A0'
global_bindkey $nbsp backward-kill-line

function compute_prompt () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  local black=$fg_bold[black]

  # show the last error code
  PS1=$'%{${fg[red]}%}%(?..Error: (%?%)\n)'

  # highlight root in red
  PS1+="%{${fg[default]}%}[%{%(#~$fg_bold[red]~$black)%}"

  # username and reset decorations, compressed_path
  PS1+='%n%{${fg_no_bold[default]}${bg[default]}%}'

  if (( $degraded_terminal[display_host] == 1 )); then
    if (( $degraded_terminal[colors256] != 1 )); then
      if (( $+commands[md5sum] )); then
        # hash hostname and generate one of 256 colors
        PS1+="%F{$((0x${$(print -P '%m'|md5sum):1:2}))}"
        PS1+="@${${(j: :)$(print -P "%m")}:0:3}%k%f"
      fi
    fi
  fi

  PS1+=' $chpwd_s_str'

  if (( $degraded_terminal[rprompt] != 1 )); then
    # shell depth
    PS1+="$(((SHLVL>1))&&echo " <"${SHLVL}">")"

    # vim normal/textobject mode indicator
    local VIM_PROMPT="%{$fg_bold[black]%} [% N]% %{$reset_color%}"
    local VIM_PROMPT_OPP="%{$fg_bold[black]%} [% N+]% %{$reset_color%}"
    RPS1="${${${KEYMAP/vicmd/$VIM_PROMPT}/opp/$VIM_PROMPT_OPP}/(afu)/}"
    RPS1=$RPS1"\${vcs_info_msg_0_}"

  else
    RPS1=""
    PS1+=" \${vcs_info_msg_0_} "
  fi
  
  # finish the prompt
  PS1+="]%#$nbsp"
}

compute_prompt

add-zsh-hook precmd compute_prompt

# intercept keymap selection
function zle-keymap-select () {
  compute_prompt
  zle && zle reset-prompt
}
zle -N zle-keymap-select
