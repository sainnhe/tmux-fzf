#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -x "$(command -v copyq)" ]; then
  copyq &>/dev/null &
fi

tmux_fzf_launch_key_option="$(tmux show-option -gqv @tmux-fzf-launch-key)"

if [ -z "$TMUX_FZF_LAUNCH_KEY" ]; then
  if [ -n "$tmux_fzf_launch_key_option" ]; then
    TMUX_FZF_LAUNCH_KEY="$tmux_fzf_launch_key_option"
  else
    TMUX_FZF_LAUNCH_KEY="F"
  fi
fi

tmux bind-key "$TMUX_FZF_LAUNCH_KEY" run-shell -b "$CURRENT_DIR/main.sh"
