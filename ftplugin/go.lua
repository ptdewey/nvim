vim.bo.expandtab = false

-- Go Auto Import commands
local go_auto_import = require("go_auto_import")

-- Command to manually import a package by alias
vim.api.nvim_buf_create_user_command(0, "GoImport", function(opts)
    local alias = opts.args
    if alias == "" then
        vim.notify("Usage: :GoImport <alias>", vim.log.levels.ERROR)
        return
    end
    go_auto_import.auto_import(alias)
end, {
    nargs = 1,
    desc = "Import a Go package by its alias",
    complete = function(_, _, _)
        return go_auto_import.list_aliases()
    end,
})

-- Command to refresh the package registry cache
vim.api.nvim_buf_create_user_command(0, "GoImportRefresh", function()
    go_auto_import.refresh_cache()
end, {
    desc = "Refresh the Go package registry cache",
})

-- Command to show all possible imports for an alias
vim.api.nvim_buf_create_user_command(0, "GoImportShow", function(opts)
    local alias = opts.args
    if alias == "" then
        vim.notify("Usage: :GoImportShow <alias>", vim.log.levels.ERROR)
        return
    end
    local paths = go_auto_import.get_all_import_paths(alias)
    if #paths == 0 then
        vim.notify(string.format("No imports found for alias '%s'", alias), vim.log.levels.WARN)
        return
    end

    local lines = { string.format("Import paths for '%s':", alias) }
    for _, p in ipairs(paths) do
        local source_info = p.source == "stdlib" and " (stdlib)" or string.format(" (count: %d)", p.count)
        table.insert(lines, string.format("  %s%s", p.path, source_info))
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, {
    nargs = 1,
    desc = "Show all possible import paths for an alias",
    complete = function(_, _, _)
        return go_auto_import.list_aliases()
    end,
})

-- Command to select and import from multiple options
vim.api.nvim_buf_create_user_command(0, "GoImportSelect", function(opts)
    local alias = opts.args
    if alias == "" then
        vim.notify("Usage: :GoImportSelect <alias>", vim.log.levels.ERROR)
        return
    end

    local paths = go_auto_import.get_all_import_paths(alias)
    if #paths == 0 then
        vim.notify(string.format("No imports found for alias '%s'", alias), vim.log.levels.WARN)
        return
    end

    if #paths == 1 then
        go_auto_import.add_import(0, paths[1].path, alias)
        vim.notify(string.format("Imported: %s", paths[1].path), vim.log.levels.INFO)
        return
    end

    -- Multiple options - use vim.ui.select
    local items = {}
    for _, p in ipairs(paths) do
        local source_info = p.source == "stdlib" and " (stdlib)" or string.format(" (count: %d)", p.count)
        table.insert(items, { path = p.path, display = p.path .. source_info })
    end

    vim.ui.select(items, {
        prompt = string.format("Select import for '%s':", alias),
        format_item = function(item)
            return item.display
        end,
    }, function(choice)
        if choice then
            go_auto_import.add_import(0, choice.path, alias)
            vim.notify(string.format("Imported: %s", choice.path), vim.log.levels.INFO)
        end
    end)
end, {
    nargs = 1,
    desc = "Select and import from multiple options for an alias",
    complete = function(_, _, _)
        return go_auto_import.list_aliases()
    end,
})
