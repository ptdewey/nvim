(import-macros {: load! : user-cmd!} :macros)

;; TODO: Rename to "Pact" add some wrappers to the commonly used functions.
;; - Possibly move plugins to a "register" pattern where loader is only called after all plugins are registered.
;; - Register pattern would allow fairly easy mass updating of plugins?

(user-cmd! :PackUpdate (fn [args]
                         (if (> (length args.fargs) 0)
                             (vim.pack.update args.fargs)
                             (vim.pack.update)))
           {:nargs "*" :complete :packadd})

(user-cmd! :PackDel (fn [args]
                      (vim.pack.del args.fargs))
           {:nargs "+" :complete :packadd})

;; Load builtin undotree plugin
(vim.cmd.packadd :nvim.undotree)

{:opts {:load (load!) :confirm false}}
