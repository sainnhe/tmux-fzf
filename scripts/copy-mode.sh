copy_mode_commands="append-selection    Append the selected buffer to the clipboard
append-selection-and-cancel    Append the selected buffer to the clipboard and cancel the current command
back-to-indentation    Move the cursor back to the indentation
begin-selection    Begin selection in the buffer
bottom-line    Move to the bottom line of the buffer
cancel    Cancel the current command
clear-selection    Clear the current selection in the buffer
copy-end-of-line [<prefix>]    Copy from the cursor position to the end of the line. If no prefix is given, it copies to the clipboard
copy-end-of-line-and-cancel [<prefix>]    Copy from the cursor position to the end of the line and cancel the current command
copy-pipe-end-of-line [<command>] [<prefix>]    This is equivalent to the copy-end-of-line method, but allows running a shell command on the text, and then copies it to the clipboard
copy-line [<prefix>]    Copy the entire line irrespective of the cursor position. If no prefix is given, it copies to the clipboard
copy-line-and-cancel [<prefix>]    Copy the entire line and cancel the current command
copy-selection [<prefix>]    This is equivalent to the window_copy_copy_selection method. It simply copies the selected text to the clipboard without any additional processing
copy-selection-and-cancel [<prefix>]    Copy the current selection and cancel the current command
cursor-down    Move the cursor down
cursor-left    Move the cursor left
cursor-right    Move the cursor right
cursor-up    Move the cursor up
end-of-line    Move the cursor to the end of the line
goto-line <line>    Go to the specific line
history-bottom    Scroll to the bottom of the history
history-top    Scroll to the top of the history
jump-again    Repeat the last jump
jump-backward <to>    Jump backwards to the specified text
jump-forward <to>    Jump forward to the specified text
jump-to-mark    Jump to the last mark
middle-line    Move to the middle line of the buffer
next-matching-bracket    Move to the next matching bracket
next-paragraph    Move to the next paragraph
next-word    Move to the next word
page-down    Scroll down by one page
page-up    Scroll up by one page
previous-matching-bracket    Move to the previous matching bracket
previous-paragraph    Move to the previous paragraph
previous-word    Move to the previous word
rectangle-toggle    Toggle rectangle selection mode
refresh-from-pane    Refresh the screen based on the current pane
search-again    Repeat the last search
search-backward <for>    Search backwards for the specified text
search-forward <for>    Search forward for the specified text
select-line    Select the current line
select-word    Select the current word
start-of-line    Move the cursor to the start of the line
top-line    Move to the top line of the buffer"

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select a copy-mode command.'"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

target=$(printf "[cancel]\n%s" "$copy_mode_commands" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS" | grep -o '^[^[:blank:]]*')

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
tmux send-keys -X "$target"