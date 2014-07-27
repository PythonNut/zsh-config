#!/bin/zsh

# core zsh setup
zstyle :compinstall filename '~/.zshrc'
skip_global_compinit=1
fpath=($fpath ~/.zsh.d/completers)
autoload -Uz compinit  && compinit
echo -n > ~/.zsh.d/startup.log
setopt function_argzero
mkdir -p ~/.zsh.d
touch ~/.zsh.d/startup.log

# ===========
# ZSH options
# ===========
{
  function s(){ setopt $@}

  # general
  s zle                    # magic stuff
  s no_beep                # beep is annoying
  s rm_star_wait           # are you REALLY sure?
  s auto_resume            # running a suspended program
  s check_jobs             # check jobs before exiting
  s auto_continue          # send CONT to disowned processes
  s function_argzero       # $0 contains the function name
  s interactive_comments   # shell comments (for presenting)

  # correction
  s correct_all            # autocorrect misspelled command
  s auto_list              # list if multiple matches
  s complete_in_word       # complete at cursor
  s menu_complete          # add first of multiple
  s auto_remove_slash      # remove extra slashes if needed
  s auto_param_slash       # completed directory ends in /
  s auto_param_keys        # smart insert spaces " "
  s list_packed            # conserve space

  # globbing
  s numeric_glob_sort      # sort globs numerically
  s extended_glob          # awesome globs
  s ksh_glob               # allow modifiers before regex ()
  s rc_expand_param        # a$abc ==> aa ab ac
  s no_case_glob           # lazy case for globs
  s glob_dots              # don't require a dot
  s no_case_match          # lazy case for regex matches
  s bare_glob_qual         # can use qualifirs by themselves
  s mark_dirs              # glob directories end in "/"
  s list_types             # append type chars to files
  s null_glob              # don't err on null globs
  s brace_ccl              # extended brace expansion

  # history
  s hist_reduce_blanks     # collapse extra whitespace
  s hist_ignore_space      # ignore lines starting with " "
  s hist_ignore_dups       # ignore immediate duplicates
  s hist_find_no_dups      # ignore all search duplicates
  s extended_history       # timestamps are nice, really
  s append_history         # append is good, append!
  s inc_append_history     # append in real time
  s share_history          # share history between terminals
  s hist_no_store          # don't store history commands
  s hist_expire_dups_first # kill the dups! kill the dups!
  s hist_verify            # verify history expansions

  # i/o and syntax
  s multios                # redirect to globs!
  s multibyte              # Unicode!
  s noclobber              # don't overwrite with > use !>
  s rc_quotes              # 'Isn''t' ==> Isn't
  s equals                 # "=ps" ==> "/usr/bin/ps"
  s hash_list_all          # more accurate correction
  s list_rows_first        # rows are way better
  s hash_cmds              # don't search for commands
  s cdable_vars            # in p, cd x ==> ~/x if x not p
  s short_loops            # sooo lazy: for x in y do cmd
  s chase_links            # resolve links to their location
  s notify                 # I want to know NOW!

  # navigation
  s auto_cd                # just "dir" instead of "cd dir"
  s auto_pushd             # push everything to the dirstack
  s pushd_silent           # don't tell me though, I know.
  s pushd_ignore_dups      # duplicates are redundant (duh)
  s pushd_minus            # invert pushd behavior
  s pushd_to_home          # pushd == pushd ~
  s auto_name_dirs         # if I set a=/usr/bin, cd a works
  s magic_equal_subst      # expand expressions after =

  s prompt_subst           # Preform live prompt substitution
  s transient_rprompt      # Get rid of old rprompts
  s csh_junkie_history     # single instead of dual bang
  s csh_junkie_loops       # use end instead of done
  s continue_on_error      # don't stop! stop = bad

} always {
  unfunction s
} &>> ~/.zsh.d/startup.log

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

# =========
# autoloads
# =========
{
  function a(){ autoload -Uz $@}
  alias a='autoload -Uz'
  
  a zargs              # a more integrated xargs
  a zmv                # concise file renaming/moving 
  a zed                # edit files right in the shell
  a zsh/mathfunc       # common mathematical functions
  a zcalc              # a calculator right in the shell
  a zkbd               # automatic keybinding detection
  a zsh-mime-setup     # automatic MIME type suffixes 
  a colors             # collor utility functions
  a vcs_info           # integrate with version control
  a copy-earlier-word  # navigate backwards with C-. C-,
  a url-quote-magic    # automatically%20escape%20characters
  
} always {
  unfunction a
} &>> ~/.zsh.d/startup.log

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

# ==================
# unified key system
# ==================
typeset -A key
if [[ ! -f ${ZDOTDIR:-$HOME}/.zkbd/$_OLD_TERM-$VENDOR-$OSTYPE ]]; then
  read -q "REPLY?Generate keybindings for $_OLD_TERM? (y/n) " -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    export TERM=$_OLD_TERM
    zkbd
    echo "Keys generated ... exiting"
    source ${ZDOTDIR:-$HOME}$TERM-$VENDOR-$OSTYPE
  else
    key[Home]=${terminfo[khome]}
    key[End]=${terminfo[kend]}
    key[Insert]=${terminfo[kich1]}
    key[Delete]=${terminfo[kdch1]}
    key[Up]=${terminfo[kcuu1]}
    key[Down]=${terminfo[kcud1]}
    key[Left]=${terminfo[kcub1]}
    key[Right]=${terminfo[kcuf1]}
    key[PageUp]=${terminfo[kpp]}
    key[PageDown]=${terminfo[knp]}
  fi
else
  source ${ZDOTDIR:-$HOME}/.zkbd/$_OLD_TERM-$VENDOR-$OSTYPE
fi

[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]}    ]] && bindkey "${key[Insert]}"    overwrite-mode
[[ -n ${key[Home]}      ]] && bindkey "${key[Home]}"      beginning-of-line
[[ -n ${key[PageUp]}    ]] && bindkey "${key[PageUp]}"    up-line-or-history
[[ -n ${key[Delete]}    ]] && bindkey "${key[Delete]}"    delete-char
[[ -n ${key[End]}       ]] && bindkey "${key[End]}"       end-of-line
[[ -n ${key[PageDown]}  ]] && bindkey "${key[PageDown]}"  down-line-or-history
[[ -n ${key[Up]}        ]] && bindkey "${key[Up]}"        up-line-or-search
[[ -n ${key[Down]}      ]] && bindkey "${key[Down]}"      down-line-or-search
[[ -n ${key[Left]}      ]] && bindkey "${key[Left]}"      forward-char
[[ -n ${key[Right]}     ]] && bindkey "${key[Right]}"     backward-char


# =================================
# FASD - all kinds of teleportation
# =================================
fasd_cache="$HOME/.zsh.d/fasd-init-cache"
fasd_path="$HOME/.zsh.d/fasd/fasd"

if [[ ! -w $fasd_cache ]]; then
  echo setting fasd up
  touch $fasd_cache
  $fasd_path --init \
    zsh-hook \
    zsh-wcomp \
    zsh-wcomp-install \
    zsh-ccomp \
    zsh-ccomp-install \
    >! $fasd_cache
fi

source $fasd_cache
source $fasd_path
unset fasd_cache
unset fasd_path

alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd -e cd -d'     # cd, same functionality as j in autojump
alias zz='fasd -e cd -d -i' # cd with interactive selection

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
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue,bold'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow,bold'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow,bold'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[assign]='fg=white,bold'

} &>> ~/.zsh.d/startup.log

# =============================
# AutoFU continuous completions
# =============================
{
  setopt local_options no_rc_expand_param
  source ~/.zsh.d/auto-fu/auto-fu.zsh
  # source ~/.zsh.d/zsh-autosuggestions/autosuggestions.zsh
  zle-line-init () {
    afu-zle-aysce-install() {}
    auto-fu-init
    # zle autosuggest-start
  }
  zle -N zle-line-init
  zstyle ":auto-fu:var" postdisplay ""
  zstyle ":auto-fu:var" autoable-function/skipwords yum touch

  zstyle ':completion:*' show-completer no
  zstyle ':completion:*' extra-verbose no
  zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}'
  zstyle ':completion:*:options' description no
  # _user_expand
  zstyle ':completion:*' completer _oldlist _complete

  afu_menu=1
  toggle_afu() {
    if [[ $afu_menu == 1 ]]; then
      afu_menu=0
    else
      afu_menu=1
    fi
  }

  # highjack afu-comppost function
  afu-comppost () {
    local will_complete
    will_complete=$afu_menu
    if [[ $BUFFER[1] == ' ' ]]; then
      will_complete=0
    fi
    
    if [[ $will_complete == 1 ]]; then
      local lines=$((compstate[list_lines] + BUFFERLINES + 2))
      if ((lines > LINES*0.75)) || ((lines > 30)); then
        compstate[list]=''
        [[ $WIDGET == afu+complete-word ]] || compstate[insert]=''
        zle -M "$compstate[list_lines]($compstate[nmatches]) too many matches..."
      else
        compstate[list]=autolist
      fi
    else
      # If this is unset, the list of matches will never be listed
      # according to zshall(1)
      compstate[list]=
    fi

    typeset -g afu_one_match_p=
    (( $compstate[nmatches] == 1 )) && afu_one_match_p=t
    afu_curcompleter=$_completer
  }
  setopt rc_expand_param
} &>> ~/.zsh.d/startup.log

function global_bindkey () {
  bindkey -M command $@
  bindkey -M emacs   $@
  bindkey -M main    $@
  bindkey -M afu     $@
  bindkey            $@
}

# ========
# VIM MODE
# ========

bindkey -M afu   jj vi-cmd-mode
bindkey -M emacs jj vi-cmd-mode

function _vi-insert () {
  # hack to enable Auto-FU during vi-insert
  zle .vi-insert
  zle zle-line-init
}
zle -N vi-insert _vi-insert

source ~/.zsh.d/zsh-vim-pattern-search/en.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp.zsh
source ~/.zsh.d/zsh-vim-textobjects/opp/surround.zsh

# ========================
# History substring search
# ========================
source ~/.zsh.d/history-substring/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=black,bg=green,underline"
bindkey -M afu '^R' history-incremental-pattern-search-backward
bindkey -M afu '^S' history-incremental-pattern-search-forward

zmodload zsh/terminfo
bindkey -M afu "${key[Up]}" history-substring-search-up
bindkey -M afu "${key[Down]}" history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ================
# path compressors
# ================

# Reduce path to shortest prefixes. Heavily Optimized
function minify_path () {
  local ppath="" full_path="/" cur_path matches revise dir
  eval "1=\${\${1:A}:gs/${HOME:gs/\//\\\//}/\~}"
  for token in ${(s:/:)1}; do
    cur_path=${full_path:s/\~/$HOME/}
    local col=1 glob=${token[0,1]}
    cur_path=($cur_path/*(/))
    # prune the single dir case
    if [[ $#cur_path == 1 ]]; then
      ppath+="/"
      full_path=${full_path%%(/##)}
      full_path+="/$token"
      continue
    fi
    while; do
      matches=0
      revise=()
      for fulldir in $cur_path; do
        dir=${${fulldir%%/}##*/}
        if [[ $options[caseglob] == "off" ]]; then
          if (( ${#dir##(#i)($glob)} < $#dir )); then
            ((matches++))
            revise+=$fulldir
            if ((matches > 1)); then
              break
            fi
          fi
        else
          if (( ${#dir##($glob)} < $#dir )); then
            ((matches++))
            revise+=$fulldir
            if ((matches > 1)); then
              break
            fi
          fi
        fi
      done
      if (( $matches > 1 )); then
        glob=${token[0,$((col++))]}
        (( $col -1 > $#token )) && break
      else
        break
      fi
      cur_path=($revise)
    done
    ppath+="/$glob"
    full_path=${full_path%%(/##)}
    full_path+="/$token"
  done
  echo ${ppath:s/\/\~/\~/}
}

# take every possible branch on the file system into account
function minify_path_full () {
  #setopt localoptions caseglob
  {
    function $0_count_arg {
      return $(($#@-1))
    }
    local glob=$(minify_path $1)
    # IFS=/ read -r -A glob <<< "$glob"
    glob=("${(@s:/:)glob}")
    local index=$(($#glob - 1))
    while ((index >= 1)); do
      if [[ ${glob[$index]} == "~" ]]; then
        break
      fi
      local old_token=${glob[$index]}
      while [[ ${#$(eval "echo ${${(j:*/:)glob}:s/*//}*(/)")} == 1 ]]; do
        old_token=${glob[$index]}
        if [[ ${#glob[$index]} == 0 ]]; then
          break
        fi
        glob[$index]=${glob[$index][0,-2]}
      done
      glob[$index]=$old_token
      ((index--))
    done
    if [[ ${#${(j:/:)glob}} == 0 ]]; then
      echo /
    else
      echo ${(j:/:)glob}
    fi
  } always {
    unfunction -m "$0_*"
  }
}

# Highlight the path's shortest prefixes. Heavily optimized
function highlight_path () {
  local ppath="" full_path="/" cur_path matches revise dir
  eval "1=\${\${1:A}:gs/${HOME:gs/\//\\\//}/\~}"
  for token in ${(@s:/:)1}; do
    cur_path=${full_path:s/\~/$HOME/}
    local col=1 glob=${token[0,1]}
    cur_path=($cur_path/*(/))
    # prune the single dir case
    if [[ $#cur_path == 1 ]]; then
      ppath+="/"
      continue
    fi
    while; do
      matches=0
      revise=()
      for fulldir in $cur_path; do
        dir=${${fulldir%%/}##*/}
        if (( ${#dir##$glob} < $#dir )); then
          ((matches++))
          revise+=$fulldir
          if ((matches > 1)); then
            break
          fi
        fi
      done
      if (( $matches > 1 )); then
        glob=${token[0,$((col++))]}
        (( $col -1 > $#token )) && break
      else
        break
      fi
      cur_path=($revise)
    done
    if [[ "$glob" == "~" ]]; then
      ppath+="~"
    else
      ppath+="/$FX[underline]${token[0,$col]}"
      ppath+="$FX[no-underline]${token[$(($col+1)),-1]}"
    fi
    
    full_path+="/$token"
  done
  echo ${ppath:s/\/\~/\~/}
}

# collapse empty runs too
function minify_path_smart () {
  local cur_path glob i
  cur_path=$(minify_path_full $1)
  for ((i=${#cur_path:gs/[^\/]/}; i>1; i--)); do
    glob=${(l:$((2*$i))::\/:)}
    eval "cur_path=\${cur_path:gs/$glob/\%\{\$FX[underline]\%\}$i\%\{\$FX[no-underline]\%\}}"
  done
  cur_path=${cur_path:s/\~\//\~}
  for char in {a-zA-Z}; do
    eval "cur_path=\${cur_path:gs/\/$char/\%\{\$FX[underline]\%\}$char\%\{\$FX[no-underline]\%\}}"
  done
  echo $cur_path
}

# find shortest unique fasd prefix. Heavily optimized
function minify_path_fasd () {
  if [[ $(type fasd) == *function* ]]; then
    local dirs index above higher base i k test escape
    1=${1%(/##)}
    dirs=$(fasd | cut -f2- -d/ | sed -e 's:.*:/&:' -e '1!G;h;$!d')
    if [[ ${dirs[(i)$1]} -le $#dirs ]]; then
      dirs=($(print ${(f)dirs}))
      index=${${${dirs[$((${dirs[(i)$1]}+1)),-1]}%/}##*/}
      1=${1##*/}
      for ((i=0; i<=$#1+1; i++)); do
        for ((k=1; k<=$#1-$i; k++)); do
          test=${1[$k,$(($k+$i))]}
          if [[ ${index[(i)*$test*]} -ge $#index ]]; then
            echo $test
            escape=t
            break
          fi
        done
        [[ -n $escape ]] && break
      done
    else
      printf " "
      return 1
    fi
  else
    printf " "
  fi
}

# ==========================
# Persistent directory stack
# ==========================
DIRSTACKSIZE=30
if [[ -f ~/.zsh.d/zdirs ]] && [[ ${#dirstack[*]} -eq 0 ]]; then
  dirstack=( ${(uf)"$(< ~/.zsh.d/zdirs)"} )
  # "cd -" won't work after login by just setting $OLDPWD, so
  if setopt | \grep autopushd &>/dev/null; then
    unsetopt AUTO_PUSHD
    cd $dirstack[0] && cd - > /dev/null
    setopt AUTO_PUSHD
  else
    cd $dirstack[0] && cd - > /dev/null
  fi
fi

# see chpwd declaration
function zshexit() {
  if [[ ! -f ~/.zsh.d/zdirs ]]; then
    touch ~/.zsh.d/zdirs
  fi
  dirs -pl >! ~/.zsh.d/zdirs
}

# ========================
# smart tab - really smart
# ========================

function pcomplete() {
  {
    setopt local_options function_argzero
    # hack a local function scope using unfuction
    function $0_forward_word () {
      local space_index
      space_index=$(expr index "$RBUFFER" ' ')
      if ((space_index == 0)); then
        zle .end-of-line
      else
        for ((x=0; x<$space_index-1; x+=1)); do
          zle .forward-char
        done
        while [[ $RBUFFER[1] == " " ]]; do
          zle .forward-char
        done
      fi
    }
    function $0_force_auto () {
      zle magic-space
      zle backward-delete-char
    }

    zstyle ':completion:*' show-completer yes
    zstyle ':completion:*' extra-verbose yes
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' menu select=1 interactive
    zstyle ':completion:*' insert-unambiguous yes
    zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}' \
      'r:|[\.\_\-/\\]=* r:|=*' 'l:|[\.\_\-/\\]=* r:|[\.\_\-/\\]=*' \
      'r:[^[:upper:]0-9]||[[:upper:]0-9]=** r:|=*'

    # _user_expand \
    zstyle ':completion:*' completer \
      _expand \
      _oldlist \
      _complete \
      _prefix \
      _history \
      _approximate \
      _match \
      _prefix

    setopt local_options complete_in_word list_packed list_rows_first

    if [[ $#BUFFER == 0 ]]; then
      zle .accept-line
      BUFFER="popd"
    else
      local single_match="" file_match="" cur_rbuffer space_index

      # detect multiple auto-fu matches
      for i in $region_highlight; do
        i=("${(@s/ /)i}")
        if [[ $i[3] == *black* ]] && (($i[2] - $i[1] > 0 && $i[1] > 1)); then
          $0_forward_word
          break
        fi
      done

      # detect single auto-fu match
      for i in $region_highlight; do
        i=("${(@s/ /)i}")
        if [[ $i[3] == *underline* ]] && (($i[2] - $i[1] > 0)); then
          if  [[ $BUFFER != (*/|* */*) ]]; then
            file_match="t"
          fi
          single_match="t"
          break
        fi
      done

      if [[ $single_match == "t" ]]; then
        $0_forward_word
        if [[ $#RBUFFER == 0 ]]; then
          if [[ $LBUFFER[-1] == "/" ]]; then
            $0_force_auto
          else
            zle magic-space
          fi
        else
          if [[ $LBUFFER[-2] == "/" ]]; then
            zle backward-char
            $0
          fi
        fi
        if [[ $LBUFFER[-2] == " " ]]; then
          zle .backward-delete-char
        fi
      else
        $0_forward_word
        cur_rbuffer=$RBUFFER
        zle expand-or-complete
        RBUFFER=$cur_rbuffer
        if [[ $LBUFFER[-1] == " " && $RBUFFER[1] == " " ]]; then
          zle .backward-delete-char
        fi
      fi
    fi

    zstyle ':completion:*' show-completer no
    zstyle ':completion:*' extra-verbose no
    zstyle ':completion:*' verbose no
    zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}'
    # _user_expand
    zstyle ':completion:*' completer _oldlist _complete
  } always {
    unfunction -m "$0_*"
  }
}

zle -N pcomplete

global_bindkey "^i" pcomplete

# ========================================
# Autogen Options - manfile/GNUdoc scraper
# ========================================

function manopts() {
  findopts() {
    if [ "$1" = -a ]; then
      shift; EXPR="$@"
    fi
    perl -n -e ' while ( /'"$EXPR"'/g ) { print("$1\n"); } '
  }
  'man' "$@" 2> /dev/null | col -bx | findopts -a "[    ]((-|--)[A-Za-z0-9-=]+)"
}

function automan() {
  local cmds comp a
  cmds=$(comm -12 <(whatis -r . | cut -f1 -d " ") <(hash | cut -f1 -d "="))
  comp=$(typeset -f | \grep -P "^_" | cut -f1 -d " " | cut -c2-)
  for i in $(comm -13 <(echo $comp) <(echo $cmds)); do
    _autogen_$i() {
      local args
      if [[ $words[-1] = (*-*) ]]; then
        args=()
        name=${0:9}
        manpage=$(man $name | col -bx)
        for arg in $(manopts $name | sort -u); do
          a=$arg
          if [[ $arg == (*=*) ]]; then
            a=${${(@s/=/)arg}[1]}
          fi
          arg=$(echo $manpage | grep -P -- "[^a-zA-Z]${a}[^a-zA-Z]" | tr -s " \n\t" " ")
          [[ -n $a ]] && args[$((${#args}+1))]="()${a}[(m)${(q)arg}]"
        done
        _arguments -s $args
      fi
      _files
    }
    compdef _autogen_$i $i
  done
}

function mangen() {
  echo -e "$1" >> ~/.zsh.d/mangen
  sort ~/.zsh.d/mangen -o ~/.zsh.d/mangen
}

# scrapes helpfiles looking for arguments
function autohelp() {
  for cmd in $(cat ~/.zsh.d/helpgen); do
    compdef _gnu_generic $cmd
  done
}

# helper function, mark a command as autohelpable
function helpgen() {
  echo -e "$1" >> ~/.zsh.d/helpgen
  sort ~/.zsh.d/helpgen -o ~/.zsh.d/helpgen
  compdef _gnu_generic $1
}

{autohelp;automan}>&/dev/null

#=================
# completion stuff
#=================

function _uexpand() {
  zstyle ':completion:*' show-completer no
  zstyle ':completion:*' extra-verbose no
  zstyle ':completion:*' verbose no
  zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}'
  # _user_expand
  zstyle ':completion:*' completer _oldlist _complete
  zstyle ':completion:*' menu 'select=0'
  if [[ $@ = "this_is_a" ]]; then
    reply=("this is a" "this was a" $BUFFER)
    reply=("${BUFFER}a" $BUFFER)
    _complete
  fi
  # reply=("${(f)$(fc -l 1000 | cut -f4- -d" " | grep "^$BUFFER" 2>/dev/null)}")
  reply=()
  REPLY="user"
  _complete
}

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' extra-verbose no
zstyle ':completion:*' show-completer no
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh.d/cache

# formatting
zstyle ':completion:*' format '%B-- %d%b'             # distinct categories
zstyle ':completion:*' auto-description 'specify: %d' # auto description
zstyle ':completion:*:descriptions' format '%B%d%b'   # description
zstyle ':completion:*:messages' format '%d'           # messages

# warnings
#zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:warnings' format "$fg_bold[red]-- no matches found -- $reset_color"

#corrections
zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'
export SPROMPT="Correct $fg_bold[red]%R$reset_color to $fg_bold[green]%r?$reset_color (Yes, No, Abort, Edit) "
zstyle ':completion:*' group-name ''

# adaptive correction
# _user_expand
zstyle ':completion:*' completer _oldlist _complete

zstyle ':completion:*:match:*' original only
zstyle ':completion::approximate*:*' prefix-needed false
zstyle ':completion:*:approximate:*' max-errors \
  'reply=($((($#PREFIX+$#SUFFIX)/3)))'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order expansions all-expansions

zstyle ':completion:*' user-expand _uexpand
zstyle ':completion:*:user-expand:*' tag-order expansions all-expansions

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd

# ignore completions for functions I don't use
zstyle ':completion:*:functions' ignored-patterns '(_|.)*'

# ignore completions that are aleady on the line
zstyle ':completion:*:(rm|kill|diff|mv|cp):*' ignore-line yes

# seperate manpage sections
zstyle ':completion:*:manuals' separate-sections true

# sort reverse by modification time so the newer the better
zstyle ':completion:*' file-sort modification reverse
#zstyle ':completion:*' file-sort change

# try to automagically generate descriptions from manpage
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' auto-description 'specify: %d'

## case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}' \
  'r:|[\.\_\-/\\]=* r:|=*' 'l:|[\.\_\-/\\]=* r:|[\.\_\-/\\]=*' \
  'r:[^[:upper:]0-9]||[[:upper:]0-9]=** r:|=*'

# Don't prompt for a huge list, page it!
# Don't prompt for a huge list, menu it!
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:default' menu 'select=0' interactive

# color suggestion output according to ls
zstyle ':completion:*:default' list-colors ${(@s.:.)LS_COLORS}

# order files first by default, dirs if command operates on dirs (ls)

zstyle ':completion:*' file-patterns \
  "^($BORING_FILES|.*)(-/):directories:normal\ directories %p~($BORING_FILES|.*)(^-/):globbed-files:normal\ files" \
  "^($BORING_FILES|.*)(^-/):noglob-files:noglob\ files" \
  ".*~($BORING_FILES)(^-/):hidden-files:hidden\ files .*~($BORING_FILES)(-/):hidden-directories:hidden\ directories" \
  "($BORING_FILES)(^-/):boring-files:boring\ files ($BORING_FILES)(-/):boring-directories:boring\ directories" \
  
zstyle ':completion:*' group-order \
  builtins expansions aliases functions commands globbed-files \
  directories hidden-files hidden-directories \
  boring-files boring-directories keywords viewable

# zstyle ':completion:*:(globbed-files|directories)' ignored-patterns "$BORING_FILES|.*"
# zstyle ':completion:*:hidden-(files|directories)' ignored-patterns $BORING_FILES

# zstyle ':completion:*:(globbed-|)files' ignored-patterns $BORING_FILES
# zstyle ':completion:*:all-files' ignored-patterns "*\~"
# zstyle ':completion:*:directories' ignored-patterns $BORING_FILES

zstyle ':completion:*:-command-:*' group-order \
  builtins expansions aliases functions commands directories \
  globbed-files hidden-directories hidden-files \
  boring-directories boring-files keywords viewable

# complete more processes, typing names substitutes PID
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*:processes' command "ps ax -o pid,user,comm"
zstyle ':completion:*:processes-names' command 'ps -e -o comm='
zstyle ':completion:*:processes-names' ignored-patterns ".*"

zstyle ':completion:history-words:*' remove-all-dups yes

# =============
# Adaptive Exit
# =============
_exitForce=0

# exit with background jobs lists them
# use logout for normal exit or EXIT
function disown_running() {
  # disown running jobs
  tmpfile==(:)
  jobs -r > $tmpfile
  running=$(awk '{gsub("[][]","",$1);print "%"$1}' < $tmpfile)
  if [ -n "$running" ] ; then disown $running; fi
  
  # check for remaining jobs
  jobs >! $tmpfile
  [ -z "`<$tmpfile`" ] ; retval=$?
  
  /bin/rm $tmpfile
  
  # returns 1 if jobs still remaining, else 0
  return $retval
}

function exit() {
  disown_running && builtin exit "$@"
  if [[ $_exitForce == $(fc -l) ]]; then
    builtin exit
  else
    echo "You have stopped jobs:"
    jobs
    _exitForce=$(fc -l)
  fi
}

alias EXIT="builtin exit"

# ======================
# Version Control System
# ======================
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:svn*+set-message:*' hooks svn-untracked-and-modified
function +vi-svn-untracked-and-modified() {
  local svn_status
  svn_status=$(svn status | cut -f1 -d ' ')
  if [[ $svn_status == *M* ]]; then
    hook_com[staged]+=" %{$fg[green]%}+%{$reset_color%}"
  fi
  if [[ $svn_status == *\?* ]]; then
    hook_com[unstaged]+='?'
  fi
}

source ~/.zsh.d/zsh-vcs-prompt/zshrc.sh
ZSH_VCS_PROMPT_ENABLE_CACHING='false'
ZSH_VCS_PROMPT_USING_PYTHON='false'

ZSH_VCS_PROMPT_AHEAD_SIGIL='↑'
ZSH_VCS_PROMPT_BEHIND_SIGIL='↓'
ZSH_VCS_PROMPT_STAGED_SIGIL='●'
ZSH_VCS_PROMPT_CONFLICTS_SIGIL='✖'
ZSH_VCS_PROMPT_UNSTAGED_SIGIL='✚'
ZSH_VCS_PROMPT_UNTRACKED_SIGIL='…'
ZSH_VCS_PROMPT_STASHED_SIGIL='⚑'
ZSH_VCS_PROMPT_CLEAN_SIGIL='✔'

function async_vcs_info () {
  # Save the prompt in a temp file so the parent shell can read it.
  printf "%s" "$(vcs_super_info)" >! ${TMPPREFIX}/vcs-prompt.$$

  local vcs_raw_data

  vcs_raw_data="$(vcs_super_info_raw_data)"

  if [[ -n $vcs_raw_data ]]; then
    echo $vcs_raw_data >! ${TMPPREFIX}/vcs-data.$$
    case "${${(f)vcs_raw_data}[2]}" in
      (git)
        git rev-parse --show-toplevel >> ${TMPPREFIX}/vcs-data.$$;;

      (hg)
        hg root >> ${TMPPREFIX}/vcs-data.$$;;

      (svn)
        local cur_path="."
        if [[ -d .svn ]]; then
          while [[ -d $cur_path/.svn ]]; do
            cur_path="$cur_path/.."
          done
          echo ${${cur_path%%/..}:A} >> ${TMPPREFIX}/vcs-data.$$
        else
          while [[ ! -d $cur_path/.svn && $cur_path:A != / ]]; do
            cur_path=$cur_path/..
          done
          echo ${cur_path:A} >> ${TMPPREFIX}/vcs-data.$$
        fi;;

      (*)
        echo >> ${TMPPREFIX}/vcs-data.$$;;

      esac
  else
    command rm -f ${TMPPREFIX}/vcs-data.$$
  fi
  
  # Signal the parent shell to update the prompt.
  kill -USR1 $$
}

function compute_context_aliases () {
  if [[ -f ${TMPPREFIX}/vcs-data.$$ ]]; then
    local vcs_data
    vcs_data=$(cat ${TMPPREFIX}/vcs-data.$$);
    alias -g .B=${${(f)vcs_data}[4]};
    
    case "${${(f)vcs_raw_data}[2]}" in
      (git)
        # git has more data
        if [[ -n ${${(f)vcs_data}[14]} ]]; then
          alias -g .R="${${(f)vcs_data}[14]}"
        fi;;
      (*)
        if [[ -n ${${(f)vcs_data}[5]} ]]; then
          alias -g .R="${${(f)vcs_data}[5]}"
        fi;;
    esac
    
  else
    if [[ $(type ".B") == *alias* ]]; then
      unalias .B
    fi
    if [[ $(type ".R") == *alias* ]]; then
      unalias .R
    fi
  fi
}

function TRAPUSR1 {
  vcs_info_msg_0_=$(cat "${TMPPREFIX}/vcs-prompt.$$" 2> /dev/null)
  command rm ${TMPPREFIX}/vcs-prompt.$$ 2> /dev/null

  compute_context_aliases
    
  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}

# ======
# Prompt
# ======

nbsp=$'\u00A0' # a prompt that commits suicide when pasted
bindkey $nbsp backward-kill-line

function compute_prompt () {
  local black=$fg[black]
  PS1=$'%{${fg[red]}%}%(?..Error: (%?%)\n)' # errors
  PS1+="%{${fg[default]}%}[%{%(#~$fg[red]~$black)$FX[bold]%}"  # root or not
  PS1+='%n%{${fg[default]}${bg[default]}$FX[reset]%} $chpwd_s_str'  # Username
  PS1+="$(((SHLVL>1))&&echo " <"${SHLVL}">")]%#$nbsp" # shell depth

  VIM_PROMPT="%{$fg_bold[black]%} [% N]% %{$reset_color%}"
  RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins|afu)/}"
  RPS1=$RPS1"\${vcs_info_msg_0_}"
  #❯
}

compute_prompt

function precmd() {
  cur_command="zsh"
  chpwd
  
  async_vcs_info &!
  compute_prompt
}

# intercept keymap selection
function zle-keymap-select () {
  compute_prompt
  zle reset-prompt
}
zle -N zle-keymap-select

# ======================
# BEGIN HOLISTIC HANDLER
# ======================

alias go="nocorrect go"
function go() {
  setopt local_options no_case_glob no_case_match equals
  cmd=(${(s/ /)1})
  # if it's a file and it's not binary and I don't need to be root
  if [[ -f "$1" ]]; then
    if file $1 |& grep '\(ASCII text\|Unicode text\|no magic\)' &>/dev/null; then
      if [[ -r "$1" ]]; then
        if ps ax |& egrep -i 'emacs --daemon' &>/dev/null; then
          # launch GUI editor
          #($GEDITOR&) >&/dev/null
          emacsclient -t -a "emacs" $1
        else
          # launch my editor
          $EDITOR "$1"
        fi
      else
        echo "zsh: insufficient permissions"
      fi
    else
      # it's binary, open it with xdg-open
      if [[ -n =xdg-open && -n "$DISPLAY" && ! -x $1 ]]; then
        (xdg-open "$1" &) &> /dev/null
      else
        # without x we try suffix aliases
        ($1&)>&/dev/null
      fi
    fi

  elif [[ -d "$1" ]]; then \cd "$1" # directory, cd to it
  elif [[ "" = "$1" ]]; then \cd    # nothing, go home
    
    # if it's a program, launch it in a seperate process in the background
  elif [[ $(type ${cmd[1]}) != *not* ]]; then
    ($@&)>/dev/null

    # check if dir is registered in database
    # elif [[ $(autojump --stat | cut -f2 | sed -e "$d" | fgrep -i $1) != "" ]]; then
  elif [[ -n $(fasd -d $@) ]]; then
    local fasd_target=$(fasd -d $@)
    local teleport
    teleport=$(highlight_path $fasd_target)
    teleport=" ${fg[blue]}${FX[bold]}$teleport${fg[default]}${FX[reset]}"
    if [[ $fasd_target != (*$@*) ]]; then
      read -k REPLY\?"zsh: teleport to$teleport? [ny] "
      if [[ $REPLY =~ ^[Yy] ]]; then
        echo " ..."
        cd $fasd_target
      fi
    else
      echo -n "zsh: teleporting: $@"
      echo $teleport
      cd $fasd_target
    fi
  else
    command_not_found=1
    command_not_found_handler $@
    return 1
  fi
}

# ==============
# Expand aliases
# ==============
# typeset -A abbrevs
expand=("math" "cd" "grep" "fgrep" "mc" "emc" "lst" ",," "lsa" "exit" "px")

for supressed in $(alias |& egrep -i (nocorrect|noglob) | cut -f1 -d "="); do
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

# ============
# Auto handler
# ============
_preAlias=()

function _accept-line() {
  local cmd

  # if buffer is effectively empty, clear instead
  # otherwise pass through
  if [[ $BUFFER =~ "^ $" ]]; then
    BUFFER="clear"
    zle .accept-line
    return 0

  elif [[ $BUFFER =~ "^\s+$" || $BUFFER[1] == " " ]]; then
    zle .accept-line
    return 0
  fi

  # remove black completion "suggestions"
  for i in $region_highlight; do
    i=("${(s/ /)i}")
    if [[ $i[3] == *black* ]] && (($i[2] - $i[1] > 0 && $i[1] > 2)); then
      BUFFER=$BUFFER[1,$i[1]]$BUFFER[$i[2],$(($#BUFFER - 1))]
    fi
  done

  # expand all aliases on return
  cmd=(${(s/ /)BUFFER})
  if (( ${(e)expand[(i)${cmd[-1]}]} > ${#expand} )) && [[ ${cmd[-1]} != (\\*) ]]; then
    if [[ $#RBUFFER == "1" ]]; then
      zle _expand_alias
    fi
  fi

  # ignore prefix commands
  if [[ $cmd[1] == "nocorrect" ]]; then
    cmd=($cmd[2,${#cmd}])
  fi

  # split it by command seperation delimiters
  if [[ $BUFFER != (*\$\{*\}*) ]]; then
    cmd=(${(ps:;:e)${(ps:|:e)${(ps:|&:e)${(ps:&&:e)${(ps:||:)BUFFER}}}}})
    for c in $cmd; do
      # process the command, strip whitespace
      process "$(echo $c | awk '{$1=$1}1')"
    done
  fi

  zle .accept-line

  # hack the syntax highlighter to highlight old lines
  zle magic-space
  _zsh_highlight
  zle backward-delete-char
  _zsh_highlight
}

zle -N _accept-line
zle -N accept-line _accept-line
command_not_found=1

function process() {
  if [[ $(type $1) == (*not*|*suffix*) ]]; then
    # skip assignments until I find something smarter to do.
    if [[ $1 == (*=*) ]]; then
      return 0
    fi
    
    # handle "/" teleport case
    if [[ $1 == "/" ]]; then
      alias "$1"="cd /"
      _preAlias+=($1)
      
      # if it's in CDPATH, teleport there
    elif [[ ${${${$(echo $cdpath*(/))%/}##*/}[(r)${1%/}]} == ${1%/} ]]; then
      alias "$1"="cd ${1%/} >/dev/null; echo zsh: teleport: \$fg[blue]\$FX[bold]\${${:-.}:A}\$reset_color"
      _preAlias+=($1)
      
      # if it contains math special characters, try to evaluate it
    elif [[ ! -f "$1" && ! -d "$1" && $1 == *[\(\)\[\]/*-+%^]* ]]; then
      local s
      # check if it compiles
      s=$(python3 -c "print(compile('$1','','eval').co_names)" 2> /dev/null)
      if [[ $? == 0 ]]; then
        # it compiled, eval it
        alias "$1"="python -c 'print($1)'"
        _preAlias+=($1)

      elif [[ $1 == *[\(\)*+~^\&\[\]]* ]]; then
        # it didn't. it must be some kind of glob
        if [[ $options[globdots] == "on" ]]; then
          alias "$1"="unsetopt globdots;LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -dhx --group-directories-first;setopt globdots"
        else
          alias "$1"="LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -dhx --group-directories-first"
        fi
        if [[ $1 == "**" ]]; then
          # ** renders single level recursive summary
          alias "$1"="LC_COLLATE='C.UTF-8' zargs $1 -- ls --color=always -h"
        fi
        _preAlias+=($1)
      fi
      
      # it's a file forward to go
    elif [[ -f "$1" && $(type $1) == (*not*)  && ! -x $1 ]]; then
      alias $1="go $1" && command_not_found=0
      _preAlias+=("$1")

      # If it's an option and it's set, unset it
    elif [[ -n $(setopt | grep -xF "$(echo "$1" | sed -e 's/\(.*\)/\L\1/' -e 's/_//g')" 2>/dev/null) ]]; then
      alias "$1"="echo \"unsetopt: $1\"; unsetopt $1"
      _preAlias+=($1)

      # If it's an option and it's unset, set it
    elif [[ -n $(unsetopt | grep -xF "$(echo "$1" | sed -e 's/\(.*\)/\L\1/' -e 's/_//g')" 2>/dev/null) ]]; then
      alias "$1"="echo \"setopt: $1\"; setopt $1"
      _preAlias+=($1)

      # if it's a parameter, echo it
    elif [[ -n ${(P)1} ]]; then
      alias "$1"="echo ${(P)1}"
      _preAlias+=($1)

      # last resort, forward to teleport handler
      # elif [[ -n $(j --stat | cut -f2 | sed -e '$d' | fgrep -i $1) ]]; then
    elif [[ -n $(fasd -d $@) ]]; then
      alias $@="go $@"
      _preAlias+=($@)

    else
    fi
  fi
}

function preexec() {
  chpwd

  unalias ${(j: :)_preAlias} &> /dev/null
  _preAlias=( )
}

function precmd() {
  chpwd
  async_vcs_info &!
  compute_prompt
}

function command_not_found_handler() {
  # only error out if the tokenizer failed
  if [[ $command_not_found == 1 ]]; then
    echo "zsh: command not found:" $1
  fi
  command_not_found=1
}

# ================================
# command layer completion scripts
# ================================

function _keywords(){
  local keywds expl
  keywds=(for do done while if elif fi case esac function break continue)
  _wanted keywords expl 'shell keyword' compadd "$@" -k keywds
}

function _cdpath(){
  tmpcdpath=(${${(@)cdpath:#.}:#$PWD}) 
  (( $#tmpcdpath )) && alt=('path-directories:directory in cdpath:_path_files -W tmpcdpath -/')
  _alternative "$alt[@]"
}

function _cmd() {
  _aliases
  _jobs
  _builtin
  _command
  _functions
  _parameters
  _hosts
  #_cd
  _tilde
  _directory_stack
  _files # -F "*(/)"
  _cdpath
  _options
  _keywords
}

compdef "_cmd" "-command-"

# ========================================
# Title + Path compression + chpwd handler
# ========================================
_titleManual=0

TMPPREFIX=/dev/shm/ # use shared memory
LAST_PWD=${${:-.}:A}
LAST_TITLE=""
function async_chpwd_worker () {
  chpwd_s_str=$(minify_path_smart .)

  printf "%s" $chpwd_s_str >! ${TMPPREFIX}/zsh-s-prompt.$$

  # Signal the parent shell to update the prompt.
  kill -USR2 $$
}

function async_chpwd_worker_subshell () {
  chpwd_s_str=$(minify_path_smart $(pwd))
  typeset -f minify_path_smart
  local GPID
  #chpwd_j_str=$(minify_path_fasd $(pwd))
  GPID=$(ps -fp $PPID | awk "/$PPID/"' { print $3 } ')
  GPID=$(ps -fp $GPID | awk "/$GPID/"' { print $3 } ')
  
  printf "%s" $chpwd_s_str >! /dev/shm/zsh-s-prompt.$GPID

  # Signal the parent shell to update the prompt.
  kill -USR2 $GPID
}

function TRAPUSR2 {
  chpwd_s_str=$(cat "${TMPPREFIX}zsh-s-prompt.$$" 2> /dev/null)
  command rm ${TMPPREFIX}zsh-s-prompt.$$ &> /dev/null

  # Force zsh to redisplay the prompt.
  zle && zle reset-prompt
}

# Build the prompt in a background job.
async_chpwd_worker &!
function chpwd() {
  cdpath=("${(s/ /)$(eval echo $(echo "\${(@)raw_cdpath:#${${:-.}:A}/}"))}")
  if [[ ${${:-.}:A} != $LAST_PWD ]]; then
    chpwd_force
  elif [[ $LAST_TITLE == "" ]]; then
    chpwd_force
  else
    _setTitle $LAST_TITLE
  fi
}

function chpwd_force() {
  setopt LOCAL_OPTIONS EQUALS
  if [[ -n $(ps $PPID 2> /dev/null | grep =mc) ]]; then
    chpwd_s_str=${${:-.}:A:t} # or $(basename $(pwd))
    zle && zle reset-prompt
  else
    chpwd_str=$(minify_path .)
    if [[ $_titleManual == 0 ]]; then 
      LAST_TITLE="$(minify_path .) [$(minify_path_fasd .)]"
      _setTitle $LAST_TITLE
    fi
    (async_chpwd_worker &!) 2> /dev/null
  fi
  LAST_PWD=${${:-.}:A}
}

# set the title
function _setTitle() {
  local titlestart titlefinish

  # determine the terminals escapes
  case "$_OLD_TERM" in
    aixterm|dtterm|putty|rxvt|xterm*)
      titlestart='\033]0;'
      titlefinish='\007';;
    cygwin)
      titlestart='\033];'
      titlefinish='\007';;
    konsole)
      titlestart='\033]30;'
      titlefinish='\007';;
    screen*|screen)
      titlestart='\033k'
      titlefinish='\033\';;
    *)
      if type tput >/dev/null 2>&1; then
        if tput longname >/dev/null 2>&1; then
          titlestart="$(tput tsl)"
          titlefinish="$(tput fsl)"
        fi
      else
        titlestart=''
        titlefinish=''
      fi
  esac

  test -z "${titlestart}" && return 0
  [[ -n $EMACS || $TERM == "dumb" ]] && return 0
  if [[ $EUID == 0 ]]; then
    printf "${titlestart}$* ! ${cur_command}${titlefinish}"
  else
    printf "${titlestart}$* ${cur_command}${titlefinish}"
  fi
}

# if title set manually, dont set automatically
function settitle() {
  _titleManual=1
  _setTitle $1
  if [[ ! -n $1 ]]; then
    _titleManual=0
    chpwd_force
  fi
}

{
  # let's initialize the title
  alias settitle="nocorrect settitle"
  _setTitle $(minify_path .)
} &>> ~/.zsh.d/startup.log

# ============
# Shell macros
# ============

source ~/.zsh.d/zsh-macro/macro.zsh
export MACRO_DIR="~/.zsh.d/macros"
if [[ ! -d $MACRO_DIR ]]; then
  mkdir $MACRO_DIR
fi

# ====================
# Interactive commands
# ====================

# increments the last number on the line
function _increase_number() {
  local -a match mbegin mend
  while [[ ! $LBUFFER =~ '([0-9]+)[^0-9]*$' ]]; do
    zle up-line-or-search
  done
  
  LBUFFER[mbegin,mend]=$(printf %0${#match[1]}d $((10#$match+${NUMERIC:-1})))
}
zle -N increase-number _increase_number
global_bindkey '^X^a' increase-number
bindkey -s '^Xx' '^[-^Xa'

# C-r adds to line instead of replacing it
autoload -Uz narrow-to-region
function _history-incremental-preserving-pattern-search-backward
{
  local state
  MARK=CURSOR  # magick, else multiple ^R don't work
  narrow-to-region -p "$LBUFFER${BUFFER:+>>}" -P "${BUFFER:+<<}$RBUFFER" -S state
  zle end-of-history
  zle history-incremental-pattern-search-backward
  narrow-to-region -R state
}
zle -N _history-incremental-preserving-pattern-search-backward
global_bindkey "^R" _history-incremental-preserving-pattern-search-backward
global_bindkey "^S" history-incremental-pattern-search-forward

bindkey -M isearch "^R" history-incremental-pattern-search-backward

# M-, moves to the previous word on the current line, like M-.
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
global_bindkey "^[," copy-earlier-word

# Move to the place where flags are to be added
function after-first-word() {
  zle beginning-of-line
  zle forward-word
}
zle -N after-first-word
global_bindkey "^X1" after-first-word

# rationalize dots
rationalise_dot () {
  # typing .... becomes ../../../ etc.
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}

zle -N rationalise_dot
bindkey . rationalise_dot
# without this, typing a "." aborts incremental history search
bindkey -M isearch . self-insert

# =====================
# Convenience functions
# =====================

# recursive Regex ls
function lv() {
  local p=$argv[-1]
  [[ -d $p ]] && { argv[-1]=(); } || p='.'
  find $p ! -type d | sed 's:^./::' | egrep "${@:-.}"
}

# super powerful ls
function lr() {
  zparseopts -D -E S=S t=t r=r h=h U=U l=l F=F d=d
  local sort="sort -t/ -k2"                                # by name (default)
  local numfmt="cat"
  local long='s:[^/]* /::; s:^\./\(.\):\1:;'               # strip detail
  local classify=''
  [[ -n $F ]] && classify='/^d/s:$:/:; /^-[^ ]*x/s:$:*:;'  # dir/ binary*
  [[ -n $l ]] && long='s: /\./\(.\): \1:; s: /\(.\): \1:;' # show detail
  [[ -n $S ]] && sort="sort -n -k5"                        # by size
  [[ -n $r ]] && sort+=" -r"                               # reverse
  [[ -n $t ]] && sort="sort -k6" && { [[ -n $r ]] || sort+=" -r" } # by date
  [[ -n $U ]] && sort=cat                                  # no sort, live output
  [[ -n $h ]] && numfmt="numfmt --field=5 --to=iec --padding=6"  # human fmt
  [[ -n $d ]] && set -- "$@" -prune                        # don't enter dirs
  find "$@" -printf "%M %2n %u %g %9s %TY-%Tm-%Td %TH:%TM /%p -> %l\n" |
  $=sort | $=numfmt |
  sed '/^[^l]/s/ -> $//; '$classify' '$long
}

# search by file contents
function g() {
  local p=$argv[-1]
  [[ -d $p ]] && { p=$p/; argv[-1]=(); } || p=''
  grep --exclude "*~" --exclude "*.o" --exclude "tags" \
    --exclude-dir .bzr --exclude-dir .git --exclude-dir .hg --exclude-dir .svn \
    --exclude-dir CVS  --exclude-dir RCS --exclude-dir _darcs \
    --exclude-dir _build \
    -r -P ${@:?regexp missing} $p
}

# search for process without matching self
alias px="nocorrect noglob px"
function px() {
  ps uwwp ${$(pgrep -d, "${(j:|:)@}"):?no matches}
}

# extract any archive 
compdef '_files -g "*.((tar|)(.gz|.bz2|.xz|.zma)|(t(gz|bz|bz2|lz|xz))|(lzma|Z|zip|rar|7z|deb)|tar)"'  extract
function extract() {
  local remove_archive
  local success
  local file_name
  local extract_dir

  if (( $# == 0 )); then
    echo "Usage: extract [-option] [file ...]"
    echo
    echo Options:
    echo "    -r, --remove    Remove archive."
    echo
    echo "Report bugs to <sorin.ionescu@gmail.com>."
  fi

  remove_archive=1
  if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
    remove_archive=0
    shift
  fi

  while (( $# > 0 )); do
    if [[ ! -f "$1" ]]; then
      echo "extract: '$1' is not a valid file" 1>&2
      shift
      continue
    fi

    success=0
    file_name="$( basename "$1" )"
    extract_dir="$( echo "$file_name" | sed "s/\.${1##*.}//g" )"
    case "$1" in
      (*.tar.gz|*.tgz) tar xvzf "$1" ;;
      (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
      (*.tar.xz|*.txz) tar --xz --help &> /dev/null \
        && tar --xz -xvf "$1" \
        || xzcat "$1" | tar xvf - ;;
      (*.tar.zma|*.tlz) tar --lzma --help &> /dev/null \
        && tar --lzma -xvf "$1" \
        || lzcat "$1" | tar xvf - ;;
      (*.tar) tar xvf "$1" ;;
      (*.gz) gunzip "$1" ;;
      (*.bz2) bunzip2 "$1" ;;
      (*.xz) unxz "$1" ;;
      (*.lzma) unlzma "$1" ;;
      (*.Z) uncompress "$1" ;;
      (*.zip) unzip "$1" -d $extract_dir ;;
      (*.rar) unrar e -ad "$1" ;;
      (*.7z) 7za x "$1" ;;
      (*.deb)
        mkdir -p "$extract_dir/control"
        mkdir -p "$extract_dir/data"
        cd "$extract_dir"; ar vx "../${1}" > /dev/null
        cd control; tar xzvf ../control.tar.gz
        cd ../data; tar xzvf ../data.tar.gz
        cd ..; rm *.tar.gz debian-binary
        cd ..
        ;;
      (*)
        echo "extract: '$1' cannot be extracted" 1>&2
        success=1
        ;;
    esac

    (( success = $success > 0 ? $success : $? ))
    (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
    shift
  done
}
