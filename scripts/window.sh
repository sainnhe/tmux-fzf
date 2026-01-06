#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"
source "$CURRENT_DIR/.utils"

current_window_origin=$(tmux display-message -p '#S:#I: #{window_name}')
current_window=$(tmux display-message -p '#S:#I:')

if [[ -z  "$TMUX_FZF_WINDOW_FILTER" ]]; then
  window_filter="-a"
else
  window_filter="-f \"$TMUX_FZF_WINDOW_FILTER\""
fi

if [[ -z "$TMUX_FZF_WINDOW_FORMAT" ]]; then
    windows=$(tmux list-windows $window_filter)
else
    windows=$(tmux list-windows $window_filter -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"

if [[ -z "$1" ]]; then
    action=$(printf "switch\nlink\nmove\nswap\nrename\nkill\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit

# Support $2 as pre-selected target (for unified.sh integration)
if [[ -n "$2" ]]; then
    # Handle [current] special case
    if [[ "$2" == "[current]" ]]; then
        target=$(echo "$current_window" | sed 's/:$//')
    else
        target="$2"
    fi
    # Execute based on action with pre-selected target
    if [[ "$action" == "kill" ]]; then
        tmux unlink-window -k -t "$target"
    elif [[ "$action" == "rename" ]]; then
        window_name=$(prompt_name "Window Name") || exit
        tmux rename-window -t "$target" "$window_name"
    elif [[ "$action" == "swap" ]]; then
        target_swap=$(select_swap_target "$windows" "$target" "Select another target window.") || exit
        tmux swap-window -s "$target" -t "$target_swap"
    elif [[ "$action" == "switch" ]]; then
        echo "$target" | sed 's/:.*//g' | xargs -I{} tmux switch-client -t {}
        tmux select-window -t "$target"
    fi
else
    # Original fzf selection logic
    if [[ "$action" == "link" ]]; then
        src_win=$(select_source_window "$windows") || exit
        tmux link-window -a -s "$src_win" -t "$(get_current_session)"
    elif [[ "$action" == "move" ]]; then
        src_win=$(select_source_window "$windows") || exit
        tmux move-window -a -s "$src_win" -t "$(get_current_session)"
    else
        if [[ "$action" == "kill" ]]; then
            FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target window(s). Press TAB to mark multiple items.'"
        else
            FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target window.'"
        fi
        if [[ "$action" != "switch" ]]; then
            target_origin=$(printf "[current]\n%s\n[cancel]" "$windows" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
            target_origin=${target_origin/\[current\]/$current_window_origin}
        else
            if [[ -z "$TMUX_FZF_SWITCH_CURRENT" ]]; then
                windows=$(echo "$windows" | grep -v "^$current_window")
            fi
            target_origin=$(printf "%s\n[cancel]" "$windows" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
        fi
        [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
        target=$(echo "$target_origin" | sed 's/: .*//')
        if [[ "$action" == "kill" ]]; then
            echo "$target" | sort -r | xargs -I{} tmux unlink-window -k -t {}
        elif [[ "$action" == "rename" ]]; then
            window_name=$(prompt_name "Window Name") || exit
            tmux rename-window -t "$target" "$window_name"
        elif [[ "$action" == "swap" ]]; then
            target_swap=$(select_swap_target "$windows" "$target" "Select another target window.") || exit
            tmux swap-window -s "$target" -t "$target_swap"
        elif [[ "$action" == "switch" ]]; then
            echo "$target" | sed 's/:.*//g' | xargs -I{} tmux switch-client -t {}
            echo "$target" | xargs -I{} tmux select-window -t {}
        fi
    fi
fi
