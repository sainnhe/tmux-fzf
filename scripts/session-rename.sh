#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-sessions | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | sed -r 's/:.*//g')
tmux command-prompt -I "rename-session -t $TARGET "
