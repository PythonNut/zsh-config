# ========================================
# Title + Path compression + chpwd handler
# ========================================

function chpwd_async_worker () {
  emulate -LR zsh
  chpwd_minify_smart_str=$(minify_path_smart .)
  chpwd_minify_fasd_str=$(minify_path_fasd .)
  zsh_pickle -i async-chpwd chpwd_minify_smart_str chpwd_minify_fasd_str

  # Signal the parent shell to update the prompt.
  kill -USR1 $$
}

function TRAPUSR1 {
  emulate -LR zsh
  setopt zle 2> /dev/null
  setopt prompt_subst transient_rprompt
  zsh_unpickle -s -c -i async-chpwd

  # Force zsh to redisplay the prompt.
  compute_prompt
  zle && zle reset-prompt

  # and update the title
  title_async_compress
}

function recompute_cdpath() {
  emulate -LR zsh
  cdpath=(${(@)raw_cdpath:#${${:-.}:A}/})
}

add-zsh-hook chpwd recompute_cdpath
recompute_cdpath

function prompt_async_compress () {
  emulate -LR zsh
  setopt prompt_subst transient_rprompt
  # check if we're running under Midnight Commander
  if (( $degraded_terminal[decorations] == 1 )); then
    chpwd_minify_smart_str=${${:-.}:A:t}
    zle && zle reset-prompt
  else
    chpwd_minify_smart_str="$(minify_path .)"
    chpwd_minify_fast_str="$chpwd_minify_smart_str"
    chpwd_async_worker &!
  fi
}

add-zsh-hook chpwd prompt_async_compress
prompt_async_compress
