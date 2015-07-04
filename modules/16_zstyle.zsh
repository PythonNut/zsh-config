#=================
# completion stuff
#=================

zstyle ':completion:*' verbose false
zstyle ':completion:*:options' verbose true
zstyle ':completion:*' extra-verbose false
zstyle ':completion:*' show-completer false
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path $ZDOTDIR/cache
zstyle ':completion:*' list-grouped true

# formatting
if (( $degraded_terminal[unicode] != 1 )); then
  zstyle ':completion:*' format '%B── %d%b' # distinct categories
  zstyle ':completion:*' list-separator '─' # distinct descriptions
else
  zstyle ':completion:*' format '%B-- %d%b' # distinct categories
  zstyle ':completion:*' list-separator '-' # distinct descriptions
fi

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
zstyle ':completion:*' completer _oldlist _complete

zstyle ':completion:*:match:*' original only

# 0 -- vanilla completion    (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion  (abc => A-big-Car)
# 3 -- full flex completion  (abc => ABraCadabra)
zstyle ':completion:*' matcher '' 'm:{a-z\-}={A-Z\_}' \
       'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
       'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

zstyle ':completion:*:functions' matcher '' 'm:{a-z\-}={A-Z\_}'
zstyle ':completion:*:parameters' matcher '' 'm:{a-z\-}={A-Z\_}'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order expansions all-expansions

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd

# ignore completions for functions I don't use
zstyle ':completion:*:functions' ignored-patterns '(_|.)*'

# ignore completions that are aleady on the line
zstyle ':completion:*:(rm|kill|diff|mv|cp):*' ignore-line true

# separate manpage sections
zstyle ':completion:*:manuals' separate-sections true

# sort reverse by modification time so the newer the better
zstyle ':completion:*' file-sort modification reverse

# try to automagically generate descriptions from manpage
zstyle ':completion:*:options' description yes
zstyle ':completion:*' auto-description 'specify: %d'

# Don't prompt for a huge list, page it!
# Don't prompt for a huge list, menu it!
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' menu select=1 interactive

# order files first by default, dirs if command operates on dirs (ls)

zstyle ':completion:*' file-patterns \
  "(%p~($BORING_FILES))(-/^D):directories:normal\ directories (%p~($BORING_FILES))(^-/D):files:normal\ files" \
  "(^($BORING_FILES))(-/^D):noglob-directories:noglob\ directories (^($BORING_FILES))(^-/D):noglob-files:noglob\ files" \
  "(.*~($BORING_FILES))(D^-/):hidden-files:hidden\ files (.*~($BORING_FILES))(D-/):hidden-directories:hidden\ directories" \
  "($BORING_FILES)(D^-/):boring-files:boring\ files ($BORING_FILES)(D-/):boring-directories:boring\ directories" \

zstyle ':completion:*' group-order \
  builtins expansions aliases functions commands files \
  directories noglob-files noglob-directories hidden-files hidden-directories \
  boring-files boring-directories keywords viewable

zstyle ':completion:*:-command-:*' group-order \
  builtins expansions aliases functions commands executables directories \
  files noglob-directories noglob-files hidden-directories hidden-files \
  boring-directories boring-files keywords viewable

zstyle ':completion:*:(\ls|ls):*' group-order \
  directories noglob-directories hidden-directories boring-directories\
  files noglob-files hidden-files boring-files

# complete more processes, typing names substitutes PID
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*:processes' command "ps ax -o pid,user,comm"
zstyle ':completion:*:processes-names' command 'ps -e -o comm='
zstyle ':completion:*:processes-names' ignored-patterns ".*"

zstyle ':completion:*:history-words:*' remove-all-dups true
zstyle ':completion:*:urls' urls $ZDOTDIR/urls/urls

# ================================
# command layer completion scripts
# ================================

function _cdpath(){
  local tmpcdpath
  # tmpcdpath=(${${(@)cdpath:#.}:#$PWD})
  tmpcdpath=(/etc/)
  if [[ $PREFIX != (\~|/|./|../)* && $IPREFIX != ../* ]]; then
    if (( $#tmpcdpath )); then
      alt=("path-directories:directory in cdpath:_path_files -W $tmpcdpath -/")
      _alternative "$alt[@]"
    fi
  fi
}

function _cmd() {
  _command_names
  _functions
  _tilde
  _path_files -g "*(^-/)"
  _cdpath
}

compdef "_cmd" "-command-"

ls_colors_parsed=${${(@s.:.)LS_COLORS}/(#m)\**=[0-9;]#/${${MATCH/(#m)[0-9;]##/$MATCH=$MATCH=04;$MATCH}/\*/'(*files|*directories)=(#b)($PREFIX:t)(?)*'}}

function _list_colors () {
  local MATCH
  reply=("${(e@s/ /)ls_colors_parsed}")
 
  # fallback to a catch-all
  reply+=("=(#b)($PREFIX:t)(?)*===04")
}

zstyle -e ':completion:*:default' list-colors _list_colors
