source $ZDOTDIR/zsh-dwim/init.zsh
global_bindkey "^u" kill-whole-line

function predict_next_line () {
  # s - show scores
  zparseopts -D -E s=S
  local hist_array i=1 hist_frequency next_line
  typeset -A hist_frequency
  # get array of history lines in order of increasing age
  hist_array=("${(@fOa)$(fc -ln 1)}") 
  while (( $i < $#hist_array )); do
    if [[ "$hist_array[$i]" == "$hist_array[1]" ]]; then
      next_line=$hist_array[$(($i+1))]
      hist_frequency[$next_line]=$((${hist_frequency[$next_line]:-0}+1/log10($i+1)))
    fi
    i=$(($i+1))
  done
  local combined result
  typeset -A combined
  combined=()
  for k v ("${(@kv)hist_frequency}"); do
    combined[$v]=$k
  done
  for k in "${(@kOn)combined}"; do
    if [[ -n $S ]]; then
      echo $combined[$k] \# $k
    else
      echo $combined[$k]
    fi
  done
}

integer prediction_index
predict_buffer=''

function zle_predict_next_line () {
  if [[ $#BUFFER == 0 ]]; then
    prediction_index=-1
  fi
  local prediction_array
  prediction_index=$(( $prediction_index + 1 ))
  if [[ $prediction_index == 0 ]]; then
    zle dwim
    zle end-of-line
    # catch the catch-all dwim case (temporary)
    if [[ "$BUFFER" == (sudo*) ]]; then
      prediction_index=$(( $prediction_index + 1 ))
    else
      return 0
    fi
  fi
  prediction_array=("${(@f)$(predict_next_line)}")
  LBUFFER="$prediction_array[$prediction_index]"
  predict_buffer="$LBUFFER"
  
  _zsh_highlight
}

zle -N predict-next-line zle_predict_next_line
