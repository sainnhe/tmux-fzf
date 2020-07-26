#!/usr/bin/env bash

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select a command"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_ORIGIN=$(tmux list-commands)
TARGET=$(printf "[cancel]\n%s" "$TARGET_ORIGIN" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$TARGET" == "[cancel]" || -z "$TARGET" ]] && exit
tmux command-prompt -I "$TARGET"
