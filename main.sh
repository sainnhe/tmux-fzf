#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TMUX_FZF_MENU" ]]; then
    items_origin=$(printf "session\nwindow\npane\ncommand\nkeybinding")
else
    items_origin=$(printf "menu\nsession\nwindow\npane\ncommand\nkeybinding")
fi
item=$(printf "%s\n[cancel]" "$items_origin" | eval "$CURRENT_DIR/scripts/.fzf-tmux $TMUX_FZF_OPTIONS")
[[ "$item" == "[cancel]" || -z "$item" ]] && exit
item=$(echo "$CURRENT_DIR/scripts/$item" | sed -E 's/$/.sh/')
tmux run-shell -b "$item"
