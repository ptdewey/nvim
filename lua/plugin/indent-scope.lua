vim.pack.add({
    {
        src = "https://github.com/lukas-reineke/indent-blankline.nvim",
        data = {
            event = { "BufReadPost", "BufNewFile" },
            after = function()
                require("profiler").require_and_setup("ibl", {
                    scope = { enabled = false },
                })
            end,
        },
    },
}, require("pack").opts)
