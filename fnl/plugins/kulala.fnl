(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://github.com/mistweaverco/kulala.nvim"
         :data {:ft [:http :rest]
                :after (setup! :kulala {}
                         (nmap :<leader>rs #((. (require :kulala) :run))
                               {:desc "run request"}))}}])
