#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

# get front end list
tmux_fzf_menu_origin=$TMUX_FZF_MENU
front_end_list=$(echo -e "$tmux_fzf_menu_origin" | head -1 )$'\n'
tmux_fzf_menu_origin=$(echo -e "$tmux_fzf_menu_origin" | tail -n +3 )
while [ $(echo -ne "$tmux_fzf_menu_origin" | wc -l ) -ge 2 ]; do
    front_end_list+=$(echo  "$tmux_fzf_menu_origin" | head -1)$'\n'
    tmux_fzf_menu_origin=$(echo  "$tmux_fzf_menu_origin" | tail -n +3)$'\n'
done

target=$(printf "%s[cancel]" "$front_end_list" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
# get the next line in $TMUX_FZF_MENU and execute
echo -e "$TMUX_FZF_MENU" | sed -n "/$target/{n;p;}" | xargs -I{} tmux -c {}
