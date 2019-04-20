![](./demo.png)

# Feature

- Manage sessions ( attach, detach, kill, rename ).
- Manage windows ( switch, kill, rename, link, unlink ).
- Manage panes ( switch, kill, layout ).
- Search commands and append to command prompt.
- Search keys and execute ( exclude copy-mode keys ).
- Multiple selection ( kill sessions/windows/panes ).

# Installation

Suppose you are using [tpm](https://github.com/tmux-plugins/tpm/), add this line into your `$HOME/.tmux.conf`

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

Reload configuration, then press `prefix` + `I`.

And of course, this plugin requires [fzf](https://github.com/junegunn/fzf/) to get it work.

# Usage

To launch tmux-fzf, press `prefix` + `F` (Shift+F).

This plugin supports multiple selection for `kill` action, you can press `TAB` and `Shift-TAB` to mark multiple items.

## link & unlink window

You can use this plugin to link a window from another session to current session.

launch tmux-fzf -> `window` -> `link` -> select a window in another session -> select destination

There are 4 available destinations:

`current`: kill current window and link it here

`after`: link it after current window

`end`: link it to the end

`begin`: link it to the begin

And you can use `unlink` action to unlink current window:

launch tmux-fzf -> `window` -> `unlink`

# Customize

## key binding

For example, to use `prefix` + `C-f` (Ctrl-F), add this line into your `$HOME/.tmux.conf`

```tmux
set -g @tmux-fzf-launch-key 'C-f'
```

## fzf behavior

This plugin will read fzf environment variables, so you can customize the behavior of fzf such as prompt and color by setting those variables.

For more information, check [official page of fzf](https://github.com/junegunn/fzf/#environment-variables).

In addition, this plugin supports options of `fzf-tmux` command which is [provided by fzf](https://github.com/junegunn/fzf#fzf-tmux-script), you can customize them by adding something like this into `$HOME/.tmux.conf`

```tmux
TMUX_FZF_OPTIONS="-d 35%"
```

To list all available `fzf-tmux` options, execute `fzf-tmux --help` in your shell.
