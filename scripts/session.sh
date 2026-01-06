#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"
source "$CURRENT_DIR/.utils"

if [[ -z "$TMUX_FZF_SESSION_FORMAT" ]]; then
    sessions=$(tmux list-sessions)
else
    sessions=$(tmux list-sessions -F "#S: $TMUX_FZF_SESSION_FORMAT")
fi

# Always initialize current_session (needed for [current] support)
current_session=$(tmux display-message -p | sed -e 's/^\[//' -e 's/\].*//')
if [[ -z "$TMUX_FZF_SWITCH_CURRENT" ]]; then
    sessions=$(echo "$sessions" | grep -v "^$current_session: ")
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
    action=$(printf "switch\nnew\nrename\ndetach\nkill\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit

# Support $2 as pre-selected target (for unified.sh integration)
if [[ -n "$2" ]]; then
    # Handle [current] special case
    if [[ "$2" == "[current]" ]]; then
        target="$current_session"
    else
        target="$2"
    fi
    # For rename action, still need to prompt for new name
    if [[ "$action" == "rename" ]]; then
        session_name=$(prompt_name "Session Name") || exit
    fi
else
    # Original fzf selection logic
    if [[ "$action" != "detach" ]]; then
        if [[ "$action" == "kill" ]]; then
            FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
        else
            FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session.'"
        fi
        if [[ "$action" == "switch" ]]; then
            target_origin=$(printf "%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_SESSION_OPTIONS")
        elif [[ "$action" != "new" ]]; then
            target_origin=$(printf "[current]\n%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_SESSION_OPTIONS")
            target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
        fi
        if [[ "$action" == "new" || "$action" == "rename" ]]; then
            session_name=$(prompt_name "Session Name") || exit
            if [[ "$action" == "new" ]]; then
                tmux new-session -d -s "$session_name" && tmux switch-client -t "$session_name"
                exit
            fi
        fi
    else
        tmux_attached_sessions=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
        sessions=$(echo "$sessions" | grep "^$tmux_attached_sessions")
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
        target_origin=$(printf "[current]\n%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_SESSION_OPTIONS")
        target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
    fi
    [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
    target=$(echo "$target_origin" | sed -e 's/:.*$//')
fi
if [[ "$action" == "switch" ]]; then
    tmux switch-client -t "$target"
elif [[ "$action" == "detach" ]]; then
    echo "$target" | xargs -I{} tmux detach -s "{}"
elif [[ "$action" == "kill" ]]; then
    echo "$target" | sort -r | xargs -I{} tmux kill-session -t "{}"
elif [[ "$action" == "rename" ]]; then
    tmux rename-session -t "$target" "$session_name"
fi
