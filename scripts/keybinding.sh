#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select a key binding"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

target=$(tmux list-keys | sed '1i [cancel]' | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
if [[ -n $(echo "$target" | grep -o "copy-mode") && -z $(echo "$target" | grep -o "prefix") ]]; then
    tmux copy-mode
    echo "$target" | sed -E 's/^.{46}//g' | xargs tmux
else
    echo "$target" | sed -E 's/^.{46}//g' | xargs tmux
fi
