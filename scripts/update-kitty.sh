#!/bin/sh

# Updates manually installed kitty

LOCAL_BIN=${LOCAL_BIN:-"/usr/local/bin"}
KITTY_BIN=${KITTY_BIN:-"kitty"}
KITTY_INSTALLATION_PATH=${KITTY_INSTALLATION_PATH:-/usr/local/stow/kitty}

if [ $(which kitty) != "$LOCAL_BIN/$KITTY_BIN" ]; then
  echo "Not manually installed. No check needed."
  exit 0
fi

current_version=$(kitty -v | awk '{ print $2 }')
latest_version=$(curl -sL https://api.github.com/repos/kovidgoyal/kitty/releases/latest | jq -r '.tag_name' | cut -c 2-)

if [ -z "$latest_version" ]; then
  echo "failed to fetch for updates using the github api"
  exit 1
fi

if [ "$latest_version" = "$current_version" ]; then
  echo "kitty is already on latest version"
  exit 0
fi

echo "New version found: $latest_version. Current version is $current_version. New version will be downloaded"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin dest=/tmp launch=n
sudo rsync -r /tmp/kitty.app/ $KITTY_INSTALLATION_PATH --delete-after
kitty -v
