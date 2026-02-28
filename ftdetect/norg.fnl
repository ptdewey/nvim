(vim.filetype.add {:extension {:norg :norg}})

(vim.api.nvim_create_autocmd :FileType
                             {:pattern :norg
                              :callback #(vim.lsp.enable :norg_lsp)})
