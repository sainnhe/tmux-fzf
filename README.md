![demo](https://gitlab.com/sainnhe/img/-/raw/master/tmux-fzf.gif)

# Features

- Manage sessions (attach, detach*, rename, kill*).
- Manage windows (switch, link, move, swap, rename, kill*).
- Manage panes (switch, break, join*, swap, layout, kill*, resize).
- Preview sessions, windows and panes.
- Multiple selection (support for actions marked by *).
- Search commands and append to command prompt.
- Search key bindings and execute.
- Search clipboard history and paste to current window.
- User menu.

# Installation

## Requirements

- [GNU bash](https://www.gnu.org/software/bash/)
- [GNU sed](https://www.gnu.org/software/sed/)
- [junegunn/fzf](https://github.com/junegunn/fzf/)
- [CopyQ](https://github.com/hluk/CopyQ) (optional for accessing system clipboard)

**Note:** Please use this command to check whether tmux is able to find fzf [#1](https://github.com/sainnhe/tmux-fzf/issues/1): `tmux run-shell -b 'command -v fzf'`

## Install via [TPM](https://github.com/tmux-plugins/tpm/)

Add this line to your `~/.tmux.conf`

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

Reload configuration, then press `prefix` + `I`.

# Usage

To launch tmux-fzf, press `prefix` + `F` (Shift+F).

This plugin supports multiple selection for some actions, you can press `TAB` and `Shift-TAB` to mark multiple items.

You can bind a key to preselect an action. See [#6](https://github.com/sainnhe/tmux-fzf/issues/6) for more information.

Most actions don't need to be explained, but there are some actions that might need to be explained here.

## link & move window

You can use **link** action to link a window from another session to current session.

launch tmux-fzf -> `window` -> `link` -> select a window in another session

And you can use **kill** action to unlink or kill current window.

`kill` actually use `tmux unlink-window -k` instead of `tmux kill-window`. The main difference between `unlink-window -k` and `kill-window` is that `kill-window` will kill current window and all other windows linked to it, while `unlink-window -k` will only kill current window.

The logic of the `unlink -k` action is a bit like hard link in unix/linux. If the current window only exists in one session, then kill; if the current window exists in multiple sessions, then unlink.

Btw, if you want to bind a key to kill current window, I would recommend `unlink-window -k` instead of `kill`.

**move** action is similar to link, except the window at source window is moved to destination.

## break & join pane

**break** action will break source pane off from its containing window to make it the only pane in destination window.

launch tmux-fzf -> `pane` -> `break` -> select source pane

**join** action is like split-window, but instead of splitting destination pane and creating a new pane, it will split it and move source pane to the current window. This can be used to reverse break-pane.

launch tmux-fzf -> `pane` -> `join` -> select source pane(s)

## user menu

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
- Commands are executed using `tmux -c`, so please make sure `tmux -c "your command"` makes sense.

## popup window

Popup window is a new feature introduced in tmux 3.2 (hasn't been released yet). To enable it, you'll need to compile and install the latest development version of [tmux/tmux](https://github.com/tmux/tmux).

For arch linux users, there is a package available in AUR: [tmux-git](https://aur.archlinux.org/packages/tmux-git)

This feature is automatically enabled in the version >= 3.2, but you can disable it using `$TMUX_FZF_OPTIONS`, see [fzf behavior](https://github.com/sainnhe/tmux-fzf#fzf-behavior).

# Customization

## key binding

For example, to use `prefix` + `C-f` (Ctrl+F), add this line to your `~/.tmux.conf`

```tmux
TMUX_FZF_LAUNCH_KEY="C-f"
```

## fzf behavior

This plugin will read fzf environment variables, so you can customize the behavior of fzf such as prompt and color by setting those variables.

For more information, check [official page of fzf](https://github.com/junegunn/fzf/#environment-variables).

In addition, this plugin supports options of `fzf-tmux` command which is [provided by fzf](https://github.com/junegunn/fzf#fzf-tmux-script), you can customize them by adding something like this to `~/.tmux.conf`

```tmux
# Default value in version < 3.2
TMUX_FZF_OPTIONS=""

# Default value in version >= 3.2
TMUX_FZF_OPTIONS="-p -w 62% -h 38%"
```

To list all available `fzf-tmux` options, execute `fzf-tmux --help` in your shell.

## preview

Preview is enabled by default, to hide it, add something like this to your `~/.tmux.conf`:

```tmux
TMUX_FZF_PREVIEW=0
```

Then the preview window will be hidden until `toggle-preview` is triggered.

## order

To customize the order of the items, add something like this to your `~/.tmux.conf`:

```tmux
TMUX_FZF_ORDER="session|window|pane|command|keybinding"
```

## format

For some reasons, you may want to customize format of panes, windows, sessions listed in fzf. There are three variables to complete this work:

`TMUX_FZF_PANE_FORMAT`   `TMUX_FZF_WINDOW_FORMAT`   `TMUX_FZF_SESSION_FORMAT`

For example, `tmux list-panes -a` doesn't show running program and window name by default. If you want to show running program and window name, add something like this to `~/.tmux.conf`

```tmux
TMUX_FZF_PANE_FORMAT="[#{window_name}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}"
```

Similarly, `TMUX_FZF_WINDOW_FORMAT` and `TMUX_FZF_SESSION_FORMAT` can also be handled in this way.

For more information, check "FORMATS" section in tmux manual.

# FAQ

- **Q:** What's your status line configuration?
- **A:** See this [article](https://www.sainnhe.dev/post/status-line-config/).
- **Q:** What's the color scheme used in the screenshot?
- **A:** [Gruvbox Material](https://github.com/gruvbox-material/gruvbox-material)

# More plugins

- [sainnhe/tmux-translator](https://github.com/sainnhe/tmux-translator): A translation plugin powered by popup window.

# License

For the code in [/fzf](./fzf) directory, see [junegunn/fzf](https://github.com/junegunn/fzf#license).

Other code is distributed under [MIT](./LICENSE) && [Anti-996](./Anti-996-LICENSE).
