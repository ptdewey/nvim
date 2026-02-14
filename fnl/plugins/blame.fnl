(import-macros {: pack! : setup! : nmap} :macros)

(pack! "https://github.com/FabijanZulj/blame.nvim"
  :cmd :BlameToggle
  :after (setup! :blame))

(nmap :<leader>gbl "<cmd>BlameToggle virtual<CR>" {:desc "git blame"})
