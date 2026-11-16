# 10x

A blazingly fast Neovim plugin for pinning your most used files and switching between them with a single key.

- Pin up to N files per project
- Jump to any pinned file with `<leader>1`, `<leader>2`, …
- See your pins in the status line, with the current file highlighted
- Pins are saved to disk and restored when you reopen Neovim

## Installation

The repo is called `10x`, but the Lua module is called `tenx`, so you use `require("tenx")`.

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({ "https://github.com/miraskbk/10x" })
require("tenx").setup({})
```

### lazy.nvim

```lua
{
    "miraskbk/10x",
    config = function()
        require("tenx").setup({})
    end,
}
```

## Setup

Calling `setup()` is optional. If you skip it, the defaults are used.

```lua
require("tenx").setup({
    max_files = 5, -- how many files you can pin per project
})
```

| Option      | Default | Description                                |
| ----------- | ------- | ------------------------------------------ |
| `max_files` | `5`     | Maximum number of pinned files per project |

## Usage

tenx does not create any keymaps itself, so you choose your own keys.

| Function                       | Description                                     |
| ------------------------------ | ----------------------------------------------- |
| `require("tenx").add()`        | Pin the current file                            |
| `require("tenx").select(n)`    | Jump to pinned file number `n`                  |
| `require("tenx").remove()`     | Unpin the current file                          |
| `require("tenx").clear()`      | Unpin all files in the current project          |
| `require("tenx").statusline()` | Return the pinned files as a status line string |

### Example keymaps

```lua
local tenx = require("tenx")

vim.keymap.set("n", "<leader>a", tenx.add, { desc = "tenx: pin file" })
vim.keymap.set("n", "<leader>x", tenx.remove, { desc = "tenx: unpin file" })
vim.keymap.set("n", "<leader>C", tenx.clear, { desc = "tenx: clear pins" })

-- <leader>1 ... <leader>N, where N is max_files
for i = 1, tenx.config.max_files do
    vim.keymap.set("n", "<leader>" .. i, function()
        tenx.select(i)
    end, { desc = "tenx: go to file " .. i })
end
```

Set these up **after** calling `setup()`, so the loop uses your `max_files`.

## Status line

Show only your pins:

```lua
vim.o.statusline = "%!v:lua.require'tenx'.statusline()"
```

Or add them to a normal status line (filename on the left, pins on the right):

```lua
vim.o.statusline = "%f %m %= %{%v:lua.require'tenx'.statusline()%}"
```

Use `%{%...%}` rather than `%{...}`, so the highlight for the current file is applied instead of printed as text.

## Notes

- Pins are stored separately for each project, based on Neovim's current working directory (`:pwd`).
- Pins are saved to `stdpath("data")/tenx.json`, which is usually `~/.local/share/nvim/tenx.json`.
