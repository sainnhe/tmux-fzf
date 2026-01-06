#!/usr/bin/env bash
# Unified Command Palette - flat search for all tmux commands
# Usage: bind-key P run-shell -b "path/to/unified.sh"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

# Get current context
current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#S:#I')
current_pane=$(tmux display-message -p '#S:#{window_index}.#{pane_index}')

generate_candidates() {
    # ========== Session commands ==========
    # new session (no target)
    echo "[ses] new  # create new session"

    # session × actions
    tmux list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}' 2>/dev/null | while IFS='|' read -r name wins attached; do
        local mark=""
        [[ "$attached" == "1" ]] && mark="*"
        # Direct execution
        echo "[ses] switch $name  # $mark ($wins win)"
        echo "[ses] kill $name  # $mark"
        echo "[ses] detach $name  # $mark"
        # Interactive (rename needs input)
        echo "[ses] rename $name  # $mark -> input new name"
    done

    # [current] session
    echo "[ses] rename [current]  # -> input new name"

    # ========== Window commands ==========
    # new window (no target)
    echo "[win] new  # create new window"
    echo "[win] split-h  # split horizontal"
    echo "[win] split-v  # split vertical"

    # window × actions
    tmux list-windows -a -F '#{session_name}:#{window_index}|#{window_name}|#{window_active}' 2>/dev/null | while IFS='|' read -r target wname active; do
        local mark=""
        [[ "$active" == "1" ]] && mark="*"
        # Direct execution
        echo "[win] switch $target  # $wname $mark"
        echo "[win] kill $target  # $wname"
        # Interactive
        echo "[win] rename $target  # $wname -> input new name"
        echo "[win] swap $target  # $wname -> select another"
    done

    # [current] window
    echo "[win] rename [current]  # -> input new name"
    echo "[win] kill [current]"
    echo "[win] swap [current]  # -> select another"

    # link/move (original fzf flow)
    echo "[win] link  # -> select source window"
    echo "[win] move  # -> select source window"

    # ========== Pane commands ==========
    # pane × actions
    tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_active}' 2>/dev/null | while IFS='|' read -r target pcmd active; do
        local mark=""
        [[ "$active" == "1" ]] && mark="*"
        # Direct execution
        echo "[pane] switch $target  # $pcmd $mark"
        echo "[pane] kill $target  # $pcmd"
        echo "[pane] zoom $target  # $pcmd"
        echo "[pane] break $target  # $pcmd -> new window"
        # Interactive
        echo "[pane] swap $target  # $pcmd -> select another"
        echo "[pane] join $target  # $pcmd -> move here"
    done

    # [current] pane
    echo "[pane] zoom [current]"
    echo "[pane] kill [current]"
    echo "[pane] break [current]  # -> new window"
    echo "[pane] swap [current]  # -> select another"

    # layout/resize (sub-menu, no target)
    echo "[pane] layout  # -> select layout"
    echo "[pane] resize  # -> select direction & size"
}

# Create preview script
preview_script=$(cat << 'PREVIEW_SCRIPT'
#!/usr/bin/env bash
line="$1"
# Extract target (word after action)
target=$(echo "$line" | sed 's/^\[[^]]*\] [^ ]* //' | sed 's/  #.*//' | awk '{print $1}')
if [[ -n "$target" && "$target" != "#" ]]; then
    if [[ "$target" == "[current]" ]]; then
        tmux capture-pane -ep 2>/dev/null
    elif [[ "$target" == *"."* ]]; then
        # Pane target (session:window.pane)
        tmux capture-pane -ep -t "$target" 2>/dev/null
    elif [[ "$target" == *":"* ]]; then
        # Window target (session:window)
        tmux capture-pane -ep -t "$target" 2>/dev/null
    else
        # Session target
        tmux capture-pane -ep -t "$target:" 2>/dev/null
    fi
else
    echo "Command: $line"
fi
PREVIEW_SCRIPT
)

preview_file=$(mktemp "/tmp/tmux-fzf-unified-preview-XXXXXX.sh")
echo "$preview_script" > "$preview_file"
chmod +x "$preview_file"

# Set header
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Tmux Command Palette  [ses] [win] [pane]'"

# Determine preview options
if [[ "$TMUX_FZF_PREVIEW" != "0" ]]; then
    preview_opts="--preview='$preview_file {}'"
else
    preview_opts=""
fi

# Run fzf and get selection
selected=$(generate_candidates | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $preview_opts")

# Cleanup
rm -f "$preview_file"

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Parse selection: [type] action target  # comment
type=$(echo "$selected" | grep -oE '^\[[^]]+\]')
rest=$(echo "$selected" | sed 's/^\[[^]]*\] //' | sed 's/  #.*//')
action=$(echo "$rest" | awk '{print $1}')
target=$(echo "$rest" | awk '{print $2}')

# Dispatch based on type and action
case "$type" in
    "[ses]")
        case "$action" in
            switch)
                tmux switch-client -t "$target"
                ;;
            kill)
                tmux kill-session -t "$target"
                ;;
            detach)
                tmux detach -s "$target"
                ;;
            rename)
                # Call original script with action and target
                "$CURRENT_DIR/session.sh" rename "$target"
                ;;
            new)
                "$CURRENT_DIR/session.sh" new
                ;;
        esac
        ;;
    "[win]")
        case "$action" in
            switch)
                # Switch to session first, then window
                session=$(echo "$target" | sed 's/:.*//')
                tmux switch-client -t "$session"
                tmux select-window -t "$target"
                ;;
            kill)
                if [[ "$target" == "[current]" ]]; then
                    tmux kill-window
                else
                    tmux unlink-window -k -t "$target"
                fi
                ;;
            rename)
                "$CURRENT_DIR/window.sh" rename "$target"
                ;;
            swap)
                "$CURRENT_DIR/window.sh" swap "$target"
                ;;
            new)
                tmux new-window
                ;;
            split-h)
                tmux split-window -h
                ;;
            split-v)
                tmux split-window -v
                ;;
            link)
                "$CURRENT_DIR/window.sh" link
                ;;
            move)
                "$CURRENT_DIR/window.sh" move
                ;;
        esac
        ;;
    "[pane]")
        case "$action" in
            switch)
                session=$(echo "$target" | sed -E 's/:.*//g')
                window=$(echo "$target" | sed -E 's/\..*//g')
                tmux switch-client -t "$session"
                tmux select-window -t "$window"
                tmux select-pane -t "$target"
                ;;
            kill)
                if [[ "$target" == "[current]" ]]; then
                    tmux kill-pane
                else
                    tmux kill-pane -t "$target"
                fi
                ;;
            zoom)
                if [[ "$target" == "[current]" ]]; then
                    tmux resize-pane -Z
                else
                    tmux resize-pane -Z -t "$target"
                fi
                ;;
            break)
                "$CURRENT_DIR/pane.sh" break "$target"
                ;;
            swap)
                "$CURRENT_DIR/pane.sh" swap "$target"
                ;;
            join)
                "$CURRENT_DIR/pane.sh" join "$target"
                ;;
            layout)
                "$CURRENT_DIR/pane.sh" layout
                ;;
            resize)
                "$CURRENT_DIR/pane.sh" resize
                ;;
        esac
        ;;
esac
