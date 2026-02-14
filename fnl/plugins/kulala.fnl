(import-macros {: pack! : setup! : nmap} :macros)

(pack! "https://github.com/mistweaverco/kulala.nvim"
  :ft [:http :rest]
  :after (setup! :kulala {}
           (nmap :<leader>rs #((. (require :kulala) :run))
                 {:desc "run request"})))
