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
    contents="[cancel]\n"
    index=0
    while [ "$index" -lt "$item_numbers" ]; do
        _content="$(copyq read ${index} | tr '\n' ' ' | tr '\\n' ' ')"
        contents="${contents}copy${index}: ${_content}\n"
        index=$((index + 1))
    done
    copyq_index=$(printf "$contents" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS --preview=\"echo {} | sed -e 's/^copy//' -e 's/: .*//' | xargs -I{} copyq read {}\"" | sed -e 's/^copy//' -e 's/: .*//')
    [[ "$copyq_index" == "[cancel]" || -z "$copyq_index" ]] && exit
    echo "$copyq_index" | xargs -I{} sh -c 'tmux set-buffer -b _temp_tmux_fzf "$(copyq read {})" && tmux paste-buffer -b _temp_tmux_fzf && tmux delete-buffer -b _temp_tmux_fzf'
elif [[ "$action" == "buffer" ]]; then
    selected_buffer=$(tmux list-buffers | sed -e 's/:.*bytes//' -e '1s/^/[cancel]\n/' -e 's/: "/: /' -e 's/"$//' | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS --preview=\"echo {} | sed -e 's/\[cancel\]//' -e 's/:.*$//' | head -1 | xargs tmux show-buffer -b\"" | sed 's/:.*$//')
    [[ "$selected_buffer" == "[cancel]" || -z "$selected_buffer" ]] && exit
    echo "$selected_buffer" | xargs -I{} sh -c 'tmux paste-buffer -b {}'
fi
