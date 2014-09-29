# ===========
# Environment
# ===========

raw_cdpath=(~/ /etc/ /run/media/$USER/)
cdpath=(/etc/ /run/media/$USER/)

HISTFILE=~/.zsh.d/.histfile
HISTSIZE=50000
SAVEHIST=50000

export ZDOTDIR=~/.zsh.d
export EDITOR="vim"
export GEDITOR="emacsclient -c -a \"emacs\" --create-frame"
export ALTERNATE_EDITOR="emacs"
export REPORTTIME=10
export SAGE_STARTUP_FILE=~/.sage/init.sage
export PATH=$PATH:~/bin:~/usr/bin


typeset -TU LD_LIBRARY_PATH ld_library_path
typeset -TU PERL5LIB        perl5lib

typeset -U path
typeset -U manpath
typeset -U fpath 
typeset -U cdpath

NULLCMD="cat"
READNULLCMD="less"

# =================
# Terminal handling
# =================

# Indicates terminal does not support colors/decorations/unicode 
typeset -A degraded_terminal

degraded_terminal=(
  colors       0
  colors256    0
  decorations  0
  unicode      0
  rprompt      0
  title        0
  display_host 0
)

export _OLD_TERM=$TERM
case $_OLD_TERM in
  (dumb)
    emulate sh
    PS1="$ "
    unsetopt prompt_cr
    return 0;;
    
  (linux)
    degraded_terminal[unicode]=1;;

  (screen*|tmux*)
    export TERM='linux';;
    
  (*)
    export TERM=xterm
    [[ -f /usr/share/terminfo/x/xterm-256color ]] && {
      export TERM=xterm-256color
    };;
esac

if [[ -n ${MC_TMPDIR+1} ]]; then
  degraded_terminal[rprompt]=1
  degraded_terminal[decorations]=1
  degraded_terminal[title]=1
fi

if [[ -n ${EMACS+1} ]]; then
    degraded_terminal[title]=1
fi

if [[ -n "$SSH_CLIENT" || -n "SSH_TTY" ]]; then
  degraded_terminal[display_host]=1
elif [[ $(ps -o comm= -p $PPID) == (sshd|*/sshd) ]]; then
  degraded_terminal[display_host]=1
fi

# ======
# Colors
# ======
typeset -Ag FX
colors

# effects
FX=(
  reset     "[00m"
  bold      "[01m" no-bold      "[22m"
  italic    "[03m" no-italic    "[23m"
  underline "[04m" no-underline "[24m"
  blink     "[05m" no-blink     "[25m"
  reverse   "[07m" no-reverse   "[27m"
)

function () {
  if (( $+commands[dircolors] )); then
    local DIRCOLORS
    DIRCOLORS=~/.zsh.d/dircolors-solarized/dircolors.ansi-universal
    eval ${$(dircolors $DIRCOLORS):s/di=36/di=1;30/}
  fi
}

# ==========================
# Persistent directory stack
# ==========================

autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':chpwd:*' recent-dirs-max 100
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true
zstyle ':chpwd:*' recent-dirs-file "$ZDOTDIR/zdirs"

dirstack=(${(nu@Q)$(<$ZDOTDIR/zdirs)})

zstyle ':completion:*:cdr:*' verbose true
zstyle ':completion:*:cdr:*' extra-verbose true
