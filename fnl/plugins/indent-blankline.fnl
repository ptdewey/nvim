(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/lukas-reineke/indent-blankline.nvim"
         :data {:event [:BufReadPost :BufNewFile]
                :after (setup! :ibl {:scope {:enabled false}})}}])
