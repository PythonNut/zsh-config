#!/usr/bin/zsh
# this file should be run exactly once immediately after this repo is cloned
# and whenever changes are made to files in modules

for file in ~/.zsh.d/modules/*; do
    zcompile -U $file
done

cd $0

git submodule init
git submodule update --init --recursive
git submodule foreach git pull origin master

git fetch --all

ln -s ~/.zsh.d/.zshrc ~/.zshrc
