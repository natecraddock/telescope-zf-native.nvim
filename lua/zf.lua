local ffi = require("ffi")

-- load the zf shared library, finding the correct library depending on the
-- arch and os
local path = (function()
    local arch = jit.arch:lower()
    local os = jit.os:lower()
    local ext
    if os == "windows" then
        ext = "dll"
    else
        ext = "so"
    end

    local dirname = string.sub(debug.getinfo(1).source, 2, #"/zf.lua" * -1)
    return dirname .. string.format("../lib/libzf-%s-%s.%s", os, arch, ext)
end)()

local zf = ffi.load(path)

-- external definitions
ffi.cdef[[
int rankItem(const char str[], const char **toks, uint64_t n_tokens, bool filename);
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

---@param line string
---@param tokens table
---@param len number
---@param filename boolean
---calls the shared zf library to rank the given line against the tokens
function M.rank(line, tokens, len, filename)
    local score = zf.rankItem(line, tokens, len, filename)
    return score
end

return M
