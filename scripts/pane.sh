#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

current_pane_origin=$(tmux display-message -p '#S:#{window_index}.#{pane_index}: #{window_name}')
current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

if [[ -z "$TMUX_FZF_PANE_FORMAT" ]]; then
    panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_title}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}")
else
    panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: $TMUX_FZF_PANE_FORMAT")
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
    action=$(printf "switch\nbreak\njoin\nswap\nlayout\nkill\nresize\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit
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
else
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
    elif [[ "$action" == "swap" ]]; then
        panes=$(echo "$panes" | grep -v "^$target")
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select another target pane.'"
        target_swap_origin=$(printf "%s\n[cancel]" "$panes" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
        [[ "$target_swap_origin" == "[cancel]" || -z "$target_swap_origin" ]] && exit
        target_swap=$(echo "$target_swap_origin" | sed 's/: .*//')
        tmux swap-pane -s "$target" -t "$target_swap"
    elif [[ "$action" == "join" ]]; then
        echo "$target" | sort -r | xargs -I{} tmux move-pane -s {}
    elif [[ "$action" == "break" ]]; then
        cur_ses=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
        last_win_num=$(tmux list-windows | sort -nr | head -1 | sed 's/:.*//')
        ((last_win_num_after = last_win_num + 1))
        tmux break-pane -s "$target" -t "$cur_ses":"$last_win_num_after"
    fi
fi
