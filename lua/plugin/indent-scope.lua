vim.pack.add({
    {
        src = "https://github.com/lukas-reineke/indent-blankline.nvim",
        data = {
            event = "BufEnter",
            after = function()
                require("profiler").require_and_setup("ibl", {
                    scope = { enabled = false },
                })
            end,
        },
    },
}, {
    load = function(plug)
        local spec = plug.spec.data or {}
        spec.name = plug.spec.name
        require("lze").load(spec)
    end,
    confirm = false,
})
