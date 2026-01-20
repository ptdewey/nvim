vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/ptdewey/lazydev.nvim" },
    -- { src = "https://github.com/ray-x/lsp_signature.nvim" },
})

local p = require("profiler")

-- TODO: figure out if there is a way to keep this up to date with mason install dir (i.e. append all binary names)
-- - there are also linters/formatters so this may cause issues (possibly write my own mason fork that stores to separate dirs? -- use mason registry)
local servers = {
    "lua_ls",
    "gopls",
    "ts_ls",
    "ruff",
    "pyright",
    "tinymist",
    "harper_ls",
    "rust_analyzer",
    "svelte",
    "just",
    "nil_ls",
    "fennel_ls",
    "jsonls",
    "gleam",
    "html",
    "cssls",
    "erlangls",
}
-- TODO: move lsp registration list somewhere else (possibly a text file that is read from/appended to?)

-- Avoid loading mason
-- TODO: load mason if directory does not exist
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

vim.api.nvim_create_user_command("Mason", function()
    vim.api.nvim_del_user_command("Mason")
    require("profiler").require_and_setup("mason")
    vim.cmd("Mason")
end, {})

-- TODO: delete command during callback (make a BufEnter group, delete group)
local group = vim.api.nvim_create_augroup("LazyDevSetup", {})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua" },
    group = group,
    callback = function()
        p.require_and_setup("lazydev", {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "lazy.nvim",
            },
        })
        vim.api.nvim_del_augroup_by_id(group)
    end,
})
