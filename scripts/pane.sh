#!/usr/bin/env bash

TMUX_FZF_SED="${TMUX_FZF_SED:-sed}"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_PANE_ORIGIN=$(tmux display-message -p '#S:#{window_index}.#{pane_index}: #{window_name}')
CURRENT_PANE=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

if [[ -z "$TMUX_FZF_PANE_FORMAT" ]]; then
    PANES=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{window_name}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}")
else
    PANES=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: $TMUX_FZF_PANE_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select an action"')
if [[ -z "$1" ]]; then
    ACTION=$(printf "switch\nbreak\njoin\nswap\nlayout\nkill\nresize\n[cancel]" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
else
    ACTION="$1"
fi

[[ "$ACTION" == "[cancel]" || -z "$ACTION" ]] && exit
if [[ "$ACTION" == "layout" ]]; then
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select a layout"')
    TARGET_ORIGIN=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\n[cancel]" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
    tmux select-layout "$TARGET_ORIGIN"
elif [[ "$ACTION" == "resize" ]]; then
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select direction"')
    TARGET_ORIGIN=$(printf "left\nright\nup\ndown\n[cancel]" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
    if [[ "$TARGET_ORIGIN" == "left" || "$TARGET_ORIGIN" == "right" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="cells to be adjusted"')
        SIZE=$(printf "1\n2\n3\n5\n10\n20\n30\n[cancel]" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        [[ "$SIZE" == "[cancel]" || -z "$SIZE" ]] && exit
        if [[ "$TARGET_ORIGIN" == "left" ]]; then
            tmux resize-pane -L "$SIZE"
        else
            tmux resize-pane -R "$SIZE"
        fi
    elif [[ "$TARGET_ORIGIN" == "up" || "$TARGET_ORIGIN" == "down" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="lines to be adjusted"')
        SIZE=$(printf "1\n2\n3\n5\n10\n15\n20\n[cancel]" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        [[ "$SIZE" == "[cancel]" || -z "$SIZE" ]] && exit
        if [[ "$TARGET_ORIGIN" == "up" ]]; then
            tmux resize-pane -U "$SIZE"
        else
            tmux resize-pane -D "$SIZE"
        fi
    fi
else
    if [[ "$ACTION" == "join" || "$ACTION" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select target pane(s), press TAB to select multiple targets"')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select target pane"')
    fi
    if [[ "$ACTION" == "switch" || "$ACTION" == "join" ]]; then
        PANES=$(echo "$PANES" | grep -v "^$CURRENT_PANE")
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    else
        TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$PANES" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -r "s/\[current\]/$CURRENT_PANE_ORIGIN/")
    fi
    [[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
    TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*\.[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
    if [[ "$ACTION" == "switch" ]]; then
        echo "$TARGET" | $TMUX_FZF_SED -r 's/:.*//g' | xargs tmux switch-client -t
        echo "$TARGET" | $TMUX_FZF_SED -r 's/\..*//g' | xargs tmux select-window -t
        echo "$TARGET" | xargs tmux select-pane -t
    elif [[ "$ACTION" == "kill" ]]; then
        echo "$TARGET" | sort -r | xargs -i tmux kill-pane -t {}
    elif [[ "$ACTION" == "swap" ]]; then
        PANES=$(echo "$PANES" | grep -v "^$TARGET")
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select another target pane"')
        TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        [[ "$TARGET_SWAP_ORIGIN" == "[cancel]" || -z "$TARGET_SWAP_ORIGIN" ]] && exit
        TARGET_SWAP=$(echo "$TARGET_SWAP_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*\.[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
        tmux swap-pane -s "$TARGET" -t "$TARGET_SWAP"
    elif [[ "$ACTION" == "join" ]]; then
        echo "$TARGET" | sort -r | xargs -i tmux move-pane -s {}
    elif [[ "$ACTION" == "break" ]]; then
        CUR_SES=$(tmux display-message -p | $TMUX_FZF_SED -e 's/^.//' -e 's/].*//')
        LAST_WIN_NUM=$(tmux list-windows | sort -r | $TMUX_FZF_SED '2,$d' | $TMUX_FZF_SED 's/:.*//')
        ((LAST_WIN_NUM_AFTER = LAST_WIN_NUM + 1))
        tmux break-pane -s "$TARGET" -t "$CUR_SES":"$LAST_WIN_NUM_AFTER"
    fi
fi
