local pack = require("config.pack")

vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    {
        src = "https://github.com/williamboman/mason.nvim",
        cmd = "Mason",
        after = function()
            require("mason").setup()
        end,
    },
})

-- TODO: also search `lsp/` for configs, append here.
-- This list primarily pulls in lspconfig configurations.
local servers = {
    "gopls",
    "lua_ls",
    "templ",
    "harper_ls",
    "just",
    "nil_ls",
    "fennel_ls",
    "jsonls",
    "html",
    "cssls",
    "ts_ls",
    "rust_analyzer",
    "ts_query_ls",
    "pyright",
    "ruff",
    "gleam",
    "elixirls",
    "dexter",
    -- "expert",
    "svelte",
    "tinymist",
    "postgres_lsp",
    "starlark_rust",
}
for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

vim.cmd.highlight("default link LspInlayHint Comment")
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("InlayHints", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if
            client
            and (
                client:supports_method("textDocument/inlayHint")
                or client.server_capabilities.inlayHintProvider
            )
        then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})

-- Built in LSP auto-completion
-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         if client:supports_method("textDocument/completion") then
--             vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
--         end
--     end,
-- })

vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("e" .. vim.fn.expand("$HOME/.local/state/nvim/lsp.log"))
end, { nargs = 0 })
