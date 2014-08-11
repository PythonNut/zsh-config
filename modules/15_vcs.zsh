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

typeset -F SECONDS
vcs_async_last=0
vcs_async_start=0
vcs_async_delay=0
VCS_INOTIFY="off"

function vcs_async_info () {
  vcs_async_start=$SECONDS
  vcs_async_info_worker $1 &!
  vcs_async_last=$SECONDS
}

VCS_ASYNC_TMP="/dev/shm"

function vcs_async_info_worker () {
  emulate -LR zsh
  setopt noclobber multios

  if (( $zsh_scheduled_events[(i)*vcs_async_info_worker*] <= $#zsh_scheduled_events )); then
    return 0;
  fi

  if (( $SECONDS - $vcs_async_last > 0.3 )); then
    # Save the prompt in a temp file so the parent shell can read it.
    echo "$(vcs_super_info)" >! $VCS_ASYNC_TMP/vcs-prompt.$$

    local vcs_raw_data
    vcs_raw_data="$(vcs_super_info_raw_data)"

    if [[ -n "$vcs_raw_data" ]]; then
      echo "$vcs_raw_data" >! $VCS_ASYNC_TMP/vcs-data.$$
    else
      command rm -f $VCS_ASYNC_TMP/vcs-data.$$
    fi
    
    # Signal the parent shell to update the prompt.
    kill -USR1 $$
    
  else
    sched +1 vcs_async_info_worker 
  fi
}

function TRAPUSR1 {
  emulate -LR zsh
  setopt zle prompt_subst transient_rprompt no_clobber

  vcs_async_delay=$(($SECONDS - $vcs_async_start))
  vcs_info_msg_0_=$(cat "$VCS_ASYNC_TMP/vcs-prompt.$$" 2> /dev/null)
  command rm -f $VCS_ASYNC_TMP/vcs-prompt.$$ 2> /dev/null

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt

  if [[ -f "$VCS_ASYNC_TMP/vcs-data.$$" ]]; then
    vcs_raw_data=$(cat "$VCS_ASYNC_TMP/vcs-data.$$" 2> /dev/null)
    command rm -f $VCS_ASYNC_TMP/vcs-data.$$ 2> /dev/null
  else
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

function vcs_inotify_watch () {
  emulate -LR zsh
  if hash inotifywait &>/dev/null; then
    inotifywait -m -q -r -e modify -e move -e create -e delete --format %w%f $1 2> /dev/null | while IFS= read -r file; do
      vcs_inotify_do "$file"
    done
  fi
}

function vcs_inotify_do () {
  emulate -LR zsh
  vcs_async_info $file
}

