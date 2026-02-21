(import-macros {: user-cmd!} :macros)

;; Disable default plugins
(let [disabled-plugins [:zipPlugin
                        :zip
                        :tarPlugin
                        :tar
                        :gzip
                        :tohtml
                        :man
                        :rplugin
                        :tutor_mode_plugin]]
  (each [_ k (ipairs disabled-plugins)]
    (set (. vim.g (.. :loaded_ k)) 1)))

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

;; Lazy load builtin undotree plugin
(user-cmd! :Undotree (fn []
                       (vim.api.nvim_del_user_command :Undotree)
                       (vim.cmd.packadd :nvim.undotree)
                       (vim.cmd :Undotree)) {})

;; Lazy load difftool plugin
(user-cmd! :DiffTool
           (fn [args]
             (vim.api.nvim_del_user_command :DiffTool)
             (vim.cmd.packadd :nvim.difftool)
             (vim.cmd (.. "DiffTool " args.args)))
           {:nargs "*" :complete :file})
