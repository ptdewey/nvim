vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

local filename = vim.fn.expand("%:t")
if filename == "openapi.yaml" or filename == "openapi.yml" then
    vim.lsp.start({
        cmd = { "vacuum", "language-server" },
        filetypes = { "yaml" },
    })
end
