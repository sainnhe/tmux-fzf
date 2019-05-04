#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITEMS_ORIGIN=$(printf "session\nwindow\npane\ncommand\nkeybinding")
if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | "$CURRENT_DIR/scripts/.fzf-tmux")
else
    ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | "$CURRENT_DIR/scripts/.fzf-tmux" "$TMUX_FZF_OPTIONS")
fi
if [[ "$ITEM" == "[cancel]" ]]; then
    exit
else
    ITEM=$(echo "$CURRENT_DIR/scripts/$ITEM" | sed 's/$/.sh/')
    tmux run-shell "$ITEM"
fi
