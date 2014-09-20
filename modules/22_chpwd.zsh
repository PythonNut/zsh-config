# ========================================
# Title + Path compression + chpwd handler
# ========================================
_titleManual=0

TMPPREFIX=/dev/shm/ # use shared memory

function chpwd_async_worker () {
  emulate -LR zsh
  chpwd_s_str=$(minify_path_smart .)

  zsh_pickle -i async-chpwd chpwd_s_str

  # Signal the parent shell to update the prompt.
  kill -USR2 $$
}

function TRAPUSR2 {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  zsh_unpickle -s -c -i async-chpwd

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}

# Build the prompt in a background job.
chpwd_async_worker &!

function recompute_cdpath() {
  emulate -LR zsh
  cdpath=("${(s/ /)$(eval echo $(echo "\${(@)raw_cdpath:#${${:-.}:A}/}"))}")
}

add-zsh-hook chpwd recompute_cdpath

function prompt_async_compress () {
  # check if we're running under Midnight Commander
  if (( $degraded_terminal[decorations] == 1 )); then
    chpwd_s_str=${${:-.}:A:t}
    zle && zle reset-prompt
  else
    chpwd_s_str=$(minify_path .)
    if [[ $_titleManual == 0 ]]; then
      _setTitle "$(minify_path .) [$(minify_path_fasd .)]"
    fi
    chpwd_async_worker &!
  fi
}


function title_async_compress () {
  if (( $degraded_terminal[title] != 1 && $_titleManual == 0 )); then
    # minify_path will not change over time, fasd will
    _setTitle "$chpwd_s_str [$(minify_path_fasd .)]"
  fi
}

add-zsh-hook chpwd prompt_async_compress
add-zsh-hook precmd title_async_compress

prompt_async_compress
title_async_compress
