local health = require("health")
local telescope = require("telescope")
local zf = require("zf")

local M = {}

M.check = function()
    health.report_start("Installation")

    local path = zf.get_path()
    health.report_info(string.format("libzf library path: %s", path))

    if vim.fn.filereadable(path) == 0 then
        health.report_error("libzf path does not exist")
    else
        health.report_ok("libzf path is valid")
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

    health.report_start(table.concat(configuration, "\n"))

end

return M
