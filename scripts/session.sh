#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_SESSION_FORMAT"x == ""x ]]; then
    SESSIONS=$(tmux list-sessions)
else
    SESSIONS=$(tmux list-sessions -F "#S: $TMUX_FZF_SESSION_FORMAT")
fi

ACTION=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
if [[ "$ACTION" == "[cancel]" ]]; then
    exit
else
    if [[ "$ACTION" != "detach" ]]; then
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    else
        TMUX_DETACHED_SESSIONS=$(tmux list-sessions | grep -v 'attached' | grep -o '^[[:alpha:]|[:digit:]]*:' | sed 's/.$//g')
        SESSIONS=$(echo "$SESSIONS" | grep -v "^$TMUX_DETACHED_SESSIONS")
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:' | sed 's/.$//g')
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
