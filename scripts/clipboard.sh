#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select clipboard history"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! [ -f "$CURRENT_DIR/../.temp" ]; then
    action="buffer"
elif [[ -z "$1" ]]; then
    action=$(printf "all\nbuffer\nsystem\n[cancel]" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit
if [[ "$action" == "all" ]]; then
    buffer_clipboard_history=$(tmux list-buffers | sed -E -e 's/^buffer[^/]*bytes: "//' -e 's/"$//')
    system_clipboard_history=$("${CURRENT_DIR}/clipboard/clipster" -on 0)
    [ -z "$buffer_clipboard_history" ] && buffer_clipboard_history="" || buffer_clipboard_history="${buffer_clipboard_history}\n"
    all_history=$(printf "%s%s" "${buffer_clipboard_history}" "${system_clipboard_history}" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ -z "${all_history}" ]] && exit
    tmux send-keys -l "${all_history}"
elif [[ "$action" == "buffer" ]]; then
    buffer_clipboard_history=$(tmux list-buffers | sed -E -e 's/^buffer[^/]*bytes: "//' -e 's/"$//' | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ -z "${buffer_clipboard_history}" ]] && exit
    tmux send-keys -l "${buffer_clipboard_history}"
elif [[ "$action" == "system" ]]; then
    system_clipboard_history=$("${CURRENT_DIR}/clipboard/clipster" -on 0 | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ -z "${system_clipboard_history}" ]] && exit
    tmux send-keys -l "${system_clipboard_history}"
fi
