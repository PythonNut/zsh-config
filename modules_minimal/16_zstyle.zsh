#=================
# completion stuff
#=================

zstyle ':completion:*' verbose false
zstyle ':completion:*:options' verbose true
zstyle ':completion:*' extra-verbose true
zstyle ':completion:*' show-completer true
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
zstyle ':completion:*' completer \
       _expand \
       _oldlist \
       _complete \
       _match \
       _files \
       _history \
       _prefix

zstyle ':completion:*:match:*' original only
zstyle ':completion::correct*:*' prefix-needed false
zstyle ':completion::correct:*' max-errors 2 numeric

zstyle ':completion::approximate*:*' prefix-needed false
zstyle ':completion::approximate:*' max-errors 2 numeric
zstyle ':completion::approximate:*' origional true

# 0 -- vanilla completion    (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion  (abc => A-big-Car)
# 3 -- full flex completion  (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
       'm:{a-z\-}={A-Z\_}' \
       'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
       'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

zstyle ':completion:*:parameters' matcher-list '' 'm:{a-z\-}={A-Z\_}'
zstyle ':completion:*:functions' matcher-list '' 'm:{a-z\-}={A-Z\_}'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order expansions all-expansions

zstyle ':completion:*' user-expand _uexpand
zstyle ':completion:*:user-expand:*' tag-order expansions all-expansions

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete directory we are already in (../here)
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' insert-unambiguous true

# ignore completions for functions I don't use
zstyle ':completion:*:functions' ignored-patterns '(_|.)*'

# ignore completions that are aleady on the line
zstyle ':completion:*:(rm|kill|diff|mv|cp):*' ignore-line true

# separate manpage sections
zstyle ':completion:*:manuals' separate-sections true

# sort reverse by modification time so the newer the better
zstyle ':completion:*' file-sort modification reverse
#zstyle ':completion:*' file-sort change

# try to automagically generate descriptions from manpage
zstyle ':completion:*:options' description yes
zstyle ':completion:*' auto-description 'specify: %d'

# Don't prompt for a huge list, page it!
# Don't prompt for a huge list, menu it!
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' menu select=1 interactive

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

zstyle ':completion:*:-command-:*' group-order \
  builtins expansions aliases functions commands directories \
  globbed-files hidden-directories hidden-files \
  boring-directories boring-files keywords viewable

zstyle ':completion:*:(\ls|ls):*' group-order \
  directories globbed-files hidden-directories hidden-files \
  boring-directories boring-files

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

function _cdpath() {
  local tmpcdpath
  tmpcdpath=(${${(@)cdpath:#.}:#$PWD})
  (( $#tmpcdpath )) && alt=('path-directories:directory in cdpath:_path_files -W tmpcdpath -/')
  _alternative "$alt[@]"
}

function _cmd() {
  _command_names
  _functions
  _tilde
  _files
  _cdpath
  _options
}

compdef "_cmd" "-command-"
