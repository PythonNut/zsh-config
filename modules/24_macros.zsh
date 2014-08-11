# ============
# Shell macros
# ============

source ~/.zsh.d/zsh-macro/macro.zsh
export MACRO_DIR="$HOME/.zsh.d/macros"
if [[ ! -d $MACRO_DIR ]]; then
    mkdir $MACRO_DIR
fi

add-zsh-hook preexec macro
