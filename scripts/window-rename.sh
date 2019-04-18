#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-windows -a | $CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS | sed -r -e 's/[[:blank:]].*//g' -e 's/.$//g')
tmux command-prompt -I "rename-window -t $TARGET "
