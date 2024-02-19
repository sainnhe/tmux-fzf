#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
    if [ -x "$(command -v pstree)" ]; then
        action=$(printf "display\ntree\nterminate\nkill\ninterrupt\ncontinue\nstop\nquit\nhangup\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    else
        action=$(printf "display\nterminate\nkill\ninterrupt\ncontinue\nstop\nquit\nhangup\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
    fi
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit

content_raw="$(ps aux)"
header=$(echo "$content_raw" | head -n 1)
content=$(echo "$content_raw" | sed 1d)
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='$header'"
ps_selected=$(printf "[cancel]\n$content" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
[[ "$ps_selected" == "[cancel]" || -z "$ps_selected" ]] && exit
pid=$(echo "$ps_selected" | awk -F ' ' '{print $2}')
user=$(echo "$ps_selected" | awk -F ' ' '{print $1}')
_kill() { #{{{ _kill SIG PID USER
    if [[ "$3" == "$(whoami)" ]]; then
        kill -s $1 $2
    else
        if [ -x "$(command -v sudo)" ]; then
            tmux split-window -v -l 30% -b -c '#{pane_current_path}' "bash -c 'sudo kill -s $1 $2'"
        elif [ -x "$(command -v doas)" ]; then
            tmux split-window -v -l 30% -b -c '#{pane_current_path}' "bash -c 'doas kill -s $1 $2'"
        fi
    fi
} #}}}
if [[ "$action" == "display" ]]; then
    if [[ "$(uname)" == "Linux" ]]; then
        tmux split-window -v -l 50% -b -c '#{pane_current_path}' "top -p $pid"
    else
        tmux split-window -v -l 50% -b -c '#{pane_current_path}' "top -pid $pid"
    fi
elif [[ "$action" == "tree" ]]; then
    pstree -p "$pid"
elif [[ "$action" == "terminate" ]]; then
    _kill TERM $pid $user
elif [[ "$action" == "kill" ]]; then
    _kill KILL $pid $user
elif [[ "$action" == "interrupt" ]]; then
    _kill INT $pid $user
elif [[ "$action" == "continue" ]]; then
    _kill CONT $pid $user
elif [[ "$action" == "stop" ]]; then
    _kill STOP $pid $user
elif [[ "$action" == "quit" ]]; then
    _kill QUIT $pid $user
elif [[ "$action" == "hangup" ]]; then
    _kill HUP $pid $user
fi
