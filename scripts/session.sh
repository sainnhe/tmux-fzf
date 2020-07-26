#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_SESSION_ORIGIN=$(tmux list-sessions | grep 'attached')

if [[ -z "$TMUX_FZF_SESSION_FORMAT" ]]; then
    SESSIONS=$(tmux list-sessions)
else
    SESSIONS=$(tmux list-sessions -F "#S: $TMUX_FZF_SESSION_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select an action"')
if [[ -z "$1" ]]; then
    ACTION=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
else
    ACTION="$1"
fi

[[ "$ACTION" == "[cancel]" || -z "$ACTION" ]] && exit
if [[ "$ACTION" != "detach" ]]; then
    if [[ "$ACTION" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select target session(s), press TAB to select multiple targets"')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select target session"')
    fi
    if [[ "$ACTION" == "attach" ]]; then
        TMUX_ATTACHED_SESSIONS=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
        SESSIONS=$(echo "$SESSIONS" | grep -v "^$TMUX_ATTACHED_SESSIONS")
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$SESSIONS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    else
        TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | sed -E "s/\[current\]/$CURRENT_SESSION_ORIGIN/")
    fi
else
    TMUX_ATTACHED_SESSIONS=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
    SESSIONS=$(echo "$SESSIONS" | grep "^$TMUX_ATTACHED_SESSIONS")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select target session(s), press TAB to select multiple targets"')
    TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | sed -E "s/\[current\]/$CURRENT_SESSION_ORIGIN/")
fi
[[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
if [[ "$ACTION" == "attach" ]]; then
    echo "$TARGET" | xargs tmux switch-client -t
elif [[ "$ACTION" == "detach" ]]; then
    echo "$TARGET" | xargs -i tmux detach -s {}
elif [[ "$ACTION" == "kill" ]]; then
    echo "$TARGET" | sort -r | xargs -i tmux kill-session -t {}
elif [[ "$ACTION" == "rename" ]]; then
    tmux command-prompt -I "rename-session -t $TARGET "
fi
