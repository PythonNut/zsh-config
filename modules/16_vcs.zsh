# ======================
# Version Control System
# ======================
zstyle ':vcs_info:*' enable git svn cvs hg bzr
zstyle ':vcs_info:*' check-for-changes true

ZSH_VCS_PROMPT_ENABLE_CACHING='false'
ZSH_VCS_PROMPT_USING_PYTHON='true'

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

function +vi-svn-untracked {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
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

function +vi-hg-untracked {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
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

function vcs_get_root_dir () {
  case $1 in
    (git)
      git rev-parse --show-toplevel;;
    (hg)
      hg root;;
    (svn)
      if [[ -d ".svn" ]]; then
        if [[ -d "../.svn" ]]; then
          # case 2: SVN < 1.7, any directory
          local parent=""
          local grandparent="."

          while [[ -d "$grandparent/.svn" ]]; do
              parent=$grandparent
              grandparent="$parent/.."
          done

          echo ${parent:A}
        else
          # case 2: SVN >= 1.7, root directory
          echo ${${:-.}:A}
        fi
      else
        # case 3: SVN >= 1.7, non root directory
        local parent="."
        while [[ ! -d "$parent/.svn" ]]; do
            parent+="/.."
        done

        echo ${parent:A}
      fi;;
    (bzr)
      bzr root;;
    (cvs)
      echo $CVSROOT;;
    (*)
      echo $(pwd);;
  esac
}

typeset -F SECONDS

function vcs_async_info () {
  async_job vcs_prompt vcs_async_info_worker ${${:-.}:A}
}

function vcs_async_info_worker () {
  local vcs_super_info
  local vcs_root_dir
  local -a vcs_super_raw_data
  builtin cd $1
  vcs_current_pwd=$1
  vcs_super_info="$(vcs_super_info)"
  vcs_super_raw_data=($(vcs_super_info_raw_data))
  vcs_root_dir=${$(vcs_get_root_dir $vcs_super_raw_data[2])%/}

  typeset -p vcs_current_pwd
  typeset -p vcs_super_info
  typeset -p vcs_super_raw_data
  typeset -p vcs_root_dir
}

function vcs_async_callback () {
  local current_pwd
  local vcs_super_info
  local vcs_super_raw_data
  local vcs_root_dir
  current_pwd=${${:-.}:A}

  eval $3

  vcs_info_msg_0_=$vcs_super_info
  vcs_raw_data=$vcs_super_raw_data

  zle reset-prompt
  zle -R

  # if we're in a vcs, start an inotify process
  if [[ $current_pwd/ != $vcs_last_root/* ]]; then
    vcs_async_cleanup
    if [[ -n $vcs_info_msg_0_ ]]; then
      async_job vcs_inotify vcs_inotify_watch $vcs_root_dir $$
    fi
    vcs_async_info
  fi

  vcs_last_root=$vcs_root_dir
}

async_start_worker vcs_prompt -u
async_register_callback vcs_prompt vcs_async_callback

add-zsh-hook precmd vcs_async_info

vcs_inotify_events=(modify move create delete)

function vcs_inotify_watch () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  if hash inotifywait &>/dev/null; then
    inotifywait -e ${=${(j: -e :)vcs_inotify_events}} \
                -mqr --format %w%f $1 2>> $ZDOTDIR/startup.log | \
    while IFS= read -r file; do
      if [[ $file == */index.lock ]]; then
        continue
      fi
      kill -USR2 $2
    done
  else
    echo "inotify-tools is not installed." >> $ZDOTDIR/startup.log
    return 1
  fi
}

function vcs_inotify_callback () {
  echo $1:$2:$3:$4:$5 &>> $ZDOTDIR/startup.log
}

function TRAPUSR2 () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  vcs_async_info
}

function vcs_async_cleanup () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  async_flush_jobs vcs_inotify
}

function vcs_pause () {
  if [[ -n ${chpwd_functions[(r)vcs_async_info]} ]]; then
    add-zsh-hook -d precmd vcs_async_info
  else
    add-zsh-hook precmd vcs_async_info
  fi
}

async_start_worker vcs_inotify -u
async_register_callback vcs_inotify vcs_inotify_callback
