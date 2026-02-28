(import-macros {: nmap : autocmd!} :macros)

(nmap :<leader>id "<Plug>(neorg.tempus.insert-date))" {:desc "insert date"})
(nmap :<leader>to "<cmd>Neorg toc<CR>" {:desc "neorg toc"})

;; Workaround for indentexpr issue in neorg `core.esupports.indent`
(autocmd! :InsertEnter
          {:pattern :*.norg
           :once true
           :callback #(when (not (vim.bo.indentexpr:find :neorg))
                        (vim.cmd "doautocmd BufEnter"))})

(set vim.opt_local.conceallevel 2)
