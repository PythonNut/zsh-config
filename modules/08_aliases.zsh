# =======
# Aliases
# =======
typeset -A global_abbrevs command_abbrevs

function alias () {
  emulate -LR zsh
  if [[ "$1" == "-eg" ]]; then
    for token in $@[2,-1]; do
      token=(${(s/=/)token})
      builtin alias -g $token
      global_abbrevs[$token[1]]=$token[2]
    done
  elif [[ "$1" == "-ec" ]]; then
    for token in $@[2,-1]; do
      builtin alias $token
      token=(${(s/=/)token})
      command_abbrevs[$token[1]]=$token[2]
    done
  else
    builtin alias $@
  fi
}

# proxy aliases
BORING_FILES='*\~|*.elc|*.pyc|!*|_*|*.swp|*.zwc|*.zwc.old'
if [[ $OSTYPE != (#i)(free|open|net)bsd* ]]; then
  alias lsa='\ls --color --group-directories-first'
  alias lst="lsa -I '${BORING_FILES:gs/\|/' -I '/}'"
else
  # in BSD, -G is the equivalent of --color
  alias lst='\ls -G'
fi
alias egrep='nocorrect \egrep --line-buffered --color=auto'

# ls aliases
alias ls='lst -BFx'
alias l='lst -lFBGh'
alias ll='lsa -lAFGh'
alias lss='lst -BFshx'
alias lsp='\ls'

# saftey aliases
alias rm='rm -i' cp='cp -i'
alias rmf='\rm' cpf='\cp'
alias ln="\ln -s"

# global aliases
alias -g G='|& egrep -i'
alias -g L='|& less -R'
alias -g Lr='|& less'
alias -g D='>&/dev/null'
alias -g W='|& wc -l -c'
alias -g Q='>&/dev/null&'
alias -g ,,=';=read -n1 -rp 'Press any key to continue...''

# regular aliases
alias su='su -'
alias cd='cdr'
alias watch='\watch -n 1 -d '
alias emacs='\emacs -nw'
alias df='\df -h'
alias ping='\ping -c 10'
alias exi='exit'
alias locate='\locate -ib'
alias exit=' exit'

# suppression aliases
alias man='nocorrect noglob \man'
alias find='noglob find'
alias touch='nocorrect \touch'
alias mkdir='nocorrect \mkdir'

if (( $+commands[killall] )); then
  alias killall='nocorrect \killall'
elif (( $+commands[pkill] )); then
  alias killall='nocorrect \pkill'
fi

# sudo aliases
if (( $+commands[sudo] )); then
  alias sudo="sudo "
  alias please='sudo !!'
fi

# yaourt aliases
if (( $+commands[yaourt] )); then
  alias y='yaourt'
  alias yi='yaourt -Sa'
  alias yu='yaourt -Syyua --noconfirm'
  alias yuu='yaourt --sucre'
fi

# yum aliases
if (( $+commands[yum] )); then
  if (( $user_has_root == 1 )); then
    alias yum-config-manager='nocorrect noglob \yum-config-manager'
    alias yum='nocorrect noglob \yum'
  else
    alias yum-config-manager='nocorrect noglob sudo \yum-config-manager'
    alias yum='nocorrect noglob sudo \yum'
  fi
fi

# git aliases
if (( $+commands[git] )); then
  alias gs='git status -s'
  alias gst='git status'

  alias gp="git pull --rebase -X patience"

  alias ga='git add'
  alias gau='git add -u'
  alias gaa='git add -A'

  alias gc='git commit -v'
  alias -ec gcm="echo git commit -v -m '{}'"
  alias gc!='git commit -v --amend'
  alias gca='git commit -v -a'
  alias -ec gcam="echo git commit -v -a -m '{}'"
  alias gca!='git commit -v -a --amend'

  alias gck='git checkout'
  alias -ec gfork='echo git checkout -b {} ${${(f)vcs_raw_data}[4]}'

  alias gb='git branch'
  alias gm='git merge -X patience --no-ff'
  alias gr="git rebase -X patience"

  alias gd='git diff --patience'
  alias gdc='git diff --patience --cached'
  alias gd!='git diff --word-diff'
  alias gdc!='git diff --word-diff --cached'

  alias gl='git log --oneline --graph --decorate'

  alias -eg .B='echo ${${(f)vcs_raw_data}[4]}'
fi

# ==============
# Expand aliases
# ==============
# typeset -A abbrevs
expand=('go' 'cd' 'grep' 'fgrep' 'egrep' 'mc' 'lst' ',,' 'lsa' 'exit' 'px')

for supressed in $(alias |& egrep -i '(nocorrect|noglob)' | cut -f1 -d=); do
  expand+=($supressed)
done

# expand aliases on space
function expandAlias() {
  emulate -LR zsh
  {
    setopt function_argzero
    # hack a local function scope using unfuction
    function $0_smart_space () {
      if [[ $RBUFFER[1] != ' ' ]]; then
        if [[ ! "$1" == "no_space" ]]; then
          zle magic-space
        fi
      else
        # we aren't at the end of the line so squeeze spaces
        
        zle forward-char
        while [[ $RBUFFER[1] == " " ]]; do
          zle forward-char
          zle backward-delete-char
        done
      fi
    }

    function $0_smart_expand () {
      zparseopts -D -E i=G
      local expansion="${@[2,-1]}"
      local delta=$(($#expansion - $expansion[(i){}] - 1))

      alias ${G:+-g} $1=${expansion/{}/}
      
      zle _expand_alias
      
      for ((i=0; i < $delta; i++)); do
        zle backward-char
      done
    }

    local cmd
    cmd=("${(@s/ /)LBUFFER}")
    if [[ -n "$command_abbrevs[$cmd[-1]]" && $#cmd == 1 ]]; then
      $0_smart_expand $cmd[-1] "$(${(s/ /e)command_abbrevs[$cmd[-1]]})"

    elif [[ -n "$global_abbrevs[$cmd[-1]]" ]]; then
      $0_smart_expand -g $cmd[-1] "$(${(s/ /e)global_abbrevs[$cmd[-1]]})"

    elif [[ ${(j: :)cmd} == *\!* ]] && alias "$cmd[-1]" &>/dev/null; then
      if [[ -n "$aliases[$cmd[-1]]" ]]; then
        LBUFFER="$aliases[$cmd[-1]] "
      fi
      
    elif (( ! $+expand[(r)$cmd[-1]] )) && [[ $cmd[-1] != (\\*) ]]; then
      zle _expand_alias
      $0_smart_space $1
      
    else
      $0_smart_space $1
    fi

  } always {
    unfunction -m "$0_*"
  }

  _zsh_highlight
}

zle -N expandAlias

global_bindkey " " expandAlias
global_bindkey "^ " magic-space
bindkey -M isearch " " magic-space

