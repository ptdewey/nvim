;; fennel-ls: macro-file

(fn map [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(fn nmap [key action opts]
  `(vim.keymap.set :n ,key ,action ,opts))

(fn vmap [key action opts]
  `(vim.keymap.set :x ,key ,action ,opts))

(fn imap [key action opts]
  `(vim.keymap.set :i ,key ,action ,opts))

(fn tmap [key action opts]
  `(vim.keymap.set :t ,key ,action ,opts))

(lambda del [mode key]
  `(vim.keymap.del ,mode ,key))

(lambda normal! [arg]
  `(vim.cmd ,arg))

(lambda o [key value]
  `(set (. vim.opt ,key) ,value))

(lambda g [key value]
  `(set (. vim.g ,key) ,value))

(lambda cmd! [name command opts]
  `(vim.api.nvim_create_user_command ,name ,command ,opts))

(fn pack! [specs opts]
  `(vim.pack.add ,specs ,opts))

(lambda autocmd! [event opts]
  `(vim.api.nvim_create_autocmd ,event ,opts))

{: map
 : nmap
 : vmap
 : imap
 : tmap
 : del
 : normal!
 : o
 : g
 : cmd!
 : pack!
 : autocmd!}
