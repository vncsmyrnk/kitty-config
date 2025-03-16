os := `cat /etc/os-release | grep "^NAME=" | cut -d "=" -f2 | tr -d '"'`

scripts_path := "${SU_SCRIPTS_PATH:-$HOME/.config/util/scripts}/kitty"

default:
  just --list

install-deps:
  #!/bin/bash
  if [ "{{os}}" = "Debian GNU/Linux" ] || [ "{{os}}" = "Ubuntu" ]; then
    STOW_PATH=/usr/local/stow
    if [ -d  $STOW_PATH/kitty.app ]; then
      echo "Kitty already installed."
      exit 0
    fi
    sudo apt-get install stow curl
    mkdir -p $STOW_PATH
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin STOW_PATH=/tmp/kitty launch=n
    sudo cp -r /tmp/kitty.app $STOW_PATH
    cd $STOW_PATH
    sudo stow kitty.app --ignore=lib # Ignores libs as liblzma5 conflicts with /lib
  elif [ "{{os}}" = "Arch Linux" ]; then
    sudo pacman -S kitty
  fi

set-as-default-alternative:
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 100

install: install-deps install-font config

install-font:
  #!/bin/bash
  FONT_PATH=/usr/local/share/fonts/jetbrains
  if [ -d  $FONT_PATH ]; then
    echo "Already installed at $FONT_PATH"
    exit 0
  fi
  curl -LO --output-dir /tmp https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
  unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
  sudo cp -r /tmp/JetBrainsMono /usr/local/share/fonts/jetbrains

config:
  @rm -f ~/.config/kitty/kitty.conf
  mkdir -p {{home_dir()}}/.config/kitty {{scripts_path}}
  stow -t {{home_dir()}}/.config/kitty . --ignore=scripts
  stow -t {{scripts_path}} scripts

unset-config:
  stow -D -t {{home_dir()}}/.config/kitty . --ignore=scripts
  stow -D -t {{scripts_path}} scripts
