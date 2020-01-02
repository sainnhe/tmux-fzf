#!/usr/bin/env bash

if [[ "$TMUX_FZF_SED"x == ""x ]]; then
    TMUX_FZF_SED="sed"
fi
if [[ "$($TMUX_FZF_SED --version 2> /dev/null | head -n 1 | grep -o GNU)" != "GNU" ]]; then
    tmux run-shell -b 'echo "Unable to find executable GNU sed."'
    exit 1
fi
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_MENU"x == ""x ]]; then
    ITEMS_ORIGIN=$(printf "session\nwindow\npane\ncommand\nkeybinding")
else
    ITEMS_ORIGIN=$(printf "menu\nsession\nwindow\npane\ncommand\nkeybinding")
fi
if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | "$CURRENT_DIR/scripts/.fzf-tmux")
else
    ITEM=$(printf "%s\n[cancel]" "$ITEMS_ORIGIN" | "$CURRENT_DIR/scripts/.fzf-tmux" "$TMUX_FZF_OPTIONS")
fi
if [[ "$ITEM" == "[cancel]" ]]; then
    exit
else
    ITEM=$(echo "$CURRENT_DIR/scripts/$ITEM" | $TMUX_FZF_SED 's/$/.sh/')
    tmux run-shell -b "$ITEM"
fi
