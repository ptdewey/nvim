-- Plugin Timer - Track initialization and setup times for Neovim plugins
local M = {}

-- Storage for timing data
M.timings = {}
M.enabled = true

-- High-resolution timer utilities
local function now()
    return vim.loop.hrtime()
end

local function ns_to_ms(nanoseconds)
    return nanoseconds / 1e6
end

-- Load multiple plugins and track each
function M.time_plugins(plugins)
    local results = {}
    local total_start = now()

    for _, plugin_spec in ipairs(plugins) do
        if type(plugin_spec) == "string" then
            results[plugin_spec] = M.time_plugin(plugin_spec)
        elseif type(plugin_spec) == "table" then
            local name = plugin_spec.name or plugin_spec[1]
            results[name] = M.time_plugin(name, plugin_spec)
        end
    end

    local total_time = ns_to_ms(now() - total_start)

    return results, total_time
end

-- Batch timing for lazy loading scenarios
function M.time_lazy_load(trigger_name, plugins)
    local batch_start = now()
    local results = {}

    for _, plugin_spec in ipairs(plugins) do
        local name = type(plugin_spec) == "string" and plugin_spec or plugin_spec[1]
        local plugin = M.time_plugin(name, plugin_spec)
        results[name] = plugin

        -- Mark this as lazy-loaded
        if M.timings[name] then
            M.timings[name].lazy_trigger = trigger_name
            M.timings[name].lazy_load = true
        end
    end

    local batch_time = ns_to_ms(now() - batch_start)

    -- Store batch timing
    M.timings["__batch_" .. trigger_name] = {
        name = trigger_name,
        type = "lazy_batch",
        total_time = batch_time,
        plugin_count = #plugins,
        timestamp = os.time(),
    }

    return results, batch_time
end

-- Get timing results with filtering and sorting
function M.get_results(opts)
    opts = opts or {}
    local results = {}

    for name, data in pairs(M.timings) do
        -- Skip batch entries if not requested
        if not opts.include_batches and name:match("^__batch_") then
            goto continue
        end

        -- Filter by minimum time
        if opts.min_time and data.total_time < opts.min_time then
            goto continue
        end

        -- Filter by plugin name pattern
        if opts.pattern and not name:match(opts.pattern) then
            goto continue
        end

        table.insert(results, data)
        ::continue::
    end

    -- Sort results
    local sort_by = opts.sort_by or "total_time"
    table.sort(results, function(a, b)
        local a_val = a[sort_by] or 0
        local b_val = b[sort_by] or 0
        return a_val > b_val
    end)

    return results
end

-- Pretty print timing report
function M.report(opts)
    opts = opts or {}
    -- local results = M.get_results(opts)
    local results = require("profiler").get_results(opts)
    local limit = opts.limit or 20

    print("\n" .. string.rep("=", 85))
    print("PLUGIN TIMING REPORT")
    print(string.rep("=", 85))

    -- Summary statistics
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

    -- Column headers
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

    -- Plugin data
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

-- Advanced: Track plugin dependencies
function M.time_with_dependencies(name, deps, opts)
    opts = opts or {}
    local dep_start = now()
    local loaded_deps = {}

    -- Load dependencies first
    if deps and #deps > 0 then
        for _, dep in ipairs(deps) do
            if type(dep) == "string" then
                loaded_deps[dep] = M.time_plugin(dep)
            elseif type(dep) == "table" then
                local dep_name = dep.name or dep[1]
                loaded_deps[dep_name] = M.time_plugin(dep_name, dep)
            end
        end
    end

    local dep_time = ns_to_ms(now() - dep_start)

    -- Load main plugin
    local plugin = M.time_plugin(name, opts)

    -- Update timing data with dependency info
    if M.timings[name] then
        M.timings[name].dependency_time = dep_time
        M.timings[name].dependencies = deps
        M.timings[name].total_with_deps = M.timings[name].total_time + dep_time
    end

    return plugin, loaded_deps
end

-- Clear timing data
function M.clear()
    M.timings = {}
    print("Plugin timing data cleared")
end

-- Setup commands for easy use
function M.setup()
    vim.api.nvim_create_user_command("PluginTimingReport", function(args)
        local limit = tonumber(args.args) or 20
        M.report({ limit = limit })
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("PluginTimingClear", function()
        M.clear()
    end, {})

    vim.api.nvim_create_user_command("PluginTimingToggle", function()
        local p = require("profiler")
        if p.enabled then
            p.disable()
            print("Plugin timing disabled")
        else
            p.enable()
            print("Plugin timing enabled")
        end
    end, {})
end

return M
