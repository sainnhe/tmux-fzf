#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select a command."')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FZF_TMUX=$(which fzf-tmux)
FZF_TMUX=${FZF_TMUX:-$CURRENT_DIR/.fzf-tmux}

target_origin=$(tmux list-commands)
target=$(printf "[cancel]\n%s" "$target_origin" | eval "$FZF_TMUX $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
tmux command-prompt -I "$target"
