(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://github.com/FabijanZulj/blame.nvim"
         :data {:cmd :BlameToggle :after (setup! :blame)}}])

(nmap :<leader>gbl "<cmd>BlameToggle virtual<CR>" {:desc "git blame"})
