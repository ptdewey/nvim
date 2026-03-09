(set vim.bo.tabstop 2)
(set vim.bo.shiftwidth 2)
(set vim.opt_local.scrolloff 5)

(macro matchadd [args]
  `(vim.api.nvim_call_function :matchadd ,args))

;; Concealing
(set vim.opt_local.conceallevel 2)
(matchadd [:Conceal "\\[\\[" 10 -1 {:conceal ""}])
(matchadd [:Conceal "\\]\\]" 10 -1 {:conceal ""}])
(matchadd [:Conceal "\\v^(\\s*)\\zs-\\ze " 10 -1 {:conceal "•"}])
(matchadd [:Conceal "\\v^(\\s*)\\zs\\*\\ze " 10 -1 {:conceal "•"}])

;; FIX: this one doesn't work yet
; (vim.api.nvim_call_function :matchadd ["@markup.link" "\\v\\[\\[.{-}\\]\\]"])

;; Level 1 replaces delims with spaces, 2 hides delims
(set vim.opt_local.conceallevel 1)

;; Hard wrap at 80 characters (seems to conflict w/obsidian.nvim)
; (vim.opt_local.textwidth 80)
; (vim.opt_local.formatoptions:append :tcq)
; (vim.opt_local.formatoptions:remove :l)
