# telescope-zf-native.nvim

native telescope bindings to [zf](https://github.com/natecraddock/zf) for
sorting results.

## Installation

Install in neovim with a package manager like
[packer.nvim](https://github.com/wbthomason/packer.nvim) or
[vim-plug](https://github.com/junegunn/vim-plug)

Then load the extension in telescope with default settings.

```lua
require("telescope").load_extension("zf_native")
```

The default config uses zf for all sorting.

For additional configuration, use the following

```lua
require("telescope").setup({
    extensions = {
        zf_native = {
            -- use zf for sorting file-like items
            override_file_sorter = true,

            -- use zf for all other sorting
            override_generic_sorter = false,
        }
    },
})

require("telescope").load_extension("zf_native")
```
