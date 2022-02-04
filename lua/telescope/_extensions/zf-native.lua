local zf = require("zf")
local sorters = require("telescope.sorters")

local make_sorter = function(opts)
    opts = vim.tbl_deep_extend("force", {
        highlight_results = true,
        match_filename = true,
    }, opts or {})

    -- load shared library
    zf.load_zf()

    return sorters.new({
        start = function(self, prompt)
            self.tokens = zf.tokenize(prompt)
        end,
        scoring_function = function(self, _, line)
            if self.tokens == nil then return 1 end

            local rank = zf.rank(line, self.tokens.tokens, self.tokens.len, opts.match_filename)
            if rank == -1 then return rank end

            return 1.0 - (1.0 / rank)
        end,

        -- it isn't ideal that we have to recalc the ranges for highlights, but without knowing the
        -- relation between the line and the display line, we cannot use the resulting ranges from
        -- the previous scoring. Luckily the highlighter only needs to run for the displayed lines
        -- so it isn't too bad!
        highlighter = function(self, _, display)
            if opts.highlight_results == false or self.tokens == nil then return nil end
            return zf.highlight(display, self.tokens.tokens, self.tokens.len, opts.match_filename)
        end
    })
end

local config = {
    file = {
        -- override default telescope file sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- enable zf filename match priority
        match_filename = true,
    },
    generic = {
        -- override default telescope generic item sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- disable zf filename match priority
        match_filename = false,
    },
}

return require("telescope").register_extension({
    setup = function(ext_config, tele_config)
        config = vim.tbl_deep_extend("force", config, ext_config or {})

        if config.file.enable then
            tele_config.file_sorter = function()
                return make_sorter(config.file)
            end
        end

        if config.generic.enable then
            tele_config.generic_sorter = function()
                return make_sorter(config.generic)
            end
        end
    end,

    exports = {
        native_zf_scorer = function(opts)
            return make_sorter(opts)
        end,

        get_config = function()
            return config
        end
    },
})
