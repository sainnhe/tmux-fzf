![demo](https://gitlab.com/sainnhe/img/-/raw/master/tmux-fzf.gif)

# Features

- Manage sessions (switch, new, rename, detach, kill).
- Manage windows (switch, link, move, swap, rename, kill).
- Manage panes (switch, break, join, swap, layout, kill, resize).
- Search commands and append to command prompt.
- Search key bindings and execute.
- Search clipboard history and paste to current window.
- Process management (top, pstree, terminate, kill, interrupt, continue, stop, quit, hangup).
- User menu (run custom commands).
- Preview sessions, windows and panes.
- Multiple selection.

# Installation

## Requirements

- [GNU bash](https://www.gnu.org/software/bash/)
- [sed](https://www.gnu.org/software/sed/)
- [junegunn/fzf](https://github.com/junegunn/fzf/)
- [CopyQ](https://github.com/hluk/CopyQ/) (optional): Access system clipboard, fallback to builtin tmux buffers if copyq is not executable.
- [pstree](https://gitlab.com/psmisc/psmisc/) (optional): Display process tree.

**Note:** Please use this command to check whether tmux is able to find fzf [#1](https://github.com/sainnhe/tmux-fzf/issues/1): `tmux run-shell -b 'command -v fzf'`

## Install via [TPM](https://github.com/tmux-plugins/tpm/)

Add this line to your `~/.tmux.conf`

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

Reload configuration, then press `prefix` + `I` (Shift+I).

# Usage

To launch tmux-fzf, press `prefix` + `F` (Shift+F).

This plugin supports multiple selection for some actions, you can press `TAB` and `Shift-TAB` to mark multiple items.

Most of the features work out of the box, but there are some features that need to be explained here.

## Kill Window(s)

The `kill` action in tmux-fzf actually uses `tmux unlink-window -k` instead of `tmux kill-window`.

The main difference between `unlink-window -k` and `kill-window` is that `kill-window` will kill current window and all other windows linked to it, while `unlink-window -k` will only kill current window.

The logic of `unlink -k` is a bit like hard links. If the current window only exists in one session, then kill; if the current window exists in multiple sessions, then unlink.

Btw, if you want to bind a key to kill current window, I would recommend `unlink-window -k` instead of `kill`.

## User Menu

You can add a custom menu to quickly execute some commands.

This feature is not enabled by default. To enable it, add something like this to `~/.tmux.conf`

```tmux
TMUX_FZF_MENU=\
"foo\necho 'Hello!'\n"\
"bar\nls ~\n"\
"sh\nsh ~/test.sh\n"
```

When you launch tmux-fzf, an extra item named `menu` will appear. Selecting this item will produce [this](https://user-images.githubusercontent.com/37491630/66251156-71836000-e73c-11e9-809d-e865651f8d7d.png).

There will be 3 items to select from: `foo`, `bar` and `sh`.

When you select `foo`, tmux will execute `echo 'Hello!'`.

When you select `bar`, tmux will execute `ls ~`.

When you select `sh`, tmux will execute `sh ~/test.sh`.

**Note:**

- `foo` and `echo 'hello'` are separated by `\n` in `TMUX_FZF_MENU`, and you need to add another `\n` after `echo 'hello'`.
- **DO NOT** add additional white spaces/tabs at the beginning of each line.
- Commands are executed using `tmux -c`, so please make sure `tmux -c "your command"` does work.

### Alternative format for TMUX_FZF_MENU

Here each menu item (`name + command`) consist of 3 lines:

1. name: Name of the item on the menu selection.
2. command: what will be execute when you select that item on the menu.
3. end of line (menu item): required end of line per menu item.

```tmux
TMUX_FZF_MENU="\
foo\n\              <- name
echo 'Hello!'\      <- command
\n""\               <- end of line
bar\n\
ls ~\
\n""\
sh\n\
sh ~/test.sh\
\n""\
nil--\n\n"          <- this is required
```

### Menu Popup

You can configure the menu output to appear on a popup window instead of the current pane you're on.

To enable this set the `TMUX_FZF_MENU_POPUP=1` variable.

You can also set the width and height for the popup window.

Default values:

```
TMUX_FZF_MENU_POPUP_WIDTH=50%
TMUX_FZF_MENU_POPUP_HEIGHT=50%
```

## Popup Window

Popup window is a new feature introduced in tmux 3.2 . To enable this feature, you'll need to have tmux >= 3.2 installed.

This feature is automatically enabled in tmux >= 3.2, but you can disable it using `$TMUX_FZF_OPTIONS`, see [Fzf Behavior](#fzf-behavior).

# Customization

## Key Binding

For example, to use `prefix` + `C-f` (Ctrl+F), add this line to your `~/.tmux.conf`

```tmux
TMUX_FZF_LAUNCH_KEY="C-f"
```

## Fzf Behavior

This plugin will read [fzf environment variables](https://github.com/junegunn/fzf/#environment-variables), so you can use these variables to customize the behavior of fzf (e.g. prompt and color).

In addition, this plugin supports customizing the options of `fzf-tmux` command which is [bundled with fzf](https://github.com/junegunn/fzf#fzf-tmux-script), you can customize them by adding something like this to `~/.tmux.conf`

```tmux
# Default value in tmux < 3.2
TMUX_FZF_OPTIONS="-m"

# Default value in tmux >= 3.2
TMUX_FZF_OPTIONS="-p -w 62% -h 38% -m"
```

To list all available options of `fzf-tmux`, execute `~/.tmux/plugins/tmux-fzf/scripts/.fzf-tmux --help` in your shell.

## Preview

Preview is enabled by default. To hide it, add something like this to your `~/.tmux.conf`:

```tmux
TMUX_FZF_PREVIEW=0
```

Then the preview window will be hidden until `toggle-preview` is triggered.

By default, the preview window will try to "follow" the content (see description in [the fzf docs](https://github.com/junegunn/fzf/blob/master/ADVANCED.md#log-tailing)). You can opt out this behavior using the following:

```tmux
TMUX_FZF_PREVIEW_FOLLOW=0
```

## Order

To customize the order of the actions, add something like this to your `~/.tmux.conf`:

```tmux
TMUX_FZF_ORDER="session|window|pane|command|keybinding|clipboard|process"
```

You can also use this variable to disable unwanted features. For example, to disable `clipboard` and `process`, simply delete them in `$TMUX_FZF_ORDER`:

```tmux
TMUX_FZF_ORDER="session|window|pane|command|keybinding"
```

## Format

For some reasons, you may want to customize format of panes, windows, sessions listed in fzf. There are three variables to complete this work:

`TMUX_FZF_PANE_FORMAT`   `TMUX_FZF_WINDOW_FORMAT`   `TMUX_FZF_SESSION_FORMAT`

For example, `tmux list-panes -a` doesn't show running program and window name by default. If you want to show running program and window name, add something like this to `~/.tmux.conf`

```tmux
TMUX_FZF_PANE_FORMAT="[#{window_name}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}"
```

Similarly, `TMUX_FZF_WINDOW_FORMAT` and `TMUX_FZF_SESSION_FORMAT` can also be handled in this way.

For more information, check "FORMATS" section in tmux manual.


## Filter

By default, the current session, window, and pane, are not listed among the switch possibilities. To include it, set:

```tmux
TMUX_FZF_SWITCH_CURRENT=1
```

When using the window listing script, it is possible to filter its output. This relies on the tmux filtering feature with a specific syntax for filters. For more information about this feature, check "FORMATS" section in the tmux manual.

To use this filtering feature, set the variable `TMUX_FZF_WINDOW_FILTER` to the filter you want to apply before calling the `window.sh` script. 

# FAQ

**Q: Why use environment variables instead of tmux options to customize this plugin?**

**A:** Because the performance of tmux options is very bad. I pushed a branch named `tmux-options` to demonstrate how bad the performance will be if we use tmux options to customize this plugin, you can checkout this branch and get it a try.

**Q: How to launch tmux-fzf with preselected action?**

**A:** See [#6](https://github.com/sainnhe/tmux-fzf/issues/6).

**Q: What's your status line configuration?**

**A:** See this [post](https://www.sainnhe.dev/post/status-line-config/).

**Q: What's the color scheme used in the screenshot?**

**A:** [Gruvbox Material](https://github.com/sainnhe/gruvbox-material)

# More plugins

- [sainnhe/tmux-translator](https://github.com/sainnhe/tmux-translator): A translation plugin powered by popup window.

# License

The code of [/scripts/.fzf-tmux](./scripts/.fzf-tmux) is copied from [junegunn/fzf](https://github.com/junegunn/fzf#license) which is licensed under [MIT](https://github.com/junegunn/fzf/blob/master/LICENSE).

Other code is distributed under [MIT](./LICENSE) && [Anti-996](./Anti-996-LICENSE).
