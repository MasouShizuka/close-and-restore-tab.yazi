# close-and-restore-tab.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that adds the functionality to close and restore tab.

## Features

 - Close the tab, and go to the left/right tab
 - Restore the closed tab to its previous position
 - Stores and restores all the tabs from previous session

## Installation

```sh
ya pkg add MasouShizuka/close-and-restore-tab
```

or

```sh
# Windows
git clone https://github.com/MasouShizuka/close-and-restore-tab.yazi.git %AppData%\yazi\config\plugins\close-and-restore-tab.yazi

# Linux/macOS
git clone https://github.com/MasouShizuka/close-and-restore-tab.yazi.git ~/.config/yazi/plugins/close-and-restore-tab.yazi
```

## Configuration

Add this to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = [ "<C-w>" ]
run = "plugin close-and-restore-tab close_to_left"
desc = "Close the current tab and turn to left tab, or quit if it is last tab"

[[mgr.prepend_keymap]]
on = [ "<C-w>" ]
run = "plugin close-and-restore-tab close_to_right"
desc = "Close the current tab and turn to right tab, or quit if it is last tab"

[[mgr.prepend_keymap]]
on = [ "<C-t>" ]
run = "plugin close-and-restore-tab restore"
desc = "Restore the closed tab"

[[mgr.prepend_keymap]]
on = [ "q" ]
run = "plugin close-and-restore-tab store_session"
desc = "Exits yazi and stores all tabs"

[[mgr.prepend_keymap]]
on = [ "<C-t>" ]
run = "plugin close-and-restore-tab restore_session"
desc = "Restores the tabs from last session"
```
`close_to_left` and `close_to_right` respectively mean switching to the left/right tab after closing the tab. Please choose the one you like.

If you want to run `restore_session` at startup you can add in `init.lua`:
```lua
require("close-and-restore-tab"):entry({ args = { "restore_session" } })
```
