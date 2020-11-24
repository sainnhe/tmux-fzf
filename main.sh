#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FZF_TMUX=$(which fzf-tmux)
FZF_TMUX=${FZF_TMUX:-$CURRENT_DIR/scripts/.fzf-tmux}
[[ -z "$TMUX_FZF_ORDER" ]] && TMUX_FZF_ORDER="session|window|pane|command|keybinding"

items_origin="$(echo $TMUX_FZF_ORDER | tr '|' '\n')"
if [[ -z "$TMUX_FZF_MENU" ]]; then
    item=$(printf "%s\n[cancel]" "$items_origin" | eval "$FZF_TMUX $TMUX_FZF_OPTIONS")
else
    item=$(printf "menu\n%s\n[cancel]" "$items_origin" | eval "$FZF_TMUX $TMUX_FZF_OPTIONS")
fi
[[ "$item" == "[cancel]" || -z "$item" ]] && exit
item=$(echo "$CURRENT_DIR/scripts/$item" | sed -E 's/$/.sh/')
tmux run-shell -b "$item"
