#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"
source "$CURRENT_DIR/.utils"

current_pane_origin=$(tmux display-message -p '#S:#{window_index}.#{pane_index}: #{window_name}')
current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

if [[ -z "$TMUX_FZF_PANE_FORMAT" ]]; then
    panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_title}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}")
else
    panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: $TMUX_FZF_PANE_FORMAT")
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
    action=$(printf "switch\nzoom\nbreak\njoin\nswap\nlayout\nkill\nresize\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit

# layout and resize have sub-menus, no target needed
if [[ "$action" == "layout" ]]; then
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select a layout.'"
    target_origin=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
    tmux select-layout "$target_origin"
elif [[ "$action" == "resize" ]]; then
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select direction.'"
    target_origin=$(printf "left\nright\nup\ndown\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
    if [[ "$target_origin" == "left" || "$target_origin" == "right" ]]; then
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Cells to be adjusted.'"
        size=$(printf "1\n2\n3\n5\n10\n20\n30\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
        [[ "$size" == "[cancel]" || -z "$size" ]] && exit
        if [[ "$target_origin" == "left" ]]; then
            tmux resize-pane -L "$size"
        else
            tmux resize-pane -R "$size"
        fi
    elif [[ "$target_origin" == "up" || "$target_origin" == "down" ]]; then
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Lines to be adjusted.'"
        size=$(printf "1\n2\n3\n5\n10\n15\n20\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
        [[ "$size" == "[cancel]" || -z "$size" ]] && exit
        if [[ "$target_origin" == "up" ]]; then
            tmux resize-pane -U "$size"
        else
            tmux resize-pane -D "$size"
        fi
    fi
# Support $2 as pre-selected target (for unified.sh integration)
elif [[ -n "$2" ]]; then
    # Handle [current] special case
    if [[ "$2" == "[current]" ]]; then
        target="$current_pane"
    else
        target="$2"
    fi
    # Execute based on action with pre-selected target
    if [[ "$action" == "switch" ]]; then
        echo "$target" | sed -E 's/:.*//g' | xargs -I{} tmux switch-client -t {}
        echo "$target" | sed -E 's/\..*//g' | xargs -I{} tmux select-window -t {}
        echo "$target" | xargs -I{} tmux select-pane -t {}
    elif [[ "$action" == "kill" ]]; then
        tmux kill-pane -t "$target"
    elif [[ "$action" == "swap" ]]; then
        target_swap=$(select_swap_target "$panes" "$target" "Select another target pane.") || exit
        tmux swap-pane -s "$target" -t "$target_swap"
    elif [[ "$action" == "join" ]]; then
        tmux move-pane -s "$target"
    elif [[ "$action" == "break" ]]; then
        break_pane_to_window "$target"
    elif [[ "$action" == "zoom" ]]; then
        tmux resize-pane -Z -t "$target"
    fi
else
    # Original fzf selection logic
    if [[ "$action" == "join" || "$action" == "kill" ]]; then
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target pane(s). Press TAB to mark multiple items.'"
    else
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target pane.'"
    fi
    if [[ "$action" == "switch" || "$action" == "join" ]]; then
        if [[ -z "$TMUX_FZF_SWITCH_CURRENT" || "$action" == "join" ]]; then
            panes=$(echo "$panes" | grep -v "^$current_pane")
        fi
        target_origin=$(printf "%s\n[cancel]" "$panes" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
    else
        target_origin=$(printf "[current]\n%s\n[cancel]" "$panes" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
        target_origin=${target_origin/\[current\]/$current_pane_origin}
    fi
    [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
    target=$(echo "$target_origin" | sed 's/: .*//')
    if [[ "$action" == "switch" ]]; then
        echo "$target" | sed -E 's/:.*//g' | xargs -I{} tmux switch-client -t {}
        echo "$target" | sed -E 's/\..*//g' | xargs -I{} tmux select-window -t {}
        echo "$target" | xargs -I{} tmux select-pane -t {}
    elif [[ "$action" == "kill" ]]; then
        echo "$target" | sort -r | xargs -I{} tmux kill-pane -t {}
    elif [[ "$action" == "zoom" ]]; then
        tmux resize-pane -Z -t "$target"
    elif [[ "$action" == "swap" ]]; then
        target_swap=$(select_swap_target "$panes" "$target" "Select another target pane.") || exit
        tmux swap-pane -s "$target" -t "$target_swap"
    elif [[ "$action" == "join" ]]; then
        echo "$target" | sort -r | xargs -I{} tmux move-pane -s {}
    elif [[ "$action" == "break" ]]; then
        break_pane_to_window "$target"
    fi
fi
