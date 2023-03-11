local ffi = require("ffi")

local M = {}

---get the path to the zf library
---@return string
M.get_path = function()
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
end

---@class Zf
---@field rank fun(str: string, filename: string, tokens: table, num_tokens: number, case_sensitive: boolean): number
---@field highlight fun(str: string, filename: string, ranges: table, tokens: table, num: number, case_sensitive: boolean): nil
local zf

---@return Zf
---load the shared library on a function call. This makes it possible to run
---require this file and not get lua errors if the path does not exist.
M.load_zf = function()
    zf = ffi.load(M.get_path())
    return zf
end

-- external definitions
ffi.cdef[[
double rank(
    const char *str,
    const char **tokens,
    uint64_t num_tokens,
    bool case_sensitive,
    bool plain
);

uint64_t highlight(
    const char *str,
    const char **tokens,
    uint64_t num_tokens,
    bool case_sensitive,
    bool plain,
    uint64_t *matches,
    uint64_t matches_len
);
]]

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
        tokens = ffi.new(string.format("const char *[%d]", #tokens), tokens),
        len = #tokens,
    }
end

local is_index_highlighted = function(matches, matches_len, index)
    local i = 0
    while i < matches_len do
        if matches[i] == index then return true end
        i = i + 1
    end
    return false
end

local matches_iter = function(matches, matches_len, str)
    local index = 0
    local highlight = is_index_highlighted(matches, matches_len, 0)

    return function()
        if index >= #str then return nil end

        local start_state = highlight
        local i = index
        while i < #str do
            if start_state ~= is_index_highlighted(matches, matches_len, i) then
                break
            end
            i = i + 1
        end

        local slice = { start = index + 1, finish = i }
        highlight = not highlight
        index = i
        return not highlight, slice
    end
end

local compute_ranges = function(matches, matches_len, str)
    local highlights = {}
    for highlight, match in matches_iter(matches, matches_len, str) do
        if highlight then
            table.insert(highlights, match)
        end
    end
    return highlights
end

---@param line string
---@param tokens table
---@param num_tokens number
---@param filename boolean
---@param case_sensitive boolean
---@return number
---calls the shared zf library to rank the given line against the tokens
M.rank = function(line, tokens, num_tokens, filename, case_sensitive)
    return zf.rank(line, tokens, num_tokens, case_sensitive, not filename)
end

-- todo: test with a tiny buffer
local buffer = ffi.new("uint64_t[2048]")

---@param line string
---@param tokens table
---@param num_tokens number
---@param filename boolean
---@param case_sensitive boolean
---@return table
M.highlight = function(line, tokens, num_tokens, filename, case_sensitive)
    local len = zf.highlight(line, tokens, num_tokens, case_sensitive, not filename, buffer, 2048)
    return compute_ranges(buffer, len, line)
end

return M
