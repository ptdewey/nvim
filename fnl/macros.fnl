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

(lambda del-map! [mode key]
  `(vim.keymap.del ,mode ,key))

(lambda normal! [arg]
  `(vim.cmd (.. :normal! ,arg)))

(lambda o [key value]
  `(set (. vim.opt ,key) ,value))

(lambda g [key value]
  `(set (. vim.g ,key) ,value))

(lambda user-cmd! [name command opts]
  `(vim.api.nvim_create_user_command ,name ,command ,opts))

(lambda autocmd! [event opts]
  `(vim.api.nvim_create_autocmd ,event ,opts))

(fn load! []
  `(fn [p#]
     (let [spec# (or p#.spec.data {})]
       (set spec#.name p#.spec.name)
       ((. (require :lze) :load) spec#))))

(fn pack! [specs opts]
  `(vim.pack.add ,specs (or ,opts {:load ,(load!) :confirm false})))

;; REFACTOR: decide on func vs not func for this and setup (and come up with better function names)
(fn require! [mod]
  `((. (require :profiler) :require) ,mod))

(fn setup! [mod opts]
  ;; TODO: possibly change to not return the function, create separate 'after!' macro
  `(fn []
     ((. (require :profiler) :require_and_setup) ,mod ,opts)))

{: map
 : nmap
 : vmap
 : imap
 : tmap
 : del-map!
 : normal!
 : o
 : g
 : user-cmd!
 : pack!
 : autocmd!
 : load!
 : setup!
 : require!}
