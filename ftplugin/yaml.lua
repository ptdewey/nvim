vim.bo.tabstop = 2
vim.bo.shiftwidth = 2

local filename = vim.fn.expand("%:t")
if filename == "openapi.yaml" or filename == "openapi.yml" then
    vim.lsp.start({
        cmd = { "vacuum", "language-server" },
        filetypes = { "yaml" },
    })
end
