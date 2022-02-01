local zf = require("zf")
local sorters = require("telescope.sorters")

local make_sorter = function(opts)
    opts = vim.tbl_deep_extend("force", {
        match_filename = false,
    }, opts or {})

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
        -- TODO: add highlighter (depends on zf returning range info)
        -- highlighter = function(self, prompt, display)
        -- end
    })
end


return require("telescope").register_extension({
    setup = function(ext_config, config)
        local override_file = vim.F.if_nil(ext_config.override_file_sorter, true)
        local override_generic = vim.F.if_nil(ext_config.override_generic_sorter, true)

        if override_file then
            config.file_sorter = function()
                return make_sorter({ match_filename = true })
            end
        end

        if override_generic then
            config.generic_sorter = function()
                return make_sorter()
            end
        end
    end,

    exports = {
        native_zf_scorer = function(opts)
            return make_sorter(opts or { match_filename = true })
        end,
    },
})
