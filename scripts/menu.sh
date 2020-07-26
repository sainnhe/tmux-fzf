#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get front end list
tmux_fzf_menu_origin=$TMUX_FZF_MENU
front_end_list=$(echo -e "$tmux_fzf_menu_origin" | sed -n '1p')
tmux_fzf_menu_origin=$(echo -e "$tmux_fzf_menu_origin" | sed '1,2d')
while [[ $(echo -e "$tmux_fzf_menu_origin" | wc -l) != "0" && $(echo -e "$tmux_fzf_menu_origin" | wc -l) != "1" ]]; do
    front_end_list="$front_end_list\n"$(echo -e "$tmux_fzf_menu_origin" | sed -n '1p')
    tmux_fzf_menu_origin=$(echo -e "$tmux_fzf_menu_origin" | sed '1,2d')
done
front_end_list=$(echo -e "$front_end_list" | sed '/^[[:space:]]*$/d')

target=$(printf "%s\n[cancel]" "$front_end_list" | eval "$CURRENT_DIR/.fzf-tmux $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
# get the next line in $TMUX_FZF_MENU and execute
echo -e "$TMUX_FZF_MENU" | sed -n "/$target/{n;p;}" | xargs -i tmux -c {}
