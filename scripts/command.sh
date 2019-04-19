#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(tmux list-commands | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')
tmux command-prompt -I "$TARGET"
