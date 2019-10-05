#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get front end list
TMUX_FZF_MENU_ORIGIN=$TMUX_FZF_MENU
FRONT_END_LIST=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | sed -n '1p')
TMUX_FZF_MENU_ORIGIN=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | sed '1,2d')
while [[ $(echo -e "$TMUX_FZF_MENU_ORIGIN" | wc -l) != "0" && $(echo -e "$TMUX_FZF_MENU_ORIGIN" | wc -l) != "1" ]]; do
    FRONT_END_LIST="$FRONT_END_LIST\n"$(echo -e "$TMUX_FZF_MENU_ORIGIN" | sed -n '1p')
    TMUX_FZF_MENU_ORIGIN=$(echo -e "$TMUX_FZF_MENU_ORIGIN" | sed '1,2d')
done
FRONT_END_LIST=$(echo -e "$FRONT_END_LIST" | sed '/^[[:space:]]*$/d')

if [[ "$TMUX_FZF_OPTIONS"x == ""x ]]; then
    TARGET=$(printf "[cancel]\n%s" "$FRONT_END_LIST" | "$CURRENT_DIR/.fzf-tmux" | grep -o '^[^[:blank:]]*')
else
    TARGET=$(printf "%s\n[cancel]" "$FRONT_END_LIST" | "$CURRENT_DIR/.fzf-tmux" "$TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')
fi

if [[ "$TARGET" == "[cancel]" ]]; then
    exit
else
    # get the next line in $TMUX_FZF_MENU and execute
    echo -e "$TMUX_FZF_MENU" | sed -n "/$TARGET/{n;p;}" | xargs -i tmux -c {}
fi
