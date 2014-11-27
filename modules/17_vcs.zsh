# ======================
# Version Control System
# ======================
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true

ZSH_VCS_PROMPT_ENABLE_CACHING='false'
ZSH_VCS_PROMPT_USING_PYTHON='false'

if (( $degraded_terminal[unicode] != 1 )); then
  ZSH_VCS_PROMPT_AHEAD_SIGIL='↑'
  ZSH_VCS_PROMPT_BEHIND_SIGIL='↓'
  ZSH_VCS_PROMPT_STAGED_SIGIL='●'
  ZSH_VCS_PROMPT_CONFLICTS_SIGIL='✖'
  ZSH_VCS_PROMPT_UNSTAGED_SIGIL='✚'
  ZSH_VCS_PROMPT_UNTRACKED_SIGIL='…'
  ZSH_VCS_PROMPT_STASHED_SIGIL='⚑'
  ZSH_VCS_PROMPT_CLEAN_SIGIL='✔'
else
  ZSH_VCS_PROMPT_AHEAD_SIGIL='>'
  ZSH_VCS_PROMPT_BEHIND_SIGIL='<'
  ZSH_VCS_PROMPT_STAGED_SIGIL='*'
  ZSH_VCS_PROMPT_CONFLICTS_SIGIL='x'
  ZSH_VCS_PROMPT_UNSTAGED_SIGIL='+'
  ZSH_VCS_PROMPT_UNTRACKED_SIGIL='.'
  ZSH_VCS_PROMPT_STASHED_SIGIL='#'
  ZSH_VCS_PROMPT_CLEAN_SIGIL='-'
fi

source ~/.zsh.d/zsh-vcs-prompt/zshrc.sh

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

    local modified_count=${#${(F)$(echo $svn_status | \grep '^[MDA!]')}}
    if (( $modified_count != 0 )); then
      modified_count=$ZSH_VCS_PROMPT_UNSTAGED_SIGIL${#${(f)modified_count}}
      hook_com[unstaged]+="%b%F{yellow}$modified_count%f"
    fi

    local unstaged_count=${#${(f)${(F)$(echo $svn_status | \grep '^?')}}}
    if (( $unstaged_count != 0 )); then
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

    local modified_count=${#${(F)$(echo $hg_status | \grep '^[MDA!]')}}
    if (( $modified_count != 0 )); then
      modified_count=$ZSH_VCS_PROMPT_UNSTAGED_SIGIL${#${(f)modified_count}}
      hook_com[unstaged]+="%b%F{yellow}$modified_count%f"
    fi

    local unstaged_count=${#${(f)${(F)$(echo $hg_status | \grep '^?')}}}
    if (( $unstaged_count != 0 )); then
      unstaged_count=$ZSH_VCS_PROMPT_UNTRACKED_SIGIL$unstaged_count
      hook_com[unstaged]+="%f%b$unstaged_count%f"
    fi

    if [[ ! -n $hook_com[unstaged] ]]; then
      hook_com[unstaged]="%F{green}$ZSH_VCS_PROMPT_CLEAN_SIGIL%f"
    fi
  fi
}

typeset -F SECONDS
float vcs_async_start=0
float vcs_async_delay=0
integer vcs_async_sentinel=0
zsh_pickle -i async-sentinel vcs_async_sentinel
integer vcs_inotify_pid=-1

function vcs_async_info () {
  zsh_unpickle -s -i async-sentinel
  if (( $vcs_async_sentinel == 0 )); then
    vcs_async_start=$SECONDS
    vcs_async_sentinel=1
    vcs_async_info_worker $1 &!
  else
    (( vcs_async_sentinel++ ))
  fi
  zsh_pickle -i async-sentinel vcs_async_sentinel
}

function vcs_async_info_worker () {
  emulate -LR zsh
  local vcs_super_info vcs_super_raw_data

  vcs_super_info="$(vcs_super_info)"
  vcs_super_raw_data="$(vcs_super_info_raw_data)"
  zsh_pickle -i vcs-data vcs_super_info vcs_super_raw_data

  # Signal the parent shell to update the prompt.
  kill -USR1 $$
  if [[ $? != 0 ]]; then
      vcs_async_cleanup
  fi
}

function TRAPUSR1 {
  emulate -LR zsh
  setopt zle 2> /dev/null
  setopt prompt_subst transient_rprompt no_clobber

  if [[ -n $VCS_PAUSE ]]; then
    return 0;
  fi

  zsh_unpickle -s -c -i vcs-data

  vcs_async_delay=$(($SECONDS - $vcs_async_start))
  vcs_info_msg_0_=$vcs_super_info

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt

  vcs_raw_data=$vcs_super_raw_data
  if [[ ! -n $vcs_raw_data ]]; then
    unset vcs_raw_data
  fi

  # we use yet another pickle to track when the pwd changes
  # TODO: only restart inotify if we move out of its tracked zone
  zsh_unpickle -s -i vcs_last_dir

  # if we're in a vcs, start an inotify process
  if [[ $vcs_last_dir == ${${:-.}:A} ]]; then
    if [[ -n $vcs_info_msg_0_ ]]; then
        if (( $vcs_inotify_pid == -1 )); then
            vcs_inotify_watch ${${:-.}:A} &!
            vcs_inotify_pid=$!
        fi
    elif (( $vcs_inotify_pid != -1 )); then
        vcs_async_cleanup &!
    fi
  else
    if [[ -n $vcs_info_msg_0_ ]]; then
      vcs_async_cleanup &!
      vcs_inotify_watch ${${:-.}:A} &!
      vcs_inotify_pid=$!
    elif (( $vcs_inotify_pid != -1 )); then
      vcs_async_cleanup &!
    fi
  fi

  vcs_last_dir=${${:-.}:A}
  zsh_pickle -i vcs-last-dir vcs_last_dir

  zsh_unpickle -s -i async-sentinel
  local -i temp_sentinel=$vcs_async_sentinel
  vcs_async_sentinel=0
  zsh_pickle -i async-sentinel vcs_async_sentinel

  if [[ $temp_sentinel == 2 ]]; then
    vcs_async_info &!
  fi
}

function vcs_async_auto_update {
  emulate -LR zsh
  setopt function_argzero
  if [[ -n $VCS_PAUSE ]]; then
    return 0;
  fi
  vcs_async_sentinel=0
  zsh_pickle -i async-sentinel vcs_async_sentinel
  vcs_async_info
}

add-zsh-hook precmd vcs_async_auto_update

vcs_inotify_events=(modify move create delete)

function vcs_inotify_watch () {
  emulate -LR zsh
  if hash inotifywait &>/dev/null; then
    inotifywait -e ${=${(j: -e :)vcs_inotify_events}} \
                -mqr --format %w%f $1 2>> $ZDOTDIR/startup.log | \
    while IFS= read -r file; do
      # if parent is dead, kill self
      if ps -p $$ &> /dev/null; then
          vcs_inotify_do "$file"
      else
        kill -TERM -- -$$ -$! -$(exec $ZSH_NAME -fc 'print $PPID')
        break
      fi
    done
  else
    echo "inotify-tools is not installed." >> $ZDOTDIR/startup.log
    return 1
  fi
}

function vcs_inotify_do () {
  emulate -LR zsh
  vcs_async_info $file
}

function vcs_async_cleanup () {
  emulate -LR zsh
  if (( $vcs_inotify_pid != -1 )); then
    kill -TERM -- -$vcs_inotify_pid &> /dev/null
    vcs_inotify_pid=-1
  fi
}

add-zsh-hook zshexit vcs_async_cleanup
