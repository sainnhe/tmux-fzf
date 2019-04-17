#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux list-windows -a | "$CURRENT_DIR/.fzf-tmux" | grep -o '[[:alpha:]]*:[[:digit:]]*:' | sed -r 's/(.*)(.)$/\1/' | xargs tmux kill-window -t
