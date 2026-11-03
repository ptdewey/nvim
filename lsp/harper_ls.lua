return {
    settings = {
        ["harper-ls"] = {
            linters = {
                ToDoHyphen = false,
                Dashes = false,
                LongSentences = false,
                SentenceCapitalization = false,
                ExpandDependencies = false,
                PunctuationClusters = false,
                Spaces = false,
            },
        },
    },
    -- TODO: this probably won't work for anything with multiple results returned
    on_attach = function()
        vim.keymap.set("n", "<C-s>", function()
            vim.lsp.buf.code_action({
                filter = function(action)
                    return action.title:match("Replace with")
                end,
                apply = true,
            })
        end)
    end,
}
