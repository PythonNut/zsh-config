# ================
# path compressors
# ================

# Reduce path to shortest prefixes. Heavily Optimized
function minify_path () {
  emulate -LR zsh
  setopt glob_dots extended_glob
  local full_path="/" ppath cur_path dir
  local -a revise
  local -i matches
  1=${${1:A}/${HOME:A}/\~}
  for token in ${(s:/:)1}; do
    cur_path=${full_path:s/\~/$HOME/}
    local -i col=1
    local glob="${token[0,1]}"
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
        if [[ ! -o caseglob ]]; then
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
  setopt extended_glob null_glob
    local glob temp_glob result
    glob=("${(@s:/:)$(minify_path $1)}")
    local -i index=$(($#glob - 1))
    while ((index >= 1)); do
      if [[ ${glob[$index]} == "~" ]]; then
        break
      fi
      local old_token=${glob[$index]}
      while true; do
        temp_glob=${${(j:*/:)glob}:s/*//}*(/)
        result=(${~temp_glob})
        if (( $#result != 1 )); then
          break
        fi
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
  # emulate -LR zsh
  if [[ $(type fasd) == *function* ]]; then
    local dirs index above higher base test
    local -i escape i k
    1=${${1:A}%/}
    dirs=${(nOa)$(fasd)##[0-9.[:space:]]##}
    if (( ${+dirs[(r)$1]} )); then
      dirs=($(print ${(f)dirs}))
      index=${${${dirs[$((${dirs[(i)$1]}+1)),-1]}%/}##*/}
      1=$1:t
      for ((i=0; i<=$#1+1; i++)); do
        for ((k=1; k<=$#1-$i; k++)); do
          test=${1[$k,$(($k+$i))]}
          if (( ! ${+index[(r)*$test*]} )); then
            if [[ $(type $test) == *not* && ! -n ${(P)temp} || -n $ALL ]]; then
              echo $test
              escape=1
              break
            fi
          fi
        done
        (( $escape == 1 )) && break
      done
    else
      printf " "
      return 1
    fi
  else
    printf " "
  fi
}

