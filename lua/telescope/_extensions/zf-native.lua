local zf = require("zf")
local sorters = require("telescope.sorters")

local zf_sorter = sorters.new({
    start = function(self, prompt)
        self.tokens = zf.tokenize(prompt)
    end,
    scoring_function = function(self, _, line)
        if self.tokens == nil then return 1 end

        local rank = zf.rank(line, self.tokens.tokens, self.tokens.len)
        if rank == -1 then return rank end
        return 1 / (100 - rank)
    end,
    -- TODO: add highlighter (depends on zf returning range info)
    -- highlighter = function(self, prompt, display)
    -- end
})

return require("telescope").register_extension({
    setup = function(ext_config, config)
        local override_file = vim.F.if_nil(ext_config.override_file_sorter, true)
        local override_generic = vim.F.if_nil(ext_config.override_generic_sorter, true)

        if override_file then
            config.file_sorter = function()
                return zf_sorter
            end
        end

        if override_generic then
            config.generic_sorter = function()
                return zf_sorter
            end
        end
    end,

    exports = {
        native_zf_scorer = function()
            return zf_sorter
        end,
    },
})
