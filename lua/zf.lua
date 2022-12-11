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
typedef struct {
    size_t start;
    size_t end;
} Range;

double rank(
    const char *str,
    const char *filename,
    const char **tokens,
    uint64_t num_tokens,
    bool case_sensitive
);

void highlight(
    const char *str,
    const char *filename,
    Range *ranges,
    const char **tokens,
    uint64_t num,
    bool case_sensitive
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

local transform_ranges = function(ranges, num_ranges)
    local highlights = {}
    for i = 0, num_ranges - 1 do
        table.insert(highlights, {
            -- offset +1 for lua string indexing
            start = tonumber(ranges[i].start) + 1,
            finish = tonumber(ranges[i]["end"]) + 1,
        })
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
    local basename = nil
    if filename then
        basename = string.gsub(line, "(.*/)(.*)", "%2")
    end
    return zf.rank(line, basename, tokens, num_tokens, case_sensitive)
end

---@param line string
---@param tokens table
---@param num_ranges number
---@param filename boolean
---@param case_sensitive boolean
---@return table
M.highlight = function(line, tokens, num_ranges, filename, case_sensitive)
    local basename = nil
    if filename then
        basename = string.gsub(line, "(.*/)(.*)", "%2")
    end
    local ranges = ffi.new(string.format("Range [%d]", num_ranges))
    zf.highlight(line, basename, ranges, tokens, num_ranges, case_sensitive)
    return transform_ranges(ranges, num_ranges)
end

return M
