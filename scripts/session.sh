#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_SESSION_ORIGIN=$(tmux list-sessions | grep 'attached')

if [[ "$TMUX_FZF_SESSION_FORMAT"x == ""x ]]; then
    SESSIONS=$(tmux list-sessions)
else
    SESSIONS=$(tmux list-sessions -F "#S: $TMUX_FZF_SESSION_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select an action"')
if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    ACTION=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
else
    ACTION=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
fi

if [[ "$ACTION" == "[cancel]" ]]; then
    exit
else
    if [[ "$ACTION" != "detach" ]]; then
        if [[ "$ACTION" == "kill" ]]; then
            FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select target session(s), press TAB to select multiple targets"')
        else
            FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select target session"')
        fi
        if [[ "$ACTION" == "attach" ]]; then
            TMUX_ATTACHED_SESSIONS=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:]|[:digit:]]*:' | sed 's/.$//g')
            SESSIONS=$(echo "$SESSIONS" | grep -v "^$TMUX_ATTACHED_SESSIONS")
            if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
                TARGET_ORIGIN=$(printf "%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux")
            else
                TARGET_ORIGIN=$(printf "%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
            fi
        else
            if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
                TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux")
            else
                TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
            fi
            TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | sed -r "s/\[current\]/$CURRENT_SESSION_ORIGIN/")
        fi
    else
        TMUX_ATTACHED_SESSIONS=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:]|[:digit:]]*:' | sed 's/.$//g')
        SESSIONS=$(echo "$SESSIONS" | grep "^$TMUX_ATTACHED_SESSIONS")
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select target session(s), press TAB to select multiple targets"')
        if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
            TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux")
        else
            TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$SESSIONS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
        fi
        TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | sed -r "s/\[current\]/$CURRENT_SESSION_ORIGIN/")
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:' | sed 's/.$//g')
        if [[ "$ACTION" == "attach" ]]; then
            echo "$TARGET" | xargs tmux switch-client -t
        elif [[ "$ACTION" == "detach" ]]; then
            echo "$TARGET" | xargs -i tmux detach -s {}
        elif [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux kill-session -t {}
        elif [[ "$ACTION" == "rename" ]]; then
            tmux command-prompt -I "rename-session -t $TARGET "
        fi
    fi
fi
