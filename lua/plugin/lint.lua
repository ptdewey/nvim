vim.pack.add({
    { src = "https://github.com/mfussenegger/nvim-lint" },
})

-- TODO: lazy load on bufwritepost
require("profiler").require("lint").linters_by_ft = {
    go = { "golangcilint" },
    sh = { "shellcheck" },
    lua = { "selene" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
        require("lint").try_lint()
    end,
})
