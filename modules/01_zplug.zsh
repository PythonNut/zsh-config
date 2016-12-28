export ZPLUG_HOME=$ZDOTDIR/.zplug
# Check if zplug is installed
if [[ ! -d $ZPLUG_HOME ]]; then
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", at:feec9f5
zplug "zsh-users/zsh-completions"
zplug "yonchu/zsh-vcs-prompt"
zplug "seebi/dircolors-solarized"
zplug "clvv/fasd", as:command
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zaw"
zplug "yonchu/zaw-src-git-log", on:"zsh-users/zaw"
zplug "yonchu/zaw-src-git-show-branch", on:"zsh-users/zaw"
zplug "mafredri/zsh-async"
zplug "PythonNut/zsh-autosuggestions", on:"zsh-async"
zplug "knu/zsh-git-escape-magic"
zplug "coldfix/zsh-soft-history"
zplug "hchbaw/auto-fu.zsh", at:pu, on:"zsh-users/zsh-syntax-highlighting"

if ! zplug check; then
    zplug install
    exec zsh
fi

function {
  setopt localoptions no_rcexpandparam
  zplug load
}
