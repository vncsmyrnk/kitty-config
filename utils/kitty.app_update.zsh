#!/bin/zsh

# Updates manually installed kitty

STOW_PATH=${STOW_PATH:-"$HOME/.local/stow"}
KITTY_STOW_PATH=${KITTY_STOW_PATH:-"kitty.app/bin/kitty"}

if [[ $(which kitty) != "$STOW_PATH/$KITTY_STOW_PATH" ]]; then
  echo "Not manually installed. No check needed."
  exit 0
fi

latest_version=$(curl -sL https://api.github.com/repos/kovidgoyal/kitty/releases/latest | jq -r '.tag_name')
latest_version="${latest_version:1}"
current_version=$(kitty -v | awk '{ print $2 }')

if [[ "$latest_version" == "$current_version" ]]; then
  echo "kitty is already on latest version"
  exit 0
fi

echo "New version found: $latest_version. Current version is $current_version. New version will be downloaded"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=~/.local/stow launch=n
kitty -v
