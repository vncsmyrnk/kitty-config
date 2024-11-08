#!/bin/bash

dest=~/.local/stow

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=$dest
cd $dest
stow kitty.app
