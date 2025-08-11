(macro o [key value]
  `(set (. vim.opt ,key) ,value))

; (vim.cmd.colorscheme :darkearth)

(o :number true)
(o :rnu true)
(o :autoindent true)
(o :scrolloff 8)
