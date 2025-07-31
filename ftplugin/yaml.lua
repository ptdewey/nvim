local options = {
    tabstop = 2,
    shiftwidth = 2,
}

for k, v in pairs(options) do
    vim.opt_local[k] = v
end

local filename = vim.fn.expand("%:t")
if filename == "openapi.yaml" or filename == "openapi.yml" then
    vim.lsp.start({
        cmd = { "vacuum", "language-server" },
        filetypes = { "yaml" },
    })
end
