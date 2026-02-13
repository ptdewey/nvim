(import-macros {: pack! : setup!} :macros)

(local keywords {:DOC {:alt [:DOCS]}
                 :REFACTOR {:color :warning}
                 :CHANGE {:color :warning}
                 :REVIEW {:color :hint}
                 :DEBUG {:color :warning}})

(pack! [{:src "https://github.com/folke/todo-comments.nvim"
         :data {:event [:BufReadPost :BufNewFile]
                :after (setup! :todo-comments {:signs false : keywords})}}])
