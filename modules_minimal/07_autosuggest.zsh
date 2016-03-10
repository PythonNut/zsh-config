{
  source $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
} &>> $ZDOTDIR/startup.log

function global_bindkey () {
  bindkey -M command $@
  bindkey -M emacs   $@
  bindkey -M main    $@
  bindkey            $@
}

# because some other lines call this function to reset state
zle-line-init () { }
zle -N zle-line-init
