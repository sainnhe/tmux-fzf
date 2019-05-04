#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select a key binding"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    TARGET_ORIGIN=$(tmux list-keys | sed '1i [cancel]' | "$CURRENT_DIR/.fzf-tmux")
else
    TARGET_ORIGIN=$(tmux list-keys | sed '1i [cancel]' | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
fi

if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
    exit
else
    if [[ $(echo "$TARGET_ORIGIN" | grep -o "copy-mode")x != ""x && $(echo "$TARGET_ORIGIN" | grep -o "prefix")x == x ]]; then
        tmux copy-mode
        echo "$TARGET_ORIGIN" | sed -r 's/^.{46}//g' | xargs tmux
    else
        echo "$TARGET_ORIGIN" | sed -r 's/^.{46}//g' | xargs tmux
    fi
fi
