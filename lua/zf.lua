local ffi = require("ffi")

-- load the zf shared library
local dirname = string.sub(debug.getinfo(1).source, 2, #"/zf.lua" * -1)
local path = dirname .. "../lib/libzf.so"
local zf = ffi.load(path)

-- external definitions
ffi.cdef[[
int rankItem(const char str[], const char **toks, uint64_t n_tokens);
]]

local M = {}

-- takes a prompt string and returns a C-compatible list of
-- whitespace-separated tokens
function M.tokenize(prompt)
    if #prompt == 0 then return nil end

    local split = vim.split(prompt, " ", { trimempty = true })
    local tokens = {}
    for _, token in ipairs(split) do
        if token ~= nil and token ~= "" then
            table.insert(tokens, token)
        end
    end

    return {
        tokens = ffi.new(string.format("const char *[%d]", #tokens + 1), tokens),
        len = #tokens,
    }
end

-- calls the shared zf library to rank the given line against the tokens
function M.rank(line, tokens, len)
    local score = zf.rankItem(line, tokens, len)
    return score
end

return M
