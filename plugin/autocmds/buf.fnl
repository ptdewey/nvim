(import-macros {: autocmd!} :macros)

(autocmd! :TermOpen
          {:callback (fn [] (set vim.opt_local.number false)
                       (set vim.opt_local.relativenumber false))})
