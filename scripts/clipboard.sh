#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select clipboard history"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! [ -x "$(command -v copyq)" ]; then
    action="buffer"
elif [ -z "$1" ]; then
    action="system"
else
    action="$1"
fi

if [[ "$action" == "system" ]]; then
    system_clipboard_history=$(copyq read 0 1 2 3 4 5 6 7 8 9 | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ -z "${system_clipboard_history}" ]] && exit
    tmux send-keys -l "${system_clipboard_history}"
elif [[ "$action" == "buffer" ]]; then
    buffer_clipboard_history=$(tmux list-buffers | sed -E -e 's/^buffer[^/]*bytes: "//' -e 's/"$//' | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ -z "${buffer_clipboard_history}" ]] && exit
    tmux send-keys -l "${buffer_clipboard_history}"
fi
