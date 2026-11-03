-- Run from the repository root: nvim --headless -u NONE -l tests/pack.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local calls = {}
local loaded = {}
vim.pack.add = function(specs, opts)
    calls[#calls + 1] = { specs = specs, opts = opts }
end
package.loaded.lze = {
    load = function(spec)
        loaded[#loaded + 1] = spec
    end,
}

local pack = require("config.pack")
assert(pack.spec == nil, "pack.add should be the only public helper")
local after = function() end
local version = vim.version.range("1.*")
local opts = { name = "example", version = version, event = "InsertEnter", after = after }
local original_opts = vim.deepcopy(opts)
pack.add("https://example.com/plugin", opts)
assert(#calls == 1 and #calls[1].specs == 1)
local spec = calls[1].specs[1]
assert(spec.src == "https://example.com/plugin")
assert(spec.name == "example" and spec.version == version)
assert(spec.event == nil and spec.after == nil)
assert(spec.data.event == "InsertEnter" and spec.data.after == after)
assert(spec.data.src == nil and spec.data.name == nil and spec.data.version == nil)
assert(vim.deep_equal(opts, original_opts), "add must not change caller options")
assert(calls[1].opts.confirm == false)
assert(#loaded == 0, "plugin configuration must wait for vim.pack's load callback")
calls[1].opts.load({ spec = spec })
assert(#loaded == 1)
assert(loaded[1].name == "example" and loaded[1].event == "InsertEnter")
assert(loaded[1].after == after)

local plugins = {
    { src = "https://example.com/plain" },
    { src = "https://example.com/dependency", name = "dep", dep_of = "example", after = after },
    { src = "https://example.com/disabled", enabled = false },
}
local original_plugins = vim.deepcopy(plugins)
pack.add(plugins)
local specs = calls[2].specs
assert(#specs == 3 and calls[2].opts.confirm == false)
assert(vim.deep_equal(specs[1], { src = "https://example.com/plain" }))
assert(specs[2].name == "dep" and specs[2].data.dep_of == "example")
assert(specs[2].data.after == after)
assert(specs[3].data.enabled == false)
assert(vim.deep_equal(plugins, original_plugins), "add must not change batch declarations")
-- vim.pack supplies an inferred name even when one wasn't specified.
calls[2].opts.load({ spec = { src = specs[1].src, name = "plain" } })
assert(vim.deep_equal(loaded[2], { name = "plain" }))
calls[2].opts.load({ spec = specs[2] })
assert(loaded[3].name == "dep" and loaded[3].dep_of == "example")
assert(vim.deep_equal(plugins, original_plugins), "loading must not change batch declarations")

pack.add("https://example.com/simple")
assert(vim.deep_equal(calls[3].specs, { { src = "https://example.com/simple" } }))
pack.add({})
assert(#calls[4].specs == 0)
print("config.pack tests passed")
