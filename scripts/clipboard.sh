#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select clipboard history"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

if ! [ -x "$(command -v copyq)" ]; then
    action="buffer"
elif [ -z "$1" ]; then
    action="system"
else
    action="$1"
fi

if [[ "$action" == "system" ]]; then
    item_numbers=$(copyq count)
    index=0
    while [ "$index" -lt "$item_numbers" ]; do
        copyq_read="$copyq_read $index"
        index=$((index + 1))
    done
    system_clipboard_history=$(eval "copyq read ${copyq_read}" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    [[ -z "${system_clipboard_history}" ]] && exit
    tmux send-keys -l "${system_clipboard_history}"
elif [[ "$action" == "buffer" ]]; then
    buffer_clipboard_history=$(tmux list-buffers | sed -E -e 's/^buffer[^/]*bytes: "//' -e 's/"$//' | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    [[ -z "${buffer_clipboard_history}" ]] && exit
    tmux send-keys -l "${buffer_clipboard_history}"
fi
