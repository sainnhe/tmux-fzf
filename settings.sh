get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

[ -z "$TMUX_FZF_LAUNCH_KEY" ] && TMUX_FZF_LAUNCH_KEY=$(get_tmux_option "@tmux-fzf-launch-key" "F")
[ -z "$TMUX_FZF_OPTIONS" ] && TMUX_FZF_OPTIONS=$(get_tmux_option "@tmux-fzf-options" "")
[ -z "$TMUX_FZF_POPUP" ] && TMUX_FZF_POPUP=$(get_tmux_option "@tmux-fzf-popup" "")
[ -z "$TMUX_FZF_POPUP_HEIGHT" ] && TMUX_FZF_POPUP_HEIGHT=$(get_tmux_option "@tmux-fzf-popup-height" "38%")
[ -z "$TMUX_FZF_POPUP_WIDTH" ] && TMUX_FZF_POPUP_WIDTH=$(get_tmux_option "@tmux-fzf-popup-width" "62%")
[ -z "$TMUX_FZF_ORDER" ] && TMUX_FZF_ORDER=$(get_tmux_option "@tmux-fzf-order" "session|window|pane|command|keybinding|clipboard")
[ -z "$TMUX_FZF_SESSION_FORMAT" ] && TMUX_FZF_SESSION_FORMAT=$(get_tmux_option "@tmux-fzf-session-format" "")
[ -z "$TMUX_FZF_WINDOW_FORMAT" ] && TMUX_FZF_WINDOW_FORMAT=$(get_tmux_option "@tmux-fzf-window-format" "")
[ -z "$TMUX_FZF_PANE_FORMAT" ] && TMUX_FZF_PANE_FORMAT=$(get_tmux_option "@tmux-fzf-pane-format" "")
[ -z "$TMUX_FZF_MENU" ] && TMUX_FZF_MENU=$(get_tmux_option "@tmux-fzf-menu" "")

TMUX_VERSION=$(tmux -V | grep -oE '[0-9]+\.[0-9]*')
version='3.1'
if [ ${TMUX_VERSION%.*} -eq ${version%.*} ] && [ ${TMUX_VERSION#*.} \> ${version#*.} ] || [ ${TMUX_VERSION%.*} -gt ${version%.*} ]; then
  TMUX_FZF_POPUP="${TMUX_FZF_POPUP:-1}"
else
  TMUX_FZF_POPUP="${TMUX_FZF_POPUP:-0}"
fi
