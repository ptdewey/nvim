(import-macros {: pack! : nmap : user-cmd!} :macros)

(pack! "https://codeberg.org/pdewey/deez-nvim" {:on_require :deez})

(nmap :<leader>af #((. (require :deez.altfile) :open)) {:desc "alternate file"})

(nmap :<leader>gbb #((. (require :deez.gitbrowse) :open))
      {:desc "browse current branch"})

(nmap :<leader>gbd #((. (require :deez.gitbrowse) :open) {:branch :default})
      {:desc "browse default branch"})

(user-cmd! :GitBrowse #((. (require :deez.gitbrowse) :open))
           {:desc "browse current branch"})
