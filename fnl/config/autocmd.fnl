(import-macros {: autocmd! : o} :macros)

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
(autocmd! :TermOpen
          {:callback (fn [] (o :number false) (o :relativenumber false))})

;; LSP Inlay Hints
; (vim.api.nvim_create_augroup :InlayHints {:clear true})
; (vim.cmd.highlight "default link LspInlayHint Comment")
; (autocmd! :LspAttach {:group :InlayHints
;                       :callback (fn [args]
;                                   (let [client (vim.lsp.get_client_by_id args.data.client_id)]
;                                     ;; TODO: figure out how to translate conditional to fennel
;                                     ))})
