# =======
# Aliases
# =======
{
  function a(){ alias $@}

  # proxy aliases
  BORING_FILES="*\~|*.elc|*.pyc|!*|_*|*.swp"
  a lsa="\ls --color --group-directories-first"
  a lst="lsa -I \"${BORING_FILES:gs/\|/\" -I \"/}\""
  a egrep="nocorrect noglob \egrep --line-buffered --color=auto"
  
  # ls aes
  a ls="lst -BFx"
  a l='lst -lFBGh'
  a ll='lsa -lAFGh'
  a lss="lst -BFshx"
  a lsp="\ls"
  
  # saftey a
  a rm="rm -i" cp="cp -i"
  a rmf="\rm" cpf="\cp"
  
  # global aes
  a -g G="|& egrep -i"
  a -g L="|& less -R"
  a -g Lr="|& less"
  a -g D=">&/dev/null"
  a -g W="|& wc -l -c"
  a -g Q=">&/dev/null&"
  a -g ,,=";=read -n1 -rp 'Press any key to continue...'"
  
  # regular aes
  a su="su -"          
  a watch="\watch -n 1 -d "    
  a emacs="\emacs -nw"       
  a df='\df -h'          
  a ping="\ping -c 10"       
  a exi="exit"           
  a locate="\locate -ib"     
  a exit=" exit"         
  a tail='\tail -n $(tput lines)'
  a y="yaourt"
  a yi="yaourt -Sa"
  a yu="yaourt -Syyua --noconfirm"
  a yuu="yaourt --sucre"
  
  # supression aes
  a yum="nocorrect noglob \yum"  
  a man="nocorrect noglob \man"  
  a find="noglob find"       
  a touch="nocorrect \touch"   
  a mkdir="nocorrect \mkdir"   
  a killall="nocorrect \killall" 
  a yum-config-manager="nocorrect noglob \yum-config-manager"
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
