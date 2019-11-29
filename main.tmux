#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/settings.sh"

set_launch_bindings() {
	local key_bindings=$(get_tmux_option "$launch_key" "$default_launch_key")
	local key
	for key in $key_bindings; do
		tmux bind-key "$key" run-shell -b "$CURRENT_DIR/main.sh"
	done
}

set_launch_bindings
