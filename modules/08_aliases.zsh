# =======
# Aliases
# =======
typeset -A global_abbrevs command_abbrevs
typeset -a expand

expand=('mc')

function alias () {
  emulate -LR zsh
  zparseopts -D -E eg=EG ec=EC E=E
  if [[ -n $EG ]]; then
    for token in $@; do
      token=(${(s/=/)token})
      builtin alias -g $token
      global_abbrevs[$token[1]]=$token[2]
    done
  elif [[ -n $EC ]]; then
    for token in $@; do
      builtin alias $token
      token=(${(s/=/)token})
      command_abbrevs[$token[1]]=$token[2]
    done
  else
    if [[ -n $E ]]; then
      for token in $@; do
        if [[ $token == (*=*) ]]; then
          token=(${(s/=/)token})
          expand+="$token[1]"
        fi
      done
    fi
    builtin alias $@
  fi
}

# history supression aliases
alias -E clear=' clear'
alias -E pwd=' pwd'
alias -E exit=' exit'

# proxy aliases
BORING_FILES='*\~|*.elc|*.pyc|!*|_*|*.swp|*.zwc|*.zwc.old'
if [[ $OSTYPE != (#i)(free|open|net)bsd* ]]; then
  alias lsa='\ls --color --group-directories-first'
  alias -E lst=" lsa -I '"${BORING_FILES//\|/\' -I \'}"'"
else
  # in BSD, -G is the equivalent of --color
  alias -E lst=' \ls -G'
fi
alias -E egrep='nocorrect \egrep --line-buffered --color=auto'

# ls aliases
alias ls='lst -BFx'
alias l='lst -lFBGh'
alias ll='lsa -lAFGh'
alias lss='lst -BFshx'
alias lsp='\ls'

# safety aliases
alias rm='rm -i' cp='cp -i'
alias rmf='\rm' cpf='\cp'
alias ln="\ln -s"

# global aliases
alias -g G='|& egrep -i'
alias -g L='|& less -R'
alias -g Lr='|& less'
alias -g D='>&/dev/null'
alias -g W='|& wc'
alias -g Q='>&/dev/null&'
alias -E -g ,,=';=read -n1 -rp "Press any key to continue..."'

# regular aliases
alias su='su -'
alias watch='\watch -n 1 -d '
alias emacs='\emacs -nw'
alias df='\df -h'
alias ping='\ping -c 10'
alias exi='exit'
alias locate='\locate -ib'
alias -E exit=' exit'

# suppression aliases
alias -E man='nocorrect noglob \man'
alias -E find='noglob find'
alias -E touch='nocorrect \touch'
alias -E mkdir='nocorrect \mkdir'

if (( $+commands[killall] )); then
  alias -E killall='nocorrect \killall'
elif (( $+commands[pkill] )); then
  alias -E killall='nocorrect \pkill'
fi

# sudo aliases
if (( $+commands[sudo] )); then
  function sudo {
    emulate -L zsh -o no_rc_expand_param
    local precommands=()
    while [[ $1 == (nocorrect|noglob) ]]; do
      precommands+=$1
      shift
    done
    eval "$precommands command sudo $@"
  }

  alias -E sudo='nocorrect sudo '
  alias -ec please='echo -E sudo ${history[$#history]}'
fi

# yaourt aliases
if (( $+commands[yaourt] )); then
  alias y='yaourt'
  alias yi='yaourt -Sa'
  alias yu='yaourt -Syyua --noconfirm'
  alias yuu='yaourt -Syyua --noconfirm --devel'
fi

# dnf aliases
if (( $+commands[dnf] )); then
  alias -E dnf='nocorrect noglob \dnf'
fi

# vim aliases
if (( $+commands[gvim] )); then
  alias -E vim="gvim -v"
fi
if (( $+commands[vim] )); then
  alias -E vi="vim"
fi

# git aliases
if (( $+commands[git] )); then
  alias gs='git status -sb'
  alias gst='git status'

  alias gp="git pull --rebase -X histogram"

  alias ga='git add'
  alias gau='git add -u'
  alias gaa='git add -A'

  alias gc='git commit -v'
  alias -ec gcm="echo -E git commit -v -m '{}'"
  alias gc!='git commit -v --amend'
  alias gca='git commit -v -a'
  alias -ec gcam="echo -E git commit -v -a -m '{}'"
  alias gca!='git commit -v -a --amend'

  alias gck='git checkout'
  alias -ec gfork='echo -E git checkout -b {} $(git rev-parse --abbrev-ref HEAD 2>/dev/null)'

  alias gb='git branch'
  alias gm='git merge -X histogram --no-ff'
  alias gr="git rebase -X histogram"

  alias gd='git diff --histogram'
  alias gdc='git diff --histogram --cached'
  alias gd!='git diff --word-diff'
  alias gdc!='git diff --word-diff --cached'

  alias gl='git log --oneline --graph --decorate'

  alias -eg .B='echo $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")'
fi

if (( $+commands[emacsclient] )); then
  alias -E ec='emacsclient -t -q'
  alias -E ecg='emacsclient -c -n -q'
fi

# ==============
# Expand aliases
# ==============

# expand aliases on space
function expand_alias() {
  emulate -LR zsh -o hist_subst_pattern
  {
    # hack a local function scope using unfuction
    function expand_alias_smart_space () {
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

    function expand_alias_smart_expand () {
      zparseopts -D -E g=G
      local expansion="${@[2,-1]}"
      local delta=$(($#expansion - $expansion[(i){}] - 1))

      alias ${G:+-g} $1=${expansion/{}/}

      zle _expand_alias
      
      for ((i=0; i < $delta; i++)); do
        zle backward-char
      done
    }

    local cmd=(${(@s/;/)LBUFFER:gs/[^[:IDENT:]]/;})
    if [[ -n "$command_abbrevs[$cmd[-1]]" && $#cmd == 1 ]]; then
      expand_alias_smart_expand $cmd[-1] "$(${=${(e)command_abbrevs[$cmd[-1]]}})"

    elif [[ -n "$global_abbrevs[$cmd[-1]]" ]]; then
      expand_alias_smart_expand -g $cmd[-1] "$(${=${(e)global_abbrevs[$cmd[-1]]}})"

    elif [[ "${(j: :)cmd}" == *\!* ]] && alias "$cmd[-1]" &>/dev/null; then
      if [[ -n "$aliases[$cmd[-1]]" ]]; then
        LBUFFER="$aliases[$cmd[-1]] "
      fi
      
    elif [[ "$+expand[(r)$cmd[-1]]" != 1 && "$cmd[-1]" != (\\|\"|\')* ]]; then
      zle _expand_alias
      expand_alias_smart_space "$1"
      
    else
      expand_alias_smart_space "$1"
    fi

  } always {
    unfunction "expand_alias_smart_space" "expand_alias_smart_expand"
  }

  _zsh_highlight
}

zle -N expand_alias

global_bindkey " " expand_alias
global_bindkey "^ " magic-space
bindkey -M isearch " " magic-space

