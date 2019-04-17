#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-panes -a | $CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS)
echo $TARGET | grep -o '.*:' | sed -r 's/(.*)(.)$/\1/' | xargs tmux kill-pane -t
