#!/usr/bin/env bash

if [[ "$TMUX_FZF_SED"x == ""x ]]; then
    TMUX_FZF_SED="sed"
fi
FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -r -e '$a --header="select a command"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_ORIGIN=$(tmux list-commands)
if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    TARGET=$(printf "[cancel]\n%s" "$TARGET_ORIGIN" | "$CURRENT_DIR/.fzf-tmux" | grep -o '^[^[:blank:]]*')
else
    TARGET=$(printf "[cancel]\n%s" "$TARGET_ORIGIN" | bash -c "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')
fi

if [[ "$TARGET" == "[cancel]" || "$TARGET"x == ""x ]]; then
    exit
else
    tmux command-prompt -I "$TARGET"
fi
