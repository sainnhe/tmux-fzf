#!/usr/bin/env bash

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select clipboard history. Press TAB to mark multiple items.'"
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
        copyq_list="$copyq_list $index"
        index=$((index + 1))
    done
    copyq_index=$(echo "[cancel] $copyq_list" | sed -e 's/\] /]/' -e 's/ /\n/g' | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS --preview='copyq read {}'")
    [[ "$copyq_index" == "[cancel]" || -z "$copyq_index" ]] && exit
    echo "$copyq_index" | xargs -I{} sh -c 'tmux set-buffer -b _temp_tmux_fzf "$(copyq read {})" && tmux paste-buffer -b _temp_tmux_fzf && tmux delete-buffer -b _temp_tmux_fzf'
elif [[ "$action" == "buffer" ]]; then
    selected_buffer=$(tmux list-buffers | sed -e 's/:.*bytes//' -e '$s/$/\n[cancel]/' | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS --preview=\"echo {} | sed 's/:.*$//' | head -1 | xargs tmux show-buffer -b\"" | sed 's/:.*$//')
    [[ "$selected_buffer" == "[cancel]" || -z "$selected_buffer" ]] && exit
    echo "$selected_buffer" | xargs -I{} sh -c 'tmux paste-buffer -b {}'
fi
