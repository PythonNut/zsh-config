# ======
# Prompt
# ======

nbsp=$'\u00A0' # a prompt that commits suicide when pasted
bindkey $nbsp backward-kill-line

function compute_prompt () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  local black=$fg_bold[black]

  # show the last error code
  PS1=$'%{${fg[red]}%}%(?..Error: (%?%)\n)'

  # highlight root in red
  PS1+="%{${fg[default]}%}[%{%(#~$fg[red]~$black)$FX[bold]%}"

  # username and reset decorations, compressed_path
  PS1+='%n%{${fg[default]}${bg[default]}$FX[reset]%} $chpwd_s_str'

  if [[ ! -n ${MC_TMPDIR+1} ]]; then
    # shell depth
    PS1+="$(((SHLVL>1))&&echo " <"${SHLVL}">")"

    # vim normal/textobject mode indicator
    local VIM_PROMPT="%{$fg_bold[black]%} [% N]% %{$reset_color%}"
    local VIM_PROMPT_OPP="%{$fg_bold[black]%} [% N+]% %{$reset_color%}"
    RPS1="${${${KEYMAP/vicmd/$VIM_PROMPT}/opp/$VIM_PROMPT_OPP}/(afu)/}"
    RPS1=$RPS1"\${vcs_info_msg_0_}"

  else
    # right prompt messes Midnight Commander up.
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
