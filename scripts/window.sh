#!/usr/bin/env bash

if [[ "$TMUX_FZF_SED"x == ""x ]]; then
    TMUX_FZF_SED="sed"
fi
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_WINDOW_ORIGIN=$(tmux display-message -p '#S:#I: #{window_name}')
CURRENT_WINDOW=$(tmux display-message -p '#S:#I')

if [[ "$TMUX_FZF_WINDOW_FORMAT"x == ""x ]]; then
    WINDOWS=$(tmux list-windows -a)
else
    WINDOWS=$(tmux list-windows -a -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select an action"')

if [[ "$1"x == ""x ]]; then
    if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
        ACTION=$(printf "switch\nlink\nmove\nswap\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
    else
        ACTION=$(printf "switch\nlink\nmove\nswap\nrename\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
else
    ACTION="$1"
fi

if [[ "$ACTION" == "[cancel]" ]]; then
    exit
elif [[ "$ACTION" == "link" ]]; then
    CUR_WIN=$(tmux display-message -p | $TMUX_FZF_SED -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
    CUR_SES=$(tmux display-message -p | $TMUX_FZF_SED -e 's/^.//' -e 's/].*//')
    LAST_WIN_NUM=$(tmux list-windows | sort -r | $TMUX_FZF_SED '2,$d' | $TMUX_FZF_SED 's/:.*//')
    WINDOWS=$(echo "$WINDOWS" | grep -v "^$CUR_SES")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select source window"')
    if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
        SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux")
    else
        SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
    if [[ "$SRC_WIN_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        SRC_WIN=$(echo "$SRC_WIN_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
        tmux link-window -a -s "$SRC_WIN" -t "$CUR_WIN"
    fi
elif [[ "$ACTION" == "move" ]]; then
    CUR_WIN=$(tmux display-message -p | $TMUX_FZF_SED -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
    CUR_SES=$(tmux display-message -p | $TMUX_FZF_SED -e 's/^.//' -e 's/].*//')
    LAST_WIN_NUM=$(tmux list-windows | sort -r | $TMUX_FZF_SED '2,$d' | $TMUX_FZF_SED 's/:.*//')
    WINDOWS=$(echo "$WINDOWS" | grep -v "^$CUR_SES")
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select source window"')
    if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
        SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux")
    else
        SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
    if [[ "$SRC_WIN_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        SRC_WIN=$(echo "$SRC_WIN_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
        tmux move-window -a -s "$SRC_WIN" -t "$CUR_WIN"
    fi
else
    if [[ "$ACTION" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select target window(s), press TAB to select multiple targets"')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select target window"')
    fi
    if [[ "$ACTION" != "switch" ]]; then
        if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
            TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux")
        else
            TARGET_ORIGIN=$(printf "[current]\n%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
        fi
        TARGET_ORIGIN=$(echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -r "s/\[current\]/$CURRENT_WINDOW_ORIGIN/")
    else
        WINDOWS=$(echo "$WINDOWS" | grep -v "^$CURRENT_WINDOW")
        if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
            TARGET_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux")
        else
            TARGET_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
        fi
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
        if [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux unlink-window -k -t {}
        elif [[ "$ACTION" == "rename" ]]; then
            tmux command-prompt -I "rename-window -t $TARGET "
        elif [[ "$ACTION" == "swap" ]]; then
            WINDOWS=$(echo "$WINDOWS" | grep -v "^$TARGET")
            FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select another target window"')
            if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
                TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux")
            else
                TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
            fi
            if [[ "$TARGET_SWAP_ORIGIN" == "[cancel]" ]]; then
                exit
            else
                TARGET_SWAP=$(echo "$TARGET_SWAP_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | $TMUX_FZF_SED 's/.$//g')
                tmux swap-pane -s "$TARGET" -t "$TARGET_SWAP"
            fi
        elif [[ "$ACTION" == "switch" ]]; then
            echo "$TARGET" | $TMUX_FZF_SED 's/:.*//g' | xargs tmux switch-client -t
            echo "$TARGET" | xargs tmux select-window -t
        fi
    fi
fi
