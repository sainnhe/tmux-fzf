#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux list-keys | grep -v 'copy-mode' | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | sed -r 's/^.{46}//g' | xargs tmux
