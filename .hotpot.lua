-- By default, the Fennel compiler wont complain if unknown variables are
-- referenced, we can force a compiler error so we don't try to run faulty code.
return {
    provide_require_fennel = true,
    enable_hotpot_diagnostics = false,
    compiler = {
        macros = {
            allowGlobals = true,
            compilerEnv = _G,
            env = "_COMPILER",
        },
        modules = {
            correlate = true,
            useBitLib = true,
        },
    },
    build = {
        { verbose = false, atomic = true },
        { "fnl/*macro*.fnl", false },
        -- { "plugin/**/*.fnl", false },
        -- { "fnl/macro*/**.fnl", false },
        -- { "fnl/**/*.fnl", false },
        -- { "lsp/*.fnl", false }, -- fnl files in `lsp/` are not cached by hotpot
    },
    -- remove stale lua/ files
    clean = false,
}
