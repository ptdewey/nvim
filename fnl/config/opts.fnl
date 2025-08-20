(macro o [key value]
  `(set (. vim.opt ,key) ,value))

(o :number true)
(o :rnu true)
(o :autoindent true)
(o :scrolloff 8)
(o :winborder :rounded)
