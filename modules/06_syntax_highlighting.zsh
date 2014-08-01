# =======================
# ZSH syntax highlighting
# =======================

{
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  source ~/.zsh.d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source ~/.zsh.d/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh
  source ~/.zsh.d/zsh-syntax-highlighting/highlighters/brackets/brackets-highlighter.zsh

  ZSH_HIGHLIGHT_STYLES[default]='fg=grey'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=white'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[function]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[command]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=black,bold'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=green'
  ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
  ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,bold'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue,bold,underline'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow,bold'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow,bold'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[assign]='fg=white,bold'

} &>> ~/.zsh.d/startup.log
