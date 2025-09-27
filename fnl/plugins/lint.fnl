(import-macros {: autocmd! : pack! : require!} :macros)

(local ft {:go [:golangcilint]
           :sh [:shellcheck]
           :bash [:shellcheck]
           :lua [:selene]})

(pack! [{:src "https://github.com/mfussenegger/nvim-lint"
         :data {:event :BufWritePre
                :after (fn []
                         (let [lint (require! :lint)]
                           (set lint.linters_by_ft ft)
                           (autocmd! [:BufWritePost]
                                     {:callback (fn []
                                                  (lint.try_lint))})))}}])
