(import-macros {: autocmd! : pack! : require!} :macros)

(local ft {:go [:golangcilint]
           :sh [:shellcheck]
           :bash [:shellcheck]
           :lua [:selene]})

(pack! "https://github.com/mfussenegger/nvim-lint"
  :event :BufWritePre
  :after #(let [lint (require! :lint)]
            (set lint.linters_by_ft ft)
            (autocmd! [:BufWritePost]
                      {:callback (fn []
                                   (lint.try_lint))})))
