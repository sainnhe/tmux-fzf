#!/usr/bin/env bash

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select a command.'"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

target_origin=$(tmux list-commands)
target=$(printf "[cancel]\n%s" "$target_origin" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS" | cut -d ' ' -f 1)

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
tmux command-prompt -I "$target"
