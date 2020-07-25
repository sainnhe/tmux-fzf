#!/usr/bin/env bash

TMUX_FZF_SED="${TMUX_FZF_SED:-sed}"
FZF_DEFAULT_OPTS=$(echo $FZF_DEFAULT_OPTS | $TMUX_FZF_SED -E -e '$a --header="select a key binding"')
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_ORIGIN=$(tmux list-keys | $TMUX_FZF_SED '1i [cancel]' | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS")

[[ "$TARGET_ORIGIN" == "[cancel]" || -z "$TARGET_ORIGIN" ]] && exit
if [[ -n $(echo "$TARGET_ORIGIN" | grep -o "copy-mode") && -z $(echo "$TARGET_ORIGIN" | grep -o "prefix") ]]; then
    tmux copy-mode
    echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -E 's/^.{46}//g' | xargs tmux
else
    echo "$TARGET_ORIGIN" | $TMUX_FZF_SED -E 's/^.{46}//g' | xargs tmux
fi
