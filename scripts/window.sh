#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_WINDOW_ORIGIN=$(tmux display-message -p '#S:#I: #{window_name}')
CURRENT_WINDOW=$(tmux display-message -p '#S:#I')

if [[ -z "$TMUX_FZF_WINDOW_FORMAT" ]]; then
    WINDOWS=$(tmux list-windows -a)
else
    WINDOWS=$(tmux list-windows -a -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select an action"')

if [[ -z "$1" ]]; then
    ACTION=$(printf "switch\nlink\nmove\nswap\nrename\nkill\n[cancel]" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
else
    ACTION="$1"
fi

[[ "$ACTION" == "[cancel]" || -z "$ACTION" ]] && exit
if [[ "$ACTION" == "link" ]]; then
    CUR_WIN=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    CUR_SES=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
    LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
    WINDOWS=$(echo "$WINDOWS" | grep -v "^$CUR_SES")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select source window"')
    SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$SRC_WIN_ORIGIN" == "[cancel]" || -z "$SRC_WIN_ORIGIN" ]] && exit
    SRC_WIN=$(echo "$SRC_WIN_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    tmux link-window -a -s "$SRC_WIN" -t "$CUR_WIN"
elif [[ "$ACTION" == "move" ]]; then
    CUR_WIN=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    CUR_SES=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
    LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
    WINDOWS=$(echo "$WINDOWS" | grep -v "^$CUR_SES")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select source window"')
    SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    [[ "$SRC_WIN_ORIGIN" == "[cancel]" || -z "$SRC_WIN_ORIGIN" ]] && exit
    SRC_WIN=$(echo "$SRC_WIN_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    tmux move-window -a -s "$SRC_WIN" -t "$CUR_WIN"
else
    if [[ "$ACTION" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select target window(s), press TAB to select multiple targets"')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select target window"')
    fi
    if [[ "$ACTION" != "switch" ]]; then
        TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$WINDOWS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | sed -E "s/\[current\]/$CURRENT_WINDOW_ORIGIN/")
    else
        WINDOWS=$(echo "$WINDOWS" | grep -v "^$CURRENT_WINDOW")
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
    fi
    [[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
    TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    if [[ "$ACTION" == "kill" ]]; then
        echo "$TARGET" | sort -r | xargs -i tmux unlink-window -k -t {}
    elif [[ "$ACTION" == "rename" ]]; then
        tmux command-prompt -I "rename-window -t $TARGET "
    elif [[ "$ACTION" == "swap" ]]; then
        WINDOWS=$(echo "$WINDOWS" | grep -v "^$TARGET")
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -E -e '$a --header="select another target window"')
        TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
        [[ "$TARGET_SWAP_ORIGIN" == "[cancel]" || -z "$TARGET_SWAP_ORIGIN" ]] && exit
        TARGET_SWAP=$(echo "$TARGET_SWAP_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
        tmux swap-pane -s "$TARGET" -t "$TARGET_SWAP"
    elif [[ "$ACTION" == "switch" ]]; then
        echo "$TARGET" | sed 's/:.*//g' | xargs tmux switch-client -t
        echo "$TARGET" | xargs tmux select-window -t
    fi
fi
