(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/windwp/nvim-autopairs"
         :data {:event :InsertEnter :after (setup! :nvim-autopairs)}}])
