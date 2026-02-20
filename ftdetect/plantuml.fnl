(import-macros {: autocmd!} :macros)

(vim.filetype.add {:extension {:puml :plantuml}})

(autocmd! :FileType
          {:pattern :plantuml
           :callback (fn [] (vim.bo.commentstring "' %s")
                       (vim.lsp.enable :plantuml-lsp))})
