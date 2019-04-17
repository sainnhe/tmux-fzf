#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux run-shell "$CURRENT_DIR/scripts/$(ls $CURRENT_DIR/scripts | sed -r 's/(.*).{3}$/\1/' | $CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS | sed 's/$/.sh/')"
