(import-macros {: pack! : setup!} :macros)

(pack! (vim.fn.expand "file:///$HOME/projects/nt")
       {:cmd :Nt :after (setup! :nt {})})
