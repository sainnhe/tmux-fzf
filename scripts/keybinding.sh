#!/usr/bin/env bash

if [[ "$TMUX_FZF_SED"x == ""x ]]; then
    TMUX_FZF_SED="sed"
fi
FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select a key binding"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    TARGET_ORIGIN=$(tmux list-keys | $TMUX_FZF_SED '1i [cancel]' | "$CURRENT_DIR/.fzf-tmux")
else
    TARGET_ORIGIN=$(tmux list-keys | $TMUX_FZF_SED '1i [cancel]' | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")
fi

if [[ "$TARGET_ORIGIN" == "[cancel]" || "$TARGET_ORIGIN"x == ""x ]]; then
    exit
else
    if [[ $(echo "$TARGET_ORIGIN" | grep -o "copy-mode")x != ""x && $(echo "$TARGET_ORIGIN" | grep -o "prefix")x == x ]]; then
        tmux copy-mode
        echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -r 's/^.{46}//g' | xargs tmux
    else
        echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -r 's/^.{46}//g' | xargs tmux
    fi
fi
