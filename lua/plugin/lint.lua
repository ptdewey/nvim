vim.pack.add({
    {
        src = "https://github.com/mfussenegger/nvim-lint",
        data = {
            event = "BufWritePre",
            after = function()
                require("profiler").require("lint").linters_by_ft = {
                    go = { "golangcilint" },
                    sh = { "shellcheck" },
                    bash = { "shellcheck" },
                    lua = { "selene" },
                }

                vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                    callback = function()
                        require("lint").try_lint()
                    end,
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
    confirm = true,
})
