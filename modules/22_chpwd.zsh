# ========================================
# Title + Path compression + chpwd handler
# ========================================

TMPPREFIX=/dev/shm/ # use shared memory

function chpwd_async_worker () {
  emulate -LR zsh
  chpwd_minify_smart_str=$(minify_path_smart .)
  chpwd_minify_fasd_str=$(minify_path_fasd .)
  zsh_pickle -i async-chpwd chpwd_minify_smart_str chpwd_minify_fasd_str

  # Signal the parent shell to update the prompt.
  kill -USR2 $$
}

function TRAPUSR2 {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  zsh_unpickle -s -c -i async-chpwd

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt

  # and update the title
  title_async_compress
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
    chpwd_minify_smart_str=${${:-.}:A:t}
    zle && zle reset-prompt
  else
    chpwd_minify_smart_str=$(minify_path .)
    chpwd_minify_fast_str=$chpwd_minify_smart_str
    chpwd_async_worker &!
  fi
}

add-zsh-hook chpwd prompt_async_compress
prompt_async_compress
