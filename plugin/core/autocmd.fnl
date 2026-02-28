(import-macros {: autocmd! : user-cmd! : o} :macros)

;; fix netrw keyboard navigation on split keyboard (that uses numpad '-')
(autocmd! :FileType
          {:pattern :netrw
           :callback (fn []
                       (vim.cmd "nnoremap <buffer> <kminus> <Plug>NetrwBrowseUpDir")
                       (vim.cmd "nnoremap <buffer> <kplus> <Plug>NetrwLocalBrowseCheck"))})

;; highlight on yank
(let [yank-hl (vim.api.nvim_create_augroup :YankHighlight {:clear true})]
  (autocmd! :TextYankPost {:callback #(vim.hl.on_yank)
                           :group yank-hl
                           :pattern "*"}))

;; TODO: could this be an ftplugin?
(autocmd! :TermOpen {:callback (fn []
                                 (o :number false)
                                 (o :relativenumber false)
                                 (o :spell false))})

(let [tw (vim.api.nvim_create_augroup :TrimTrailingWhitespace {:clear true})]
  (let [enable (fn []
                 (autocmd! :BufWritePre
                           {:group tw
                            :pattern "*"
                            :callback #(vim.cmd "silent! %s/\\s\\+$//e")})
                 (print "Trim trailing whitespace enabled"))
        disable (fn [] (vim.api.nvim_clear_autocmds {:group tw})
                  (print "Trim trailing whitespace disabled"))]
    (user-cmd! :EnableTrimWhitespace enable {})
    (user-cmd! :DisableTrimWhitespace disable {})))
