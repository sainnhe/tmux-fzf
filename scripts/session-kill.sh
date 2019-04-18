#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux list-sessions | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | sed -E 's/:.*$//'  | grep -v \"^$(tmux display-message -p '#S')\$\" | xargs tmux kill-session -t
