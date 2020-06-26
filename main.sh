#!/usr/bin/env bash

TMUX_FZF_SED="${TMUX_FZF_SED:-sed}"
if [[ "$($TMUX_FZF_SED --version 2>/dev/null | head -n 1 | grep -o GNU)" != "GNU" ]]; then
    tmux run-shell -b 'echo "Unable to find executable GNU sed."'
    exit 1
fi
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TMUX_FZF_MENU" ]]; then
    ITEMS_ORIGIN=$(printf "session\nwindow\npane\ncommand\nkeybinding")
else
    ITEMS_ORIGIN=$(printf "menu\nsession\nwindow\npane\ncommand\nkeybinding")
fi
ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | bash -c "$CURRENT_DIR/scripts/.fzf-tmux $TMUX_FZF_OPTIONS")
[[ "$ITEM" == "[cancel]" || -z "$ITEM" ]] && exit
ITEM=$(echo "$CURRENT_DIR/scripts/$ITEM" | $TMUX_FZF_SED 's/$/.sh/')
tmux run-shell -b "$ITEM"
