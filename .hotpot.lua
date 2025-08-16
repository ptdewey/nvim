-- By default, the Fennel compiler wont complain if unknown variables are
-- referenced, we can force a compiler error so we don't try to run faulty code.
local allowed_globals = { vim }
for key, _ in pairs(_G) do
    table.insert(allowed_globals, key)
end

return {
    build = {
        -- { verbose = false, atomic = true },
        { "fnl/*macro*.fnl", false },
        { "fnl/macro*/**.fnl", false },
        { "fnl/**/*.fnl", true },
        { "fnl/plugin/*.fnl", false },
        { "lsp/*.fnl", true },
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
