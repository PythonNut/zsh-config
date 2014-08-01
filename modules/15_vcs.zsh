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
ZSH_VCS_PROMPT_USING_PYTHON='false'

ZSH_VCS_PROMPT_AHEAD_SIGIL='↑'
ZSH_VCS_PROMPT_BEHIND_SIGIL='↓'
ZSH_VCS_PROMPT_STAGED_SIGIL='●'
ZSH_VCS_PROMPT_CONFLICTS_SIGIL='✖'
ZSH_VCS_PROMPT_UNSTAGED_SIGIL='✚'
ZSH_VCS_PROMPT_UNTRACKED_SIGIL='…'
ZSH_VCS_PROMPT_STASHED_SIGIL='⚑'
ZSH_VCS_PROMPT_CLEAN_SIGIL='✔'

function async_vcs_info () {
  # Save the prompt in a temp file so the parent shell can read it.
  printf "%s" "$(vcs_super_info)" >! ${TMPPREFIX}/vcs-prompt.$$

  local vcs_raw_data

  vcs_raw_data="$(vcs_super_info_raw_data)"

  if [[ -n $vcs_raw_data ]]; then
    echo $vcs_raw_data >! ${TMPPREFIX}/vcs-data.$$
    case "${${(f)vcs_raw_data}[2]}" in
      (git)
        git rev-parse --show-toplevel >> ${TMPPREFIX}/vcs-data.$$;;

      (hg)
        hg root >> ${TMPPREFIX}/vcs-data.$$;;

      (svn)
        local cur_path="."
        if [[ -d .svn ]]; then
          while [[ -d $cur_path/.svn ]]; do
            cur_path="$cur_path/.."
          done
          echo ${${cur_path%%/..}:A} >> ${TMPPREFIX}/vcs-data.$$
        else
          while [[ ! -d $cur_path/.svn && $cur_path:A != / ]]; do
            cur_path=$cur_path/..
          done
          echo ${cur_path:A} >> ${TMPPREFIX}/vcs-data.$$
        fi;;

      (*)
        echo >> ${TMPPREFIX}/vcs-data.$$;;

      esac
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
    
    case "${${(f)vcs_raw_data}[2]}" in
      (git)
        # git has more data
        if [[ -n ${${(f)vcs_data}[14]} ]]; then
          alias -g .R="${${(f)vcs_data}[14]}"
        fi;;
      (*)
        if [[ -n ${${(f)vcs_data}[5]} ]]; then
          alias -g .R="${${(f)vcs_data}[5]}"
        fi;;
    esac
    
  else
    if [[ $(type ".B") == *alias* ]]; then
      unalias .B
    fi
    if [[ $(type ".R") == *alias* ]]; then
      unalias .R
    fi
  fi
}

function TRAPUSR1 {
  vcs_info_msg_0_=$(cat "${TMPPREFIX}/vcs-prompt.$$" 2> /dev/null)
  command rm ${TMPPREFIX}/vcs-prompt.$$ 2> /dev/null

  compute_context_aliases
    
  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}
