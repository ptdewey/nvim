local skip_lsps = {
    ["svelte"] = true,
}

-- inlay hints
vim.api.nvim_create_augroup("InlayHints", { clear = true })
vim.cmd.highlight("default link LspInlayHint Comment")
vim.api.nvim_create_autocmd("LspAttach", {
    group = "InlayHints",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or skip_lsps[client.name] then
            return
        end

        if
            client:supports_method("textDocument/inlayHint")
            or client.server_capabilities.inlayHintProvider
        then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})

-- Builtin lsp autocompletion
-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(ev)
--         local client = vim.lsp.get_client_by_id(ev.data.client_id)
--         if client:supports_method("textDocument/completion") then
--             vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--         end
--     end,
-- })
