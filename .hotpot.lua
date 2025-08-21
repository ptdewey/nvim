-- By default, the Fennel compiler wont complain if unknown variables are
-- referenced, we can force a compiler error so we don't try to run faulty code.
local allowed_globals = {}
for key, _ in pairs(_G) do
    table.insert(allowed_globals, key)
end

return {
    build = {
        -- { verbose = false, atomic = true },
        { "fnl/*macro*.fnl", false },
        { "fnl/macro*/**.fnl", false },
        { "fnl/config/*.fnl", false },
        { "fnl/**/*.fnl", false },
        { "fnl/plugin/*.fnl", false },
        { "lsp/*.fnl", false },
    },

    -- remove stale lua/ files
    clean = false,

    compiler = {
        modules = {
            -- enforce unknown variable errors
            allowedGlobals = allowed_globals,
        },
    },
}
