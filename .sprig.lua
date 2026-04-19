return {
    compiler = { correlate = false },
    ignore = { "flsproject%.fnl" },
    macros = { "fnl/macros%.fnl" },
    paths = {
        ["^fnl/sprig%.fnl$"] = "lua/sprig.lua"
    }
}
