local M = {}

function M.report(opts)
    opts = opts or {}
    local results = require("profiler").get_results(opts)
    local limit = opts.limit or 20

    print("\n" .. string.rep("=", 85))
    print("PLUGIN PROFILER REPORT")
    print(string.rep("=", 85))

    local total_plugins = 0
    local total_time = 0
    local avg_time = 0
    local lazy_loaded = 0

    for _, data in ipairs(results) do
        if not data.modname:match("^__batch_") then
            total_plugins = total_plugins + 1
            total_time = total_time + data.total_time
            if data.lazy_load then
                lazy_loaded = lazy_loaded + 1
            end
        end
    end

    if total_plugins > 0 then
        avg_time = total_time / total_plugins
    end

    print(
        string.format(
            "Total Plugins: %d | Total Time: %.2fms | Average: %.2fms | Lazy Loaded: %d",
            total_plugins,
            total_time,
            avg_time,
            lazy_loaded
        )
    )
    print(string.rep("-", 85))

    print(
        string.format(
            "%-25s %10s %10s %10s %12s %8s",
            "Plugin",
            "Total(ms)",
            "Require(ms)",
            "Setup(ms)",
            "Setup Type",
            "Lazy"
        )
    )
    print(string.rep("-", 85))

    for i, data in ipairs(results) do
        if i > limit then
            break
        end
        if data.modname:match("^__batch_") then
            goto continue
        end

        local setup_type = data.setup_type or "none"
        local lazy_marker = data.lazy_load and "✓" or ""

        print(
            string.format(
                "%-25s %10.2f %10.2f %10.2f %12s %8s",
                data.modname:sub(1, 25),
                data.total_time,
                data.require_time or 0,
                data.setup_time or 0,
                setup_type:sub(1, 12),
                lazy_marker
            )
        )

        -- Show errors if any
        if data.error then
            print(string.format("  ERROR: %s", data.error))
        end
        if data.setup_error then
            print(string.format("  SETUP ERROR: %s", data.setup_error))
        end

        ::continue::
    end

    print(string.rep("=", 85))
end

function M.clear()
    M.timings = {}
    print("Plugin timing data cleared")
end

-- Setup commands for easy use
function M.setup()
    vim.api.nvim_create_user_command("ProfilerReport", function(args)
        local limit = tonumber(args.args) or 20
        M.report({ limit = limit })
    end, { nargs = "?" })

    -- FIX: needs to be moved to fennel to actually work
    vim.api.nvim_create_user_command("PluginTimingClear", function()
        M.clear()
    end, {})
end

return M
