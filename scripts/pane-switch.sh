#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-panes -a | $CURRENT_DIR/.fzf-tmux)
echo $TARGET | grep -o '.*:' | grep -o '[[:alpha:]]*' | xargs tmux switch-client -t
echo $TARGET | grep -o '.*:' | sed -r 's/(.*)(.)$/\1/' | grep -o '[[:alpha:]]*:[[:digit:]]*' | xargs tmux select-window -t
echo $TARGET | grep -o '.*:' | sed -r 's/(.*)(.)$/\1/' | xargs tmux select-pane -t
