![](./demo.png)

# Feature

- Manage sessions(detach, kill, switch, rename).
- Manage panes(kill, switch, layout).
- Manage windows(kill, switch, rename).
- Search commands and append to command prompt.

# Installation

Suppose you are using [tpm](https://github.com/tmux-plugins/tpm/), add this line into your `$HOME/.tmux.conf`

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

Reload configuration, then press `prefix` + `I`.

And of course, this plugin requires [fzf](https://github.com/junegunn/fzf/) to get it work.

# Usage

press `prefix` + `F` (Shift+F)

# Customize

This plugin will read fzf environment variables, so you can customize the behavior of fzf such as prompt and color by setting those variables.

For more information, check [official page of fzf](https://github.com/junegunn/fzf/).

In addition, this plugin supports options of `fzf-tmux` command which is [officially provided by fzf](https://github.com/junegunn/fzf#examples), you can customize them by adding something like this into `$HOME/.tmux.conf`

```tmux
TMUX_FZF_OPTIONS="-d 35%"
```

To list all available `fzf-tmux` options, execute `fzf-tmux --help` in your shell.
