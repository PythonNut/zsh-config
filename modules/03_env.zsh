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

NULLCMD="cat"
READNULLCMD="less"

export _OLD_TERM=$TERM
case $_OLD_TERM in
   (dumb)
      emulate sh
      PS1="$ "
      return 1;;
   
   (screen*)
      export TERM='linux';;
   
   (*)
      export TERM=xterm
      [[ -f /usr/share/terminfo/x/xterm-256color ]] && {
        export TERM=xterm-256color
      };;
esac

# color files in ls
{
   DIRCOLORS=~/.zsh.d/dircolors-solarized/dircolors.ansi-universal
   eval $(dircolors $DIRCOLORS | sed "s/di=36/di=1;30/")
} always {
   # make sure DIRCOLORS does not pollute the environment
   unset DIRCOLORS
}

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
