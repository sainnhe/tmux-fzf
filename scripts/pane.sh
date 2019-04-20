#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION=$(printf "switch\nlayout\nkill\n[cancel]" | "$CURRENT_DIR/.fzf-tmux")
if [[ "$ACTION" == "[cancel]" ]]; then
    exit
elif [[ "$ACTION" == "layout" ]]; then
    TARGET_ORIGIN=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\n[cancel]" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS")
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        tmux select-layout "$TARGET_ORIGIN"
    fi
else
    TARGET_ORIGIN=$(printf "%s\n[cancel]" "$(tmux list-panes -a  -F '#S:#{window_index}(#{window_name}).#{pane_index}: #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}')" | "$CURRENT_DIR/.fzf-tmux")
    if [[ "$TARGET_ORIGIN" == "[cancel]" ]]; then
        exit
    else
        TARGET=$(echo "$TARGET_ORIGIN" | sed -r -e 's/\(.*\)//g' | grep -o '.*:' | sed -r 's/(.*)(.)$/\1/')
        if [[ "$ACTION" == "switch" ]]; then
            echo "$TARGET" | sed -r 's/:.*//g' | xargs tmux switch-client -t
            echo "$TARGET" | sed -r 's/\..*//g' | xargs tmux select-window -t
            echo "$TARGET" | xargs tmux select-pane -t
        elif [[ "$ACTION" == "kill" ]]; then
            echo "$TARGET" | sort -r | xargs -i tmux kill-pane -t {}
        fi
    fi
fi
