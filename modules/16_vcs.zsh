# ======================
# Version Control System
# ======================
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true


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

# zstyle ':vcs_info:*+*:*' debug true
zstyle ':vcs_info:(svn|csv|hg)*' formats "(%B%F{yellow}%s%%b%f)[%b|%u%c]"
zstyle ':vcs_info:(svn|csv|hg)*' branchformat "%B%F{red}%b(%r)%%b%f"
zstyle ':vcs_info:svn*+set-message:*' hooks svn-untracked
zstyle ':vcs_info:hg*+set-message:*' hooks hg-untracked

ZSH_VCS_PROMPT_VCS_FORMATS="#s"

+vi-svn-untracked() {
  emulate -LR zsh
  if ! hash svn; then
    return 0;
  fi
  if command svn info &> /dev/null; then
    local svn_status=${(F)$(command svn status)}

    local modified_count=${(F)$(echo $svn_status | \grep '^[MDA!]')}
    if [[ ${#${(f)modified_count}} != 0 ]]; then
      modified_count=$ZSH_VCS_PROMPT_UNSTAGED_SIGIL${#${(f)modified_count}}
      hook_com[unstaged]+="%b%F{yellow}$modified_count%f"
    fi

    local unstaged_count=${#${(f)${(F)$(echo $svn_status | \grep '^?')}}}
    if [[ $unstaged_count != 0 ]]; then
      unstaged_count=$ZSH_VCS_PROMPT_UNTRACKED_SIGIL$unstaged_count
      hook_com[unstaged]+="%f%b$unstaged_count%f"
    fi

    if [[ ! -n $hook_com[unstaged] ]]; then
      hook_com[unstaged]="%F{green}$ZSH_VCS_PROMPT_CLEAN_SIGIL%f"
    fi
  fi
}

+vi-hg-untracked() {
  emulate -LR zsh
  if ! hash hg; then
    return 0;
  fi
  if command hg id &> /dev/null; then
    local hg_status=${(F)$(command hg status)}

    local modified_count=${(F)$(echo $hg_status | \grep '^[MDA!]')}
    if [[ ${#${(f)modified_count}} != 0 ]]; then
      modified_count=$ZSH_VCS_PROMPT_UNSTAGED_SIGIL${#${(f)modified_count}}
      hook_com[unstaged]+="%b%F{yellow}$modified_count%f"
    fi

    local unstaged_count=${#${(f)${(F)$(echo $hg_status | \grep '^?')}}}
    if [[ $unstaged_count != 0 ]]; then
      unstaged_count=$ZSH_VCS_PROMPT_UNTRACKED_SIGIL$unstaged_count
      hook_com[unstaged]+="%f%b$unstaged_count%f"
    fi

    if [[ ! -n $hook_com[unstaged] ]]; then
      hook_com[unstaged]="%F{green}$ZSH_VCS_PROMPT_CLEAN_SIGIL%f"
    fi
  fi
}

typeset -F SECONDS
vcs_async_last=0
vcs_async_start=0
vcs_async_delay=0
integer vcs_async_sentinel=0
zsh_pickle -i async-sentinel vcs_async_sentinel
VCS_INOTIFY="off"

function vcs_async_info () {
  zsh_unpickle -s -i async-sentinel
  if [[ ${vcs_async_sentinel:-0} == 0 ]]; then
    vcs_async_start=$SECONDS
    vcs_async_info_worker $1 &!
    vcs_async_last=$SECONDS
    vcs_async_sentinel=1
  else
    vcs_async_sentinel=2
  fi
  zsh_pickle -i async-sentinel vcs_async_sentinel
}

VCS_ASYNC_TMP="/dev/shm"

function vcs_async_info_worker () {
  emulate -LR zsh
  setopt noclobber multios
  local vcs_raw_data vcs_super_info

  vcs_super_info="$(vcs_super_info)"
  vcs_super_raw_data="$(vcs_super_info_raw_data)"

  zsh_pickle -i vcs-data vcs_super_info vcs_super_raw_data
  
  # Signal the parent shell to update the prompt.
  kill -USR1 $$
}

function TRAPUSR1 {
  emulate -LR zsh
  setopt zle 2>/dev/null
  setopt prompt_subst transient_rprompt no_clobber
  zsh_unpickle -s -i vcs-data
  
  vcs_async_delay=$(($SECONDS - $vcs_async_start))
  vcs_info_msg_0_=$vcs_super_info

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt

  vcs_raw_data=$vcs_super_raw_data
  if [[ ! -n $vcs_raw_data ]]; then
    unset vcs_raw_data
  fi
  
  # if we're in a vcs, start an inotify process
  if [[ -n $vcs_info_msg_0_ ]]; then
    if [[ $VCS_INOTIFY == "off" ]]; then
      vcs_inotify_watch ${${:-.}:A} &!
      VCS_INOTIFY=$!
    fi
  elif [[ $VCS_INOTIFY != "off" ]]; then
    kill $VCS_INOTIFY
    VCS_INOTIFY="off"
  fi

  zsh_unpickle -s -i async-sentinel
  local temp_sentinel=$vcs_async_sentinel
  vcs_async_sentinel=0
  if [[ $vcs_async_sentinel == 2 ]]; then
    vcs_async_info &!
  fi
  
  zsh_pickle -i async-sentinel vcs_async_sentinel
}


function vcs_async_auto_update {
  emulate -LR zsh
  setopt local_options function_argzero
  if [[ -n $VCS_PAUSE ]]; then
    return 0;
  fi
  vcs_async_info
}

add-zsh-hook precmd vcs_async_auto_update

vcs_inotify_events=(modify move create delete)

function vcs_inotify_watch () {
  emulate -LR zsh
  if hash inotifywait &>/dev/null; then
    inotifywait -e ${=${(j: -e :)vcs_inotify_events}} \
      -mqr --format %w%f $1 2> ~/.zsh.d/startup.log \
      | while IFS= read -r file; do
      vcs_inotify_do "$file"
    done
  fi
}

function vcs_inotify_do () {
  emulate -LR zsh
  vcs_async_info $file
}

function vcs_async_cleanup () {
  if [[ -n $VCS_INOTIFY ]]; then
    kill $VCS_INOTIFY 2>/dev/null
  fi
}

add-zsh-hook zshexit vcs_async_cleanup
