# close-and-restore-tab.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that adds the functionality to restore closed tabs.

## Features

- Remember a tab's working directory and position when it is closed.
- Restore any closed tab at its previous position.

## Installation

```sh
ya pkg add MasouShizuka/close-and-restore-tab

# or

# Windows
git clone https://github.com/MasouShizuka/close-and-restore-tab.yazi.git %AppData%\yazi\config\plugins\close-and-restore-tab.yazi

# Linux/macOS
git clone https://github.com/MasouShizuka/close-and-restore-tab.yazi.git ~/.config/yazi/plugins/close-and-restore-tab.yazi
```

Then add the plugin's `setup` function in Yazi's `init.lua`, i.e. `~/.config/yazi/init.lua`.

```lua
require("close-and-restore-tab"):setup()
```

## Keymap

Add this to your `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = [ "<C-t>" ]
run = "plugin close-and-restore-tab restore"
desc = "Restore the previously closed tab"
```

If you want to use a non-default binding to close the current tab,
which is bound to `<C-c>`:

```toml
[[mgr.prepend_keymap]]
on = "<C-w>"
run = "close"
desc = "Close the current tab, or quit if it's last"
```
