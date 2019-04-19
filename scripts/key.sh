#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_ORIGIN=$(tmux list-keys)
TARGET=$(printf "[cancel]\n%s" "$TARGET_ORIGIN" | grep -v 'copy-mode' | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | sed -r 's/^.{46}//g')
if [[ "$TARGET" == "[cancel]" ]]; then
    exit
else
    tmux "$TARGET"
fi
