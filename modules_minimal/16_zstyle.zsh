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
       _oldlist \
       _expand \
       _complete \
       _match \
       _files \
       _prefix

zstyle ':completion:*:match:*' original only

# smart case completion (abc => Abc)
zstyle ':completion:*' matcher 'm:{a-z\-}={A-Z\_}'

# full flex completion  (abc => ABraCadabra)
zstyle ':completion:*:files:*' matcher 'r:|?=** m:{a-z\-}={A-Z\_}'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order expansions all-expansions

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' insert-unambiguous true

# ignore completions for functions I don't use
zstyle ':completion:*:functions' ignored-patterns '(_|.)*'

# ignore completions that are aleady on the line
zstyle ':completion:*:(rm|kill|diff|mv|cp|trash):*' ignore-line true

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

zstyle ':completion:*:(\cd|cd):*' group-order \
       directories noglob-directories hidden-directories boring-directories\

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
  if [[ $PREFIX != (\~|/|./|../)* && $IPREFIX != ../* ]]; then
    local tmpcdpath
    tmpcdpath=(${${(@)cdpath:#.}:#$PWD})
    if (( $#tmpcdpath )); then
      alt=("path-directories:directory in cdpath:_path_files -W $tmpcdpath -/")
      _alternative "$alt[@]"
    fi
  fi
}

_command_names_noexecutables () {
  local args defs ffilt
  local -a cmdpath
  if zstyle -t ":completion:${curcontext}:commands" rehash; then
    rehash
  fi

  if zstyle -t ":completion:${curcontext}:functions" prefix-needed; then
    if [[ $PREFIX != [_.]* ]]; then
      ffilt='[(I)[^_.]*]'
    fi
  fi

  defs=('commands:external command:_path_commands')
  if [[ "$1" = -e ]]; then
    shift
  else
    [[ "$1" = - ]] && shift
    defs=(
      "$defs[@]"
      'builtins:builtin command:compadd -Qk builtins'
      "functions:shell function:compadd -k 'functions$ffilt'"
      'aliases:alias:compadd -Qk aliases'
      'suffix-aliases:suffix alias:_suffix_alias_files'
      'reserved-words:reserved word:compadd -Qk reswords'
      'jobs:: _jobs -t'
      'parameters:: _parameters -g "^*readonly*" -qS= -r "\n\t\- =["'
    )
  fi
  args=("$@")
  if zstyle -a ":completion:${curcontext}" command-path cmdpath; then
    if [[ $#cmdpath -gt 0 ]]; then
      local -a +h path
      local -A +h commands
      path=($cmdpath)
    fi
  fi
  _alternative -O args "$defs[@]"
}

function _cmd() {
  _command_names_noexecutables
  _functions
  _tilde
  _files
  _cdpath
}

compdef "_cmd" "-command-"
