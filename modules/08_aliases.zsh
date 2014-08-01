# =======
# Aliases
# =======
{
  # proxy aliases
  BORING_FILES="*\~|*.elc|*.pyc|!*|_*|*.swp"
  alias lsa="\ls --color --group-directories-first"
  alias lst="lsa -I \"${BORING_FILES:gs/\|/\" -I \"/}\""
  alias egrep="nocorrect noglob \egrep --line-buffered --color=auto"
  
  # ls aes
  alias ls="lst -BFx"
  alias l='lst -lFBGh'
  alias ll='lsa -lAFGh'
  alias lss="lst -BFshx"
  alias lsp="\ls"
  
  # saftey a
  alias rm="rm -i" cp="cp -i"
  alias rmf="\rm" cpf="\cp"
  
  # global aes
  alias -g G="|& egrep -i"
  alias -g L="|& less -R"
  alias -g Lr="|& less"
  alias -g D=">&/dev/null"
  alias -g W="|& wc -l -c"
  alias -g Q=">&/dev/null&"
  alias -g ,,=";=read -n1 -rp 'Press any key to continue...'"
  
  # regular aes
  alias su="su -"          
  alias watch="\watch -n 1 -d "    
  alias emacs="\emacs -nw"       
  alias df='\df -h'          
  alias ping="\ping -c 10"       
  alias exi="exit"           
  alias locate="\locate -ib"     
  alias exit=" exit"         
  alias tail='\tail -n $(tput lines)'
  alias y="yaourt"
  alias yi="yaourt -Sa"
  alias yu="yaourt -Syyua --noconfirm"
  alias yuu="yaourt --sucre"
  
  # supression aes
  alias yum="nocorrect noglob \yum"  
  alias man="nocorrect noglob \man"  
  alias find="noglob find"       
  alias touch="nocorrect \touch"   
  alias mkdir="nocorrect \mkdir"   
  alias killall="nocorrect \killall" 
  alias yum-config-manager="nocorrect noglob \yum-config-manager"
} always {
  unfunction a
} &>> ~/.zsh.d/startup.log

# ==============
# Expand aliases
# ==============
# typeset -A abbrevs
expand=("math" "cd" "grep" "fgrep" "mc" "emc" "lst" ",," "lsa" "exit" "px")

for supressed in $(alias |& egrep -i '(nocorrect|noglob)' | cut -f1 -d "="); do
  expand+=($supressed)
done

# expand aliases on space
function expandAlias() {
  cmd=(${(s/ /)LBUFFER})
  if (( ${(e)expand[(i)${cmd[-1]}]} > ${#expand} )) && [[ ${cmd[-1]} != (\\*) ]]; then
    zle _expand_alias
  fi
  if [[ $RBUFFER[1] != " " ]]; then
    zle self-insert
  else
    zle forward-char
    while [[ $RBUFFER[1] == " " ]]; do
      zle forward-char
      zle backward-delete-char
    done
  fi
  _zsh_highlight
}

zle -N expandAlias

global_bindkey " " expandAlias
global_bindkey "^ " magic-space
bindkey -M isearch " " magic-space
