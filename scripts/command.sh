#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select a command."')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/../settings.sh"

target_origin=$(tmux list-commands)
target=$(printf "[cancel]\n%s" "$target_origin" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
tmux command-prompt -I "$target"
