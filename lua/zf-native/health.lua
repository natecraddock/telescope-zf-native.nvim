local health = vim.fn.has('nvim-0.8') and vim.health or require("health")
local telescope = require("telescope")
local zf = require("zf")

local health_start = health.start or health.report_start
local health_error = health.error or health.report_error
local health_warn = health.warn or health.report_warn
local health_info = health.info or health.report_info
local health_ok = health.ok or health.report_ok

local M = {}

M.check = function()
    health_start("Installation")

    local path = zf.get_path()
    health_info(string.format("libzf library path: %s", path))

    if vim.fn.filereadable(path) == 0 then
        health_error("libzf path does not exist")
    else
        health_ok("libzf path is valid")
    end

    local configuration = { "Configuration" }

    local config = telescope.extensions["zf-native"].get_config()
    local file = config.file
    local generic = config.generic

    if file.enable then
        local report = {
            "  - zf telescope file sorter enabled",
            string.format("    - highlights: %s", tostring(file.highlight_results)),
            string.format("    - filename score priority: %s", tostring(file.match_filename)),
        }
        table.insert(configuration, (table.concat(report, "\n")))
    else
        table.insert(configuration, "  - zf telescope file sorter disabled")
    end

    if generic.enable then
        local report = {
            "  - zf telescope generic sorter enabled",
            string.format("    - highlights: %s", tostring(generic.highlight_results)),
            string.format("    - filename score priority: %s", tostring(generic.match_filename)),
        }
        table.insert(configuration, (table.concat(report, "\n")))
    else
        table.insert(configuration, "  - zf telescope generic sorter disabled")
    end

    health_start(table.concat(configuration, "\n"))

end

return M
