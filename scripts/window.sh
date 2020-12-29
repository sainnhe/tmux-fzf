#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/../settings.sh"

current_window_origin=$(tmux display-message -p '#S:#I: #{window_name}')
current_window=$(tmux display-message -p '#S:#I')
if [[ -z "$TMUX_FZF_WINDOW_FORMAT" ]]; then
    windows=$(tmux list-windows -a)
else
    windows=$(tmux list-windows -a -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select an action."')

if [[ -z "$1" ]]; then
    action=$(printf "switch\nlink\nmove\nswap\nrename\nkill\n[cancel]" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit
if [[ "$action" == "link" ]]; then
    cur_win=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    cur_ses=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
    last_win_num=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
    windows=$(echo "$windows" | grep -v "^$cur_ses")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select source window."')
    src_win_origin=$(printf "%s\n[cancel]" "$windows" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$src_win_origin" == "[cancel]" || -z "$src_win_origin" ]] && exit
    src_win=$(echo "$src_win_origin" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    tmux link-window -a -s "$src_win" -t "$cur_win"
elif [[ "$action" == "move" ]]; then
    cur_win=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    cur_ses=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
    last_win_num=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
    windows=$(echo "$windows" | grep -v "^$cur_ses")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select source window."')
    src_win_origin=$(printf "%s\n[cancel]" "$windows" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$src_win_origin" == "[cancel]" || -z "$src_win_origin" ]] && exit
    src_win=$(echo "$src_win_origin" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    tmux move-window -a -s "$src_win" -t "$cur_win"
else
    if [[ "$action" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select target window(s). Press TAB to mark multiple items."')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select target window."')
    fi
    if [[ "$action" != "switch" ]]; then
        target_origin=$(printf "[current]\n%s\n[cancel]" "$windows" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_window_origin/")
    else
        windows=$(echo "$windows" | grep -v "^$current_window")
        target_origin=$(printf "%s\n[cancel]" "$windows" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    fi
    [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
    target=$(echo "$target_origin" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    if [[ "$action" == "kill" ]]; then
        echo "$target" | sort -r | xargs -i tmux unlink-window -k -t {}
    elif [[ "$action" == "rename" ]]; then
        tmux command-prompt -I "rename-window -t $target "
    elif [[ "$action" == "swap" ]]; then
        windows=$(echo "$windows" | grep -v "^$target")
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="Select another target window."')
        target_swap_origin=$(printf "%s\n[cancel]" "$windows" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        [[ "$target_swap_origin" == "[cancel]" || -z "$target_swap_origin" ]] && exit
        target_swap=$(echo "$target_swap_origin" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
        tmux swap-pane -s "$target" -t "$target_swap"
    elif [[ "$action" == "switch" ]]; then
        echo "$target" | sed 's/:.*//g' | xargs tmux switch-client -t
        echo "$target" | xargs tmux select-window -t
    fi
fi
