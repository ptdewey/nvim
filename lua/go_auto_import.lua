-- Go Auto Import Module
-- Provides functionality to automatically import Go packages based on alias usage
-- Resolves conflicts by counting occurrences in the codebase

local M = {}

-- Cache for package registry: alias -> { path = string, count = number }[]
-- Populated by scanning the codebase
M.package_registry = {}

-- Cache timestamp to know when to refresh
M.cache_time = 0
M.cache_ttl = 300 -- 5 minutes

-- Common standard library packages (alias -> import path)
-- These serve as fallbacks when no codebase matches are found
M.stdlib = {
    fmt = "fmt",
    os = "os",
    io = "io",
    log = "log",
    time = "time",
    strings = "strings",
    strconv = "strconv",
    bytes = "bytes",
    bufio = "bufio",
    errors = "errors",
    context = "context",
    sync = "sync",
    sort = "sort",
    math = "math",
    rand = "math/rand",
    regexp = "regexp",
    json = "encoding/json",
    xml = "encoding/xml",
    base64 = "encoding/base64",
    hex = "encoding/hex",
    binary = "encoding/binary",
    http = "net/http",
    url = "net/url",
    filepath = "path/filepath",
    path = "path",
    reflect = "reflect",
    runtime = "runtime",
    testing = "testing",
    flag = "flag",
    ioutil = "io/ioutil",
    template = "text/template",
    html = "html/template",
    sql = "database/sql",
    exec = "os/exec",
    signal = "os/signal",
    user = "os/user",
    atomic = "sync/atomic",
    cipher = "crypto/cipher",
    sha256 = "crypto/sha256",
    sha512 = "crypto/sha512",
    md5 = "crypto/md5",
    tls = "crypto/tls",
    x509 = "crypto/x509",
    rsa = "crypto/rsa",
    ecdsa = "crypto/ecdsa",
    ed25519 = "crypto/ed25519",
    pem = "encoding/pem",
    asn1 = "encoding/asn1",
    gob = "encoding/gob",
    csv = "encoding/csv",
    tar = "archive/tar",
    zip = "archive/zip",
    gzip = "compress/gzip",
    zlib = "compress/zlib",
    heap = "container/heap",
    list = "container/list",
    ring = "container/ring",
    embed = "embed",
    fs = "io/fs",
    slog = "log/slog",
    slices = "slices",
    maps = "maps",
    cmp = "cmp",
}

-- Scan a single Go file and extract import aliases and paths
-- Returns a table of { alias = string, path = string }
local function scan_file_imports(filepath)
    local imports = {}
    local file = io.open(filepath, "r")
    if not file then
        return imports
    end

    local content = file:read("*all")
    file:close()

    -- Match import blocks: import ( ... )
    for import_block in content:gmatch("import%s*%((.-)%)") do
        -- Match each import line: optional_alias "path"
        for line in import_block:gmatch("[^\n]+") do
            -- Skip comments
            if not line:match("^%s*//") then
                -- Match: alias "path" or just "path"
                local alias, path = line:match('%s*([%w_]+)%s+"([^"]+)"')
                if alias and path then
                    table.insert(imports, { alias = alias, path = path })
                else
                    -- No alias, extract from path
                    path = line:match('"([^"]+)"')
                    if path then
                        -- Get the last component of the path as the alias
                        local inferred_alias = path:match("([^/]+)$")
                        -- Handle versioned paths like v2, v3
                        if inferred_alias and inferred_alias:match("^v%d+$") then
                            inferred_alias = path:match("([^/]+)/v%d+$")
                        end
                        if inferred_alias then
                            table.insert(imports, { alias = inferred_alias, path = path })
                        end
                    end
                end
            end
        end
    end

    -- Match single-line imports: import "path" or import alias "path"
    for line in content:gmatch("import%s+[^\n(]+") do
        if not line:match("%(") then
            local alias, path = line:match('import%s+([%w_]+)%s+"([^"]+)"')
            if alias and path then
                table.insert(imports, { alias = alias, path = path })
            else
                path = line:match('import%s+"([^"]+)"')
                if path then
                    local inferred_alias = path:match("([^/]+)$")
                    if inferred_alias and inferred_alias:match("^v%d+$") then
                        inferred_alias = path:match("([^/]+)/v%d+$")
                    end
                    if inferred_alias then
                        table.insert(imports, { alias = inferred_alias, path = path })
                    end
                end
            end
        end
    end

    return imports
end

-- Find all Go files in the current project
local function find_go_files()
    local cwd = vim.fn.getcwd()
    local files = {}

    -- Use ripgrep if available for speed, otherwise fall back to find
    local cmd
    if vim.fn.executable("rg") == 1 then
        cmd = string.format("rg --files --type go %s 2>/dev/null", vim.fn.shellescape(cwd))
    else
        cmd = string.format("find %s -name '*.go' -type f 2>/dev/null", vim.fn.shellescape(cwd))
    end

    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            table.insert(files, line)
        end
        handle:close()
    end

    return files
end

-- Scan the codebase and build/update the package registry
function M.scan_codebase()
    local now = os.time()
    if now - M.cache_time < M.cache_ttl and next(M.package_registry) ~= nil then
        return M.package_registry
    end

    local registry = {}
    local files = find_go_files()

    for _, filepath in ipairs(files) do
        local imports = scan_file_imports(filepath)
        for _, imp in ipairs(imports) do
            if not registry[imp.alias] then
                registry[imp.alias] = {}
            end

            -- Find or create entry for this path
            local found = false
            for _, entry in ipairs(registry[imp.alias]) do
                if entry.path == imp.path then
                    entry.count = entry.count + 1
                    found = true
                    break
                end
            end

            if not found then
                table.insert(registry[imp.alias], { path = imp.path, count = 1 })
            end
        end
    end

    -- Sort each alias's paths by count (descending)
    for alias, paths in pairs(registry) do
        table.sort(paths, function(a, b)
            return a.count > b.count
        end)
    end

    M.package_registry = registry
    M.cache_time = now
    return registry
end

-- Get the best import path for a given alias
-- Returns the import path or nil if not found
function M.get_import_path(alias)
    M.scan_codebase()

    -- Check codebase registry first
    if M.package_registry[alias] and #M.package_registry[alias] > 0 then
        return M.package_registry[alias][1].path
    end

    -- Fall back to stdlib
    if M.stdlib[alias] then
        return M.stdlib[alias]
    end

    return nil
end

-- Get all possible import paths for an alias (for disambiguation)
function M.get_all_import_paths(alias)
    M.scan_codebase()

    local paths = {}

    -- Add codebase matches
    if M.package_registry[alias] then
        for _, entry in ipairs(M.package_registry[alias]) do
            table.insert(paths, { path = entry.path, count = entry.count, source = "codebase" })
        end
    end

    -- Add stdlib if not already present
    if M.stdlib[alias] then
        local found = false
        for _, p in ipairs(paths) do
            if p.path == M.stdlib[alias] then
                found = true
                break
            end
        end
        if not found then
            table.insert(paths, { path = M.stdlib[alias], count = 0, source = "stdlib" })
        end
    end

    return paths
end

-- Check if import already exists in the current buffer
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

    local query = vim.treesitter.query.parse(
        "go",
        [[
            (import_spec path: (interpreted_string_literal) @path)
        ]]
    )

    local root = tree:root()
    for _, node in query:iter_captures(root, bufnr) do
        local text = vim.treesitter.get_node_text(node, bufnr)
        -- Remove quotes
        text = text:gsub('^"', ""):gsub('"$', "")
        if text == import_path then
            return true
        end
    end

    return false
end

-- Find the import declaration node in the buffer
local function find_import_declaration(bufnr)
    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil
    end

    local query = vim.treesitter.query.parse(
        "go",
        [[
            (import_declaration) @import
        ]]
    )

    local root = tree:root()
    for _, node in query:iter_captures(root, bufnr) do
        return node
    end

    return nil
end

-- Find the package declaration to insert import after it
local function find_package_declaration(bufnr)
    local parser = vim.treesitter.get_parser(bufnr, "go")
    if not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil
    end

    local query = vim.treesitter.query.parse(
        "go",
        [[
            (package_clause) @package
        ]]
    )

    local root = tree:root()
    for _, node in query:iter_captures(root, bufnr) do
        return node
    end

    return nil
end

-- Add an import to the current buffer
-- If alias is different from the package name inferred from path, it will be explicit
function M.add_import(bufnr, import_path, explicit_alias)
    bufnr = bufnr or 0

    -- Check if already imported
    if M.import_exists(bufnr, import_path) then
        return true
    end

    -- Determine if we need an explicit alias
    local inferred_alias = import_path:match("([^/]+)$")
    if inferred_alias and inferred_alias:match("^v%d+$") then
        inferred_alias = import_path:match("([^/]+)/v%d+$")
    end

    local import_line
    if explicit_alias and explicit_alias ~= inferred_alias then
        import_line = string.format('\t%s "%s"', explicit_alias, import_path)
    else
        import_line = string.format('\t"%s"', import_path)
    end

    local import_node = find_import_declaration(bufnr)

    if import_node then
        -- Add to existing import block
        local start_row, _, end_row, _ = import_node:range()

        -- Check if it's a single import or a block
        local import_text = vim.treesitter.get_node_text(import_node, bufnr)

        if import_text:match("import%s*%(") then
            -- Block import - insert before the closing paren
            local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

            -- Find the line with closing paren
            for i = #lines, 1, -1 do
                if lines[i]:match("^%s*%)") then
                    -- Insert before this line
                    vim.api.nvim_buf_set_lines(bufnr, start_row + i - 1, start_row + i - 1, false, { import_line })
                    return true
                end
            end
        else
            -- Single import - convert to block
            local single_path = import_text:match('import%s+"([^"]+)"')
            local single_alias = import_text:match('import%s+([%w_]+)%s+"')

            local new_lines
            if single_alias then
                new_lines = {
                    "import (",
                    string.format('\t%s "%s"', single_alias, single_path),
                    import_line,
                    ")",
                }
            else
                new_lines = {
                    "import (",
                    string.format('\t"%s"', single_path),
                    import_line,
                    ")",
                }
            end

            vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, new_lines)
            return true
        end
    else
        -- No import block exists, create one after package declaration
        local pkg_node = find_package_declaration(bufnr)
        if pkg_node then
            local _, _, end_row, _ = pkg_node:range()

            local new_lines = {
                "",
                "import (",
                import_line,
                ")",
            }

            vim.api.nvim_buf_set_lines(bufnr, end_row + 1, end_row + 1, false, new_lines)
            return true
        end
    end

    return false
end

-- Main function: auto-import a package by alias
-- Returns true if import was added, false otherwise
function M.auto_import(alias)
    local import_path = M.get_import_path(alias)
    if not import_path then
        vim.notify(string.format("No import found for alias '%s'", alias), vim.log.levels.WARN)
        return false
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local success = M.add_import(bufnr, import_path, alias)

    if success then
        vim.notify(string.format("Imported: %s", import_path), vim.log.levels.INFO)
    end

    return success
end

-- Force refresh the package registry cache
function M.refresh_cache()
    M.cache_time = 0
    M.scan_codebase()
    vim.notify("Go package registry refreshed", vim.log.levels.INFO)
end

-- List all known aliases (for debugging/completion)
function M.list_aliases()
    M.scan_codebase()

    local aliases = {}
    for alias, _ in pairs(M.package_registry) do
        table.insert(aliases, alias)
    end
    for alias, _ in pairs(M.stdlib) do
        if not M.package_registry[alias] then
            table.insert(aliases, alias)
        end
    end

    table.sort(aliases)
    return aliases
end

return M
