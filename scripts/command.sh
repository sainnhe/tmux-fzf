#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ORIGIN=$(tmux list-commands)
TARGET=$(printf "[cancel]\n%s" "$TARGET_ORIGIN" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')
if [[ "$TARGET" == "[cancel]" ]]; then
    exit
else
    tmux command-prompt -I "$TARGET"
fi
