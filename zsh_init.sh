#!/usr/bin/bash

for file in ~/.zsh.d/modules/*; do
    zcompile -U $file
done

cd $(dirname "${BASH_SOURCE[0]}")

git submodule init
git submodule update --init --recursive
git submodule foreach git pull origin master

git fetch --all

ln -s ~/.zsh.d/.zshrc ~/.zshrc
