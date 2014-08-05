# ================
# path compressors
# ================

# Reduce path to shortest prefixes. Heavily Optimized
function minify_path () {
  emulate -LR zsh
  setopt glob_dots
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
  emulate -LR zsh
  # setopt caseglob
  setopt extended_glob
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
  emulate -LR zsh
  setopt extended_glob
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
  # emulate -LR zsh
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
  # emulate -LR zsh
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
