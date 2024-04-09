# DiffThis.nvim

Use neovim as a git diff tool

## Requirements

- neovim
- git

## Installation

### lazy.nvim:
```
{
    "Bleksak/diffthis.nvim",
    opts = {
        keys = {
            toggle = "<leader>dd",
            obtain = "do",
            put = "dp",
            next = "dn",
            prev = "dN",
        }
    }
}
```

## Usage

Use your toggle key binding to toggle the diff window, then you can use the key bindings you have set to resolve merge conflicts.
Toggling back will save the left (local changes) buffer as the original file. Even if there are any conflicts left, so make sure to resolve every conflict before toggling back.
Toggling back without any changes will revert back to the original file.

## Warning

This plugin is using 'git show' for displaying the diff. I have no idea how bad it is in terms of performance. Feel free to open PR if you find any issues or want to improve this plugin.
