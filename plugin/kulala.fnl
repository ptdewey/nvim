(import-macros {: pack! : setup! : nmap : user-cmd!} :macros)

(fn select-kulala-env []
  (let [kulala-envs [:dev :stage :default]]
    (vim.ui.select kulala-envs {:prompt "Kulala env"}
                   (fn [env]
                     (when env
                       ((. (require :kulala) :set_selected_env) env)
                       (vim.notify (.. "Kulala env: " env)))))))

(pack! "https://github.com/mistweaverco/kulala.nvim"
       {:ft [:http :rest]
        :after (setup! :kulala {}
                       (nmap :<leader>rs #((. (require :kulala) :run))
                             {:desc "run request"})
                       (user-cmd! :KulalaEnv select-kulala-env
                                  {:desc "select Kulala environment"}))})
