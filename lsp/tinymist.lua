return {
    filetypes = { "typst" },
    settings = {
        exportPdf = "onSave",
        formatterMode = "typstyle",
        semanticTokens = "diable",
    },
    on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>tp", function()
            client:exec_cmd({
                title = "pin",
                command = "tinymist.pinMain",
                arguments = { vim.api.nvim_buf_get_name(0) },
            }, { bufnr = bufnr })
        end, { desc = "tinymint pin", noremap = true })
        vim.keymap.set("n", "<leader>tu", function()
            client:exec_cmd({
                title = "unpin",
                command = "tinymist.pinMain",
                arguments = { vim.v.null },
            }, { bufnr = bufnr })
        end, { desc = "tinymist unpin", noremap = true })
    end,
}
