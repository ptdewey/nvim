(import-macros {: pack! :raw-setup! setup! : nmap} :macros)

(pack! [{:src "https://github.com/mistweaverco/kulala.nvim"
         :data {:ft [:http :rest]
                :after (fn []
                         (setup! :kulala {})
                         (nmap :<leader>rs #((. (require :kulala) :run))
                               {:desc "run request"}))}}])
