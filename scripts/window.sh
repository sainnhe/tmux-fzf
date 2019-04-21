#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_WINDOW_FORMAT"x == ""x ]]; then
    WINDOWS=$(tmux list-windows -a)
else
    WINDOWS=$(tmux list-windows -a -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

ACTION=$(printf "switch\nrename\nkill\nlink\nunlink\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
if [[ "$ACTION" == "[cancel]" ]]; then
    exit
elif [[ "$ACTION" == "link" ]]; then
    CUR_WIN=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    CUR_SES=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
    LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
    WINDOWS=$(echo "$WINDOWS" | grep -v "^$CUR_SES")
    SRC_WIN_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    if [[ "$SRC_WIN_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        SRC_WIN=$(echo "$SRC_WIN_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
        DST_WIN_ORIGIN=$(printf "after\nend\nbegin\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
        if [[ "$DST_WIN_ORIGIN" == "[cancel]" ]]; then
            exit
        elif [[ "$DST_WIN_ORIGIN" == "after" ]]; then
            tmux link-window -a -s "$SRC_WIN" -t "$CUR_WIN"
        elif [[ "$DST_WIN_ORIGIN" == "end" ]]; then
            ((LAST_WIN_NUM=LAST_WIN_NUM+1))
            tmux link-window -s "$SRC_WIN" -t "$CUR_SES":"$LAST_WIN_NUM"
        elif [[ "$DST_WIN_ORIGIN" == "begin" ]]; then
            ((LAST_WIN_NUM=LAST_WIN_NUM+1))
            tmux link-window -s "$SRC_WIN" -t "$CUR_SES":"$LAST_WIN_NUM"
            tmux swap-window -s "$LAST_WIN_NUM" -t 0
        fi
    fi
elif [[ "$ACTION" == "unlink" ]]; then
    CUR_WIN=$(tmux display-message -p | sed -e 's/^.//' -e 's/] /:/' | grep -o '[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
    tmux unlink-window -k -t "$CUR_WIN"
else
    TARGET_ORIGIN=$(printf "%s\n[cancel]" "$WINDOWS" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*:' | sed 's/.$//g')
        if [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux kill-window -t {}
        elif [[ "$ACTION" == "rename" ]]; then
            tmux command-prompt -I "rename-window -t $TARGET "
        elif [[ "$ACTION" == "switch" ]]; then
            echo "$TARGET" | sed 's/:.*//g' | xargs tmux switch-client -t
            echo "$TARGET" | xargs tmux select-window -t
        fi
    fi
fi
