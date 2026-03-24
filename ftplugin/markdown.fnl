(set vim.bo.tabstop 2)
(set vim.bo.shiftwidth 2)
(set vim.opt_local.scrolloff 5)

;; Concealing
(set vim.opt_local.conceallevel 2)
(vim.api.nvim_call_function :matchadd [:Conceal "\\[\\[" 10 -1 {:conceal ""}])
(vim.api.nvim_call_function :matchadd [:Conceal "\\]\\]" 10 -1 {:conceal ""}])

;; Hard wrap at 80 characters (seems to conflict w/obsidian.nvim)
; (vim.opt_local.textwidth 80)
; (vim.opt_local.formatoptions:append :tcq)
; (vim.opt_local.formatoptions:remove :l)
