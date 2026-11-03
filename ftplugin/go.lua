vim.bo.expandtab = false

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function()
        vim.keymap.set("i", "<C-f>", function()
            vim.lsp.buf.code_action({
                filter = function(action)
                    return action.title:match("Fill")
                end,
                apply = true,
            })
        end)
        vim.lsp.semantic_tokens.enable(false, {})
    end,
})
