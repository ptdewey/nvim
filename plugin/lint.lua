local pack = require("config.pack")

pack.add("https://github.com/mfussenegger/nvim-lint", {
    event = "BufWritePre",
    after = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            go = { "golangcilint" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
        }
        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
})
