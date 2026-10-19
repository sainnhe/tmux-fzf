#!/usr/bin/env bash

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select a key binding.'"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

target=$(tmux list-keys | sed '1s/^/[cancel]\n/' | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
[[ $target = *copy-mode* && ! "$target" = *prefix* ]] && tmux copy-mode
tmux source /dev/stdin < <(echo "$target" | awk '{ $1=$2=$3=$4=""; print $0 }')
