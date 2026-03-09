(import-macros {: nmap} :macros)

(macro lsp-action [pattern]
  `#(vim.lsp.buf.code_action {:filter #($1.title:match ,pattern) :apply true}))

{:settings {:harper-ls {:linters {:ToDoHyphen false
                                  :Dashes false
                                  :LongSentences false
                                  :SentenceCapitalization false
                                  :ExpandDependencies false
                                  :PunctuationClusters false
                                  :Spaces false}}}
 ;; TODO: this probably won't work for anything with multiple results returned
 :on_attach #(nmap :<C-s> (lsp-action "Replace with"))}
