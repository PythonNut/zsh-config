source ~/.zsh.d/zsh-dwim/init.zsh
global_bindkey "^u" kill-whole-line

function predict_next_line () {
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
        echo $combined[$k]
    done
}

integer prediction_index
predict_buffer=''
