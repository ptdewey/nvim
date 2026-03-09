(import-macros {: autocmd! : user-cmd!} :macros)

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
