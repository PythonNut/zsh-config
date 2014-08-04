# ======================
# Version Control System
# ======================
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:svn*+set-message:*' hooks svn-untracked-and-modified
function +vi-svn-untracked-and-modified() {
  local svn_status
  svn_status=$(svn status | cut -f1 -d ' ')
  if [[ $svn_status == *M* ]]; then
    hook_com[staged]+=" %{$fg[green]%}+%{$reset_color%}"
  fi
  if [[ $svn_status == *\?* ]]; then
    hook_com[unstaged]+='?'
  fi
}

source ~/.zsh.d/zsh-vcs-prompt/zshrc.sh
ZSH_VCS_PROMPT_ENABLE_CACHING='false'
ZSH_VCS_PROMPT_USING_PYTHON='true'

ZSH_VCS_PROMPT_AHEAD_SIGIL='↑'
ZSH_VCS_PROMPT_BEHIND_SIGIL='↓'
ZSH_VCS_PROMPT_STAGED_SIGIL='●'
ZSH_VCS_PROMPT_CONFLICTS_SIGIL='✖'
ZSH_VCS_PROMPT_UNSTAGED_SIGIL='✚'
ZSH_VCS_PROMPT_UNTRACKED_SIGIL='…'
ZSH_VCS_PROMPT_STASHED_SIGIL='⚑'
ZSH_VCS_PROMPT_CLEAN_SIGIL='✔'

typeset -F SECONDS
vcs_async_start=0
vcs_async_delay=0

function vcs_async_info () {
  vcs_async_start=$SECONDS
  vcs_async_info_worker &>/dev/null&!
}

function vcs_async_info_worker () {
  # Save the prompt in a temp file so the parent shell can read it.
  printf "%s" "$(vcs_super_info)" >! ${TMPPREFIX}/vcs-prompt.$$

  local vcs_raw_data

  vcs_raw_data="$(vcs_super_info_raw_data)"

  if [[ -n $vcs_raw_data ]]; then
    echo $vcs_raw_data >! ${TMPPREFIX}/vcs-data.$$
  else
    command rm -f ${TMPPREFIX}/vcs-data.$$
  fi
  
  # Signal the parent shell to update the prompt.
  kill -USR1 $$
}

function compute_context_aliases () {
  if [[ -f ${TMPPREFIX}/vcs-data.$$ ]]; then
    local vcs_data
    vcs_data=$(cat ${TMPPREFIX}/vcs-data.$$);
    alias -g .B=${${(f)vcs_data}[4]};
    
  else
    if [[ $(type ".B") == *alias* ]]; then
      unalias .B
    fi
  fi
}

function TRAPUSR1 {
  vcs_async_delay=$(($SECONDS - $vcs_async_start))
  vcs_info_msg_0_=$(cat "${TMPPREFIX}/vcs-prompt.$$" 2> /dev/null)
  command rm ${TMPPREFIX}/vcs-prompt.$$ 2> /dev/null

  compute_context_aliases
    
  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}

function vcs_async_auto_update {
  setopt local_options function_argzero
  vcs_async_info
  sched +00:00:${(l:2::0:)$((int(ceil(($vcs_async_delay * 10)))+1))} $0
}

vcs_async_auto_update
