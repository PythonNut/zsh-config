# ======
# Prompt
# ======

nbsp=$'\u00A0' # a prompt that commits suicide when pasted
bindkey $nbsp backward-kill-line

function compute_prompt () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  local black=$fg_bold[black]
  PS1=$'%{${fg[red]}%}%(?..Error: (%?%)\n)' # errors
  PS1+="%{${fg[default]}%}[%{%(#~$fg[red]~$black)$FX[bold]%}"  # root or not
  PS1+='%n%{${fg[default]}${bg[default]}$FX[reset]%} $chpwd_s_str'  # Username
  PS1+="$(((SHLVL>1))&&echo " <"${SHLVL}">")]%#$nbsp" # shell depth
  
  local VIM_PROMPT="%{$fg_bold[black]%} [% N]% %{$reset_color%}"
  local VIM_PROMPT_OPP="%{$fg_bold[black]%} [% N+]% %{$reset_color%}"
  RPS1="${${${KEYMAP/vicmd/$VIM_PROMPT}/opp/$VIM_PROMPT_OPP}/(afu)/}"
  RPS1=$RPS1"\${vcs_info_msg_0_}"
}

compute_prompt

function precmd() {
  cur_command=""
  chpwd
}

add-zsh-hook precmd compute_prompt

# intercept keymap selection
function zle-keymap-select () {
  compute_prompt
  zle && zle reset-prompt
}
zle -N zle-keymap-select
