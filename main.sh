#!/usr/bin/env bash

TMUX_FZF_SED="${TMUX_FZF_SED:-sed}"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TMUX_FZF_MENU" ]]; then
    ITEMS_ORIGIN=$(printf "session\nwindow\npane\ncommand\nkeybinding")
else
    ITEMS_ORIGIN=$(printf "menu\nsession\nwindow\npane\ncommand\nkeybinding")
fi
ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | eval "$CURRENT_DIR/scripts/.fzf-tmux $TMUX_FZF_OPTIONS")
[[ "$ITEM" == "[cancel]" || -z "$ITEM" ]] && exit
ITEM=$(echo "$CURRENT_DIR/scripts/$ITEM" | $TMUX_FZF_SED 's/$/.sh/')
tmux run-shell -b "$ITEM"
