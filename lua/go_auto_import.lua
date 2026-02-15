local M = {}

M.package_registry = {}
M.cache_time = 0
M.cache_ttl = 300
M.stdlib = nil

-- Infer alias from an import path, handling versioned paths (v2, v3, etc.)
local function alias_from_path(path)
    local alias = path:match("([^/]+)$")
    if alias and alias:match("^v%d+$") then
        alias = path:match("([^/]+)/v%d+$")
    end
    return alias
end

-- Build stdlib alias→path map from `go list std`, cached once per session.
-- Conflicting aliases (e.g. math/rand vs crypto/rand) are omitted;
-- the codebase scan resolves them once they've been used.
local function load_stdlib()
    if M.stdlib then
        return M.stdlib
    end
    M.stdlib = {}
    local handle = io.popen("go list std 2>/dev/null")
    if not handle then
        return M.stdlib
    end
    local conflicts = {}
    for path in handle:lines() do
        if not path:match("internal") and not path:match("vendor") then
            local alias = alias_from_path(path)
            if alias then
                if M.stdlib[alias] then
                    conflicts[alias] = true
                else
                    M.stdlib[alias] = path
                end
            end
        end
    end
    handle:close()
    for alias in pairs(conflicts) do
        M.stdlib[alias] = nil
    end
    return M.stdlib
end

-- Parse a single import line, returning { alias, path } or nil
local function parse_import_line(line, prefix)
    if line:match("^%s*//") then
        return nil
    end
    local pattern = prefix or ""
    local alias, path = line:match(pattern .. '%s*([%w_]+)%s+"([^"]+)"')
    if alias and path then
        return { alias = alias, path = path }
    end
    path = line:match(pattern .. '%s*"([^"]+)"')
    if not path then
        return nil
    end
    local inferred = alias_from_path(path)
    return inferred and { alias = inferred, path = path }
end

local function scan_file_imports(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return {}
    end
    local content = file:read("*all")
    file:close()

    local imports = {}
    -- Block imports: import ( ... )
    for block in content:gmatch("import%s*%((.-)%)") do
        for line in block:gmatch("[^\n]+") do
            local imp = parse_import_line(line)
            if imp then
                table.insert(imports, imp)
            end
        end
    end
    -- Single-line imports: import "path" or import alias "path"
    for line in content:gmatch("import%s+[^\n(]+") do
        if not line:match("%(") then
            local imp = parse_import_line(line, "import")
            if imp then
                table.insert(imports, imp)
            end
        end
    end
    return imports
end

local function find_go_files()
    local cwd = vim.fn.getcwd()
    local cmd = vim.fn.executable("rg") == 1
            and string.format("rg --files --type go %s 2>/dev/null", vim.fn.shellescape(cwd))
        or string.format("find %s -name '*.go' -type f 2>/dev/null", vim.fn.shellescape(cwd))
    local files = {}
    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            table.insert(files, line)
        end
        handle:close()
    end
    return files
end

function M.scan_codebase()
    local now = os.time()
    if now - M.cache_time < M.cache_ttl and next(M.package_registry) ~= nil then
        return M.package_registry
    end

    local registry = {}
    for _, filepath in ipairs(find_go_files()) do
        for _, imp in ipairs(scan_file_imports(filepath)) do
            local entries = registry[imp.alias]
            if not entries then
                entries = {}
                registry[imp.alias] = entries
            end
            local found = false
            for _, entry in ipairs(entries) do
                if entry.path == imp.path then
                    entry.count = entry.count + 1
                    found = true
                    break
                end
            end
            if not found then
                table.insert(entries, { path = imp.path, count = 1 })
            end
        end
    end

    for _, paths in pairs(registry) do
        table.sort(paths, function(a, b)
            return a.count > b.count
        end)
    end

    M.package_registry = registry
    M.cache_time = now
    return registry
end

function M.get_import_path(alias)
    M.scan_codebase()
    local reg = M.package_registry[alias]
    if reg and #reg > 0 then
        return reg[1].path
    end
    return load_stdlib()[alias]
end

function M.get_all_import_paths(alias)
    M.scan_codebase()
    local stdlib = load_stdlib()
    local paths = {}
    if M.package_registry[alias] then
        for _, entry in ipairs(M.package_registry[alias]) do
            table.insert(paths, { path = entry.path, count = entry.count, source = "codebase" })
        end
    end
    if stdlib[alias] then
        local already = false
        for _, p in ipairs(paths) do
            if p.path == stdlib[alias] then
                already = true
                break
            end
        end
        if not already then
            table.insert(paths, { path = stdlib[alias], count = 0, source = "stdlib" })
        end
    end
    return paths
end

-- Run a treesitter query on the buffer root, return first captured node
local function ts_query_first(bufnr, query_str)
    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return nil
    end
    local tree = parser:parse()[1]
    if not tree then
        return nil
    end
    local query = vim.treesitter.query.parse("go", query_str)
    for _, node in query:iter_captures(tree:root(), bufnr) do
        return node
    end
end

function M.import_exists(bufnr, import_path)
    bufnr = bufnr or 0
    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return false
    end
    local tree = parser:parse()[1]
    if not tree then
        return false
    end
    local query =
        vim.treesitter.query.parse("go", "(import_spec path: (interpreted_string_literal) @path)")
    for _, node in query:iter_captures(tree:root(), bufnr) do
        local text = vim.treesitter.get_node_text(node, bufnr):gsub('^"', ""):gsub('"$', "")
        if text == import_path then
            return true
        end
    end
    return false
end

function M.add_import(bufnr, import_path, explicit_alias)
    bufnr = bufnr or 0
    if M.import_exists(bufnr, import_path) then
        return true
    end

    local inferred = alias_from_path(import_path)
    local import_line = (explicit_alias and explicit_alias ~= inferred)
            and string.format('\t%s "%s"', explicit_alias, import_path)
        or string.format('\t"%s"', import_path)

    local import_node = ts_query_first(bufnr, "(import_declaration) @import")
    if import_node then
        local start_row, _, end_row, _ = import_node:range()
        local import_text = vim.treesitter.get_node_text(import_node, bufnr)

        if import_text:match("import%s*%(") then
            local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
            for i = #lines, 1, -1 do
                if lines[i]:match("^%s*%)") then
                    vim.api.nvim_buf_set_lines(
                        bufnr,
                        start_row + i - 1,
                        start_row + i - 1,
                        false,
                        { import_line }
                    )
                    return true
                end
            end
        else
            local single_path = import_text:match('import%s+"([^"]+)"')
            local single_alias = import_text:match('import%s+([%w_]+)%s+"')
            local existing = single_alias and string.format('\t%s "%s"', single_alias, single_path)
                or string.format('\t"%s"', single_path)
            vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {
                "import (",
                existing,
                import_line,
                ")",
            })
            return true
        end
    else
        local pkg_node = ts_query_first(bufnr, "(package_clause) @package")
        if pkg_node then
            local _, _, end_row, _ = pkg_node:range()
            vim.api.nvim_buf_set_lines(bufnr, end_row + 1, end_row + 1, false, {
                "",
                "import (",
                import_line,
                ")",
            })
            return true
        end
    end
    return false
end

function M.auto_import(alias)
    local import_path = M.get_import_path(alias)
    if not import_path then
        vim.notify(string.format("No import found for alias '%s'", alias), vim.log.levels.WARN)
        return false
    end
    local success = M.add_import(vim.api.nvim_get_current_buf(), import_path, alias)
    if success then
        vim.notify(string.format("Imported: %s", import_path), vim.log.levels.INFO)
    end
    return success
end

function M.refresh_cache()
    M.cache_time = 0
    M.stdlib = nil
    M.scan_codebase()
    vim.notify("Go package registry refreshed", vim.log.levels.INFO)
end

function M.list_aliases()
    M.scan_codebase()
    local aliases = {}
    for alias in pairs(M.package_registry) do
        table.insert(aliases, alias)
    end
    for alias in pairs(load_stdlib()) do
        if not M.package_registry[alias] then
            table.insert(aliases, alias)
        end
    end
    table.sort(aliases)
    return aliases
end

return M
