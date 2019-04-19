#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION=$(printf "attach\ndetach\nkill\nrename\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
if [[ "$ACTION" == "[cancel]" ]]; then
    exit
else
    TARGET_ORIGIN=$(printf "$(tmux list-sessions)\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\")
        if [[ "$ACTION" == "attach" ]]; then
            echo "$TARGET" | xargs tmux switch-client -t
        elif [[ "$ACTION" == "detach" ]]; then
            echo "$TARGET" | xargs tmux detach -s
        elif [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | xargs tmux kill-session -t
        elif [[ "$ACTION" == "rename" ]]; then
            tmux command-prompt -I "rename-session -t $TARGET "
        fi
    fi
fi
