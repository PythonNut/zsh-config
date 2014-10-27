#!/bin/zsh

# core zsh setup

# disable traps until we define them later
TRAPUSR1(){ echo "USR1 called before init!" }
TRAPUSR2(){ echo "USR2 called before init!" }

zstyle :compinstall filename '~/.zshrc'
skip_global_compinit=1
fpath=(~/.zsh.d/completers $fpath)
autoload -Uz compinit  && compinit -d ~/.zsh.d/zcompdump
echo -n > ~/.zsh.d/startup.log
setopt function_argzero
mkdir -p ~/.zsh.d

export ZDOTDIR=~/.zsh.d

# let us begin
for zsh_module in ~/.zsh.d/modules/*.zsh(n); do
  source $zsh_module
done

# and source host specific files
for file in ~/.zsh.d/local/*.zsh(n); do
  source $file
done
