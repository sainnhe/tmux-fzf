#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-windows -a | $CURRENT_DIR/.fzf-tmux)
echo $TARGET | grep -o '.*:' | grep -o '[[:alpha:]]*' | xargs tmux switch-client -t
echo $TARGET | grep -o '[[:alpha:]]*:[[:digit:]]*:' | sed -r 's/(.*)(.)$/\1/' | xargs tmux select-window -t
