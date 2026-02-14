(import-macros {: pack! : setup!} :macros)

(let [keywords {:DOC {:alt [:DOCS]}
                :REFACTOR {:color :warning}
                :CHANGE {:color :warning}
                :REVIEW {:color :hint}
                :DEBUG {:color :warning}}]
  (pack! "https://github.com/folke/todo-comments.nvim" :event
         [:BufReadPost :BufNewFile] :after
         (setup! :todo-comments {:signs false : keywords})))
