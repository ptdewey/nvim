-- sprig: fennel compile-on-save
-- Place a .sprig.lua in any project root to configure compilation.
--
-- Config format (.sprig.lua):
--   return {
--     ignore   = { "flsproject%.fnl" },                -- patterns to skip
--     macros   = { "fnl/macros.fnl" },                 -- macro-only files (not compiled)
--     paths    = { ["fnl/(.*)%.fnl"] = "lua/%1.lua" }, -- custom output mapping
--     compiler = { correlate = true, allowGlobals = true }, -- fennel compiler opts
--   }
--
-- Without a paths table, output goes to ~/.cache/nvim/sprig/<rel>.lua
-- with fnl/ remapped to lua/.

local M = {}

-- Derive nvim config dir from this file's location (lua/sprig.lua -> config root)
local nvim_config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local cache_dir = vim.fn.stdpath("cache") .. "/sprig"

--- Find .sprig.lua config by walking up from the given file path.
--- Returns (config_table, project_root) or (nil, nil).
local config_cache = {}
local function find_config(fnl_path)
    local dir = vim.fn.fnamemodify(fnl_path, ":h")
    if config_cache[dir] ~= nil then
        local cached = config_cache[dir]
        if cached == false then
            return nil, nil
        end
        return cached.config, cached.root
    end

    local found = vim.fn.findfile(".sprig.lua", dir .. ";")
    if found == "" then
        config_cache[dir] = false
        return nil, nil
    end

    local config_path = vim.fn.fnamemodify(found, ":p")
    local root = vim.fn.fnamemodify(config_path, ":h")
    local ok, cfg = pcall(dofile, config_path)
    if not ok or type(cfg) ~= "table" then
        cfg = {}
    end

    config_cache[dir] = { config = cfg, root = root }
    return cfg, root
end

--- Check if a file should be ignored based on its project config.
local function is_ignored(fnl_path, cfg, root)
    if not cfg or not cfg.ignore then
        return false
    end
    local rel = fnl_path:sub(#root + 2)
    for _, pattern in ipairs(cfg.ignore) do
        if rel:match(pattern) then
            return true
        end
    end
    return false
end

--- Map a .fnl path to its .lua output path.
--- If the project config has a `paths` table, use pattern matching against it.
--- Otherwise, fall back to the default cache-based mapping.
local function fnl_to_lua_path(fnl_path, cfg, root)
    if cfg and cfg.paths then
        local rel = fnl_path:sub(#root + 2)
        for pattern, replacement in pairs(cfg.paths) do
            local mapped = rel:gsub(pattern, replacement)
            if mapped ~= rel then
                return root .. "/" .. mapped
            end
        end
    end

    -- Default: output to cache dir, remap fnl/ -> lua/
    local rel = fnl_path:sub(#root + 2):gsub("^fnl/", "lua/"):gsub("%.fnl$", ".lua")
    return cache_dir .. "/" .. rel
end

--- Check if a file is a macro-only file based on the config's macros list.
local function is_macro_file(fnl_path, cfg, root)
    if not cfg or not cfg.macros then
        return false
    end
    local rel = fnl_path:sub(#root + 2)
    for _, pattern in ipairs(cfg.macros) do
        if rel:match(pattern) then
            return true
        end
    end
    return false
end

--- Load vendored fennel and set up macro-path once.
local function get_fennel()
    if M._fennel then
        return M._fennel
    end
    local chunk = loadfile(nvim_config_dir .. "/deps/fennel-1.6.1.lua")
    local saved_arg, saved_print = arg, print
    arg = { "--version" }
    print = function() end
    pcall(chunk)
    arg, print = saved_arg, saved_print
    local fennel = require("fennel")
    local macro_path = nvim_config_dir .. "/fnl/?.fnl;" .. nvim_config_dir .. "/fnl/?/init.fnl"
    fennel["macro-path"] = macro_path .. ";" .. (fennel["macro-path"] or "")
    M._fennel = fennel
    return fennel
end

--- Compile a single .fnl file to .lua.
function M.compile(fnl_path)
    fnl_path = vim.fn.resolve(fnl_path)

    local cfg, root = find_config(fnl_path)
    if not root then
        return
    end

    if is_ignored(fnl_path, cfg, root) or is_macro_file(fnl_path, cfg, root) then
        return
    end

    local f = io.open(fnl_path, "r")
    if not f then
        vim.notify("sprig: cannot read " .. fnl_path, vim.log.levels.ERROR)
        return
    end
    local source = f:read("*a")
    f:close()

    local fennel = get_fennel()

    local compiler_opts = cfg and cfg.compiler or {}
    local compile_opts = {
        filename = fnl_path,
        compilerEnv = compiler_opts.compilerEnv or _G,
        allowGlobals = compiler_opts.allowGlobals ~= false,
        correlate = compiler_opts.correlate or false,
    }

    -- Temporarily prepend project-local macro paths for non-nvim-config projects
    local saved_macro_path
    if root ~= nvim_config_dir then
        saved_macro_path = fennel["macro-path"]
        fennel["macro-path"] = root
            .. "/fnl/?.fnl;"
            .. root
            .. "/fnl/?/init.fnl;"
            .. fennel["macro-path"]
    end

    local ok, result = pcall(fennel.compileString, source, compile_opts)

    if saved_macro_path then
        fennel["macro-path"] = saved_macro_path
    end
    if not ok then
        vim.notify("sprig: " .. tostring(result), vim.log.levels.ERROR)
        return
    end

    local lua_path = fnl_to_lua_path(fnl_path, cfg, root)
    vim.fn.mkdir(vim.fn.fnamemodify(lua_path, ":h"), "p")

    local out = io.open(lua_path, "w")
    if not out then
        vim.notify("sprig: cannot write " .. lua_path, vim.log.levels.ERROR)
        return
    end
    out:write(result)
    out:close()
end

--- Compile all .fnl files under a given root (defaults to nvim config dir).
function M.compile_all(root)
    root = root or nvim_config_dir
    local files = vim.fn.globpath(root, "**/*.fnl", false, true)
    local count = 0
    for _, fnl_path in ipairs(files) do
        M.compile(fnl_path)
        count = count + 1
    end
    vim.notify("sprig: compiled " .. count .. " files")
end

function M.setup()
    -- Bootstrap: if cache dir is empty, compile everything now before anything else loads
    local existing = vim.fn.globpath(cache_dir, "**/*.lua", false, true)
    if #existing == 0 then
        M.compile_all()
        -- Ensure newly compiled files are discoverable by both neovim and raw require
        package.path = cache_dir .. "/lua/?.lua;" .. cache_dir .. "/lua/?/init.lua;" .. package.path
        vim.loader.reset()
    end

    local group = vim.api.nvim_create_augroup("sprig", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.fnl",
        group = group,
        callback = function(ev)
            M.compile(ev.match)
        end,
    })

    vim.api.nvim_create_user_command("SprigCompileAll", function()
        M.compile_all()
    end, { desc = "Compile all .fnl files to .lua" })
end

return M
