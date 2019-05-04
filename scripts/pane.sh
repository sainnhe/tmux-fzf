#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_PANE_FORMAT"x == ""x ]]; then
    PANES=$(tmux list-panes -a)
else
    PANES=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: $TMUX_FZF_PANE_FORMAT")
fi

FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select an action"')
if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    ACTION=$(printf "switch\nbreak\njoin\nswap\nlayout\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
else
    ACTION=$(printf "switch\nbreak\njoin\nswap\nlayout\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
fi

if [[ "$ACTION" == "[cancel]" ]]; then
    exit
elif [[ "$ACTION" == "layout" ]]; then
    FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select a layout"')
    if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
        TARGET_ORIGIN=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
    else
        TARGET_ORIGIN=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        tmux select-layout "$TARGET_ORIGIN"
    fi
else
    if [[ "$ACTION" == "join" || "$ACTION" == "kill" ]]; then
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select target pane(s), press TAB to select multiple targets"')
    else
        FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select target pane"')
    fi
    if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | "$CURRENT_DIR/.fzf-tmux")
    else
        TARGET_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    fi
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*\.[[:digit:]]*:' | sed 's/.$//g')
        if [[ "$ACTION" == "switch" ]]; then
            echo "$TARGET" | sed -r 's/:.*//g' | xargs tmux switch-client -t
            echo "$TARGET" | sed -r 's/\..*//g' | xargs tmux select-window -t
            echo "$TARGET" | xargs tmux select-pane -t
        elif [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux kill-pane -t {}
        elif [[ "$ACTION" == "swap" ]]; then
            PANES=$(echo "$PANES" | grep -v "^$TARGET")
            FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select another target pane"')
            if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
                TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | "$CURRENT_DIR/.fzf-tmux")
            else
                TARGET_SWAP_ORIGIN=$(printf "%s\n[cancel]" "$PANES" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
            fi
            if [[ "$TARGET_SWAP_ORIGIN" == "[cancel]" ]]; then
                exit
            else
                TARGET_SWAP=$(echo "$TARGET_SWAP_ORIGIN" | grep -o '^[[:alpha:]|[:digit:]]*:[[:digit:]]*\.[[:digit:]]*:' | sed 's/.$//g')
                tmux swap-pane -s "$TARGET" -t "$TARGET_SWAP"
            fi
        elif [[ "$ACTION" == "join" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux move-pane -s {}
        elif [[ "$ACTION" == "break" ]]; then
            FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | sed -r -e '$a --header="select destination"')
            if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
                DST_WIN=$(printf "after\nend\nbegin\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
            else
                DST_WIN=$(printf "after\nend\nbegin\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
            fi
            CUR_WIN_NUM=$(tmux display-message -p | grep -o '[[[:alpha:]|[:digit:]]*] [[:digit:]]*:' | sed -e 's/\[.*\] //' -e 's/.$//')
            CUR_SES=$(tmux display-message -p | sed -e 's/^.//' -e 's/].*//')
            LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
            ((LAST_WIN_NUM_AFTER = LAST_WIN_NUM + 1))
            ((CUR_WIN_NUM_AFTER = CUR_WIN_NUM + 1))
            if [[ "$DST_WIN" == "after" ]]; then
                tmux break-pane -s "$TARGET" -t "$CUR_SES":"$LAST_WIN_NUM_AFTER"
                tmux new-window -a -t "$CUR_SES":"$CUR_WIN_NUM"
                LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
                tmux swap-window -s "$CUR_SES":"$LAST_WIN_NUM" -t "$CUR_SES":"$CUR_WIN_NUM_AFTER"
                tmux kill-window -t "$CUR_SES":"$LAST_WIN_NUM"
            elif [[ "$DST_WIN" == "end" ]]; then
                tmux break-pane -s "$TARGET" -t "$CUR_SES":"$LAST_WIN_NUM_AFTER"
            elif [[ "$DST_WIN" == "begin" ]]; then
                tmux break-pane -s "$TARGET" -t "$CUR_SES":"$LAST_WIN_NUM_AFTER"
                tmux new-window -a -t "$CUR_SES":0
                LAST_WIN_NUM=$(tmux list-windows | sort -r | sed '2,$d' | sed 's/:.*//')
                tmux swap-window -s "$CUR_SES":"$LAST_WIN_NUM" -t "$CUR_SES":1
                tmux swap-window -s "$CUR_SES":1 -t "$CUR_SES":0
                tmux kill-window -t "$CUR_SES":"$LAST_WIN_NUM"
            fi
        fi
    fi
fi
