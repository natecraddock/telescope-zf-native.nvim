# telescope-zf-native.nvim

native [telescope](https://github.com/nvim-telescope/telescope.nvim) bindings to
[zf](https://github.com/natecraddock/zf) for sorting results.

[Try it online!](https://nathancraddock.com/zf-playground/)

In short, zf is a filepath fuzzy finder. It is designed for better matching on filepaths than fzf or fzy. Matches on filenames are prioritized, and the strict path matching feature helps narrow down directory trees with precision. See the [zf](https://www.github.com/natecraddock/zf) repo for full details. Some highlights:

* a match on the filename is prioritized over a match on the full path
* a search including path separators enables "strict path matching"
  * this means each path segment in the query must be found in a path segment of the file
  * `src/` would match `src/index.js` but not `tests/routes/client/index.js`
* the search query is space-separated to make narrowing down results easier
  * searching for `init.py` would find several `__init__.py` files in a Python project
  * but a search for `init.py c` would match `./config/__init__.py` (or any other paths also containing `c`)

## Why

By default, [telescope](https://github.com/nvim-telescope/telescope.nvim) uses a
sorter implemented in Lua. This is fine, but performance can suffer on larger
lists of data.

telescope-zf-native.nvim is a telescope extension that provides a more
performant natively-compiled sorter written in [Zig](https://ziglang.org) with
more accurate filename matching using the
[zf](https://github.com/natecraddock/zf) algorithm. Pre-compiled libzf binaries
are included. See below for the current list of supported platforms and
architectures.

### The zf algorithm

See the [zf repo](https://github.com/natecraddock/zf) for more information on
the algorithm and standalone executable (a replacement for `fzf` or `fzy`). But
here's a short summary:

After analyzing filenames from over 50 git repositories selected randomly from
GitHub, I concluded that the majority of filenames are unique in a project. I
used this in designing the zf algorithm to make a fuzzy-finder that is optimized
for filtering filepaths.

* Matches on filenames are highly favored over filepath matches
* Matches on the beginning of a word are prioritized over matches in
  the middle of a word
* Non-sequential character matches are penalized

With these heuristics, zf does a really good job sorting the desired file to the
top of the results list. But there are plenty of files that share the same or
similar names like `init.lua` or `__init__.py` for example. zf parses the query
string as a list of space-delimited tokens to easily refine the search results
when the first match isn't the wanted file. Simply append further terms to the
query to narrow down the results.

## Installation

Install in neovim with a package manager like
[packer.nvim](https://github.com/wbthomason/packer.nvim) or
[vim-plug](https://github.com/junegunn/vim-plug).

```lua
--- packer
use "natecraddock/telescope-zf-native.nvim"
```

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim) and experience troubles installing the plugin, try something like the following (see [this issue](https://github.com/natecraddock/telescope-zf-native.nvim/issues/21) for more details):

```lua
require('lazy').setup('my_plugins', { rocks = { enabled = false } })
```

Then load the extension in telescope with default settings.

```lua
require("telescope").load_extension("zf-native")
```

The default config replaces the default telescope sorters with zf for all
sorting. To confirm that the extension loaded properly, and to view the current
settings, run `:checkhealth zf-native`.

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

                -- optional function to define a sort order when the query is empty
                initial_sort = nil,

                -- set to false to enable case sensitive matching
                smart_case = true,
            },

            -- options for sorting all other items
            generic = {
                -- override default telescope generic item sorter
                enable = true,

                -- highlight matching text in results
                highlight_results = true,

                -- disable zf filename match priority
                match_filename = false,

                -- optional function to define a sort order when the query is empty
                initial_sort = nil,

                -- set to false to enable case sensitive matching
                smart_case = true,
            },
        }
    },
})

require("telescope").load_extension("zf-native")
```

The above settings are the default, so if you are satisfied with the defaults
there is no need to change anything.

#### Example initial_sort function

The `initial_sort` function is used when the query is empty.

Here is an example that prioritizes `.lua` files

```lua
['zf-native'] = {
  file = {
    initial_sort = function (line)
      if line:match('%.lua$') then
        return 0
      end
      return 1
    end
  }
}
```

The function accepts a line to rank and should return a number between 0 and 1,
with numbers closer to 0 giving the line a higher priority.

### Supported Platforms

The `lib/` directory contains libzf pre-compiled libraries for:
* linux (x86 and arm)
* macos (x86 and arm)
* windows (x86)

If your OS is not supported, or there are issues loading the libraries please
submit an issue. For requests of support of new platforms or any other issue,
please include the output of `:checkhealth zf-native` in the issue.

## Related

* [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
* [telescope-fzy-native.nvim](https://github.com/nvim-telescope/telescope-fzy-native.nvim)

I also thank the developers who worked on these projects as my reference for
using the LuaJIT FFI.
