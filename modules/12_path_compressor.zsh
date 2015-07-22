# ================
# path compressors
# ================

# Reduce path to shortest prefixes. Heavily Optimized
function minify_path () {
  emulate -LR zsh
  setopt glob_dots extended_glob
  local full_path="/" ppath cur_path dir glob
  local -a revise
  local -i matches col
  for token in ${(s:/:)${1:A}/${HOME:A}/\~}; do
    cur_path=${full_path:s/\~/$HOME/}
    col=1
    glob="${token[0,1]}"
    cur_path=($cur_path/*(/))
    # prune the single dir case
    if [[ $#cur_path == 1 ]]; then
      ppath+="/"
      full_path=${full_path%%(/##)}/$token
      continue
    fi
    while; do
      matches=0
      revise=()
      for fulldir in $cur_path; do
        dir=${${fulldir%%/}##*/}
        if (( ${#dir##(#l)($glob)} < $#dir )); then
          ((matches++))
          revise+=$fulldir
          if (( matches > 1 )); then
            break
          fi
        fi
      done
      if (( $matches > 1 )); then
        glob=${token[0,$((col++))]}
        if (( $col -1 > $#token )); then
          break
        fi
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
  setopt extended_glob null_glob glob_dots
  local glob temp_glob result official_result seg
  glob=${${1:A}/${HOME:A}/\~}
  glob=("${(@s:/:)glob}")

  local -i index=$(($#glob)) k

  temp_glob=("${(s/ /)glob//(#m)?/$MATCH*}")
  temp_glob=${${(j:/:)temp_glob}:s/~*/~/}(/)
  official_result=(${~temp_glob})

  while ((index >= 1)); do
    if [[ ${glob[$index]} == "~" ]]; then
      break
    fi
    k=${#glob[$index]}
    while true; do
      seg=$glob[$index]
      temp_glob=("${(s/ /)glob//(#m)?/$MATCH*}")
      temp_glob=${${(j:/:)temp_glob}:s/~*/~/}(/)
      result=(${~temp_glob})

      if [[ $result != $official_result ]]; then
        glob[$index]=$old_glob
        seg=$old_glob
      fi

      if (( $k == 0 )); then
        break
      fi
      old_glob=${glob[$index]}
      glob[$index]=$seg[0,$(($k-1))]$seg[$(($k+1)),-1]
      ((k--))
    done
    ((index--))
  done
  echo ${(j:/:)glob}
}

# collapse empty runs too
function minify_path_smart () {
  emulate -LR zsh
  setopt brace_ccl
  local cur_path glob
  local -i i
  cur_path=$(minify_path_full $1)
  for ((i=${#cur_path:gs/[^\/]/}; i>1; i--)); do
    glob=${(l:$i::/:)}
    cur_path=${cur_path//$glob/%U$i%u}
  done
  cur_path=${cur_path:s/\~\//\~}
  for char in {a-zA-Z}; do
    cur_path=${cur_path//\/$char/%U$char%u}
  done
  echo $cur_path
}

# find shortest unique fasd prefix. Heavily optimized
function minify_path_fasd () {
  zparseopts -D -E a=ALL
  if [[ $(type fasd) != *function* ]]; then
    printf " "
    return
  fi
  local dirs index above higher base test
  local -i escape i k
  1=${${1:A}%/}
  dirs=${(nOa)$(fasd)##[0-9.[:space:]]##}
  if ! (( ${+dirs[(r)$1]} )); then
    printf " "
    return 1
  fi
  dirs=($(print ${(f)dirs}))
  index=${${${dirs[$((${dirs[(i)$1]}+1)),-1]}%/}##*/}
  1=$1:t
  for ((i=0; i<=$#1+1; i++)); do
    for ((k=1; k<=$#1-$i; k++)); do
      test=${1[$k,$(($k+$i))]}
      if [[ -z ${index[(r)*$test*]} ]]; then
        if [[ $(type $test) == *not* && -z ${(P)temp} || -n $ALL ]]; then
          echo $test
          escape=1
          break
        fi
      fi
    done
    if (( $escape == 1 )); then
      break
    fi
  done
}

