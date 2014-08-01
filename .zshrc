#!/bin/zsh

# core zsh setup
zstyle :compinstall filename '~/.zshrc'
skip_global_compinit=1
fpath=(~/.zsh.d/completers $fpath)
autoload -Uz compinit  && compinit -d ~/.zsh.d/zcompdump
echo -n > ~/.zsh.d/startup.log
setopt function_argzero
mkdir -p ~/.zsh.d
touch ~/.zsh.d/startup.log



# let us begin
for zsh_module in ~/.zsh.d/modules/*(n); do
  source $zsh_module
done
