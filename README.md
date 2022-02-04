# telescope-zf-native.nvim

native telescope bindings to [zf](https://github.com/natecraddock/zf) for
sorting results.

## Why

By default, [telescope](https://github.com/nvim-telescope/telescope.nvim) uses a
sorter implemented in Lua. This is fine, but performance can suffer on larger
lists of data.

telescope-zf-native.nvim is a telescope extension that offers a compiled sorter
with improved performance and accuracy using the
[zf](https://github.com/natecraddock/zf) algorithm. Because the majority of
filenames in a project are unique, the zf algorithm prioritizes matches on
filenames. zf also parses the query as a list of whitespace-delimited tokens.
Each token may be used to further refine the search results.

See the [zf repo](https://github.com/natecraddock/zf) for more
information on the algorithm and standalone executable.

## Installation

Install in neovim with a package manager like
[packer.nvim](https://github.com/wbthomason/packer.nvim) or
[vim-plug](https://github.com/junegunn/vim-plug)

Then load the extension in telescope with default settings.

```lua
require("telescope").load_extension("zf-native")
```

The default config uses zf for all sorting.

For additional configuration, use the following:

```lua
require("telescope").setup({
    extensions = {
        ["zf-native"] = {
            -- options for sorting file-like items
            file = {
                -- override default telescope file sorter
                enable = true,

                -- highlight matching text in results
                highlight_results = true,

                -- enable zf filename match priority
                match_filename = true,
            },

            -- options for sorting all other items
            generic = {
                -- override default telescope generic item sorter
                enable = true,

                -- highlight matching text in results
                highlight_results = true,

                -- disable zf filename match priority
                match_filename = false,
            },
        }
    },
})

require("telescope").load_extension("zf-native")
```

The above settings are the default, so if you are satisfied with the defaults
there is no need to change anything.

To confirm that the extension loaded properly, and that settings are applied,
run `:checkhealth zf-native` to view the library path and current settings.

### Supported Platforms

The `lib/` directory contains libraries for:
* linux (x86 and arm)
* macos (x86 and arm)
* windows (x86)

If your OS is not supported, or there are issues loading the libraries please
submit an issue.

## Related

* [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
* [telescope-fzy-native.nvim](https://github.com/nvim-telescope/telescope-fzy-native.nvim)

I also thank the developers who worked on these projects as my reference for
using the LuaJIT FFI.
