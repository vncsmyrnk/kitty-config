os := `cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d '"'`

utils_path := "${UTILS_SCRIPTS_DIR:-$HOME/utils}"

default:
  just --list

install-deps:
  #!/bin/bash
  if [ "{{os}}" = "Debian GNU/Linux" ] || [ "{{os}}" = "Ubuntu" ]; then
    dest=~/.local/stow
    if [ -d  $dest/kitty.app ]; then
      exit 0
    fi
    sudo apt-get install stow curl
    mkdir -p $dest
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=$dest launch=n
    cd $dest
    stow kitty.app
  elif [ "{{os}}" = "Arch Linux" ]; then
    sudo pacman -S kitty
  fi

install: install-deps install-font config

install-font:
  #!/bin/bash
  fonts_path=~/.local/share/fonts/ttf
  if [ -d  $fonts_path ]; then
    echo "Already installed at $fonts_path"
    exit 0
  fi
  mkdir -p $fonts_path
  curl -LO --output-dir $fonts_path https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
  unzip $fonts_path/JetBrainsMono.zip -d $fonts_path
  rm $fonts_path/JetBrainsMono.zip

config:
  @rm -f ~/.config/kitty/kitty.conf
  mkdir -p {{home_dir()}}/.config/kitty
  stow -t {{home_dir()}}/.config/kitty . --ignore=utils
  stow -t {{utils_path}} utils

unset-config:
  stow -D -t {{home_dir()}}/.config/kitty . --ignore=utils
  stow -D -t {{utils_path}} utils
