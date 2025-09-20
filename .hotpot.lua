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
        -- { verbose = false, atomic = true },
        { "fnl/*macro*.fnl", false },
        { "fnl/macro*/**.fnl", false },
        { "fnl/config/*.fnl", false },
        -- { "fnl/*.fnl", true },
        { "fnl/**/*.fnl", false },
        { "fnl/plugin/*.fnl", false },
        { "lsp/*.fnl", false },
    },
    -- remove stale lua/ files
    clean = false,
}
