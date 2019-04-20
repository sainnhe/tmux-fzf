#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
if [[ "$ACTION" == "[cancel]" ]]; then
    exit
else
    if [[ "$ACTION" == "detach" ]]; then
        TARGET_ORIGIN=$(tmux list-sessions | grep "attached" | sed -r '$a [cancel]' | "$CURRENT_DIR/.fzf-tmux")
    else
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$(tmux list-sessions)" | "$CURRENT_DIR/.fzf-tmux")
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | sed -E 's/:.*$//')
        if [[ "$ACTION" == "attach" ]]; then
            echo "$TARGET" | xargs tmux switch-client -t
        elif [[ "$ACTION" == "detach" ]]; then
            echo "$TARGET" | xargs tmux detach -s
        elif [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux kill-session -t {}
        elif [[ "$ACTION" == "rename" ]]; then
            tmux command-prompt -I "rename-session -t $TARGET "
        fi
    fi
fi
