#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -x "$(command -v copyq)" ]; then
  copyq &>/dev/null &
fi

[ -z "$TMUX_FZF_LAUNCH_KEY" ] && TMUX_FZF_LAUNCH_KEY="F"
tmux bind-key "$TMUX_FZF_LAUNCH_KEY" run-shell -b "$CURRENT_DIR/main.sh"
