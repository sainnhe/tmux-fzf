#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled" | $CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS | xargs tmux select-layout 

