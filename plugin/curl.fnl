(import-macros {: pack! : setup! : nmap} :macros)

(pack! ;;(vim.fn.expand :$HOME/projects/open-source/curl.nvim)
       "https://github.com/ptdewey/curl.nvim"
       {:version :main
        :cmd [:CurlRun :CurlCancel]
        :keys [:<leader>rs]
        :after (setup! :curl {})})

(nmap :<leader>rs :<cmd>CurlRun<CR> {:desc "run curl request"})
