local options = {
    tabstop = 2,
    shiftwidth = 2,
}

for k, v in pairs(options) do
    vim.opt_local[k] = v
end

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "openapi.yaml", "openapi.yml", "openapi.json" },
    callback = function()
        vim.lsp.start({
            cmd = { "vacuum", "language-server" },
            filetypes = { "yaml", "json" },
        })
    end,
})
