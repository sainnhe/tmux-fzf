#!/usr/bin/env bash

TMUX_FZF_SED="${TMUX_FZF_SED:-sed}"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get front end list
TMUX_FZF_MENU_ORIGIN=$TMUX_FZF_MENU
FRONT_END_LIST=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | $TMUX_FZF_SED -n '1p')
TMUX_FZF_MENU_ORIGIN=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | $TMUX_FZF_SED '1,2d')
while [[ $(echo -e "$TMUX_FZF_MENU_ORIGIN" | wc -l) != "0" && $(echo -e "$TMUX_FZF_MENU_ORIGIN" | wc -l) != "1" ]]; do
    FRONT_END_LIST="$FRONT_END_LIST\n"$(echo -e "$TMUX_FZF_MENU_ORIGIN" | $TMUX_FZF_SED -n '1p')
    TMUX_FZF_MENU_ORIGIN=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | $TMUX_FZF_SED '1,2d')
done
FRONT_END_LIST=$(echo -e "$FRONT_END_LIST" | $TMUX_FZF_SED '/^[[:space:]]*$/d')

TARGET=$(printf "%s\n[cancel]" "$FRONT_END_LIST" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$TARGET" == "[cancel]" || -z "$TARGET" ]] && exit
# get the next line in $TMUX_FZF_MENU and execute
echo -e "$TMUX_FZF_MENU" | $TMUX_FZF_SED -n "/$TARGET/{n;p;}" | xargs -i tmux -c {}
