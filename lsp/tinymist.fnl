(import-macros {: nmap} :macros)

{:filetypes [:typst]
 :settings {:exportPdf :onSave
            :formatterMode :typstyle
            :semanticTokens :diable}
 :on_attach (fn [client bufnr]
              (nmap :<leader>tp
                    #(client:exec_cmd {:title :pin
                                       :command :tinymist.pinMain
                                       :arguments [(vim.api.nvim_buf_get_name 0)]}
                                      {: bufnr})
                    {:desc "tinymint pin" :noremap true})
              (nmap :<leader>tu
                    #(client:exec_cmd {:title :unpin
                                       :command :tinymist.pinMain
                                       :arguments [vim.v.null]}
                                      {: bufnr})
                    {:desc "tinymist unpin" :noremap true}))}
