-- Global require profiling (must be first, before any other requires)
local _require = require
local _require_timings = {}
local _require_stack = {}
local _boot_time = vim.uv.hrtime()
_G.__require_timings = _require_timings
_G.__boot_time = _boot_time

_G.require = function(modname)
    if package.loaded[modname] then
        return package.loaded[modname]
    end
    local parent = _require_stack[#_require_stack]
    _require_stack[#_require_stack + 1] = modname

    local start = vim.uv.hrtime()
    local ok, result = pcall(_require, modname)
    local elapsed = (vim.uv.hrtime() - start) / 1e6

    _require_stack[#_require_stack] = nil

    _require_timings[modname] = {
        modname = modname,
        total_time = elapsed,
        parent = parent,
        depth = #_require_stack,
        load_start = (start - _boot_time) / 1e6,
        phase = vim.v.vim_did_enter == 1 and "runtime" or "startup",
        trigger = _G.__current_trigger or "init",
        source = "require",
    }

    if not ok then
        error(result, 2)
    end
    return result
end

-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Import required plugins (fennel interpreter and lazy loader)
vim.pack.add({
    -- { src = "https://github.com/rktjmp/hotpot.nvim", version = "v0.15.0" },
    { src = "https://github.com/ptdewey/hotpot.nvim" }, -- Note: using my fork for `lsp/` support
    { src = "https://github.com/BirdeeHub/lze" },
}, { confirm = false })

require("hotpot").setup({
    enable_hotpot_diagnostics = false,
})

-- Can only be loaded after hotpot
require("profiler").setup()

-- Load themes first
-- require("plugin.theme")

-- load required files
-- require("config.maps")
-- require("config.opts")
-- require("autocmds")

-- Load all files in plugin directories
-- require("pack")
-- require("plugin")
-- require("plugins")
