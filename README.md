# DiffThis.nvim

Use neovim as a diffing tool

## Requirements

- neovim

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
Toggling back will save the left buffer as the original file. Even if there are any conflicts left, so make sure to resolve every conflict before toggling back. This will probably get fixed in a future version of this plugin.

## Contributing

Feel free to open a pull request if you find any issues or want to improve this plugin in any way.
