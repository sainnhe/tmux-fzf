#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
  action=$(printf "display\n$([ -x "$(command -v pstree)" ] && printf %s 'tree\n')terminate\nkill\ninterrupt\ncontinue\nstop\nquit\nhangup\n[cancel]"| eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit

content_raw="$(ps aux)"
header=$(echo "$content_raw" | head -n 1)
content=$(echo "$content_raw" | sed 1d)
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='$header'"
ps_selected=$(printf "[cancel]\n%s" "$content" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
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

case "$action" in
    display)
    if [[ $(uname) = Linux ]]; then
        tmux split-window -v -l 50% -b -c '#{pane_current_path}' "top -p $pid"
    else
        tmux split-window -v -l 50% -b -c '#{pane_current_path}' "top -pid $pid"
    fi
        ;;
    tree)
        pstree -p "$pid"
        ;;
    terminate)
        _kill TERM $pid $user
        ;;
    kill)
        _kill KILL $pid $user
        ;;
    interrupt)
        _kill INT $pid $user
        ;;
    continue)
        _kill CONT $pid $user
        ;;
    stop)
        _kill STOP $pid $user
        ;;
    quit)
        _kill QUIT $pid $user
        ;;
    hangup)
        _kill HUP $pid $user
        ;;
esac
